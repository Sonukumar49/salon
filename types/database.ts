export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      appointments: {
        Row: {
          appointment_date: string
          business_id: string
          created_at: string
          customer_id: string
          customer_name: string
          customer_phone: string | null
          end_time: string
          id: string
          location_id: string
          notes: string | null
          price: number
          service_id: string
          start_time: string
          status: Database["public"]["Enums"]["appointment_status"]
          stylist_id: string
          updated_at: string
        }
        Insert: {
          appointment_date: string
          business_id: string
          created_at?: string
          customer_id: string
          customer_name: string
          customer_phone?: string | null
          end_time: string
          id?: string
          location_id: string
          notes?: string | null
          price: number
          service_id: string
          start_time: string
          status?: Database["public"]["Enums"]["appointment_status"]
          stylist_id: string
          updated_at?: string
        }
        Update: {
          appointment_date?: string
          business_id?: string
          created_at?: string
          customer_id?: string
          customer_name?: string
          customer_phone?: string | null
          end_time?: string
          id?: string
          location_id?: string
          notes?: string | null
          price?: number
          service_id?: string
          start_time?: string
          status?: Database["public"]["Enums"]["appointment_status"]
          stylist_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "appointments_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "appointments_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "appointments_location_id_business_id_fkey"
            columns: ["location_id", "business_id"]
            isOneToOne: false
            referencedRelation: "business_locations"
            referencedColumns: ["id", "business_id"]
          },
          {
            foreignKeyName: "appointments_service_id_business_id_fkey"
            columns: ["service_id", "business_id"]
            isOneToOne: false
            referencedRelation: "services"
            referencedColumns: ["id", "business_id"]
          },
          {
            foreignKeyName: "appointments_stylist_id_business_id_fkey"
            columns: ["stylist_id", "business_id"]
            isOneToOne: false
            referencedRelation: "stylists"
            referencedColumns: ["id", "business_id"]
          },
          {
            foreignKeyName: "appointments_stylist_id_service_id_fkey"
            columns: ["stylist_id", "service_id"]
            isOneToOne: false
            referencedRelation: "stylist_services"
            referencedColumns: ["stylist_id", "service_id"]
          },
        ]
      }
      availability: {
        Row: {
          created_at: string
          day_of_week: number
          end_time: string
          id: string
          start_time: string
          stylist_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          day_of_week: number
          end_time: string
          id?: string
          start_time: string
          stylist_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          day_of_week?: number
          end_time?: string
          id?: string
          start_time?: string
          stylist_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "availability_stylist_id_fkey"
            columns: ["stylist_id"]
            isOneToOne: false
            referencedRelation: "stylists"
            referencedColumns: ["id"]
          },
        ]
      }
      blocked_slots: {
        Row: {
          created_at: string
          ends_at: string
          id: string
          note: string | null
          reason: Database["public"]["Enums"]["blocked_reason"]
          starts_at: string
          stylist_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          ends_at: string
          id?: string
          note?: string | null
          reason?: Database["public"]["Enums"]["blocked_reason"]
          starts_at: string
          stylist_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          ends_at?: string
          id?: string
          note?: string | null
          reason?: Database["public"]["Enums"]["blocked_reason"]
          starts_at?: string
          stylist_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "blocked_slots_stylist_id_fkey"
            columns: ["stylist_id"]
            isOneToOne: false
            referencedRelation: "stylists"
            referencedColumns: ["id"]
          },
        ]
      }
      business_locations: {
        Row: {
          address_line: string
          business_id: string
          created_at: string
          id: string
          is_primary: boolean
          landmark: string | null
          latitude: number
          location_id: string
          longitude: number
          name: string | null
          phone: string | null
          postal_code: string | null
          updated_at: string
        }
        Insert: {
          address_line: string
          business_id: string
          created_at?: string
          id?: string
          is_primary?: boolean
          landmark?: string | null
          latitude: number
          location_id: string
          longitude: number
          name?: string | null
          phone?: string | null
          postal_code?: string | null
          updated_at?: string
        }
        Update: {
          address_line?: string
          business_id?: string
          created_at?: string
          id?: string
          is_primary?: boolean
          landmark?: string | null
          latitude?: number
          location_id?: string
          longitude?: number
          name?: string | null
          phone?: string | null
          postal_code?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "business_locations_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "business_locations_location_id_fkey"
            columns: ["location_id"]
            isOneToOne: false
            referencedRelation: "locations"
            referencedColumns: ["id"]
          },
        ]
      }
      businesses: {
        Row: {
          approval_status: Database["public"]["Enums"]["moderation_status"]
          cover_image_url: string | null
          created_at: string
          description: string | null
          email: string | null
          id: string
          logo_url: string | null
          name: string
          owner_id: string
          phone: string | null
          rating_avg: number
          review_count: number
          slug: string
          updated_at: string
          website: string | null
        }
        Insert: {
          approval_status?: Database["public"]["Enums"]["moderation_status"]
          cover_image_url?: string | null
          created_at?: string
          description?: string | null
          email?: string | null
          id?: string
          logo_url?: string | null
          name: string
          owner_id: string
          phone?: string | null
          rating_avg?: number
          review_count?: number
          slug: string
          updated_at?: string
          website?: string | null
        }
        Update: {
          approval_status?: Database["public"]["Enums"]["moderation_status"]
          cover_image_url?: string | null
          created_at?: string
          description?: string | null
          email?: string | null
          id?: string
          logo_url?: string | null
          name?: string
          owner_id?: string
          phone?: string | null
          rating_avg?: number
          review_count?: number
          slug?: string
          updated_at?: string
          website?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "businesses_owner_id_fkey"
            columns: ["owner_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      favorites: {
        Row: {
          business_id: string | null
          created_at: string
          customer_id: string
          id: string
          stylist_id: string | null
        }
        Insert: {
          business_id?: string | null
          created_at?: string
          customer_id: string
          id?: string
          stylist_id?: string | null
        }
        Update: {
          business_id?: string | null
          created_at?: string
          customer_id?: string
          id?: string
          stylist_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "favorites_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "favorites_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "favorites_stylist_id_fkey"
            columns: ["stylist_id"]
            isOneToOne: false
            referencedRelation: "stylists"
            referencedColumns: ["id"]
          },
        ]
      }
      hair_concerns: {
        Row: {
          description: string | null
          id: string
          name: string
          slug: string
        }
        Insert: {
          description?: string | null
          id?: string
          name: string
          slug: string
        }
        Update: {
          description?: string | null
          id?: string
          name?: string
          slug?: string
        }
        Relationships: []
      }
      hair_profile_concerns: {
        Row: {
          hair_concern_id: string
          hair_profile_id: string
        }
        Insert: {
          hair_concern_id: string
          hair_profile_id: string
        }
        Update: {
          hair_concern_id?: string
          hair_profile_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "hair_profile_concerns_hair_concern_id_fkey"
            columns: ["hair_concern_id"]
            isOneToOne: false
            referencedRelation: "hair_concerns"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "hair_profile_concerns_hair_profile_id_fkey"
            columns: ["hair_profile_id"]
            isOneToOne: false
            referencedRelation: "hair_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      hair_profile_hairstyles: {
        Row: {
          hair_profile_id: string
          hairstyle_id: string
        }
        Insert: {
          hair_profile_id: string
          hairstyle_id: string
        }
        Update: {
          hair_profile_id?: string
          hairstyle_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "hair_profile_hairstyles_hair_profile_id_fkey"
            columns: ["hair_profile_id"]
            isOneToOne: false
            referencedRelation: "hair_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "hair_profile_hairstyles_hairstyle_id_fkey"
            columns: ["hairstyle_id"]
            isOneToOne: false
            referencedRelation: "hairstyles"
            referencedColumns: ["id"]
          },
        ]
      }
      hair_profile_treatments: {
        Row: {
          created_at: string
          hair_profile_id: string
          id: string
          notes: string | null
          treated_on: string | null
          treatment: Database["public"]["Enums"]["chemical_treatment"]
        }
        Insert: {
          created_at?: string
          hair_profile_id: string
          id?: string
          notes?: string | null
          treated_on?: string | null
          treatment: Database["public"]["Enums"]["chemical_treatment"]
        }
        Update: {
          created_at?: string
          hair_profile_id?: string
          id?: string
          notes?: string | null
          treated_on?: string | null
          treatment?: Database["public"]["Enums"]["chemical_treatment"]
        }
        Relationships: [
          {
            foreignKeyName: "hair_profile_treatments_hair_profile_id_fkey"
            columns: ["hair_profile_id"]
            isOneToOne: false
            referencedRelation: "hair_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      hair_profiles: {
        Row: {
          condition: Database["public"]["Enums"]["hair_condition"] | null
          created_at: string
          hair_type_id: string | null
          id: string
          length: Database["public"]["Enums"]["hair_length"] | null
          notes: string | null
          texture: Database["public"]["Enums"]["hair_texture"] | null
          thickness: Database["public"]["Enums"]["hair_thickness"] | null
          updated_at: string
          user_id: string
        }
        Insert: {
          condition?: Database["public"]["Enums"]["hair_condition"] | null
          created_at?: string
          hair_type_id?: string | null
          id?: string
          length?: Database["public"]["Enums"]["hair_length"] | null
          notes?: string | null
          texture?: Database["public"]["Enums"]["hair_texture"] | null
          thickness?: Database["public"]["Enums"]["hair_thickness"] | null
          updated_at?: string
          user_id: string
        }
        Update: {
          condition?: Database["public"]["Enums"]["hair_condition"] | null
          created_at?: string
          hair_type_id?: string | null
          id?: string
          length?: Database["public"]["Enums"]["hair_length"] | null
          notes?: string | null
          texture?: Database["public"]["Enums"]["hair_texture"] | null
          thickness?: Database["public"]["Enums"]["hair_thickness"] | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "hair_profiles_hair_type_id_fkey"
            columns: ["hair_type_id"]
            isOneToOne: false
            referencedRelation: "hair_types"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "hair_profiles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      hair_types: {
        Row: {
          description: string | null
          id: string
          name: string
          slug: string
        }
        Insert: {
          description?: string | null
          id?: string
          name: string
          slug: string
        }
        Update: {
          description?: string | null
          id?: string
          name?: string
          slug?: string
        }
        Relationships: []
      }
      hairstyles: {
        Row: {
          description: string | null
          id: string
          name: string
          service_category_id: string | null
          slug: string
        }
        Insert: {
          description?: string | null
          id?: string
          name: string
          service_category_id?: string | null
          slug: string
        }
        Update: {
          description?: string | null
          id?: string
          name?: string
          service_category_id?: string | null
          slug?: string
        }
        Relationships: [
          {
            foreignKeyName: "hairstyles_service_category_id_fkey"
            columns: ["service_category_id"]
            isOneToOne: false
            referencedRelation: "service_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      locations: {
        Row: {
          city: string
          country: string
          created_at: string
          id: string
          latitude: number
          locality: string
          longitude: number
          slug: string
          state: string
          updated_at: string
        }
        Insert: {
          city: string
          country?: string
          created_at?: string
          id?: string
          latitude: number
          locality: string
          longitude: number
          slug: string
          state: string
          updated_at?: string
        }
        Update: {
          city?: string
          country?: string
          created_at?: string
          id?: string
          latitude?: number
          locality?: string
          longitude?: number
          slug?: string
          state?: string
          updated_at?: string
        }
        Relationships: []
      }
      opening_hours: {
        Row: {
          business_location_id: string
          close_time: string | null
          day_of_week: number
          id: string
          is_closed: boolean
          open_time: string | null
        }
        Insert: {
          business_location_id: string
          close_time?: string | null
          day_of_week: number
          id?: string
          is_closed?: boolean
          open_time?: string | null
        }
        Update: {
          business_location_id?: string
          close_time?: string | null
          day_of_week?: number
          id?: string
          is_closed?: boolean
          open_time?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "opening_hours_business_location_id_fkey"
            columns: ["business_location_id"]
            isOneToOne: false
            referencedRelation: "business_locations"
            referencedColumns: ["id"]
          },
        ]
      }
      portfolio_items: {
        Row: {
          after_image_url: string | null
          before_image_url: string | null
          business_id: string
          client_gender: Database["public"]["Enums"]["client_gender"] | null
          created_at: string
          description: string | null
          hair_length: Database["public"]["Enums"]["hair_length"] | null
          hair_thickness: Database["public"]["Enums"]["hair_thickness"] | null
          hair_type_id: string | null
          hairstyle_id: string | null
          id: string
          image_url: string
          moderation_status: Database["public"]["Enums"]["moderation_status"]
          price: number | null
          service_id: string
          stylist_id: string
          title: string | null
          updated_at: string
        }
        Insert: {
          after_image_url?: string | null
          before_image_url?: string | null
          business_id: string
          client_gender?: Database["public"]["Enums"]["client_gender"] | null
          created_at?: string
          description?: string | null
          hair_length?: Database["public"]["Enums"]["hair_length"] | null
          hair_thickness?: Database["public"]["Enums"]["hair_thickness"] | null
          hair_type_id?: string | null
          hairstyle_id?: string | null
          id?: string
          image_url: string
          moderation_status?: Database["public"]["Enums"]["moderation_status"]
          price?: number | null
          service_id: string
          stylist_id: string
          title?: string | null
          updated_at?: string
        }
        Update: {
          after_image_url?: string | null
          before_image_url?: string | null
          business_id?: string
          client_gender?: Database["public"]["Enums"]["client_gender"] | null
          created_at?: string
          description?: string | null
          hair_length?: Database["public"]["Enums"]["hair_length"] | null
          hair_thickness?: Database["public"]["Enums"]["hair_thickness"] | null
          hair_type_id?: string | null
          hairstyle_id?: string | null
          id?: string
          image_url?: string
          moderation_status?: Database["public"]["Enums"]["moderation_status"]
          price?: number | null
          service_id?: string
          stylist_id?: string
          title?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "portfolio_items_hair_type_id_fkey"
            columns: ["hair_type_id"]
            isOneToOne: false
            referencedRelation: "hair_types"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "portfolio_items_hairstyle_id_fkey"
            columns: ["hairstyle_id"]
            isOneToOne: false
            referencedRelation: "hairstyles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "portfolio_items_service_id_business_id_fkey"
            columns: ["service_id", "business_id"]
            isOneToOne: false
            referencedRelation: "services"
            referencedColumns: ["id", "business_id"]
          },
          {
            foreignKeyName: "portfolio_items_stylist_id_business_id_fkey"
            columns: ["stylist_id", "business_id"]
            isOneToOne: false
            referencedRelation: "stylists"
            referencedColumns: ["id", "business_id"]
          },
        ]
      }
      reviews: {
        Row: {
          appointment_id: string
          body: string | null
          business_id: string
          created_at: string
          customer_id: string
          id: string
          moderation_status: Database["public"]["Enums"]["moderation_status"]
          photo_urls: string[]
          rating: number
          service_id: string
          stylist_id: string
          updated_at: string
        }
        Insert: {
          appointment_id: string
          body?: string | null
          business_id: string
          created_at?: string
          customer_id: string
          id?: string
          moderation_status?: Database["public"]["Enums"]["moderation_status"]
          photo_urls?: string[]
          rating: number
          service_id: string
          stylist_id: string
          updated_at?: string
        }
        Update: {
          appointment_id?: string
          body?: string | null
          business_id?: string
          created_at?: string
          customer_id?: string
          id?: string
          moderation_status?: Database["public"]["Enums"]["moderation_status"]
          photo_urls?: string[]
          rating?: number
          service_id?: string
          stylist_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "reviews_appointment_id_customer_id_business_id_stylist_id__fkey"
            columns: [
              "appointment_id",
              "customer_id",
              "business_id",
              "stylist_id",
              "service_id",
            ]
            isOneToOne: false
            referencedRelation: "appointments"
            referencedColumns: [
              "id",
              "customer_id",
              "business_id",
              "stylist_id",
              "service_id",
            ]
          },
        ]
      }
      service_categories: {
        Row: {
          description: string | null
          id: string
          name: string
          slug: string
          sort_order: number
        }
        Insert: {
          description?: string | null
          id?: string
          name: string
          slug: string
          sort_order?: number
        }
        Update: {
          description?: string | null
          id?: string
          name?: string
          slug?: string
          sort_order?: number
        }
        Relationships: []
      }
      services: {
        Row: {
          business_id: string
          category_id: string
          created_at: string
          description: string | null
          duration_minutes: number
          id: string
          is_active: boolean
          name: string
          price_max: number | null
          price_min: number
          updated_at: string
        }
        Insert: {
          business_id: string
          category_id: string
          created_at?: string
          description?: string | null
          duration_minutes: number
          id?: string
          is_active?: boolean
          name: string
          price_max?: number | null
          price_min: number
          updated_at?: string
        }
        Update: {
          business_id?: string
          category_id?: string
          created_at?: string
          description?: string | null
          duration_minutes?: number
          id?: string
          is_active?: boolean
          name?: string
          price_max?: number | null
          price_min?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "services_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "services_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "service_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      stylist_services: {
        Row: {
          business_id: string
          created_at: string
          duration_minutes: number | null
          is_active: boolean
          price: number | null
          service_id: string
          stylist_id: string
          updated_at: string
        }
        Insert: {
          business_id: string
          created_at?: string
          duration_minutes?: number | null
          is_active?: boolean
          price?: number | null
          service_id: string
          stylist_id: string
          updated_at?: string
        }
        Update: {
          business_id?: string
          created_at?: string
          duration_minutes?: number | null
          is_active?: boolean
          price?: number | null
          service_id?: string
          stylist_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "stylist_services_service_id_business_id_fkey"
            columns: ["service_id", "business_id"]
            isOneToOne: false
            referencedRelation: "services"
            referencedColumns: ["id", "business_id"]
          },
          {
            foreignKeyName: "stylist_services_stylist_id_business_id_fkey"
            columns: ["stylist_id", "business_id"]
            isOneToOne: false
            referencedRelation: "stylists"
            referencedColumns: ["id", "business_id"]
          },
        ]
      }
      stylist_specialties: {
        Row: {
          service_category_id: string
          stylist_id: string
        }
        Insert: {
          service_category_id: string
          stylist_id: string
        }
        Update: {
          service_category_id?: string
          stylist_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "stylist_specialties_service_category_id_fkey"
            columns: ["service_category_id"]
            isOneToOne: false
            referencedRelation: "service_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stylist_specialties_stylist_id_fkey"
            columns: ["stylist_id"]
            isOneToOne: false
            referencedRelation: "stylists"
            referencedColumns: ["id"]
          },
        ]
      }
      stylists: {
        Row: {
          approval_status: Database["public"]["Enums"]["moderation_status"]
          bio: string | null
          business_id: string
          business_location_id: string | null
          created_at: string
          experience_years: number | null
          gender: Database["public"]["Enums"]["stylist_gender"] | null
          id: string
          languages: string[]
          name: string
          profile_image_url: string | null
          updated_at: string
          user_id: string | null
        }
        Insert: {
          approval_status?: Database["public"]["Enums"]["moderation_status"]
          bio?: string | null
          business_id: string
          business_location_id?: string | null
          created_at?: string
          experience_years?: number | null
          gender?: Database["public"]["Enums"]["stylist_gender"] | null
          id?: string
          languages?: string[]
          name: string
          profile_image_url?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          approval_status?: Database["public"]["Enums"]["moderation_status"]
          bio?: string | null
          business_id?: string
          business_location_id?: string | null
          created_at?: string
          experience_years?: number | null
          gender?: Database["public"]["Enums"]["stylist_gender"] | null
          id?: string
          languages?: string[]
          name?: string
          profile_image_url?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "stylists_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stylists_business_location_id_business_id_fkey"
            columns: ["business_location_id", "business_id"]
            isOneToOne: false
            referencedRelation: "business_locations"
            referencedColumns: ["id", "business_id"]
          },
          {
            foreignKeyName: "stylists_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      users: {
        Row: {
          avatar_url: string | null
          created_at: string
          email: string | null
          full_name: string | null
          id: string
          phone: string | null
          role: Database["public"]["Enums"]["user_role"]
          updated_at: string
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string
          email?: string | null
          full_name?: string | null
          id: string
          phone?: string | null
          role?: Database["public"]["Enums"]["user_role"]
          updated_at?: string
        }
        Update: {
          avatar_url?: string | null
          created_at?: string
          email?: string | null
          full_name?: string | null
          id?: string
          phone?: string | null
          role?: Database["public"]["Enums"]["user_role"]
          updated_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      t_as: { Args: { r: string; user_key: string }; Returns: undefined }
      t_run: {
        Args: { expect: string; label: string; q: string }
        Returns: undefined
      }
      t_uid: { Args: { k: string }; Returns: string }
    }
    Enums: {
      appointment_status:
      | "PENDING"
      | "CONFIRMED"
      | "CANCELLED"
      | "COMPLETED"
      | "NO_SHOW"
      blocked_reason: "LEAVE" | "PERSONAL" | "CLOSURE" | "OTHER"
      chemical_treatment:
      | "COLOR"
      | "BLEACH"
      | "KERATIN"
      | "SMOOTHENING"
      | "REBONDING"
      | "PERM"
      | "RELAXER"
      | "OTHER"
      client_gender: "FEMALE" | "MALE" | "UNISEX"
      hair_condition: "HEALTHY" | "DRY" | "DAMAGED" | "OILY"
      hair_length: "SHORT" | "MEDIUM" | "LONG" | "EXTRA_LONG"
      hair_texture: "FINE" | "MEDIUM" | "COARSE"
      hair_thickness: "THIN" | "MEDIUM" | "THICK"
      moderation_status: "PENDING" | "APPROVED" | "REJECTED"
      stylist_gender: "FEMALE" | "MALE" | "NON_BINARY"
      user_role: "CUSTOMER" | "BUSINESS_OWNER" | "STYLIST" | "ADMIN"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
  | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
  | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
    DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
  ? R
  : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
    DefaultSchema["Views"])
  ? (DefaultSchema["Tables"] &
    DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
      Row: infer R
    }
  ? R
  : never
  : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
  | keyof DefaultSchema["Tables"]
  | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
    Insert: infer I
  }
  ? I
  : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
    Insert: infer I
  }
  ? I
  : never
  : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
  | keyof DefaultSchema["Tables"]
  | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
    Update: infer U
  }
  ? U
  : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
    Update: infer U
  }
  ? U
  : never
  : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
  | keyof DefaultSchema["Enums"]
  | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
  ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
  : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
  | keyof DefaultSchema["CompositeTypes"]
  | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
  ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
  : never

export const Constants = {
  public: {
    Enums: {
      appointment_status: [
        "PENDING",
        "CONFIRMED",
        "CANCELLED",
        "COMPLETED",
        "NO_SHOW",
      ],
      blocked_reason: ["LEAVE", "PERSONAL", "CLOSURE", "OTHER"],
      chemical_treatment: [
        "COLOR",
        "BLEACH",
        "KERATIN",
        "SMOOTHENING",
        "REBONDING",
        "PERM",
        "RELAXER",
        "OTHER",
      ],
      client_gender: ["FEMALE", "MALE", "UNISEX"],
      hair_condition: ["HEALTHY", "DRY", "DAMAGED", "OILY"],
      hair_length: ["SHORT", "MEDIUM", "LONG", "EXTRA_LONG"],
      hair_texture: ["FINE", "MEDIUM", "COARSE"],
      hair_thickness: ["THIN", "MEDIUM", "THICK"],
      moderation_status: ["PENDING", "APPROVED", "REJECTED"],
      stylist_gender: ["FEMALE", "MALE", "NON_BINARY"],
      user_role: ["CUSTOMER", "BUSINESS_OWNER", "STYLIST", "ADMIN"],
    },
  },
} as const