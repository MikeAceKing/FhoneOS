-- Location: supabase/migrations/20251210011807_fhoneos_auth_setup.sql
-- Schema Analysis: Empty database - FRESH_PROJECT
-- Integration Type: Complete authentication setup for FhoneOS
-- Dependencies: None - creating base schema

-- ==============================================================================
-- 1. CUSTOM TYPES
-- ==============================================================================

-- Safe creation: only create if doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE public.user_role AS ENUM ('user', 'admin');
    END IF;
END $$;

-- ==============================================================================
-- 2. CORE TABLES
-- ==============================================================================

-- Critical intermediary table for PostgREST compatibility
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    avatar_url TEXT DEFAULT '',
    role public.user_role DEFAULT 'user'::public.user_role,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 3. INDEXES
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON public.user_profiles(role);

-- ==============================================================================
-- 4. FUNCTIONS (MUST BE BEFORE RLS POLICIES)
-- ==============================================================================

-- Function to automatically create user profile when auth user is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, avatar_url, role, is_active)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', ''),
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'user'::public.user_role),
        COALESCE((NEW.raw_user_meta_data->>'is_active')::BOOLEAN, true)
    );
    RETURN NEW;
END;
$func$;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

-- ==============================================================================
-- 5. ENABLE RLS
-- ==============================================================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- 6. RLS POLICIES (Pattern 1: Core User Table)
-- ==============================================================================

-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "users_view_own_profile" ON public.user_profiles;
DROP POLICY IF EXISTS "users_update_own_profile" ON public.user_profiles;

-- Users can view their own profile
CREATE POLICY "users_view_own_profile"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (id = auth.uid());

-- Users can update their own profile
CREATE POLICY "users_update_own_profile"
ON public.user_profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- ==============================================================================
-- 7. TRIGGERS
-- ==============================================================================

-- Drop existing triggers if they exist to avoid conflicts
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_user_profile_updated ON public.user_profiles;

-- Trigger to create profile when new user signs up
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Trigger to update updated_at timestamp
CREATE TRIGGER on_user_profile_updated
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 8. MOCK DATA FOR TESTING
-- ==============================================================================

DO $$
DECLARE
    demo_id UUID := gen_random_uuid();
    user1_id UUID := gen_random_uuid();
BEGIN
    -- Delete existing mock users to avoid conflicts (safe for development)
    DELETE FROM auth.users WHERE email IN ('demo@cloudos.com', 'michael@fhoneos.com');
    
    -- Create mock auth users with complete required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (
            demo_id, 
            '00000000-0000-0000-0000-000000000000', 
            'authenticated', 
            'authenticated',
            'demo@cloudos.com',
            crypt('CloudOS@2025', gen_salt('bf', 10)),
            now(),
            now(),
            now(),
            '{"full_name": "Demo User", "role": "user", "avatar_url": "", "is_active": true}'::jsonb,
            '{"provider": "email", "providers": ["email"]}'::jsonb,
            false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null
        ),
        (
            user1_id,
            '00000000-0000-0000-0000-000000000000',
            'authenticated',
            'authenticated',
            'michael@fhoneos.com',
            crypt('user123', gen_salt('bf', 10)),
            now(),
            now(),
            now(),
            '{"full_name": "Michael Martinez", "role": "user", "avatar_url": "", "is_active": true}'::jsonb,
            '{"provider": "email", "providers": ["email"]}'::jsonb,
            false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null
        );

    RAISE NOTICE 'Mock users created successfully';
    RAISE NOTICE 'Demo: demo@cloudos.com / CloudOS@2025';
    RAISE NOTICE 'User: michael@fhoneos.com / user123';
END $$;