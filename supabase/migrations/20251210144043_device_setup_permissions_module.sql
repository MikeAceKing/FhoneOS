-- =====================================================
-- FhoneOS Device Setup & Permissions Module
-- =====================================================
-- Purpose: Track device registrations and permission grants for FhoneOS wizard

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- CUSTOM TYPES
-- =====================================================

-- Permission status enum
CREATE TYPE permission_status AS ENUM (
  'not_requested',
  'granted',
  'denied',
  'restricted'
);

-- Device setup step enum
CREATE TYPE setup_step AS ENUM (
  'welcome',
  'device_registration',
  'permissions',
  'twilio_setup',
  'contact_backup',
  'sms_backup',
  'notification_setup',
  'file_access',
  'cloud_sync',
  'completed'
);

-- =====================================================
-- TABLES
-- =====================================================

-- Device registrations table
CREATE TABLE device_registrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL UNIQUE,
  device_model TEXT,
  device_manufacturer TEXT,
  android_version TEXT,
  fcm_token TEXT,
  twilio_number TEXT,
  current_setup_step setup_step DEFAULT 'welcome',
  setup_completed BOOLEAN DEFAULT FALSE,
  setup_started_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  setup_completed_at TIMESTAMPTZ,
  is_launcher_default BOOLEAN DEFAULT FALSE,
  is_sms_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT unique_user_device UNIQUE(user_id, device_id)
);

-- User permissions table
CREATE TABLE user_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  device_id UUID NOT NULL REFERENCES device_registrations(id) ON DELETE CASCADE,
  
  -- Essential permissions
  phone_permission permission_status DEFAULT 'not_requested',
  sms_permission permission_status DEFAULT 'not_requested',
  contacts_permission permission_status DEFAULT 'not_requested',
  
  -- Media permissions
  camera_permission permission_status DEFAULT 'not_requested',
  microphone_permission permission_status DEFAULT 'not_requested',
  storage_permission permission_status DEFAULT 'not_requested',
  
  -- Location permissions
  location_precise permission_status DEFAULT 'not_requested',
  location_approximate permission_status DEFAULT 'not_requested',
  location_background permission_status DEFAULT 'not_requested',
  
  -- Optional permissions
  calendar_permission permission_status DEFAULT 'not_requested',
  notifications_permission permission_status DEFAULT 'not_requested',
  biometrics_permission permission_status DEFAULT 'not_requested',
  call_logs_permission permission_status DEFAULT 'not_requested',
  notification_listener_enabled BOOLEAN DEFAULT FALSE,
  
  -- Usage tracking
  last_permission_request_at TIMESTAMPTZ,
  permission_requests_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT unique_user_device_permissions UNIQUE(user_id, device_id)
);

-- Permission history (audit log)
CREATE TABLE permission_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  device_id UUID NOT NULL REFERENCES device_registrations(id) ON DELETE CASCADE,
  permission_name TEXT NOT NULL,
  previous_status permission_status,
  new_status permission_status NOT NULL,
  requested_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  context TEXT,
  usage_frequency INTEGER DEFAULT 0
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX idx_device_registrations_user_id ON device_registrations(user_id);
CREATE INDEX idx_device_registrations_device_id ON device_registrations(device_id);
CREATE INDEX idx_device_registrations_setup_step ON device_registrations(current_setup_step);
CREATE INDEX idx_user_permissions_user_id ON user_permissions(user_id);
CREATE INDEX idx_user_permissions_device_id ON user_permissions(device_id);
CREATE INDEX idx_permission_history_user_device ON permission_history(user_id, device_id);
CREATE INDEX idx_permission_history_requested_at ON permission_history(requested_at DESC);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE device_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE permission_history ENABLE ROW LEVEL SECURITY;

-- Device registrations policies
CREATE POLICY "users_manage_own_devices"
  ON device_registrations FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- User permissions policies
CREATE POLICY "users_manage_own_permissions"
  ON user_permissions FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Permission history policies
CREATE POLICY "users_view_own_permission_history"
  ON permission_history FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "users_insert_own_permission_history"
  ON permission_history FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Updated at trigger function
CREATE OR REPLACE FUNCTION update_device_registration_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER device_registration_updated
  BEFORE UPDATE ON device_registrations
  FOR EACH ROW
  EXECUTE FUNCTION update_device_registration_timestamp();

CREATE TRIGGER user_permissions_updated
  BEFORE UPDATE ON user_permissions
  FOR EACH ROW
  EXECUTE FUNCTION update_device_registration_timestamp();

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to get user's device setup progress
CREATE OR REPLACE FUNCTION get_device_setup_progress(p_user_id UUID)
RETURNS TABLE (
  device_id UUID,
  device_model TEXT,
  current_step setup_step,
  progress_percentage INTEGER,
  setup_completed BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    dr.id,
    dr.device_model,
    dr.current_setup_step,
    CASE dr.current_setup_step
      WHEN 'welcome' THEN 0
      WHEN 'device_registration' THEN 10
      WHEN 'permissions' THEN 30
      WHEN 'twilio_setup' THEN 40
      WHEN 'contact_backup' THEN 50
      WHEN 'sms_backup' THEN 60
      WHEN 'notification_setup' THEN 70
      WHEN 'file_access' THEN 80
      WHEN 'cloud_sync' THEN 90
      WHEN 'completed' THEN 100
      ELSE 0
    END AS progress_percentage,
    dr.setup_completed
  FROM device_registrations dr
  WHERE dr.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get permission summary
CREATE OR REPLACE FUNCTION get_permission_summary(p_user_id UUID, p_device_id UUID)
RETURNS JSONB AS $$
DECLARE
  result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'essential', jsonb_build_object(
      'phone', phone_permission,
      'sms', sms_permission,
      'contacts', contacts_permission
    ),
    'media', jsonb_build_object(
      'camera', camera_permission,
      'microphone', microphone_permission,
      'storage', storage_permission
    ),
    'location', jsonb_build_object(
      'precise', location_precise,
      'approximate', location_approximate,
      'background', location_background
    ),
    'optional', jsonb_build_object(
      'calendar', calendar_permission,
      'notifications', notifications_permission,
      'biometrics', biometrics_permission,
      'call_logs', call_logs_permission
    ),
    'notification_listener_enabled', notification_listener_enabled,
    'last_request', last_permission_request_at,
    'request_count', permission_requests_count
  ) INTO result
  FROM user_permissions
  WHERE user_id = p_user_id AND device_id = p_device_id;
  
  RETURN COALESCE(result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- MOCK DATA
-- =====================================================

-- Insert mock device registrations (using existing user_profiles)
INSERT INTO device_registrations (
  user_id,
  device_id,
  device_model,
  device_manufacturer,
  android_version,
  fcm_token,
  twilio_number,
  current_setup_step,
  setup_completed,
  is_launcher_default,
  is_sms_default
) VALUES
  (
    '0d94605d-f5e6-4051-9d0d-b486ab051082',
    'device-demo-001',
    'Pixel 8 Pro',
    'Google',
    '14.0',
    'fcm-token-demo-xyz123',
    '+1-555-0123',
    'completed',
    TRUE,
    TRUE,
    TRUE
  ),
  (
    '072ad3a3-b713-4b3d-88ce-ca173c18145f',
    'device-michael-001',
    'Galaxy S24',
    'Samsung',
    '14.0',
    'fcm-token-michael-abc456',
    '+1-555-0456',
    'cloud_sync',
    FALSE,
    TRUE,
    TRUE
  );

-- Insert mock permissions (using device_registrations)
INSERT INTO user_permissions (
  user_id,
  device_id,
  phone_permission,
  sms_permission,
  contacts_permission,
  camera_permission,
  microphone_permission,
  storage_permission,
  location_precise,
  notifications_permission,
  notification_listener_enabled,
  permission_requests_count
) VALUES
  (
    '0d94605d-f5e6-4051-9d0d-b486ab051082',
    (SELECT id FROM device_registrations WHERE device_id = 'device-demo-001'),
    'granted',
    'granted',
    'granted',
    'granted',
    'granted',
    'granted',
    'granted',
    'granted',
    TRUE,
    8
  ),
  (
    '072ad3a3-b713-4b3d-88ce-ca173c18145f',
    (SELECT id FROM device_registrations WHERE device_id = 'device-michael-001'),
    'granted',
    'granted',
    'granted',
    'granted',
    'denied',
    'granted',
    'restricted',
    'granted',
    FALSE,
    5
  );

-- Insert permission history
INSERT INTO permission_history (
  user_id,
  device_id,
  permission_name,
  previous_status,
  new_status,
  context,
  usage_frequency
) VALUES
  (
    '0d94605d-f5e6-4051-9d0d-b486ab051082',
    (SELECT id FROM device_registrations WHERE device_id = 'device-demo-001'),
    'camera',
    'not_requested',
    'granted',
    'Setup wizard - camera permission for profile photos',
    25
  ),
  (
    '072ad3a3-b713-4b3d-88ce-ca173c18145f',
    (SELECT id FROM device_registrations WHERE device_id = 'device-michael-001'),
    'microphone',
    'granted',
    'denied',
    'User revoked permission in Permission Management Center',
    0
  );

COMMENT ON TABLE device_registrations IS 'Tracks device registrations for FhoneOS setup wizard';
COMMENT ON TABLE user_permissions IS 'Stores permission states for each user device';
COMMENT ON TABLE permission_history IS 'Audit log of permission changes';