-- Location: supabase/migrations/20251210163218_twilio_whatsapp_video_extension.sql
-- Schema Analysis: Existing SMS/messaging system with conversations, messages, calls tables
-- Integration Type: Extension - Adding Twilio Conversations API, WhatsApp, and Video support
-- Dependencies: conversations, messages, calls, contacts, user_profiles tables

-- ============================================================================
-- STEP 1: NEW TYPES FOR MULTI-PLATFORM MESSAGING
-- ============================================================================

CREATE TYPE public.message_platform AS ENUM ('sms', 'whatsapp', 'telegram', 'twilio_conversations');
CREATE TYPE public.video_session_status AS ENUM ('scheduled', 'active', 'completed', 'cancelled', 'failed');
CREATE TYPE public.device_sync_status AS ENUM ('synced', 'pending', 'failed', 'offline');

-- ============================================================================
-- STEP 2: EXTEND EXISTING TABLES WITH TWILIO/WHATSAPP FIELDS
-- ============================================================================

-- Extend conversations table with Twilio Conversations API fields
ALTER TABLE public.conversations
ADD COLUMN IF NOT EXISTS platform public.message_platform DEFAULT 'sms'::public.message_platform,
ADD COLUMN IF NOT EXISTS twilio_conversation_sid TEXT,
ADD COLUMN IF NOT EXISTS whatsapp_contact_id TEXT,
ADD COLUMN IF NOT EXISTS sync_data JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ;

-- Extend messages table with platform indicators
ALTER TABLE public.messages
ADD COLUMN IF NOT EXISTS platform public.message_platform DEFAULT 'sms'::public.message_platform,
ADD COLUMN IF NOT EXISTS twilio_message_sid TEXT,
ADD COLUMN IF NOT EXISTS media_urls TEXT[];

-- Add indexes for new fields
CREATE INDEX IF NOT EXISTS idx_conversations_platform ON public.conversations(platform);
CREATE INDEX IF NOT EXISTS idx_conversations_twilio_sid ON public.conversations(twilio_conversation_sid);
CREATE INDEX IF NOT EXISTS idx_conversations_whatsapp_contact ON public.conversations(whatsapp_contact_id);
CREATE INDEX IF NOT EXISTS idx_messages_platform ON public.messages(platform);
CREATE INDEX IF NOT EXISTS idx_messages_twilio_sid ON public.messages(twilio_message_sid);

-- ============================================================================
-- STEP 3: NEW TABLES FOR VIDEO CONFERENCING
-- ============================================================================

-- Video sessions table for Twilio Video / WebRTC
CREATE TABLE public.video_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    room_sid TEXT,
    room_name TEXT NOT NULL,
    host_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    status public.video_session_status DEFAULT 'scheduled'::public.video_session_status,
    scheduled_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    max_participants INTEGER DEFAULT 10,
    is_recording BOOLEAN DEFAULT false,
    recording_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Video session participants tracking
CREATE TABLE public.video_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.video_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    participant_sid TEXT,
    display_name TEXT NOT NULL,
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMPTZ,
    is_audio_enabled BOOLEAN DEFAULT true,
    is_video_enabled BOOLEAN DEFAULT true,
    is_screen_sharing BOOLEAN DEFAULT false,
    connection_quality NUMERIC
);

-- Device sync tracking for multi-device support
CREATE TABLE public.device_sync_states (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL,
    device_name TEXT NOT NULL,
    last_sync_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    sync_status public.device_sync_status DEFAULT 'pending'::public.device_sync_status,
    unread_count INTEGER DEFAULT 0,
    pending_messages JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- STEP 4: INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX idx_video_sessions_account_id ON public.video_sessions(account_id);
CREATE INDEX idx_video_sessions_host_id ON public.video_sessions(host_id);
CREATE INDEX idx_video_sessions_status ON public.video_sessions(status);
CREATE INDEX idx_video_sessions_scheduled_at ON public.video_sessions(scheduled_at);

CREATE INDEX idx_video_participants_session_id ON public.video_participants(session_id);
CREATE INDEX idx_video_participants_user_id ON public.video_participants(user_id);

CREATE INDEX idx_device_sync_user_id ON public.device_sync_states(user_id);
CREATE INDEX idx_device_sync_device_id ON public.device_sync_states(device_id);
CREATE INDEX idx_device_sync_status ON public.device_sync_states(sync_status);

-- ============================================================================
-- STEP 5: ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.video_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.video_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_sync_states ENABLE ROW LEVEL SECURITY;

-- Video sessions policies
CREATE POLICY "users_view_own_video_sessions"
ON public.video_sessions
FOR SELECT
TO authenticated
USING (
    host_id = auth.uid() OR
    EXISTS (
        SELECT 1 FROM public.video_participants vp
        WHERE vp.session_id = video_sessions.id
        AND vp.user_id = auth.uid()
    )
);

CREATE POLICY "users_create_own_video_sessions"
ON public.video_sessions
FOR INSERT
TO authenticated
WITH CHECK (host_id = auth.uid());

CREATE POLICY "hosts_manage_own_video_sessions"
ON public.video_sessions
FOR UPDATE
TO authenticated
USING (host_id = auth.uid());

-- Video participants policies
CREATE POLICY "users_view_session_participants"
ON public.video_participants
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.video_sessions vs
        WHERE vs.id = video_participants.session_id
        AND (vs.host_id = auth.uid() OR video_participants.user_id = auth.uid())
    )
);

CREATE POLICY "users_join_video_sessions"
ON public.video_participants
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_update_own_participant_state"
ON public.video_participants
FOR UPDATE
TO authenticated
USING (user_id = auth.uid());

-- Device sync policies
CREATE POLICY "users_manage_own_device_sync"
ON public.device_sync_states
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ============================================================================
-- STEP 6: TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- ============================================================================

CREATE TRIGGER update_video_sessions_updated_at
BEFORE UPDATE ON public.video_sessions
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================================
-- STEP 7: HELPER FUNCTIONS
-- ============================================================================

-- Function to get active video sessions for a user
CREATE OR REPLACE FUNCTION public.get_active_video_sessions(user_uuid UUID)
RETURNS TABLE (
    session_id UUID,
    room_name TEXT,
    host_name TEXT,
    participant_count BIGINT,
    started_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT 
        vs.id,
        vs.room_name,
        up.full_name,
        COUNT(vp.id),
        vs.started_at
    FROM public.video_sessions vs
    JOIN public.user_profiles up ON vs.host_id = up.id
    LEFT JOIN public.video_participants vp ON vs.id = vp.session_id
    WHERE vs.status = 'active'::public.video_session_status
    AND (vs.host_id = user_uuid OR EXISTS (
        SELECT 1 FROM public.video_participants vp2
        WHERE vp2.session_id = vs.id AND vp2.user_id = user_uuid
    ))
    GROUP BY vs.id, vs.room_name, up.full_name, vs.started_at
    ORDER BY vs.started_at DESC;
$$;

-- Function to sync conversation state across devices
CREATE OR REPLACE FUNCTION public.sync_conversation_state(
    conversation_uuid UUID,
    device_uuid TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    sync_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'conversation_id', c.id,
        'unread_count', c.unread_count,
        'last_message', c.last_message_text,
        'last_message_at', c.last_message_at,
        'platform', c.platform,
        'participants', (
            SELECT jsonb_agg(jsonb_build_object(
                'id', up.id,
                'name', up.full_name,
                'avatar', up.avatar_url
            ))
            FROM public.user_profiles up
            WHERE up.id = c.user_id OR up.id = c.contact_id
        )
    )
    INTO sync_result
    FROM public.conversations c
    WHERE c.id = conversation_uuid;
    
    UPDATE public.device_sync_states
    SET 
        last_sync_at = CURRENT_TIMESTAMP,
        sync_status = 'synced'::public.device_sync_status
    WHERE device_id = device_uuid;
    
    RETURN sync_result;
END;
$$;

-- ============================================================================
-- STEP 8: MOCK DATA (REFERENCES EXISTING USERS)
-- ============================================================================

DO $$
DECLARE
    existing_user_id UUID;
    existing_account_id UUID;
    existing_contact_id UUID;
    video_session_id UUID := gen_random_uuid();
    conversation_id UUID;
BEGIN
    -- Get existing user and account IDs from schema
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    SELECT id INTO existing_account_id FROM public.accounts LIMIT 1;
    SELECT id INTO existing_contact_id FROM public.contacts LIMIT 1;
    
    IF existing_user_id IS NULL OR existing_account_id IS NULL THEN
        RAISE NOTICE 'No existing users or accounts found. Skipping mock data generation.';
        RETURN;
    END IF;
    
    -- Create sample WhatsApp conversation
    INSERT INTO public.conversations (
        id,
        account_id,
        user_id,
        contact_id,
        conversation_name,
        platform,
        whatsapp_contact_id,
        is_group,
        participant_count,
        last_message_text,
        last_message_at
    ) VALUES (
        gen_random_uuid(),
        existing_account_id,
        existing_user_id,
        existing_contact_id,
        'WhatsApp Contact',
        'whatsapp'::public.message_platform,
        'whatsapp:+1234567890',
        false,
        2,
        'Hey, how are you?',
        CURRENT_TIMESTAMP - INTERVAL '5 minutes'
    ) RETURNING id INTO conversation_id;
    
    -- Create sample WhatsApp messages
    INSERT INTO public.messages (
        conversation_id,
        account_id,
        user_id,
        from_number,
        to_number,
        body,
        platform,
        status,
        direction,
        sent_at
    ) VALUES
    (
        conversation_id,
        existing_account_id,
        existing_user_id,
        '+1234567890',
        '+0987654321',
        'Hey, how are you?',
        'whatsapp'::public.message_platform,
        'delivered'::public.message_status,
        'incoming',
        CURRENT_TIMESTAMP - INTERVAL '5 minutes'
    ),
    (
        conversation_id,
        existing_account_id,
        existing_user_id,
        '+0987654321',
        '+1234567890',
        'I am good! Thanks for asking 😊',
        'whatsapp'::public.message_platform,
        'delivered'::public.message_status,
        'outgoing',
        CURRENT_TIMESTAMP - INTERVAL '3 minutes'
    );
    
    -- Create sample video session
    INSERT INTO public.video_sessions (
        id,
        account_id,
        room_name,
        host_id,
        status,
        scheduled_at,
        max_participants,
        is_recording
    ) VALUES (
        video_session_id,
        existing_account_id,
        'Team Standup',
        existing_user_id,
        'scheduled'::public.video_session_status,
        CURRENT_TIMESTAMP + INTERVAL '1 hour',
        10,
        true
    );
    
    -- Add host as participant
    INSERT INTO public.video_participants (
        session_id,
        user_id,
        display_name,
        is_audio_enabled,
        is_video_enabled
    ) VALUES (
        video_session_id,
        existing_user_id,
        'Host User',
        true,
        true
    );
    
    -- Create device sync state
    INSERT INTO public.device_sync_states (
        user_id,
        device_id,
        device_name,
        sync_status,
        unread_count
    ) VALUES (
        existing_user_id,
        'device-web-001',
        'Chrome Browser',
        'synced'::public.device_sync_status,
        3
    );
    
    RAISE NOTICE 'Mock data created successfully for Twilio/WhatsApp integration';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data creation failed: %', SQLERRM;
END $$;