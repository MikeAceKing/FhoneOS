-- Location: supabase/migrations/20251210144043_fhoneos_cloud_sync_module.sql
-- Schema Analysis: Existing FhoneOS system with accounts, subscriptions, phone_numbers
-- Integration Type: Addition - New cloud sync & device management module
-- Dependencies: user_profiles, accounts

-- 1. ENUM TYPES
CREATE TYPE public.sync_status AS ENUM ('active', 'paused', 'error', 'pending');
CREATE TYPE public.sync_frequency AS ENUM ('realtime', 'hourly', 'daily', 'weekly', 'manual');
CREATE TYPE public.conflict_resolution_strategy AS ENUM ('server_priority', 'device_priority', 'manual', 'newest_wins');
CREATE TYPE public.encryption_level AS ENUM ('none', 'basic', 'standard', 'enterprise');
CREATE TYPE public.sync_category_type AS ENUM ('contacts', 'messages', 'call_history', 'media', 'app_settings', 'device_preferences');

-- 2. CORE TABLES

-- Sync Categories (what can be synced)
CREATE TABLE public.sync_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_type public.sync_category_type NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    icon_name TEXT,
    is_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User Sync Configurations
CREATE TABLE public.sync_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.sync_categories(id) ON DELETE CASCADE,
    is_enabled BOOLEAN DEFAULT true,
    sync_frequency public.sync_frequency DEFAULT 'daily'::public.sync_frequency,
    wifi_only BOOLEAN DEFAULT true,
    cellular_data_limit_mb INTEGER DEFAULT 100,
    background_sync BOOLEAN DEFAULT true,
    last_sync_at TIMESTAMPTZ,
    next_sync_at TIMESTAMPTZ,
    storage_used_mb DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, category_id)
);

-- Device Registrations
CREATE TABLE public.device_registrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL,
    device_name TEXT NOT NULL,
    device_model TEXT,
    os_version TEXT,
    app_version TEXT,
    last_active_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_trusted BOOLEAN DEFAULT true,
    can_remote_wipe BOOLEAN DEFAULT false,
    sync_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, device_id)
);

-- Sync History
CREATE TABLE public.sync_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    device_id UUID REFERENCES public.device_registrations(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.sync_categories(id) ON DELETE CASCADE,
    sync_status public.sync_status NOT NULL,
    items_synced INTEGER DEFAULT 0,
    data_transferred_mb DECIMAL(10,2) DEFAULT 0,
    started_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ,
    error_message TEXT,
    connection_type TEXT
);

-- Conflict Resolutions
CREATE TABLE public.conflict_resolutions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.sync_categories(id) ON DELETE CASCADE,
    strategy public.conflict_resolution_strategy DEFAULT 'newest_wins'::public.conflict_resolution_strategy,
    auto_resolve BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, category_id)
);

-- Encryption Settings
CREATE TABLE public.encryption_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    encryption_level public.encryption_level DEFAULT 'standard'::public.encryption_level,
    end_to_end_enabled BOOLEAN DEFAULT true,
    encryption_key_hash TEXT,
    key_rotation_days INTEGER DEFAULT 90,
    last_key_rotation TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- Backup Schedules
CREATE TABLE public.backup_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    frequency public.sync_frequency DEFAULT 'daily'::public.sync_frequency,
    scheduled_time TIME,
    last_backup_at TIMESTAMPTZ,
    next_backup_at TIMESTAMPTZ,
    storage_quota_mb INTEGER DEFAULT 5000,
    storage_used_mb DECIMAL(10,2) DEFAULT 0,
    auto_cleanup_enabled BOOLEAN DEFAULT true,
    retention_days INTEGER DEFAULT 30,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- 3. INDEXES
CREATE INDEX idx_sync_configurations_user_id ON public.sync_configurations(user_id);
CREATE INDEX idx_sync_configurations_category_id ON public.sync_configurations(category_id);
CREATE INDEX idx_device_registrations_user_id ON public.device_registrations(user_id);
CREATE INDEX idx_sync_history_user_id ON public.sync_history(user_id);
CREATE INDEX idx_sync_history_device_id ON public.sync_history(device_id);
CREATE INDEX idx_sync_history_started_at ON public.sync_history(started_at DESC);
CREATE INDEX idx_conflict_resolutions_user_id ON public.conflict_resolutions(user_id);
CREATE INDEX idx_encryption_settings_user_id ON public.encryption_settings(user_id);
CREATE INDEX idx_backup_schedules_user_id ON public.backup_schedules(user_id);

-- 4. FUNCTIONS

-- Function to calculate next sync time
CREATE OR REPLACE FUNCTION public.calculate_next_sync_time(
    frequency public.sync_frequency,
    last_sync TIMESTAMPTZ
)
RETURNS TIMESTAMPTZ
LANGUAGE plpgsql
STABLE
AS $func$
BEGIN
    RETURN CASE frequency
        WHEN 'realtime'::public.sync_frequency THEN last_sync + INTERVAL '5 minutes'
        WHEN 'hourly'::public.sync_frequency THEN last_sync + INTERVAL '1 hour'
        WHEN 'daily'::public.sync_frequency THEN last_sync + INTERVAL '1 day'
        WHEN 'weekly'::public.sync_frequency THEN last_sync + INTERVAL '7 days'
        ELSE NULL
    END;
END;
$func$;

-- Trigger to update sync configuration timestamps
CREATE OR REPLACE FUNCTION public.handle_sync_config_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    IF NEW.sync_frequency != 'manual'::public.sync_frequency THEN
        NEW.next_sync_at = public.calculate_next_sync_time(NEW.sync_frequency, COALESCE(NEW.last_sync_at, CURRENT_TIMESTAMP));
    END IF;
    RETURN NEW;
END;
$func$;

-- 5. ENABLE RLS
ALTER TABLE public.sync_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conflict_resolutions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.encryption_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.backup_schedules ENABLE ROW LEVEL SECURITY;

-- 6. RLS POLICIES

-- Sync categories - public read
CREATE POLICY "public_can_read_sync_categories"
ON public.sync_categories
FOR SELECT
TO public
USING (true);

-- Sync configurations - user ownership
CREATE POLICY "users_manage_own_sync_configurations"
ON public.sync_configurations
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Device registrations - user ownership
CREATE POLICY "users_manage_own_device_registrations"
ON public.device_registrations
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Sync history - user ownership
CREATE POLICY "users_manage_own_sync_history"
ON public.sync_history
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Conflict resolutions - user ownership
CREATE POLICY "users_manage_own_conflict_resolutions"
ON public.conflict_resolutions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Encryption settings - user ownership
CREATE POLICY "users_manage_own_encryption_settings"
ON public.encryption_settings
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Backup schedules - user ownership
CREATE POLICY "users_manage_own_backup_schedules"
ON public.backup_schedules
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 7. TRIGGERS
CREATE TRIGGER sync_configurations_updated_at
    BEFORE UPDATE ON public.sync_configurations
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_sync_config_updated_at();

CREATE TRIGGER conflict_resolutions_updated_at
    BEFORE UPDATE ON public.conflict_resolutions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER encryption_settings_updated_at
    BEFORE UPDATE ON public.encryption_settings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER backup_schedules_updated_at
    BEFORE UPDATE ON public.backup_schedules
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 8. MOCK DATA
DO $$
DECLARE
    existing_user_id UUID;
    contacts_cat_id UUID;
    messages_cat_id UUID;
    call_history_cat_id UUID;
    media_cat_id UUID;
    settings_cat_id UUID;
    preferences_cat_id UUID;
    device1_id UUID;
BEGIN
    -- Get existing user ID
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NOT NULL THEN
        -- Insert sync categories
        INSERT INTO public.sync_categories (id, category_type, name, description, icon_name) VALUES
            (gen_random_uuid(), 'contacts'::public.sync_category_type, 'Contacts', 'Sync phone contacts across devices', 'contacts'),
            (gen_random_uuid(), 'messages'::public.sync_category_type, 'Messages', 'Sync SMS and MMS messages', 'messages'),
            (gen_random_uuid(), 'call_history'::public.sync_category_type, 'Call History', 'Sync call logs and recordings', 'call'),
            (gen_random_uuid(), 'media'::public.sync_category_type, 'Media', 'Sync photos and videos', 'photo'),
            (gen_random_uuid(), 'app_settings'::public.sync_category_type, 'App Settings', 'Sync app preferences and configurations', 'settings'),
            (gen_random_uuid(), 'device_preferences'::public.sync_category_type, 'Device Preferences', 'Sync device-specific settings', 'device')
        RETURNING id INTO contacts_cat_id;

        -- Get category IDs
        SELECT id INTO messages_cat_id FROM public.sync_categories WHERE category_type = 'messages'::public.sync_category_type;
        SELECT id INTO call_history_cat_id FROM public.sync_categories WHERE category_type = 'call_history'::public.sync_category_type;
        SELECT id INTO media_cat_id FROM public.sync_categories WHERE category_type = 'media'::public.sync_category_type;
        SELECT id INTO settings_cat_id FROM public.sync_categories WHERE category_type = 'app_settings'::public.sync_category_type;
        SELECT id INTO preferences_cat_id FROM public.sync_categories WHERE category_type = 'device_preferences'::public.sync_category_type;

        -- Register a device
        INSERT INTO public.device_registrations (id, user_id, device_id, device_name, device_model, os_version, app_version)
        VALUES (gen_random_uuid(), existing_user_id, 'DEVICE-' || substr(md5(random()::text), 1, 8), 'Samsung Galaxy S23', 'SM-S911B', 'Android 14', '1.0.0')
        RETURNING id INTO device1_id;

        -- Create sync configurations
        INSERT INTO public.sync_configurations (user_id, category_id, is_enabled, sync_frequency, storage_used_mb) VALUES
            (existing_user_id, contacts_cat_id, true, 'daily'::public.sync_frequency, 12.5),
            (existing_user_id, messages_cat_id, true, 'realtime'::public.sync_frequency, 45.8),
            (existing_user_id, call_history_cat_id, true, 'daily'::public.sync_frequency, 8.3),
            (existing_user_id, media_cat_id, false, 'weekly'::public.sync_frequency, 1523.4),
            (existing_user_id, settings_cat_id, true, 'hourly'::public.sync_frequency, 2.1),
            (existing_user_id, preferences_cat_id, true, 'daily'::public.sync_frequency, 1.5);

        -- Create sync history
        INSERT INTO public.sync_history (user_id, device_id, category_id, sync_status, items_synced, data_transferred_mb, started_at, completed_at) VALUES
            (existing_user_id, device1_id, contacts_cat_id, 'active'::public.sync_status, 247, 12.5, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '1 hour 55 minutes'),
            (existing_user_id, device1_id, messages_cat_id, 'active'::public.sync_status, 1834, 45.8, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '23 hours 50 minutes'),
            (existing_user_id, device1_id, call_history_cat_id, 'error'::public.sync_status, 0, 0, CURRENT_TIMESTAMP - INTERVAL '3 hours', NULL);

        -- Create conflict resolutions
        INSERT INTO public.conflict_resolutions (user_id, category_id, strategy) VALUES
            (existing_user_id, contacts_cat_id, 'newest_wins'::public.conflict_resolution_strategy),
            (existing_user_id, messages_cat_id, 'server_priority'::public.conflict_resolution_strategy),
            (existing_user_id, media_cat_id, 'manual'::public.conflict_resolution_strategy);

        -- Create encryption settings
        INSERT INTO public.encryption_settings (user_id, encryption_level, end_to_end_enabled) VALUES
            (existing_user_id, 'standard'::public.encryption_level, true);

        -- Create backup schedule
        INSERT INTO public.backup_schedules (user_id, frequency, scheduled_time, storage_quota_mb, storage_used_mb) VALUES
            (existing_user_id, 'daily'::public.sync_frequency, '02:00:00', 5000, 1593.6);
    ELSE
        RAISE NOTICE 'No existing users found. Run auth migration first.';
    END IF;
END $$;