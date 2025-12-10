-- Location: supabase/migrations/20251210145320_unified_social_inbox_module.sql
-- Schema Analysis: Existing tables include user_profiles, device_registrations, accounts
-- Integration Type: NEW MODULE - Social inbox and messaging functionality
-- Dependencies: user_profiles (for user relationships), device_registrations (for device sync)

-- 1. TYPES - Message platforms and statuses
CREATE TYPE public.message_platform AS ENUM (
    'sms',
    'whatsapp', 
    'telegram',
    'facebook',
    'instagram',
    'twitter',
    'email',
    'twilio'
);

CREATE TYPE public.message_direction AS ENUM ('incoming', 'outgoing');
CREATE TYPE public.message_status AS ENUM ('sent', 'delivered', 'read', 'failed', 'pending');
CREATE TYPE public.connection_status AS ENUM ('connected', 'disconnected', 'pending', 'expired');

-- 2. CORE TABLES

-- Connected platforms for OAuth integrations
CREATE TABLE public.connected_platforms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    platform public.message_platform NOT NULL,
    platform_user_id TEXT NOT NULL,
    platform_username TEXT,
    access_token TEXT,
    refresh_token TEXT,
    token_expires_at TIMESTAMPTZ,
    connection_status public.connection_status DEFAULT 'connected'::public.connection_status,
    last_synced_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, platform, platform_user_id)
);

-- Message threads (conversations)
CREATE TABLE public.message_threads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    platform public.message_platform NOT NULL,
    platform_thread_id TEXT NOT NULL,
    participant_name TEXT NOT NULL,
    participant_identifier TEXT NOT NULL,
    last_message_preview TEXT,
    last_message_at TIMESTAMPTZ,
    unread_count INTEGER DEFAULT 0,
    is_archived BOOLEAN DEFAULT false,
    is_pinned BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, platform, platform_thread_id)
);

-- Individual messages
CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    thread_id UUID NOT NULL REFERENCES public.message_threads(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    platform public.message_platform NOT NULL,
    platform_message_id TEXT,
    direction public.message_direction NOT NULL,
    sender_name TEXT NOT NULL,
    sender_identifier TEXT NOT NULL,
    recipient_name TEXT,
    recipient_identifier TEXT,
    content TEXT NOT NULL,
    message_status public.message_status DEFAULT 'sent'::public.message_status,
    is_read BOOLEAN DEFAULT false,
    sent_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    delivered_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Message attachments
CREATE TABLE public.message_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_type TEXT,
    file_size_bytes BIGINT,
    file_name TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. INDEXES
CREATE INDEX idx_connected_platforms_user_id ON public.connected_platforms(user_id);
CREATE INDEX idx_connected_platforms_platform ON public.connected_platforms(platform);
CREATE INDEX idx_connected_platforms_status ON public.connected_platforms(connection_status);

CREATE INDEX idx_message_threads_user_id ON public.message_threads(user_id);
CREATE INDEX idx_message_threads_platform ON public.message_threads(platform);
CREATE INDEX idx_message_threads_last_message ON public.message_threads(last_message_at DESC);
CREATE INDEX idx_message_threads_unread ON public.message_threads(user_id, unread_count) WHERE unread_count > 0;

CREATE INDEX idx_messages_thread_id ON public.messages(thread_id);
CREATE INDEX idx_messages_user_id ON public.messages(user_id);
CREATE INDEX idx_messages_platform ON public.messages(platform);
CREATE INDEX idx_messages_sent_at ON public.messages(sent_at DESC);
CREATE INDEX idx_messages_unread ON public.messages(user_id, is_read) WHERE is_read = false;

CREATE INDEX idx_message_attachments_message_id ON public.message_attachments(message_id);

-- 4. FUNCTIONS (BEFORE RLS POLICIES)

-- Update thread timestamp when new message arrives
CREATE OR REPLACE FUNCTION public.update_thread_last_message()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    UPDATE public.message_threads
    SET 
        last_message_preview = LEFT(NEW.content, 100),
        last_message_at = NEW.sent_at,
        unread_count = CASE 
            WHEN NEW.direction = 'incoming'::public.message_direction 
            THEN unread_count + 1 
            ELSE unread_count 
        END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.thread_id;
    
    RETURN NEW;
END;
$func$;

-- Update timestamps
CREATE OR REPLACE FUNCTION public.handle_message_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

-- 5. ENABLE RLS
ALTER TABLE public.connected_platforms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_attachments ENABLE ROW LEVEL SECURITY;

-- 6. RLS POLICIES (Pattern 2: Simple User Ownership)

-- Connected platforms
CREATE POLICY "users_manage_own_connected_platforms"
ON public.connected_platforms
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Message threads
CREATE POLICY "users_manage_own_message_threads"
ON public.message_threads
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Messages
CREATE POLICY "users_manage_own_messages"
ON public.messages
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Message attachments (access through message ownership)
CREATE POLICY "users_access_own_message_attachments"
ON public.message_attachments
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messages m
        WHERE m.id = message_id AND m.user_id = auth.uid()
    )
);

CREATE POLICY "users_create_own_message_attachments"
ON public.message_attachments
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.messages m
        WHERE m.id = message_id AND m.user_id = auth.uid()
    )
);

-- 7. TRIGGERS
CREATE TRIGGER trigger_update_thread_last_message
    AFTER INSERT ON public.messages
    FOR EACH ROW
    EXECUTE FUNCTION public.update_thread_last_message();

CREATE TRIGGER trigger_connected_platforms_updated_at
    BEFORE UPDATE ON public.connected_platforms
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_message_updated_at();

CREATE TRIGGER trigger_message_threads_updated_at
    BEFORE UPDATE ON public.message_threads
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_message_updated_at();

-- 8. MOCK DATA
DO $$
DECLARE
    sample_user_id UUID;
    whatsapp_platform_id UUID;
    telegram_platform_id UUID;
    sms_thread_id UUID;
    whatsapp_thread_id UUID;
BEGIN
    -- Get existing user from user_profiles
    SELECT id INTO sample_user_id FROM public.user_profiles LIMIT 1;
    
    -- Only proceed if user exists
    IF sample_user_id IS NOT NULL THEN
        -- Create connected platforms
        INSERT INTO public.connected_platforms (id, user_id, platform, platform_user_id, platform_username, connection_status, last_synced_at)
        VALUES 
            (gen_random_uuid(), sample_user_id, 'whatsapp'::public.message_platform, 'whatsapp_12345', 'John Doe', 'connected'::public.connection_status, NOW()),
            (gen_random_uuid(), sample_user_id, 'telegram'::public.message_platform, 'telegram_67890', '@johndoe', 'connected'::public.connection_status, NOW()),
            (gen_random_uuid(), sample_user_id, 'sms'::public.message_platform, 'device_sms', 'SMS', 'connected'::public.connection_status, NOW())
        RETURNING id INTO whatsapp_platform_id;

        -- Create message threads
        INSERT INTO public.message_threads (id, user_id, platform, platform_thread_id, participant_name, participant_identifier, last_message_preview, last_message_at, unread_count)
        VALUES 
            (gen_random_uuid(), sample_user_id, 'sms'::public.message_platform, 'thread_sms_001', 'Mom', '+1234567890', 'Do not forget to call me tonight', NOW() - INTERVAL '2 hours', 1),
            (gen_random_uuid(), sample_user_id, 'whatsapp'::public.message_platform, 'thread_wa_002', 'Sarah Johnson', '+1987654321', 'See you at the meeting tomorrow', NOW() - INTERVAL '1 hour', 2),
            (gen_random_uuid(), sample_user_id, 'telegram'::public.message_platform, 'thread_tg_003', 'Team Project', '@teamproject', 'New update pushed to main branch', NOW() - INTERVAL '30 minutes', 3)
        RETURNING id INTO sms_thread_id;

        -- Get whatsapp thread
        SELECT id INTO whatsapp_thread_id FROM public.message_threads WHERE platform = 'whatsapp'::public.message_platform LIMIT 1;

        -- Create messages for SMS thread
        INSERT INTO public.messages (thread_id, user_id, platform, direction, sender_name, sender_identifier, content, message_status, is_read, sent_at)
        VALUES 
            (sms_thread_id, sample_user_id, 'sms'::public.message_platform, 'incoming'::public.message_direction, 'Mom', '+1234567890', 'Hi honey, how are you doing?', 'delivered'::public.message_status, true, NOW() - INTERVAL '3 hours'),
            (sms_thread_id, sample_user_id, 'sms'::public.message_platform, 'outgoing'::public.message_direction, 'You', sample_user_id::TEXT, 'Hey Mom! I am doing great, thanks for asking!', 'delivered'::public.message_status, true, NOW() - INTERVAL '2 hours 30 minutes'),
            (sms_thread_id, sample_user_id, 'sms'::public.message_platform, 'incoming'::public.message_direction, 'Mom', '+1234567890', 'Do not forget to call me tonight', 'delivered'::public.message_status, false, NOW() - INTERVAL '2 hours');

        -- Create messages for WhatsApp thread
        INSERT INTO public.messages (thread_id, user_id, platform, direction, sender_name, sender_identifier, content, message_status, is_read, sent_at)
        VALUES 
            (whatsapp_thread_id, sample_user_id, 'whatsapp'::public.message_platform, 'incoming'::public.message_direction, 'Sarah Johnson', '+1987654321', 'Hey! Did you finish the report?', 'delivered'::public.message_status, true, NOW() - INTERVAL '2 hours'),
            (whatsapp_thread_id, sample_user_id, 'whatsapp'::public.message_platform, 'outgoing'::public.message_direction, 'You', sample_user_id::TEXT, 'Almost done, will send it in 30 mins', 'delivered'::public.message_status, true, NOW() - INTERVAL '1 hour 30 minutes'),
            (whatsapp_thread_id, sample_user_id, 'whatsapp'::public.message_platform, 'incoming'::public.message_direction, 'Sarah Johnson', '+1987654321', 'See you at the meeting tomorrow', 'delivered'::public.message_status, false, NOW() - INTERVAL '1 hour');

        RAISE NOTICE 'Mock messaging data created successfully';
    ELSE
        RAISE NOTICE 'No existing users found. Please create users first or run auth migration.';
    END IF;
END $$;