-- Location: supabase/migrations/20251210013808_fhoneos_tenant_architecture.sql
-- Schema Analysis: Existing user_profiles table with user_role enum
-- Integration Type: Addition - Multi-tenant architecture for FhoneOS
-- Dependencies: public.user_profiles, public.user_role
-- Module: Tenant Model (accounts, subscriptions, add-ons, phone numbers)

-- ====================================================================================================
-- STEP 1: TYPES (ENUMs)
-- ====================================================================================================

-- Account member role types
CREATE TYPE public.account_role AS ENUM ('owner', 'admin', 'member');

-- Subscription status types
CREATE TYPE public.subscription_status AS ENUM ('active', 'trialing', 'past_due', 'canceled', 'incomplete');

-- Phone number status types
CREATE TYPE public.phone_status AS ENUM ('active', 'pending', 'released', 'porting');

-- Add-on types for categorization
CREATE TYPE public.addon_type AS ENUM ('phone_number', 'integration', 'feature', 'storage');

-- ====================================================================================================
-- STEP 2: CORE TABLES (No foreign keys)
-- ====================================================================================================

-- Accounts (tenant organizations/companies)
CREATE TABLE public.accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    billing_email TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Plans (subscription plans catalog)
CREATE TABLE public.plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10,2),
    price_yearly DECIMAL(10,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Add-ons catalog (available add-ons for purchase)
CREATE TABLE public.addons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    type public.addon_type NOT NULL,
    price DECIMAL(10,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Apps catalog (available applications in FhoneOS)
CREATE TABLE public.apps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    icon_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================================================
-- STEP 3: DEPENDENT TABLES (With foreign keys to existing and new core tables)
-- ====================================================================================================

-- Account users (junction table for multi-tenant membership)
CREATE TABLE public.account_users (
    account_id UUID REFERENCES public.accounts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    role public.account_role NOT NULL DEFAULT 'member'::public.account_role,
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (account_id, user_id)
);

-- Account subscriptions (active subscriptions per account)
CREATE TABLE public.account_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES public.plans(id),
    status public.subscription_status NOT NULL DEFAULT 'active'::public.subscription_status,
    started_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ends_at TIMESTAMPTZ,
    trial_ends_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Account add-ons (purchased add-ons per account)
CREATE TABLE public.account_addons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    addon_id UUID NOT NULL REFERENCES public.addons(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    purchased_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ,
    UNIQUE (account_id, addon_id)
);

-- Phone numbers (virtual phone numbers per account)
CREATE TABLE public.phone_numbers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    e164_number TEXT NOT NULL UNIQUE,
    country_code TEXT NOT NULL,
    provider TEXT NOT NULL DEFAULT 'twilio',
    status public.phone_status NOT NULL DEFAULT 'active'::public.phone_status,
    capabilities JSONB DEFAULT '{"voice": true, "sms": true}'::JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    released_at TIMESTAMPTZ
);

-- Account app access (which apps each account can access)
CREATE TABLE public.account_app_access (
    account_id UUID REFERENCES public.accounts(id) ON DELETE CASCADE,
    app_id UUID REFERENCES public.apps(id) ON DELETE CASCADE,
    source TEXT NOT NULL DEFAULT 'base_plan',
    granted_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (account_id, app_id)
);

-- ====================================================================================================
-- STEP 4: INDEXES
-- ====================================================================================================

-- Account indexes
CREATE INDEX idx_accounts_slug ON public.accounts(slug);
CREATE INDEX idx_accounts_is_active ON public.accounts(is_active);

-- Account users indexes
CREATE INDEX idx_account_users_user_id ON public.account_users(user_id);
CREATE INDEX idx_account_users_account_id ON public.account_users(account_id);
CREATE INDEX idx_account_users_role ON public.account_users(role);

-- Subscription indexes
CREATE INDEX idx_account_subscriptions_account_id ON public.account_subscriptions(account_id);
CREATE INDEX idx_account_subscriptions_status ON public.account_subscriptions(status);
CREATE INDEX idx_account_subscriptions_plan_id ON public.account_subscriptions(plan_id);

-- Add-on indexes
CREATE INDEX idx_account_addons_account_id ON public.account_addons(account_id);
CREATE INDEX idx_account_addons_addon_id ON public.account_addons(addon_id);

-- Phone number indexes
CREATE INDEX idx_phone_numbers_account_id ON public.phone_numbers(account_id);
CREATE INDEX idx_phone_numbers_status ON public.phone_numbers(status);
CREATE INDEX idx_phone_numbers_e164 ON public.phone_numbers(e164_number);

-- App access indexes
CREATE INDEX idx_account_app_access_account_id ON public.account_app_access(account_id);
CREATE INDEX idx_account_app_access_app_id ON public.account_app_access(app_id);

-- ====================================================================================================
-- STEP 5: FUNCTIONS (BEFORE RLS POLICIES)
-- ====================================================================================================

-- Function: Check if user is member of an account
CREATE OR REPLACE FUNCTION public.is_account_member(account_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.account_users au
    WHERE au.account_id = account_uuid
    AND au.user_id = auth.uid()
)
$$;

-- Function: Check if user is admin or owner of an account
CREATE OR REPLACE FUNCTION public.is_account_admin(account_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.account_users au
    WHERE au.account_id = account_uuid
    AND au.user_id = auth.uid()
    AND au.role IN ('admin', 'owner')
)
$$;

-- Function: Get user accounts
CREATE OR REPLACE FUNCTION public.get_user_accounts()
RETURNS TABLE(
    account_id UUID,
    account_name TEXT,
    account_slug TEXT,
    user_role TEXT,
    joined_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    a.id,
    a.name,
    a.slug,
    au.role::TEXT,
    au.joined_at
FROM public.accounts a
JOIN public.account_users au ON a.id = au.account_id
WHERE au.user_id = auth.uid()
AND a.is_active = true
ORDER BY au.joined_at DESC
$$;

-- Function: Handle updated_at timestamp for accounts
CREATE OR REPLACE FUNCTION public.handle_account_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- ====================================================================================================
-- STEP 6: ENABLE RLS
-- ====================================================================================================

ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_addons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.phone_numbers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_app_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.apps ENABLE ROW LEVEL SECURITY;

-- ====================================================================================================
-- STEP 7: RLS POLICIES
-- ====================================================================================================

-- Accounts: Users can view/manage accounts they are members of
CREATE POLICY "users_view_own_accounts"
ON public.accounts
FOR SELECT
TO authenticated
USING (public.is_account_member(id));

CREATE POLICY "users_manage_own_accounts"
ON public.accounts
FOR ALL
TO authenticated
USING (public.is_account_admin(id))
WITH CHECK (public.is_account_admin(id));

-- Account users: Members can view, admins can manage
CREATE POLICY "users_view_account_members"
ON public.account_users
FOR SELECT
TO authenticated
USING (public.is_account_member(account_id));

CREATE POLICY "admins_manage_account_members"
ON public.account_users
FOR ALL
TO authenticated
USING (public.is_account_admin(account_id))
WITH CHECK (public.is_account_admin(account_id));

-- Subscriptions: Members can view, admins can manage
CREATE POLICY "users_view_account_subscriptions"
ON public.account_subscriptions
FOR SELECT
TO authenticated
USING (public.is_account_member(account_id));

CREATE POLICY "admins_manage_subscriptions"
ON public.account_subscriptions
FOR ALL
TO authenticated
USING (public.is_account_admin(account_id))
WITH CHECK (public.is_account_admin(account_id));

-- Add-ons: Members can view, admins can manage
CREATE POLICY "users_view_account_addons"
ON public.account_addons
FOR SELECT
TO authenticated
USING (public.is_account_member(account_id));

CREATE POLICY "admins_manage_addons"
ON public.account_addons
FOR ALL
TO authenticated
USING (public.is_account_admin(account_id))
WITH CHECK (public.is_account_admin(account_id));

-- Phone numbers: Members can view, admins can manage
CREATE POLICY "users_view_account_phone_numbers"
ON public.phone_numbers
FOR SELECT
TO authenticated
USING (public.is_account_member(account_id));

CREATE POLICY "admins_manage_phone_numbers"
ON public.phone_numbers
FOR ALL
TO authenticated
USING (public.is_account_admin(account_id))
WITH CHECK (public.is_account_admin(account_id));

-- App access: Members can view
CREATE POLICY "users_view_account_app_access"
ON public.account_app_access
FOR SELECT
TO authenticated
USING (public.is_account_member(account_id));

-- Plans: Public read-only
CREATE POLICY "public_view_plans"
ON public.plans
FOR SELECT
TO public
USING (is_active = true);

-- Add-ons: Public read-only
CREATE POLICY "public_view_addons"
ON public.addons
FOR SELECT
TO public
USING (is_active = true);

-- Apps: Public read-only
CREATE POLICY "public_view_apps"
ON public.apps
FOR SELECT
TO public
USING (is_active = true);

-- ====================================================================================================
-- STEP 8: TRIGGERS
-- ====================================================================================================

-- Trigger: Update accounts.updated_at on modification
CREATE TRIGGER on_account_updated
BEFORE UPDATE ON public.accounts
FOR EACH ROW
EXECUTE FUNCTION public.handle_account_updated_at();

-- Trigger: Update subscriptions.updated_at on modification
CREATE TRIGGER on_subscription_updated
BEFORE UPDATE ON public.account_subscriptions
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- ====================================================================================================
-- STEP 9: MOCK DATA
-- ====================================================================================================

DO $$
DECLARE
    -- Existing user IDs from user_profiles
    admin_user_id UUID;
    regular_user_id UUID;
    
    -- New account IDs
    acme_account_id UUID := gen_random_uuid();
    startup_account_id UUID := gen_random_uuid();
    
    -- Plan IDs
    basic_plan_id UUID := gen_random_uuid();
    pro_plan_id UUID := gen_random_uuid();
    enterprise_plan_id UUID := gen_random_uuid();
    
    -- Add-on IDs
    phone_addon_id UUID := gen_random_uuid();
    sms_addon_id UUID := gen_random_uuid();
    storage_addon_id UUID := gen_random_uuid();
    
    -- App IDs
    phone_app_id UUID := gen_random_uuid();
    messages_app_id UUID := gen_random_uuid();
    contacts_app_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user IDs
    SELECT id INTO admin_user_id FROM public.user_profiles WHERE role = 'admin'::public.user_role LIMIT 1;
    SELECT id INTO regular_user_id FROM public.user_profiles WHERE role = 'user'::public.user_role LIMIT 1;
    
    -- Create plans
    INSERT INTO public.plans (id, code, name, description, price_monthly, price_yearly, is_active) VALUES
        (basic_plan_id, 'basic', 'Basic Plan', 'Essential features for individuals', 9.99, 99.99, true),
        (pro_plan_id, 'pro', 'Pro Plan', 'Advanced features for small teams', 29.99, 299.99, true),
        (enterprise_plan_id, 'enterprise', 'Enterprise Plan', 'Full features for large organizations', 99.99, 999.99, true);
    
    -- Create add-ons
    INSERT INTO public.addons (id, code, name, description, type, price, is_active) VALUES
        (phone_addon_id, 'phone_number', 'Virtual Phone Number', 'Get a dedicated phone number', 'phone_number'::public.addon_type, 5.00, true),
        (sms_addon_id, 'sms_credits', 'SMS Credits (1000)', 'Send SMS messages', 'integration'::public.addon_type, 10.00, true),
        (storage_addon_id, 'extra_storage', 'Extra Storage (10GB)', 'Additional cloud storage', 'storage'::public.addon_type, 3.00, true);
    
    -- Create apps
    INSERT INTO public.apps (id, code, name, description, icon_url, is_active) VALUES
        (phone_app_id, 'phone', 'Phone', 'Make and receive calls', 'https://cdn.example.com/icons/phone.svg', true),
        (messages_app_id, 'messages', 'Messages', 'Send and receive SMS/MMS', 'https://cdn.example.com/icons/messages.svg', true),
        (contacts_app_id, 'contacts', 'Contacts', 'Manage your contacts', 'https://cdn.example.com/icons/contacts.svg', true);
    
    -- Create accounts
    INSERT INTO public.accounts (id, name, slug, billing_email, is_active) VALUES
        (acme_account_id, 'Acme Corporation', 'acme-corp', 'billing@acme.com', true),
        (startup_account_id, 'Tech Startup Inc', 'tech-startup', 'billing@techstartup.com', true);
    
    -- Add users to accounts
    INSERT INTO public.account_users (account_id, user_id, role) VALUES
        (acme_account_id, admin_user_id, 'owner'::public.account_role),
        (acme_account_id, regular_user_id, 'member'::public.account_role),
        (startup_account_id, regular_user_id, 'owner'::public.account_role);
    
    -- Create subscriptions
    INSERT INTO public.account_subscriptions (account_id, plan_id, status, started_at, ends_at) VALUES
        (acme_account_id, pro_plan_id, 'active'::public.subscription_status, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 year'),
        (startup_account_id, basic_plan_id, 'trialing'::public.subscription_status, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '14 days');
    
    -- Add add-ons to accounts
    INSERT INTO public.account_addons (account_id, addon_id, quantity) VALUES
        (acme_account_id, phone_addon_id, 5),
        (acme_account_id, sms_addon_id, 2),
        (startup_account_id, phone_addon_id, 2);
    
    -- Add phone numbers
    INSERT INTO public.phone_numbers (account_id, e164_number, country_code, provider, status) VALUES
        (acme_account_id, '+1234567890', 'US', 'twilio', 'active'::public.phone_status),
        (acme_account_id, '+1234567891', 'US', 'twilio', 'active'::public.phone_status),
        (startup_account_id, '+1987654321', 'US', 'twilio', 'pending'::public.phone_status);
    
    -- Grant app access based on plans
    INSERT INTO public.account_app_access (account_id, app_id, source) VALUES
        (acme_account_id, phone_app_id, 'base_plan'),
        (acme_account_id, messages_app_id, 'base_plan'),
        (acme_account_id, contacts_app_id, 'base_plan'),
        (startup_account_id, phone_app_id, 'base_plan'),
        (startup_account_id, messages_app_id, 'base_plan');

END $$;

-- ====================================================================================================
-- STEP 10: COMMENTS FOR DOCUMENTATION
-- ====================================================================================================

COMMENT ON TABLE public.accounts IS 'Tenant organizations/companies in multi-tenant architecture';
COMMENT ON TABLE public.account_users IS 'Junction table for user membership in accounts';
COMMENT ON TABLE public.account_subscriptions IS 'Active subscription plans per account';
COMMENT ON TABLE public.account_addons IS 'Purchased add-ons per account';
COMMENT ON TABLE public.phone_numbers IS 'Virtual phone numbers assigned to accounts';
COMMENT ON TABLE public.account_app_access IS 'Apps accessible by each account';
COMMENT ON TABLE public.plans IS 'Available subscription plans catalog';
COMMENT ON TABLE public.addons IS 'Available add-ons catalog';
COMMENT ON TABLE public.apps IS 'Available applications in FhoneOS';

COMMENT ON FUNCTION public.is_account_member IS 'Check if authenticated user is member of specified account';
COMMENT ON FUNCTION public.is_account_admin IS 'Check if authenticated user is admin/owner of specified account';
COMMENT ON FUNCTION public.get_user_accounts IS 'Get all accounts that authenticated user belongs to';