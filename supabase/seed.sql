-- =============================================================================
-- SEED DATA: Bengaluru salons. Deterministic and idempotent-safe on a fresh DB.
-- Seed accounts have NO password (data only). To test roles, sign up in the app,
-- then promote yourself, e.g.:  update public.users set role='ADMIN' where email='you@example.com';
-- =============================================================================

create or replace function pg_temp.uid(k text) returns uuid language sql immutable as $$ select md5(k)::uuid $$;

create or replace function pg_temp.h(k text)   returns int  language sql immutable as $$ select abs(hashtext(k)) $$;

-- ---------- Reference data ----------------------------------------------------
create temp
table seed_loc (
    locality text,
    lat float8,
    lng float8,
    pin text
);

insert into
    seed_loc
values (
        'Indiranagar',
        12.9784,
        77.6408,
        '560038'
    ),
    (
        'Koramangala',
        12.9352,
        77.6245,
        '560034'
    ),
    (
        'HSR Layout',
        12.9116,
        77.6474,
        '560102'
    ),
    (
        'Jayanagar',
        12.9250,
        77.5938,
        '560011'
    ),
    (
        'Whitefield',
        12.9698,
        77.7500,
        '560066'
    ),
    (
        'JP Nagar',
        12.9063,
        77.5857,
        '560078'
    ),
    (
        'Malleshwaram',
        13.0035,
        77.5647,
        '560003'
    ),
    (
        'Bellandur',
        12.9304,
        77.6784,
        '560103'
    ),
    (
        'MG Road',
        12.9756,
        77.6068,
        '560001'
    ),
    (
        'Sadashivanagar',
        13.0068,
        77.5813,
        '560080'
    ),
    (
        'BTM Layout',
        12.9166,
        77.6101,
        '560076'
    ),
    (
        'Basavanagudi',
        12.9422,
        77.5738,
        '560004'
    ),
    (
        'Marathahalli',
        12.9569,
        77.7011,
        '560037'
    ),
    (
        'Electronic City',
        12.8452,
        77.6602,
        '560100'
    ),
    (
        'Frazer Town',
        12.9985,
        77.6136,
        '560005'
    );

insert into
    public.locations (
        locality,
        city,
        state,
        country,
        latitude,
        longitude,
        slug
    )
select locality, 'Bengaluru', 'Karnataka', 'India', lat, lng, lower(
        regexp_replace(
            locality, '[^A-Za-z0-9]+', '-', 'g'
        )
    ) || '-bengaluru'
from seed_loc;

insert into
    public.service_categories (name, slug, sort_order)
values ('Haircut', 'haircut', 1),
    (
        'Hair Colouring',
        'coloring',
        2
    ),
    (
        'Smoothening & Texture',
        'straightening',
        3
    ),
    (
        'Styling & Blowout',
        'styling',
        4
    ),
    ('Bridal & Party', 'bridal', 5),
    ('Men''s Grooming', 'mens', 6),
    (
        'Hair Treatments',
        'treatments',
        7
    );

insert into
    public.hair_types (name, slug, description)
values (
        'Straight',
        'straight',
        'No natural curl pattern'
    ),
    (
        'Wavy',
        'wavy',
        'Loose S-shaped waves'
    ),
    (
        'Curly',
        'curly',
        'Defined spirals or ringlets'
    ),
    (
        'Coily',
        'coily',
        'Tight coils and zig-zag patterns'
    );

insert into
    public.hair_concerns (name, slug)
values ('Dryness', 'dryness'),
    ('Frizz', 'frizz'),
    ('Damage', 'damage'),
    ('Hair Fall', 'hair-fall'),
    ('Split Ends', 'split-ends'),
    ('Dandruff', 'dandruff'),
    ('Thinning', 'thinning'),
    ('Oily Scalp', 'oily-scalp'),
    ('Colour Fade', 'colour-fade'),
    (
        'Lack of Volume',
        'lack-of-volume'
    );

insert into
    public.hairstyles (
        name,
        slug,
        service_category_id
    )
select v.name, lower(
        regexp_replace(
            v.name, '[^A-Za-z0-9]+', '-', 'g'
        )
    ), c.id
from (
        values ('Bob', 'haircut'), ('Long Layers', 'haircut'), ('Pixie Cut', 'haircut'), ('Blunt Cut', 'haircut'), ('Shag Cut', 'haircut'), ('Butterfly Cut', 'haircut'), ('Balayage', 'coloring'), ('Ombre', 'coloring'), ('Highlights', 'coloring'), ('Global Colour', 'coloring'), ('Pastel Colour', 'coloring'), (
                'Keratin Smooth', 'straightening'
            ), (
                'Rebonded Straight', 'straightening'
            ), (
                'Digital Perm', 'straightening'
            ), ('Beach Waves', 'styling'), ('Curtain Bangs', 'styling'), ('Bouncy Blowout', 'styling'), ('Bridal Bun', 'bridal'), ('Bridal Braid', 'bridal'), ('Fade', 'mens'), ('Undercut', 'mens'), ('Buzz Cut', 'mens'), ('Textured Crop', 'mens')
    ) v (name, cat)
    join public.service_categories c on c.slug = v.cat;

-- ---------- Accounts (auth.users -> trigger creates public.users) -------------
create temp table seed_first (i int, name text);

insert into seed_first select row_number() over (), n from unnest(array[
 'Ananya','Priya','Meera','Divya','Kavya','Sneha','Ishita','Pooja','Lakshmi','Nisha','Aarti','Deepika','Shruti','Tanvi','Rhea',
 'Rahul','Arjun','Vikram','Sanjay','Imran','Karthik','Rohan','Manoj','Faisal','Suresh']) n;
-- 1-15 female, 16-25 male
create temp table seed_last (i int, name text);

insert into seed_last select row_number() over (), n from unnest(array[
 'Sharma','Reddy','Nair','Iyer','Gowda','Kapoor','Khan','Menon','Patel','Rao','Das','Shetty']) n;

create temp table seed_people ( kind text, n int, full_name text );

insert into
    seed_people
select k, g, (
        select name
        from seed_first
        where
            i = 1 + (g * 7 + off) % 25
    ) || ' ' || (
        select name
        from seed_last
        where
            i = 1 + (g * 5 + off) % 12
    )
from (
        values ('admin', 0), ('owner', 3), ('stylist', 0), ('customer', 11)
    ) t (k, off)
    cross join lateral generate_series (
        case
            when k = 'admin' then 1
            else 1
        end, case k
            when 'admin' then 1
            when 'owner' then 20
            when 'stylist' then 50
            else 60
        end
    ) g;

insert into
    auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        email_confirmed_at,
        raw_app_meta_data,
        raw_user_meta_data,
        confirmation_token,
        recovery_token,
        email_change_token_new,
        email_change
    )
select
    '00000000-0000-0000-0000-000000000000',
    pg_temp.uid ('user-' || kind || '-' || n),
    'authenticated',
    'authenticated',
    kind || n || '@seed.salonly.test',
    now(),
    '{"provider":"email","providers":["email"]}',
    jsonb_build_object ('full_name', full_name),
    '',
    '',
    '',
    ''
from seed_people;

update public.users u set
  role  = case split_part(u.email,'@',1) when 'admin1' then 'ADMIN'::public.user_role
            else case when u.email like 'owner%'   then 'BUSINESS_OWNER'::public.user_role
                      when u.email like 'stylist%' then 'STYLIST'::public.user_role
                      else 'CUSTOMER'::public.user_role end end,
  phone = '+91 9' || lpad((pg_temp.h(u.email) % 1000000000)::text, 9, '0')
where u.email like '%@seed.salonly.test';

-- ---------- Businesses (20) + locations (25) + opening hours ------------------
create temp
table seed_biz (
    n int,
    name text,
    locality text,
    tier numeric,
    blurb text
);

insert into
    seed_biz
values (
        1,
        'The Hair Atelier',
        'Indiranagar',
        1.4,
        'Premium cuts and colour by senior stylists'
    ),
    (
        2,
        'Glow & Grace Salon',
        'Koramangala',
        1.2,
        'Full-service salon for hair, skin and grooming'
    ),
    (
        3,
        'Studio Nine',
        'HSR Layout',
        1.1,
        'Modern unisex studio with a relaxed vibe'
    ),
    (
        4,
        'Mane Society',
        'Jayanagar',
        1.0,
        'Neighbourhood favourite for precision cuts'
    ),
    (
        5,
        'Velvet Cuts',
        'Whitefield',
        1.1,
        'Trend-led styling for the tech corridor'
    ),
    (
        6,
        'Tress & Co.',
        'JP Nagar',
        0.9,
        'Honest pricing and consistent results'
    ),
    (
        7,
        'Bloom Beauty Lounge',
        'Malleshwaram',
        1.0,
        'Classic and contemporary hair services'
    ),
    (
        8,
        'Urban Shears',
        'Bellandur',
        1.2,
        'Fast, stylish cuts near the ORR'
    ),
    (
        9,
        'The Gentlemen''s Parlour',
        'MG Road',
        1.3,
        'Barbering and grooming for men'
    ),
    (
        10,
        'Crown & Comb',
        'Sadashivanagar',
        1.6,
        'Luxury hair studio and treatments'
    ),
    (
        11,
        'Silk Strands',
        'BTM Layout',
        0.8,
        'Budget-friendly cuts, spa and smoothening'
    ),
    (
        12,
        'Luxe Locks Studio',
        'Indiranagar',
        1.5,
        'Colour specialists and premium care'
    ),
    (
        13,
        'Curl Culture',
        'Koramangala',
        1.1,
        'Specialists in wavy, curly and coily hair'
    ),
    (
        14,
        'Kaveri Hair Studio',
        'Basavanagudi',
        0.8,
        'Traditional care with modern technique'
    ),
    (
        15,
        'Halo Hair Lounge',
        'Marathahalli',
        0.9,
        'Comfortable lounge with wide service menu'
    ),
    (
        16,
        'Chroma Colour Bar',
        'HSR Layout',
        1.3,
        'Dedicated colour and balayage bar'
    ),
    (
        17,
        'Salon Serenity',
        'Electronic City',
        0.8,
        'Calm salon for after-work appointments'
    ),
    (
        18,
        'The Fade Room',
        'Frazer Town',
        0.9,
        'Fades, beards and sharp men''s styling'
    ),
    (
        19,
        'Bridal Bloom Studio',
        'Jayanagar',
        1.4,
        'Bridal and occasion hair specialists'
    ),
    (
        20,
        'Tonic Hair & Beauty',
        'Whitefield',
        1.0,
        'Everyday hair and beauty services'
    );

insert into public.businesses (id, owner_id, name, slug, description, phone, email, website, logo_url, cover_image_url, approval_status)
select pg_temp.uid('biz-'||n), pg_temp.uid('user-owner-'||n), name,
       trim(both '-' from lower(regexp_replace(name, '[^A-Za-z0-9]+', '-', 'g'))),
       name || ' in ' || locality || ', Bengaluru. ' || blurb || '.',
       '+91 80 4' || lpad((pg_temp.h('bp'||n) % 10000000)::text, 7, '0'),
       'hello@' || trim(both '-' from lower(regexp_replace(name, '[^A-Za-z0-9]+', '-', 'g'))) || '.example.com',
       'https://' || trim(both '-' from lower(regexp_replace(name, '[^A-Za-z0-9]+', '-', 'g'))) || '.example.com',
       'https://picsum.photos/seed/logo-'||n||'/200/200', 'https://picsum.photos/seed/cover-'||n||'/1200/600', 'APPROVED'
from seed_biz;

-- (business n, branch k, locality): everyone has branch 1; businesses 1,2,5,8,10 also have branch 2
create temp table seed_branch (n int, k int, locality text);

insert into
    seed_branch
select n, 1, locality
from seed_biz
union all
select 1, 2, 'Koramangala'
union all
select 2, 2, 'Indiranagar'
union all
select 5, 2, 'Marathahalli'
union all
select 8, 2, 'HSR Layout'
union all
select 10, 2, 'MG Road';

insert into public.business_locations (id, business_id, location_id, name, address_line, postal_code, landmark, phone, latitude, longitude, is_primary)
select pg_temp.uid('bl-'||b.n||'-'||b.k), pg_temp.uid('biz-'||b.n), l.id,
       case when b.k = 1 then null else sb.name || ' - ' || b.locality end,
       'No. ' || (10 + pg_temp.h('addr'||b.n||b.k) % 190) || ', ' ||
         (array['12th Main Road','100 Feet Road','5th Cross','Outer Ring Road','1st Block','Main Road','Service Road'])[1 + pg_temp.h('st'||b.n||b.k) % 7] || ', ' || b.locality,
       sl.pin,
       (array['Near the metro station','Opposite the main market','Above the coffee shop','Next to the petrol pump','Behind the mall'])[1 + pg_temp.h('lm'||b.n||b.k) % 5],
       '+91 80 4' || lpad((pg_temp.h('blp'||b.n||b.k) % 10000000)::text, 7, '0'),
       sl.lat + ((pg_temp.h('lat'||b.n||b.k) % 81) - 40) / 10000.0,
       sl.lng + ((pg_temp.h('lng'||b.n||b.k) % 81) - 40) / 10000.0,
       b.k = 1
from seed_branch b
join seed_biz sb on sb.n = b.n
join seed_loc sl on sl.locality = b.locality
join public.locations l on l.slug = lower(regexp_replace(b.locality, '[^A-Za-z0-9]+', '-', 'g')) || '-bengaluru';

insert into
    public.opening_hours (
        business_location_id,
        day_of_week,
        open_time,
        close_time
    )
select
    bl.id,
    d,
    case
        when d = 0 then time '11:00'
        else time '10:00'
    end,
    time '20:00'
from public.business_locations bl
    cross join generate_series (0, 6) d;

-- ---------- Services (100) ----------------------------------------------------
create temp
table seed_tpl (
    id int,
    name text,
    cat text,
    pmin numeric,
    pmax numeric,
    dur int
);

insert into
    seed_tpl
values (
        1,
        'Women''s Haircut',
        'haircut',
        700,
        1800,
        45
    ),
    (
        2,
        'Men''s Haircut',
        'mens',
        350,
        900,
        30
    ),
    (
        3,
        'Layered Haircut',
        'haircut',
        1000,
        2200,
        60
    ),
    (
        4,
        'Kids Haircut',
        'haircut',
        300,
        600,
        30
    ),
    (
        5,
        'Bob & Blunt Cut',
        'haircut',
        1000,
        2000,
        60
    ),
    (
        6,
        'Global Hair Colour',
        'coloring',
        2500,
        6000,
        120
    ),
    (
        7,
        'Balayage',
        'coloring',
        5500,
        12000,
        180
    ),
    (
        8,
        'Highlights',
        'coloring',
        3000,
        7000,
        150
    ),
    (
        9,
        'Root Touch-up',
        'coloring',
        1200,
        2500,
        75
    ),
    (
        10,
        'Ombre Colour',
        'coloring',
        5000,
        10000,
        165
    ),
    (
        11,
        'Keratin Smoothening',
        'straightening',
        4500,
        12000,
        180
    ),
    (
        12,
        'Hair Rebonding',
        'straightening',
        5000,
        10000,
        180
    ),
    (
        13,
        'Digital Perm',
        'straightening',
        4500,
        9000,
        180
    ),
    (
        14,
        'Blow Dry & Styling',
        'styling',
        500,
        1200,
        40
    ),
    (
        15,
        'Curls & Waves Styling',
        'styling',
        700,
        1500,
        50
    ),
    (
        16,
        'Party Hairstyle',
        'styling',
        900,
        2200,
        60
    ),
    (
        17,
        'Bridal Hairstyling',
        'bridal',
        4000,
        15000,
        150
    ),
    (
        18,
        'Bridal Trial',
        'bridal',
        1500,
        4000,
        90
    ),
    (
        19,
        'Beard Trim & Shape',
        'mens',
        250,
        600,
        25
    ),
    (
        20,
        'Men''s Fade & Style',
        'mens',
        500,
        1200,
        40
    ),
    (
        21,
        'Hair Spa',
        'treatments',
        1200,
        3000,
        60
    ),
    (
        22,
        'Deep Conditioning',
        'treatments',
        1000,
        2500,
        50
    ),
    (
        23,
        'Scalp Treatment',
        'treatments',
        1500,
        3500,
        60
    ),
    (
        24,
        'Hair Fall Therapy',
        'treatments',
        2000,
        5000,
        75
    ),
    (
        25,
        'Olaplex Repair Treatment',
        'treatments',
        2500,
        6000,
        90
    );

-- which 5 templates each business offers (specialist salons get themed menus)
create temp table seed_menu as
select b.n, k,
  case
    when b.n in (9,18)  then (array[2,19,20,23,24])[k+1]
    when b.n = 19       then (array[17,18,16,14,3])[k+1]
    when b.n = 16       then (array[6,7,8,9,10])[k+1]
    when b.n = 13       then (array[15,22,21,1,14])[k+1]
    else ((b.n*3 + k*5) % 25) + 1
  end as tpl
from seed_biz b cross join generate_series(0,4) k;

insert into
    public.services (
        id,
        business_id,
        category_id,
        name,
        description,
        price_min,
        price_max,
        duration_minutes
    )
select pg_temp.uid ('svc-' || m.n || '-' || m.k), pg_temp.uid ('biz-' || m.n), c.id, t.name, t.name || ' at ' || b.name || '. Final price depends on hair length and thickness.', round(t.pmin * b.tier / 50) * 50, round(t.pmax * b.tier / 50) * 50, t.dur
from
    seed_menu m
    join seed_tpl t on t.id = m.tpl
    join seed_biz b on b.n = m.n
    join public.service_categories c on c.slug = t.cat;

-- ---------- Stylists (50), specialties, stylist_services ----------------------
-- stylist s -> business ((s-1)%20)+1; q = 0,1,2 is their rank inside the business
insert into public.stylists (id, business_id, business_location_id, user_id, name, profile_image_url, bio,
                             experience_years, languages, gender, approval_status)
select pg_temp.uid('sty-'||s), pg_temp.uid('biz-'||x.n),
       pg_temp.uid('bl-'||x.n||'-'||case when x.q = 1 and x.n in (1,2,5,8,10) then 2 else 1 end),
       pg_temp.uid('user-stylist-'||s),
       p.full_name, 'https://i.pravatar.cc/300?u=stylist-'||s,
       (array['Consultation-first stylist who focuses on cuts that suit your face and routine.',
              'Loves transformations and low-maintenance looks that grow out well.',
              'Trained in international techniques; gentle with damaged and chemically treated hair.',
              'Known for precise cutting and honest advice on what will (and won''t) work for your hair.'])[1 + s % 4],
       1 + (s*7) % 15,
       case s % 6 when 0 then array['English','Kannada','Hindi'] when 1 then array['English','Kannada']
                  when 2 then array['English','Hindi'] when 3 then array['English','Tamil','Kannada']
                  when 4 then array['English','Telugu','Hindi'] else array['English','Malayalam','Kannada'] end,
       (case when (1 + (s*7) % 25) <= 15 then 'FEMALE' else 'MALE' end)::public.stylist_gender,
       'APPROVED'
from generate_series(1,50) s
cross join lateral (select ((s-1) % 20) + 1 as n, (s-1) / 20 as q) x
join seed_people p on p.kind = 'stylist' and p.n = s;

-- each stylist offers 3 of their business's 5 services; senior stylists (9+ yrs) charge ~25% more
insert into
    public.stylist_services (
        stylist_id,
        service_id,
        business_id,
        price
    )
select
    pg_temp.uid ('sty-' || s),
    pg_temp.uid (
        'svc-' || x.n || '-' || ((x.q + j) % 5)
    ),
    pg_temp.uid ('biz-' || x.n),
    case
        when st.experience_years >= 9 then round(sv.price_min * 1.25 / 50) * 50
    end
from
    generate_series (1, 50) s
    cross join lateral (
        select ((s -1) % 20) + 1 as n, (s -1) / 20 as q
    ) x
    cross join generate_series (0, 2) j
    join public.stylists st on st.id = pg_temp.uid ('sty-' || s)
    join public.services sv on sv.id = pg_temp.uid (
        'svc-' || x.n || '-' || ((x.q + j) % 5)
    );

-- specialties = up to 2 distinct categories among the stylist's services
insert into
    public.stylist_specialties (
        stylist_id,
        service_category_id
    )
select stylist_id, category_id
from (
        select d.stylist_id, d.category_id, row_number() over (
                partition by
                    d.stylist_id
                order by d.category_id
            ) rn
        from (
                select distinct
                    ss.stylist_id, sv.category_id
                from public.stylist_services ss
                    join public.services sv on sv.id = ss.service_id
            ) d
    ) t
where
    rn <= 2;

-- ---------- Availability (3 different schedules) + blocked slots --------------
--  type 0: Mon-Sat 10-19 | type 1: Tue-Sun 11-20 | type 2: Mon-Sat 10-18
insert into
    public.availability (
        stylist_id,
        day_of_week,
        start_time,
        end_time
    )
select
    pg_temp.uid ('sty-' || s),
    d,
    case s % 3
        when 1 then time '11:00'
        else time '10:00'
    end,
    case s % 3
        when 0 then time '19:00'
        when 1 then time '20:00'
        else time '18:00'
    end
from
    generate_series (1, 50) s
    cross join generate_series (0, 6) d
where (
        s % 3 = 1
        and d <> 1
    )
    or (
        s % 3 <> 1
        and d <> 0
    );

insert into public.blocked_slots (stylist_id, starts_at, ends_at, reason, note)
select pg_temp.uid('sty-'||s),
       ((current_date + 8 + s % 5) + time '10:00') at time zone 'Asia/Kolkata',
       ((current_date + 8 + s % 5) + time '19:00') at time zone 'Asia/Kolkata',
       (array['LEAVE','PERSONAL','CLOSURE','OTHER'])[1 + s % 4]::public.blocked_reason,
       'Seeded blocked day'
from generate_series(1,20) s;

-- ---------- Appointments: 500 COMPLETED (one per review) + 40 other statuses --
-- every appointment picks a service the stylist really offers; dates avoid the stylist's day off
create temp
table seed_ss as
select ss.stylist_id, ss.service_id, ss.price as override_price, row_number() over (
        partition by
            ss.stylist_id
        order by ss.service_id
    ) rn
from public.stylist_services ss;

insert into public.appointments (id, customer_id, business_id, location_id, stylist_id, service_id,
   appointment_date, start_time, end_time, price, customer_name, customer_phone, status, created_at)
select pg_temp.uid('appt-'||q.c), pg_temp.uid('user-customer-'||q.cust), st.business_id, st.business_location_id, st.id, sv.id,
       d.dt, t.tm, t.tm + make_interval(mins => sv.duration_minutes),
       coalesce(x.override_price,
         sv.price_min + round(((coalesce(sv.price_max, sv.price_min) - sv.price_min) * (pg_temp.h('pr'||q.c) % 100) / 100.0) / 50) * 50),
       u.full_name, u.phone, 'COMPLETED', (d.dt - 2)::timestamptz
from generate_series(1,50) s
cross join generate_series(0,9) k
cross join lateral (select (s-1)*10 + k + 1 as c, 1 + (((s-1)*10 + k + 1) * 7) % 60 as cust) q
join public.stylists st on st.id = pg_temp.uid('sty-'||s)
join seed_ss x on x.stylist_id = st.id and x.rn = (k % 3) + 1
join public.services sv on sv.id = x.service_id
join public.users u on u.id = pg_temp.uid('user-customer-'||q.cust)
cross join lateral (select (array['11:00','13:30','15:00'])[1 + k % 3]::time as tm) t
cross join lateral (select (b0.base - case when extract(dow from b0.base) = (case when s % 3 = 1 then 1 else 0 end) then 1 else 0 end)::date as dt
                    from (select current_date - (k*4 + 7) as base) b0) d;

-- 40 more appointments in the other statuses (future PENDING/CONFIRMED, past CANCELLED/NO_SHOW)
insert into public.appointments (id, customer_id, business_id, location_id, stylist_id, service_id,
   appointment_date, start_time, end_time, price, customer_name, customer_phone, status, created_at)
select pg_temp.uid('appt-x-'||j), pg_temp.uid('user-customer-'||(1 + j % 60)), st.business_id, st.business_location_id, st.id, sv.id,
       d.dt, time '12:00', time '12:00' + make_interval(mins => sv.duration_minutes),
       sv.price_min, u.full_name, u.phone, v.status, now() - interval '3 days'
from generate_series(1,40) j
cross join lateral (select (array['PENDING','CONFIRMED','CANCELLED','NO_SHOW'])[1 + j % 4]::public.appointment_status as status) v
join public.stylists st on st.id = pg_temp.uid('sty-'||j)
join seed_ss x on x.stylist_id = st.id and x.rn = 1
join public.services sv on sv.id = x.service_id
join public.users u on u.id = pg_temp.uid('user-customer-'||(1 + j % 60))
cross join lateral (select (b0.base - case when extract(dow from b0.base) = (case when j % 3 = 1 then 1 else 0 end) then 1 else 0 end)::date as dt
                    from (select case when v.status in ('PENDING','CONFIRMED') then current_date + 2 + j % 10
                                      else current_date - 1 - j % 5 end as base) b0) d;

-- ---------- Reviews (500): one per COMPLETED appointment ----------------------
insert into public.reviews (customer_id, business_id, stylist_id, service_id, appointment_id,
                            rating, body, photo_urls, moderation_status, created_at)
select a.customer_id, a.business_id, a.stylist_id, a.service_id, a.id,
       r.rating,
       'Went in for ' || lower(sv.name) || ' with ' || split_part(st.name, ' ', 1) || '. ' ||
         (case r.rating
            when 5 then (array['Exactly what I asked for and the finish was flawless.','Loved the result, would happily book again.','Great consultation, and the price matched the quote.','Best experience I have had at a salon in Bengaluru.'])[1 + pg_temp.h('t'||c) % 4]
            when 4 then (array['Very good work, only a short wait at the start.','Happy with the result and the price felt fair.','Skilled and friendly, would recommend.'])[1 + pg_temp.h('t'||c) % 3]
            when 3 then (array['Decent result but it took longer than promised.','Okay overall, the finish was not quite what I pictured.'])[1 + pg_temp.h('t'||c) % 2]
            when 2 then (array['Result was not what we discussed and I needed a fix.','Rushed appointment and average finish.'])[1 + pg_temp.h('t'||c) % 2]
            else 'Very disappointed with the outcome and the communication.'
          end),
       case when c % 10 = 0 then array['https://picsum.photos/seed/review-'||c||'/600/800'] else '{}'::text[] end,
       (case when c % 50 = 0 then 'PENDING' when c % 97 = 0 then 'REJECTED' else 'APPROVED' end)::public.moderation_status,
       (a.appointment_date + 1)::timestamptz + interval '10 hours'
from generate_series(1,500) c
join public.appointments a on a.id = pg_temp.uid('appt-'||c)
join public.services sv on sv.id = a.service_id
join public.stylists st on st.id = a.stylist_id
cross join lateral (
  select case when pg_temp.h('r'||c) % 100 < 4  then 1
              when pg_temp.h('r'||c) % 100 < 9  then 2
              when pg_temp.h('r'||c) % 100 < 20 then 3
              when pg_temp.h('r'||c) % 100 < 55 - (((ascii(substr(sv.business_id::text,1,1)) * 7) % 21) - 10) then 4
              else 5 end::smallint as rating) r;

-- ---------- Portfolio (200): 4 structured items per stylist -------------------
insert into public.portfolio_items (business_id, stylist_id, service_id, hairstyle_id, hair_type_id, hair_length, hair_thickness,
   client_gender, price, title, description, image_url, before_image_url, after_image_url, moderation_status, created_at)
select st.business_id, st.id, sv.id, hs.id, ht.id,
       (array['SHORT','MEDIUM','LONG','EXTRA_LONG'])[1 + pg_temp.h('len'||i) % 4]::public.hair_length,
       (array['THIN','MEDIUM','THICK'])[1 + pg_temp.h('thk'||i) % 3]::public.hair_thickness,
       (case when cat.slug = 'mens' then 'MALE' when i % 6 = 0 then 'UNISEX' else 'FEMALE' end)::public.client_gender,
       coalesce(x.override_price,
         sv.price_min + round(((coalesce(sv.price_max, sv.price_min) - sv.price_min) * (pg_temp.h('pp'||i) % 100) / 100.0) / 50) * 50),
       coalesce(hs.name, sv.name) || ' by ' || st.name,
       'Result of ' || lower(sv.name) || ' at ' || b.name || '.',
       'https://picsum.photos/seed/portfolio-'||i||'/800/1000',
       case when cat.slug in ('coloring','straightening','treatments') or i % 3 = 0
            then 'https://picsum.photos/seed/portfolio-'||i||'-before/800/1000' end,
       case when cat.slug in ('coloring','straightening','treatments') or i % 3 = 0
            then 'https://picsum.photos/seed/portfolio-'||i||'/800/1000' end,
       (case when i % 20 = 0 then 'PENDING' when i % 53 = 0 then 'REJECTED' else 'APPROVED' end)::public.moderation_status,
       now() - make_interval(days => pg_temp.h('cd'||i) % 180)
from generate_series(1,200) i
join public.stylists st on st.id = pg_temp.uid('sty-'||(((i-1) % 50) + 1))
join seed_ss x on x.stylist_id = st.id and x.rn = (((i-1) / 50) % 3) + 1
join public.services sv on sv.id = x.service_id
join public.service_categories cat on cat.id = sv.category_id
join public.businesses b on b.id = st.business_id
cross join lateral (select id from public.hair_types order by slug offset (pg_temp.h('ht'||i) % 4) limit 1) ht
left join lateral (
  select h.id, h.name from public.hairstyles h
  where h.service_category_id = sv.category_id
  order by h.slug
  offset (pg_temp.h('hs'||i) % greatest((select count(*) from public.hairstyles h2 where h2.service_category_id = sv.category_id), 1))
  limit 1) hs on true;

-- ---------- Favorites, hair profiles ------------------------------------------
insert into
    public.favorites (customer_id, business_id)
select pg_temp.uid ('user-customer-' || c), pg_temp.uid (
        'biz-' || (((c * 3) % 20) + 1)
    )
from generate_series (1, 30) c;

insert into
    public.favorites (customer_id, stylist_id)
select pg_temp.uid ('user-customer-' || c), pg_temp.uid (
        'sty-' || (((c * 7) % 50) + 1)
    )
from generate_series (1, 30) c;

insert into public.hair_profiles (id, user_id, hair_type_id, texture, length, thickness, condition)
select pg_temp.uid('hp-'||c), pg_temp.uid('user-customer-'||c),
       (select id from public.hair_types order by slug offset (pg_temp.h('phT'||c) % 4) limit 1),
       (array['FINE','MEDIUM','COARSE'])[1 + pg_temp.h('phx'||c) % 3]::public.hair_texture,
       (array['SHORT','MEDIUM','LONG','EXTRA_LONG'])[1 + pg_temp.h('phl'||c) % 4]::public.hair_length,
       (array['THIN','MEDIUM','THICK'])[1 + pg_temp.h('pht'||c) % 3]::public.hair_thickness,
       (array['HEALTHY','DRY','DAMAGED','OILY'])[1 + pg_temp.h('phc'||c) % 4]::public.hair_condition
from generate_series(1,30) c;

insert into
    public.hair_profile_concerns (
        hair_profile_id,
        hair_concern_id
    )
select pg_temp.uid ('hp-' || c), (
        select id
        from public.hair_concerns
        order by slug
        offset (a + o) % 10
        limit 1
    )
from generate_series (1, 30) c
    cross join lateral (
        select pg_temp.h ('cn' || c) % 10 as a
    ) x
    cross join (
        values (0), (3)
    ) v (o);

insert into
    public.hair_profile_hairstyles (hair_profile_id, hairstyle_id)
select pg_temp.uid ('hp-' || c), (
        select id
        from public.hairstyles
        order by slug
        offset (a + o) % 23
        limit 1
    )
from generate_series (1, 30) c
    cross join lateral (
        select pg_temp.h ('pf' || c) % 23 as a
    ) x
    cross join (
        values (0), (5)
    ) v (o);

insert into public.hair_profile_treatments (hair_profile_id, treatment, treated_on)
select pg_temp.uid('hp-'||c), (array['COLOR','KERATIN','BLEACH'])[1 + c % 3]::public.chemical_treatment, current_date - (60 + c * 5)
from generate_series(1,30) c where c % 3 = 0;