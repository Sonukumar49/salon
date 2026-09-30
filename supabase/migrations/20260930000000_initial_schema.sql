-- =============================================================================
-- STEP 2: Initial schema (tables, constraints, indexes, triggers, RLS)
-- Rebuild from scratch with:  supabase db reset   (local)  or  supabase db push (remote)
-- =============================================================================

create extension if not exists btree_gist;
-- needed for the no-double-booking constraint
create schema if not exists private;
-- internal helpers, NOT exposed through the API
grant usage on schema private to anon, authenticated, service_role;

-- -----------------------------------------------------------------------------
-- 1. ENUMS (fixed vocabularies; growing lists like hair types are tables instead)
-- -----------------------------------------------------------------------------
create type public.user_role           as enum ('CUSTOMER','BUSINESS_OWNER','STYLIST','ADMIN');

create type public.moderation_status   as enum ('PENDING','APPROVED','REJECTED');

create type public.appointment_status  as enum ('PENDING','CONFIRMED','CANCELLED','COMPLETED','NO_SHOW');

create type public.stylist_gender      as enum ('FEMALE','MALE','NON_BINARY');

create type public.client_gender       as enum ('FEMALE','MALE','UNISEX');

create type public.hair_texture        as enum ('FINE','MEDIUM','COARSE');

create type public.hair_length         as enum ('SHORT','MEDIUM','LONG','EXTRA_LONG');

create type public.hair_thickness      as enum ('THIN','MEDIUM','THICK');

create type public.hair_condition      as enum ('HEALTHY','DRY','DAMAGED','OILY');

create type public.chemical_treatment  as enum ('COLOR','BLEACH','KERATIN','SMOOTHENING','REBONDING','PERM','RELAXER','OTHER');

create type public.blocked_reason      as enum ('LEAVE','PERSONAL','CLOSURE','OTHER');

-- -----------------------------------------------------------------------------
-- 2. TABLES
-- -----------------------------------------------------------------------------

-- Discovery geography (locality/city pages, SEO, distance filtering)
create table public.locations (
    id uuid primary key default gen_random_uuid (),
    locality text not null,
    city text not null,
    state text not null,
    country text not null default 'India',
    latitude double precision not null check (latitude between -90 and 90),
    longitude double precision not null check (
        longitude between -180 and 180
    ),
    slug text not null unique,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (
        country,
        state,
        city,
        locality
    )
);

-- App profile; 1:1 with auth.users
create table public.users (
    id uuid primary key references auth.users (id) on delete cascade,
    role public.user_role not null default 'CUSTOMER',
    full_name text,
    email text,
    phone text,
    avatar_url text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.businesses (
    id uuid primary key default gen_random_uuid (),
    owner_id uuid not null references public.users (id) on delete restrict,
    name text not null check (length(trim(name)) > 0),
    slug text not null unique,
    description text,
    phone text,
    email text,
    website text,
    logo_url text,
    cover_image_url text,
    approval_status public.moderation_status not null default 'PENDING',
    -- denormalised, maintained by trigger from APPROVED reviews (fast sorting/filtering)
    rating_avg numeric(3, 2) not null default 0 check (rating_avg between 0 and 5),
    review_count integer not null default 0 check (review_count >= 0),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.business_locations (
    id uuid primary key default gen_random_uuid (),
    business_id uuid not null references public.businesses (id) on delete cascade,
    location_id uuid not null references public.locations (id) on delete restrict, -- locality/city/state
    name text, -- branch name, optional
    address_line text not null,
    postal_code text,
    landmark text,
    phone text,
    latitude double precision not null check (latitude between -90 and 90),
    longitude double precision not null check (
        longitude between -180 and 180
    ),
    is_primary boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (id, business_id) -- lets child tables prove "same business"
);

create unique index business_locations_one_primary on public.business_locations (business_id)
where
    is_primary;

-- Weekly opening hours per branch (0 = Sunday ... 6 = Saturday)
create table public.opening_hours (
    id uuid primary key default gen_random_uuid (),
    business_location_id uuid not null references public.business_locations (id) on delete cascade,
    day_of_week smallint not null check (day_of_week between 0 and 6),
    open_time time,
    close_time time,
    is_closed boolean not null default false,
    check (
        is_closed
        or (
            open_time is not null
            and close_time is not null
            and close_time > open_time
        )
    ),
    unique (
        business_location_id,
        day_of_week
    )
);

create table public.service_categories (
    id uuid primary key default gen_random_uuid (),
    name text not null unique,
    slug text not null unique,
    description text,
    sort_order integer not null default 0
);

create table public.hair_types (
    id uuid primary key default gen_random_uuid (),
    name text not null unique,
    slug text not null unique,
    description text
);

create table public.hair_concerns (
    id uuid primary key default gen_random_uuid (),
    name text not null unique,
    slug text not null unique,
    description text
);

create table public.hairstyles (
    id uuid primary key default gen_random_uuid (),
    name text not null unique,
    slug text not null unique,
    service_category_id uuid references public.service_categories (id) on delete set null,
    description text
);

create table public.stylists (
  id                   uuid primary key default gen_random_uuid(),
  business_id          uuid not null references public.businesses(id) on delete cascade,
  business_location_id uuid,
  user_id              uuid unique references public.users(id) on delete set null,  -- login account, optional
  name                 text not null,
  profile_image_url    text,
  bio                  text,
  experience_years     smallint check (experience_years between 0 and 60),
  languages            text[] not null default '{}',
  gender               public.stylist_gender,
  approval_status      public.moderation_status not null default 'PENDING',
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  unique (id, business_id),
  -- a stylist's branch must belong to the stylist's business
  foreign key (business_location_id, business_id)
    references public.business_locations (id, business_id) on delete set null (business_location_id)
);

-- Specialties = service categories the stylist is known for
create table public.stylist_specialties (
    stylist_id uuid not null references public.stylists (id) on delete cascade,
    service_category_id uuid not null references public.service_categories (id) on delete cascade,
    primary key (
        stylist_id,
        service_category_id
    )
);

-- Business-specific service catalogue with a price RANGE (final price can vary per stylist)
create table public.services (
    id uuid primary key default gen_random_uuid (),
    business_id uuid not null references public.businesses (id) on delete cascade,
    category_id uuid not null references public.service_categories (id) on delete restrict,
    name text not null,
    description text,
    price_min numeric(10, 2) not null check (price_min >= 0),
    price_max numeric(10, 2),
    duration_minutes integer not null check (
        duration_minutes between 5 and 720
    ),
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (
        price_max is null
        or price_max >= price_min
    ),
    unique (id, business_id),
    unique (business_id, name)
);

-- Which stylist performs which service, with optional price/duration override
create table public.stylist_services (
    stylist_id uuid not null,
    service_id uuid not null,
    business_id uuid not null,
    price numeric(10, 2) check (price >= 0),
    duration_minutes integer check (
        duration_minutes between 5 and 720
    ),
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    primary key (stylist_id, service_id),
    -- both sides must belong to the SAME business
    foreign key (stylist_id, business_id) references public.stylists (id, business_id) on delete cascade,
    foreign key (service_id, business_id) references public.services (id, business_id) on delete cascade
);

-- Customer hair profile (1 per user) + relational children
create table public.hair_profiles (
    id uuid primary key default gen_random_uuid (),
    user_id uuid not null unique references public.users (id) on delete cascade,
    hair_type_id uuid references public.hair_types (id) on delete set null,
    texture public.hair_texture,
    length public.hair_length,
    thickness public.hair_thickness,
    condition public.hair_condition,
    notes text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.hair_profile_concerns (
    hair_profile_id uuid not null references public.hair_profiles (id) on delete cascade,
    hair_concern_id uuid not null references public.hair_concerns (id) on delete cascade,
    primary key (
        hair_profile_id,
        hair_concern_id
    )
);

create table public.hair_profile_hairstyles ( -- preferred hairstyles
    hair_profile_id uuid not null references public.hair_profiles (id) on delete cascade,
    hairstyle_id uuid not null references public.hairstyles (id) on delete cascade,
    primary key (hair_profile_id, hairstyle_id)
);

create table public.hair_profile_treatments ( -- chemical treatment history
    id uuid primary key default gen_random_uuid (),
    hair_profile_id uuid not null references public.hair_profiles (id) on delete cascade,
    treatment public.chemical_treatment not null,
    treated_on date,
    notes text,
    created_at timestamptz not null default now()
);

-- Structured portfolio: every filter dimension is a real column
create table public.portfolio_items (
    id uuid primary key default gen_random_uuid (),
    business_id uuid not null,
    stylist_id uuid not null,
    service_id uuid not null,
    hairstyle_id uuid references public.hairstyles (id) on delete set null,
    hair_type_id uuid references public.hair_types (id) on delete set null,
    hair_length public.hair_length,
    hair_thickness public.hair_thickness,
    client_gender public.client_gender,
    price numeric(10, 2) check (price >= 0),
    title text,
    description text,
    image_url text not null,
    before_image_url text,
    after_image_url text,
    moderation_status public.moderation_status not null default 'PENDING',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    foreign key (stylist_id, business_id) references public.stylists (id, business_id) on delete cascade,
    foreign key (service_id, business_id) references public.services (id, business_id) on delete cascade
);

-- Recurring weekly windows (0 = Sunday). Several windows per day allowed (e.g. lunch break).
create table public.availability (
    id uuid primary key default gen_random_uuid (),
    stylist_id uuid not null references public.stylists (id) on delete cascade,
    day_of_week smallint not null check (day_of_week between 0 and 6),
    start_time time not null,
    end_time time not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (end_time > start_time),
    unique (
        stylist_id,
        day_of_week,
        start_time
    )
);

-- Leave / personal time / closures
create table public.blocked_slots (
    id uuid primary key default gen_random_uuid (),
    stylist_id uuid not null references public.stylists (id) on delete cascade,
    starts_at timestamptz not null,
    ends_at timestamptz not null,
    reason public.blocked_reason not null default 'OTHER',
    note text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (ends_at > starts_at)
);

create table public.appointments (
    id uuid primary key default gen_random_uuid (),
    customer_id uuid not null references public.users (id) on delete cascade,
    business_id uuid not null references public.businesses (id) on delete restrict,
    location_id uuid not null,
    stylist_id uuid not null,
    service_id uuid not null,
    appointment_date date not null,
    start_time time not null,
    end_time time not null,
    price numeric(10, 2) not null check (price >= 0),
    customer_name text not null,
    customer_phone text,
    notes text,
    status public.appointment_status not null default 'PENDING',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (end_time > start_time),
    unique (
        id,
        customer_id,
        business_id,
        stylist_id,
        service_id
    ), -- target for reviews
    foreign key (location_id, business_id) references public.business_locations (id, business_id),
    foreign key (stylist_id, business_id) references public.stylists (id, business_id),
    foreign key (service_id, business_id) references public.services (id, business_id),
    -- the stylist must actually offer this service
    foreign key (stylist_id, service_id) references public.stylist_services (stylist_id, service_id),
    -- a stylist cannot have two live appointments that overlap in time
    exclude using gist (
        stylist_id
        with
            =,
            tsrange (
                appointment_date + start_time,
                appointment_date + end_time
            )
        with
            &&
    )
    where (
            status in (
                'PENDING',
                'CONFIRMED',
                'COMPLETED'
            )
        )
);

create table public.reviews (
  id                uuid primary key default gen_random_uuid(),
  customer_id       uuid not null,
  business_id       uuid not null,
  stylist_id        uuid not null,
  service_id        uuid not null,
  appointment_id    uuid not null unique,            -- one review per appointment
  rating            smallint not null check (rating between 1 and 5),
  body              text,
  photo_urls        text[] not null default '{}',
  moderation_status public.moderation_status not null default 'PENDING',
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  -- review must match its appointment's customer / business / stylist / service exactly
  foreign key (appointment_id, customer_id, business_id, stylist_id, service_id)
    references public.appointments (id, customer_id, business_id, stylist_id, service_id) on delete cascade
);

create table public.favorites (
  id          uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.users(id) on delete cascade,
  business_id uuid references public.businesses(id) on delete cascade,
  stylist_id  uuid references public.stylists(id)   on delete cascade,
  created_at  timestamptz not null default now(),
  check ((business_id is not null)::int + (stylist_id is not null)::int = 1)  -- exactly one target
);

create unique index favorites_customer_business_uq on public.favorites (customer_id, business_id)
where
    business_id is not null;

create unique index favorites_customer_stylist_uq on public.favorites (customer_id, stylist_id)
where
    stylist_id is not null;

-- -----------------------------------------------------------------------------
-- 3. INDEXES (only what discovery/search/booking will actually use)
-- -----------------------------------------------------------------------------
create index locations_city_idx on public.locations (city, locality);

create index businesses_owner_idx on public.businesses (owner_id);

create index businesses_approved_rating_idx on public.businesses (rating_avg desc)
where
    approval_status = 'APPROVED';

create index business_locations_business_idx on public.business_locations (business_id);

create index business_locations_location_idx on public.business_locations (location_id);

create index business_locations_geo_idx on public.business_locations (latitude, longitude);

create index stylists_business_idx on public.stylists (business_id);

create index stylists_location_idx on public.stylists (business_location_id);

create index stylist_specialties_cat_idx on public.stylist_specialties (service_category_id);

create index services_business_idx on public.services (business_id);

create index services_category_idx on public.services (category_id);

create index stylist_services_service_idx on public.stylist_services (service_id);

create index stylist_services_business_idx on public.stylist_services (business_id);

create index hairstyles_category_idx on public.hairstyles (service_category_id);

create index portfolio_business_idx on public.portfolio_items (business_id);

create index portfolio_stylist_idx on public.portfolio_items (stylist_id);

create index portfolio_service_idx on public.portfolio_items (service_id);

create index portfolio_hairstyle_idx on public.portfolio_items (hairstyle_id);

create index portfolio_hair_type_idx on public.portfolio_items (hair_type_id);

create index portfolio_approved_idx on public.portfolio_items (created_at desc)
where
    moderation_status = 'APPROVED';

create index blocked_slots_stylist_idx on public.blocked_slots (stylist_id, starts_at);

create index appointments_customer_idx on public.appointments (customer_id);

create index appointments_business_idx on public.appointments (business_id);

create index appointments_stylist_date_idx on public.appointments (stylist_id, appointment_date);

create index appointments_service_idx on public.appointments (service_id);

create index appointments_date_idx on public.appointments (appointment_date);

create index appointments_status_idx on public.appointments (status);

create index reviews_business_idx on public.reviews (business_id)
where
    moderation_status = 'APPROVED';

create index reviews_stylist_idx on public.reviews (stylist_id);

create index reviews_service_idx on public.reviews (service_id);

create index reviews_customer_idx on public.reviews (customer_id);

create index favorites_business_idx on public.favorites (business_id);

create index favorites_stylist_idx on public.favorites (stylist_id);

-- -----------------------------------------------------------------------------
-- 4. HELPER FUNCTIONS + TRIGGERS
-- -----------------------------------------------------------------------------

-- 4a. updated_at
create function private.set_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin new.updated_at = now(); return new; end $$;

do $$
declare t text;
begin
  foreach t in array array['locations','users','businesses','business_locations','stylists','services',
    'stylist_services','hair_profiles','portfolio_items','availability','blocked_slots','appointments','reviews']
  loop
    execute format('create trigger set_updated_at before update on public.%I
                    for each row execute function private.set_updated_at()', t);
  end loop;
end $$;

-- 4b. Role helpers used by RLS (security definer avoids recursive policy checks)
create function private.is_admin() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.users where id = (select auth.uid()) and role = 'ADMIN')
$$;

create function private.current_user_role() returns public.user_role
language sql stable security definer set search_path = '' as $$
  select role from public.users where id = (select auth.uid())
$$;

create function private.owns_business(bid uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.businesses where id = bid and owner_id = (select auth.uid()))
$$;

create function private.owns_location(lid uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.business_locations bl
                 join public.businesses b on b.id = bl.business_id
                 where bl.id = lid and b.owner_id = (select auth.uid()))
$$;

create function private.is_own_stylist(sid uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.stylists where id = sid and user_id = (select auth.uid()))
$$;

-- owner of the stylist's business OR the stylist themself
create function private.can_manage_stylist(sid uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select private.is_own_stylist(sid) or exists (
    select 1 from public.stylists s join public.businesses b on b.id = s.business_id
    where s.id = sid and b.owner_id = (select auth.uid()))
$$;

-- 4c. Protect sensitive columns from non-admin API users (RLS can't restrict columns).
--     Only applies to API roles; migrations, seed, service_role and internal triggers are unaffected.
create function private.guard_protected_columns() returns trigger
language plpgsql set search_path = '' as $$
declare col text;
begin
  if current_user not in ('authenticated','anon') or private.is_admin() then return new; end if;
  foreach col in array tg_argv loop
    if to_jsonb(new) -> col is distinct from to_jsonb(old) -> col then
      raise exception 'Column "%" can only be changed by an admin', col using errcode = '42501';
    end if;
  end loop;
  return new;
end $$;

create trigger guard_protected before update on public.users
  for each row execute function private.guard_protected_columns('email');

create trigger guard_protected before update on public.businesses
  for each row execute function private.guard_protected_columns('approval_status','owner_id','rating_avg','review_count');

create trigger guard_protected before update on public.stylists
  for each row execute function private.guard_protected_columns('approval_status','user_id','business_id');

create trigger guard_protected before update on public.portfolio_items
  for each row execute function private.guard_protected_columns('moderation_status');

create trigger guard_protected before update on public.reviews
  for each row execute function private.guard_protected_columns(
    'moderation_status','customer_id','business_id','stylist_id','service_id','appointment_id');

create trigger guard_protected before update on public.appointments
  for each row execute function private.guard_protected_columns(
    'customer_id','business_id','location_id','stylist_id','service_id','price');

-- Users may self-select CUSTOMER or BUSINESS_OWNER; STYLIST/ADMIN are granted by an admin.
create function private.guard_user_role() returns trigger
language plpgsql set search_path = '' as $$
begin
  if current_user in ('authenticated','anon') and not private.is_admin()
     and new.role is distinct from old.role and new.role not in ('CUSTOMER','BUSINESS_OWNER') then
    raise exception 'Only an admin can assign role %', new.role using errcode = '42501';
  end if;
  return new;
end $$;

create trigger guard_role before update of role on public.users
  for each row execute function private.guard_user_role();

-- 4d. Create the app profile automatically on signup. Role is ALWAYS CUSTOMER here.
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.users (id, email, full_name, phone)
  values (new.id, new.email, new.raw_user_meta_data ->> 'full_name', new.phone)
  on conflict (id) do nothing;
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- 4e. Appointments: server decides price/end time for API callers; enforce status flow.
create function private.prepare_appointment() returns trigger
language plpgsql set search_path = '' as $$
declare v_price numeric; v_dur integer;
begin
  select coalesce(ss.price, s.price_min), coalesce(ss.duration_minutes, s.duration_minutes)
    into v_price, v_dur
    from public.stylist_services ss
    join public.services s on s.id = ss.service_id
   where ss.stylist_id = new.stylist_id and ss.service_id = new.service_id and ss.is_active and s.is_active;

  if current_user in ('authenticated','anon') and not private.is_admin() then
    if v_price is null then raise exception 'This stylist does not currently offer this service'; end if;
    new.price := v_price;
  end if;
  if new.end_time is null and v_dur is not null then
    new.end_time := new.start_time + make_interval(mins => v_dur);
  end if;
  return new;
end $$;

create trigger prepare_appointment before insert on public.appointments
  for each row execute function private.prepare_appointment();

create function private.check_appointment_transition() returns trigger
language plpgsql set search_path = '' as $$
begin
  if old.status = new.status then return new; end if;
  if not ((old.status = 'PENDING'   and new.status in ('CONFIRMED','CANCELLED'))
       or (old.status = 'CONFIRMED' and new.status in ('COMPLETED','CANCELLED','NO_SHOW'))) then
    raise exception 'Invalid appointment status change: % -> %', old.status, new.status;
  end if;
  return new;
end $$;

create trigger check_transition before update of status on public.appointments
  for each row execute function private.check_appointment_transition();

-- 4f. Reviews: only for COMPLETED appointments; keep business rating in sync
create function private.check_review_allowed() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if not exists (select 1 from public.appointments where id = new.appointment_id and status = 'COMPLETED') then
    raise exception 'Reviews can only be created for completed appointments';
  end if;
  return new;
end $$;

create trigger check_review_allowed before insert on public.reviews
  for each row execute function private.check_review_allowed();

create function private.refresh_business_rating() returns trigger
language plpgsql security definer set search_path = '' as $$
declare bid uuid := coalesce(new.business_id, old.business_id);
begin
  update public.businesses b set
    rating_avg   = coalesce((select round(avg(rating)::numeric, 2) from public.reviews
                             where business_id = bid and moderation_status = 'APPROVED'), 0),
    review_count = (select count(*) from public.reviews
                    where business_id = bid and moderation_status = 'APPROVED')
  where b.id = bid;
  return null;
end $$;

create trigger refresh_rating after insert or update of rating, moderation_status or delete on public.reviews
  for each row execute function private.refresh_business_rating();

-- -----------------------------------------------------------------------------
-- 5. ROW LEVEL SECURITY
-- -----------------------------------------------------------------------------
-- Every table: RLS on + full admin access. Specific policies follow.
do $$
declare t text;
begin
  foreach t in array array['locations','users','businesses','business_locations','opening_hours',
    'service_categories','hair_types','hair_concerns','hairstyles','stylists','stylist_specialties','services',
    'stylist_services','hair_profiles','hair_profile_concerns','hair_profile_hairstyles','hair_profile_treatments',
    'portfolio_items','availability','blocked_slots','appointments','reviews','favorites']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy "Admin full access" on public.%I for all to authenticated
                    using (private.is_admin()) with check (private.is_admin())', t);
  end loop;
  -- Reference data is public-read (writes: admin only)
  foreach t in array array['locations','service_categories','hair_types','hair_concerns','hairstyles']
  loop
    execute format('create policy "Public read" on public.%I for select using (true)', t);
  end loop;
end $$;

-- USERS: read/update own row (role limited by guard trigger)
create policy "Read own profile" on public.users for
select to authenticated using (
        id = (
            select auth.uid ()
        )
    );

create policy "Update own profile" on public.users for
update to authenticated using (
    id = (
        select auth.uid ()
    )
)
with
    check (
        id = (
            select auth.uid ()
        )
    );

-- BUSINESSES: approved are public; owners see/edit their own
create policy "Public read approved" on public.businesses for
select using (
        approval_status = 'APPROVED'
        or owner_id = (
            select auth.uid ()
        )
    );

create policy "Owner creates pending business" on public.businesses for
insert
    to authenticated
with
    check (
        owner_id = (
            select auth.uid ()
        )
        and approval_status = 'PENDING'
        and rating_avg = 0
        and review_count = 0
        and private.current_user_role () = 'BUSINESS_OWNER'
    );

create policy "Owner updates own business" on public.businesses for
update to authenticated using (
    owner_id = (
        select auth.uid ()
    )
)
with
    check (
        owner_id = (
            select auth.uid ()
        )
    );

-- BUSINESS LOCATIONS / OPENING HOURS: visible when the business is visible; owner manages
create policy "Public read" on public.business_locations for
select using (
        exists (
            select 1
            from public.businesses b
            where
                b.id = business_id
        )
    );

create policy "Owner manages locations" on public.business_locations for all to authenticated using (
    private.owns_business (business_id)
)
with
    check (
        private.owns_business (business_id)
    );

create policy "Public read" on public.opening_hours for
select using (
        exists (
            select 1
            from public.business_locations bl
            where
                bl.id = business_location_id
        )
    );

create policy "Owner manages hours" on public.opening_hours for all to authenticated using (
    private.owns_location (business_location_id)
)
with
    check (
        private.owns_location (business_location_id)
    );

-- SERVICES: active ones public; owner manages
create policy "Public read active" on public.services for
select using (
        is_active
        and exists (
            select 1
            from public.businesses b
            where
                b.id = business_id
        )
    );

create policy "Owner manages services" on public.services for all to authenticated using (
    private.owns_business (business_id)
)
with
    check (
        private.owns_business (business_id)
    );

-- STYLISTS: approved public; owner manages (new = PENDING); stylist edits self
create policy "Public read approved" on public.stylists for
select using (
        (
            approval_status = 'APPROVED'
            and exists (
                select 1
                from public.businesses b
                where
                    b.id = business_id
            )
        )
        or user_id = (
            select auth.uid ()
        )
        or private.owns_business (business_id)
    );

create policy "Owner adds pending stylist" on public.stylists for
insert
    to authenticated
with
    check (
        private.owns_business (business_id)
        and approval_status = 'PENDING'
    );

create policy "Owner updates stylist" on public.stylists for
update to authenticated using (
    private.owns_business (business_id)
)
with
    check (
        private.owns_business (business_id)
    );

create policy "Owner deletes stylist" on public.stylists for delete to authenticated using (
    private.owns_business (business_id)
);

create policy "Stylist updates self" on public.stylists for
update to authenticated using (
    user_id = (
        select auth.uid ()
    )
)
with
    check (
        user_id = (
            select auth.uid ()
        )
    );

create policy "Public read" on public.stylist_specialties for
select using (
        exists (
            select 1
            from public.stylists s
            where
                s.id = stylist_id
        )
    );

create policy "Owner or stylist manages" on public.stylist_specialties for all to authenticated using (
    private.can_manage_stylist (stylist_id)
)
with
    check (
        private.can_manage_stylist (stylist_id)
    );

create policy "Public read active" on public.stylist_services for
select using (
        is_active
        and exists (
            select 1
            from public.stylists s
            where
                s.id = stylist_id
        )
    );

create policy "Owner manages stylist services" on public.stylist_services for all to authenticated using (
    private.owns_business (business_id)
)
with
    check (
        private.owns_business (business_id)
    );

-- AVAILABILITY (public read for booking UI) / BLOCKED SLOTS (private)
create policy "Public read" on public.availability for
select using (
        exists (
            select 1
            from public.stylists s
            where
                s.id = stylist_id
        )
    );

create policy "Owner or stylist manages" on public.availability for all to authenticated using (
    private.can_manage_stylist (stylist_id)
)
with
    check (
        private.can_manage_stylist (stylist_id)
    );

create policy "Owner or stylist manages" on public.blocked_slots for all to authenticated using (
    private.can_manage_stylist (stylist_id)
)
with
    check (
        private.can_manage_stylist (stylist_id)
    );

-- PORTFOLIO: approved public; owner/stylist manage (new = PENDING, moderation by admin)
create policy "Public read approved" on public.portfolio_items for
select using (
        (
            moderation_status = 'APPROVED'
            and exists (
                select 1
                from public.businesses b
                where
                    b.id = business_id
            )
        )
        or private.owns_business (business_id)
        or private.is_own_stylist (stylist_id)
    );

create policy "Owner or stylist adds pending" on public.portfolio_items for
insert
    to authenticated
with
    check (
        (
            private.owns_business (business_id)
            or private.is_own_stylist (stylist_id)
        )
        and moderation_status = 'PENDING'
    );

create policy "Owner or stylist updates" on public.portfolio_items for
update to authenticated using (
    private.owns_business (business_id)
    or private.is_own_stylist (stylist_id)
)
with
    check (
        private.owns_business (business_id)
        or private.is_own_stylist (stylist_id)
    );

create policy "Owner or stylist deletes" on public.portfolio_items for delete to authenticated using (
    private.owns_business (business_id)
    or private.is_own_stylist (stylist_id)
);

-- APPOINTMENTS: customer / business owner / stylist see theirs
create policy "Participants read" on public.appointments for
select to authenticated using (
        customer_id = (
            select auth.uid ()
        )
        or private.owns_business (business_id)
        or private.is_own_stylist (stylist_id)
    );

create policy "Customer books pending" on public.appointments for
insert
    to authenticated
with
    check (
        customer_id = (
            select auth.uid ()
        )
        and status = 'PENDING'
    );

create policy "Customer cancels own" on public.appointments for
update to authenticated using (
    customer_id = (
        select auth.uid ()
    )
    and status in ('PENDING', 'CONFIRMED')
)
with
    check (
        customer_id = (
            select auth.uid ()
        )
        and status = 'CANCELLED'
    );

create policy "Business or stylist manages" on public.appointments for
update to authenticated using (
    private.owns_business (business_id)
    or private.is_own_stylist (stylist_id)
)
with
    check (
        private.owns_business (business_id)
        or private.is_own_stylist (stylist_id)
    );

-- REVIEWS: approved public; customer writes own (must be PENDING at creation)
create policy "Public read approved" on public.reviews for
select using (
        (
            moderation_status = 'APPROVED'
            and exists (
                select 1
                from public.businesses b
                where
                    b.id = business_id
            )
        )
        or customer_id = (
            select auth.uid ()
        )
        or private.owns_business (business_id)
    );

create policy "Customer writes own pending" on public.reviews for
insert
    to authenticated
with
    check (
        customer_id = (
            select auth.uid ()
        )
        and moderation_status = 'PENDING'
    );

create policy "Customer edits own" on public.reviews for
update to authenticated using (
    customer_id = (
        select auth.uid ()
    )
)
with
    check (
        customer_id = (
            select auth.uid ()
        )
    );

create policy "Customer deletes own" on public.reviews for delete to authenticated using (
    customer_id = (
        select auth.uid ()
    )
);

-- FAVORITES / HAIR PROFILE: strictly own data
create policy "Own favorites" on public.favorites for all to authenticated using (
    customer_id = (
        select auth.uid ()
    )
)
with
    check (
        customer_id = (
            select auth.uid ()
        )
    );

create policy "Own hair profile" on public.hair_profiles for all to authenticated using (
    user_id = (
        select auth.uid ()
    )
)
with
    check (
        user_id = (
            select auth.uid ()
        )
    );

do $$
declare t text;
begin
  foreach t in array array['hair_profile_concerns','hair_profile_hairstyles','hair_profile_treatments']
  loop
    execute format('create policy "Own hair profile data" on public.%I for all to authenticated
      using (exists (select 1 from public.hair_profiles hp where hp.id = hair_profile_id and hp.user_id = (select auth.uid())))
      with check (exists (select 1 from public.hair_profiles hp where hp.id = hair_profile_id and hp.user_id = (select auth.uid())))', t);
  end loop;
end $$;