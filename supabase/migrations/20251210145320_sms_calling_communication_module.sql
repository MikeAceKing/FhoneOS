-- =====================================================
-- FhoneOS SMS & Calling Communication Module Migration
-- =====================================================
-- Purpose: Complete SMS messaging and calling functionality
-- Status: NEW_MODULE (references existing user_profiles, accounts, phone_numbers)
-- Timestamp: 2025-12-10 14:53:20

-- =====================================================
-- 1. ENUMS (Message & Call Types)
-- =====================================================

CREATE TYPE message_status AS ENUM (
    'sending',
    'sent',
    'delivered',
    'read',
    'failed'
);

CREATE TYPE call_status AS ENUM (
    'ringing',
    'in_progress',
    'completed',
    'missed',
    'declined',
    'failed',
    'voicemail'
);

CREATE TYPE call_type AS ENUM (
    'incoming',
    'outgoing',
    'missed'
);

CREATE TYPE attachment_type AS ENUM (
    'image',
    'video',
    'audio',
    'document',
    'location'
);

-- =====================================================
-- 2. CONTACTS TABLE
-- =====================================================

CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    
    -- Contact information
    full_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    email TEXT,
    avatar_url TEXT,
    
    -- Organization
    is_favorite BOOLEAN DEFAULT false,
    tags TEXT[] DEFAULT '{}',
    notes TEXT,
    
    -- Sync metadata
    device_contact_id TEXT,
    last_synced_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(user_id, phone_number)
);

CREATE INDEX idx_contacts_user_id ON contacts(user_id);
CREATE INDEX idx_contacts_account_id ON contacts(account_id);
CREATE INDEX idx_contacts_phone_number ON contacts(phone_number);
CREATE INDEX idx_contacts_is_favorite ON contacts(is_favorite) WHERE is_favorite = true;

-- =====================================================
-- 3. CONVERSATIONS TABLE
-- =====================================================

CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    phone_number_id UUID REFERENCES phone_numbers(id) ON DELETE SET NULL,
    
    -- Conversation details
    contact_id UUID REFERENCES contacts(id) ON DELETE SET NULL,
    conversation_name TEXT,
    is_group BOOLEAN DEFAULT false,
    participant_count INT DEFAULT 1,
    
    -- Message tracking
    last_message_text TEXT,
    last_message_at TIMESTAMPTZ,
    unread_count INT DEFAULT 0,
    
    -- Status
    is_archived BOOLEAN DEFAULT false,
    is_muted BOOLEAN DEFAULT false,
    is_pinned BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_conversations_user_id ON conversations(user_id);
CREATE INDEX idx_conversations_account_id ON conversations(account_id);
CREATE INDEX idx_conversations_contact_id ON conversations(contact_id);
CREATE INDEX idx_conversations_last_message_at ON conversations(last_message_at DESC);
CREATE INDEX idx_conversations_unread ON conversations(unread_count) WHERE unread_count > 0;

-- =====================================================
-- 4. MESSAGES TABLE
-- =====================================================

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    phone_number_id UUID REFERENCES phone_numbers(id) ON DELETE SET NULL,
    
    -- Message content
    body TEXT NOT NULL,
    direction TEXT NOT NULL CHECK (direction IN ('incoming', 'outgoing')),
    status message_status DEFAULT 'sending',
    
    -- Message metadata
    from_number TEXT NOT NULL,
    to_number TEXT NOT NULL,
    
    -- External references (Twilio)
    external_message_id TEXT,
    error_code TEXT,
    error_message TEXT,
    
    -- Timestamps
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    delivered_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_user_id ON messages(user_id);
CREATE INDEX idx_messages_account_id ON messages(account_id);
CREATE INDEX idx_messages_sent_at ON messages(sent_at DESC);
CREATE INDEX idx_messages_status ON messages(status);
CREATE INDEX idx_messages_external_id ON messages(external_message_id);

-- =====================================================
-- 5. MESSAGE ATTACHMENTS TABLE
-- =====================================================

CREATE TABLE message_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    
    -- Attachment details
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size BIGINT,
    mime_type TEXT,
    attachment_type attachment_type NOT NULL,
    
    -- Storage reference
    storage_path TEXT,
    thumbnail_url TEXT,
    
    -- Metadata
    duration_seconds INT,
    width INT,
    height INT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_message_attachments_message_id ON message_attachments(message_id);

-- =====================================================
-- 6. CALLS TABLE
-- =====================================================

CREATE TABLE calls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    phone_number_id UUID REFERENCES phone_numbers(id) ON DELETE SET NULL,
    contact_id UUID REFERENCES contacts(id) ON DELETE SET NULL,
    
    -- Call details
    call_type call_type NOT NULL,
    call_status call_status DEFAULT 'ringing',
    from_number TEXT NOT NULL,
    to_number TEXT NOT NULL,
    
    -- Call metrics
    duration_seconds INT DEFAULT 0,
    network_quality DECIMAL(3,2),
    
    -- External references (Twilio)
    external_call_id TEXT,
    conference_sid TEXT,
    
    -- Recording
    is_recorded BOOLEAN DEFAULT false,
    recording_url TEXT,
    
    -- Timestamps
    started_at TIMESTAMPTZ DEFAULT NOW(),
    answered_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_calls_user_id ON calls(user_id);
CREATE INDEX idx_calls_account_id ON calls(account_id);
CREATE INDEX idx_calls_contact_id ON calls(contact_id);
CREATE INDEX idx_calls_started_at ON calls(started_at DESC);
CREATE INDEX idx_calls_call_type ON calls(call_type);
CREATE INDEX idx_calls_call_status ON calls(call_status);

-- =====================================================
-- 7. CALL PARTICIPANTS TABLE (for conference calls)
-- =====================================================

CREATE TABLE call_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    call_id UUID NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
    contact_id UUID REFERENCES contacts(id) ON DELETE SET NULL,
    
    -- Participant details
    phone_number TEXT NOT NULL,
    display_name TEXT,
    
    -- Participant status
    is_muted BOOLEAN DEFAULT false,
    is_on_hold BOOLEAN DEFAULT false,
    
    -- Timestamps
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    left_at TIMESTAMPTZ
);

CREATE INDEX idx_call_participants_call_id ON call_participants(call_id);
CREATE INDEX idx_call_participants_contact_id ON call_participants(contact_id);

-- =====================================================
-- 8. VOICEMAILS TABLE
-- =====================================================

CREATE TABLE voicemails (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    call_id UUID REFERENCES calls(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    contact_id UUID REFERENCES contacts(id) ON DELETE SET NULL,
    
    -- Voicemail content
    from_number TEXT NOT NULL,
    duration_seconds INT NOT NULL,
    audio_url TEXT NOT NULL,
    transcription TEXT,
    
    -- Status
    is_read BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    
    -- External reference
    external_recording_id TEXT,
    
    -- Timestamps
    received_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_voicemails_user_id ON voicemails(user_id);
CREATE INDEX idx_voicemails_account_id ON voicemails(account_id);
CREATE INDEX idx_voicemails_call_id ON voicemails(call_id);
CREATE INDEX idx_voicemails_received_at ON voicemails(received_at DESC);
CREATE INDEX idx_voicemails_is_read ON voicemails(is_read) WHERE is_read = false;

-- =====================================================
-- 9. CALL RECORDINGS TABLE
-- =====================================================

CREATE TABLE call_recordings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    call_id UUID NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    
    -- Recording details
    recording_url TEXT NOT NULL,
    duration_seconds INT NOT NULL,
    file_size BIGINT,
    
    -- Storage
    storage_path TEXT,
    
    -- External reference
    external_recording_id TEXT,
    
    -- Timestamps
    recorded_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_call_recordings_call_id ON call_recordings(call_id);
CREATE INDEX idx_call_recordings_user_id ON call_recordings(user_id);

-- =====================================================
-- 10. ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE calls ENABLE ROW LEVEL SECURITY;
ALTER TABLE call_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE voicemails ENABLE ROW LEVEL SECURITY;
ALTER TABLE call_recordings ENABLE ROW LEVEL SECURITY;

-- Contacts policies
CREATE POLICY "Users can view own contacts"
    ON contacts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own contacts"
    ON contacts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own contacts"
    ON contacts FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own contacts"
    ON contacts FOR DELETE
    USING (auth.uid() = user_id);

-- Conversations policies
CREATE POLICY "Users can view own conversations"
    ON conversations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own conversations"
    ON conversations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own conversations"
    ON conversations FOR UPDATE
    USING (auth.uid() = user_id);

-- Messages policies
CREATE POLICY "Users can view own messages"
    ON messages FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own messages"
    ON messages FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own messages"
    ON messages FOR UPDATE
    USING (auth.uid() = user_id);

-- Message attachments policies
CREATE POLICY "Users can view attachments of own messages"
    ON message_attachments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM messages
            WHERE messages.id = message_attachments.message_id
            AND messages.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert attachments to own messages"
    ON message_attachments FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM messages
            WHERE messages.id = message_attachments.message_id
            AND messages.user_id = auth.uid()
        )
    );

-- Calls policies
CREATE POLICY "Users can view own calls"
    ON calls FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own calls"
    ON calls FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own calls"
    ON calls FOR UPDATE
    USING (auth.uid() = user_id);

-- Call participants policies
CREATE POLICY "Users can view participants of own calls"
    ON call_participants FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM calls
            WHERE calls.id = call_participants.call_id
            AND calls.user_id = auth.uid()
        )
    );

-- Voicemails policies
CREATE POLICY "Users can view own voicemails"
    ON voicemails FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own voicemails"
    ON voicemails FOR UPDATE
    USING (auth.uid() = user_id);

-- Call recordings policies
CREATE POLICY "Users can view own call recordings"
    ON call_recordings FOR SELECT
    USING (auth.uid() = user_id);

-- =====================================================
-- 11. TRIGGERS (Auto-update timestamps)
-- =====================================================

CREATE TRIGGER update_contacts_updated_at
    BEFORE UPDATE ON contacts
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER update_conversations_updated_at
    BEFORE UPDATE ON conversations
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- =====================================================
-- 12. FUNCTIONS (Helper functions)
-- =====================================================

-- Function to update conversation metadata when message is sent
CREATE OR REPLACE FUNCTION update_conversation_on_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations
    SET 
        last_message_text = NEW.body,
        last_message_at = NEW.sent_at,
        unread_count = CASE 
            WHEN NEW.direction = 'incoming' THEN unread_count + 1
            ELSE unread_count
        END,
        updated_at = NOW()
    WHERE id = NEW.conversation_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_conversation_on_message
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_on_message();

-- Function to mark conversation messages as read
CREATE OR REPLACE FUNCTION mark_conversation_as_read(conversation_uuid UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE conversations
    SET unread_count = 0, updated_at = NOW()
    WHERE id = conversation_uuid AND user_id = auth.uid();
    
    UPDATE messages
    SET status = 'read', read_at = NOW()
    WHERE conversation_id = conversation_uuid 
    AND user_id = auth.uid()
    AND direction = 'incoming'
    AND status != 'read';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get conversation statistics
CREATE OR REPLACE FUNCTION get_conversation_statistics(account_uuid UUID)
RETURNS TABLE (
    total_conversations BIGINT,
    unread_conversations BIGINT,
    total_messages BIGINT,
    messages_today BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(DISTINCT c.id) as total_conversations,
        COUNT(DISTINCT c.id) FILTER (WHERE c.unread_count > 0) as unread_conversations,
        COUNT(m.id) as total_messages,
        COUNT(m.id) FILTER (WHERE m.sent_at >= CURRENT_DATE) as messages_today
    FROM conversations c
    LEFT JOIN messages m ON m.conversation_id = c.id
    WHERE c.account_id = account_uuid AND c.user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 13. COMMENTS (Documentation)
-- =====================================================

COMMENT ON TABLE contacts IS 'Stores user contacts synced from device or added manually';
COMMENT ON TABLE conversations IS 'SMS conversation threads with contacts';
COMMENT ON TABLE messages IS 'Individual SMS messages within conversations';
COMMENT ON TABLE message_attachments IS 'Media attachments for MMS messages';
COMMENT ON TABLE calls IS 'Call history and active calls';
COMMENT ON TABLE call_participants IS 'Participants in conference calls';
COMMENT ON TABLE voicemails IS 'Received voicemail messages';
COMMENT ON TABLE call_recordings IS 'Recorded call audio files';

-- =====================================================
-- Migration Complete
-- =====================================================