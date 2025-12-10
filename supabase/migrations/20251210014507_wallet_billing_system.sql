-- ============================================================================
-- FHONEOS WALLET & BILLING SYSTEM MIGRATION
-- ============================================================================
-- Extends existing multi-tenant architecture with:
-- - Wallet system (prepaid balance tracking)
-- - Payment methods (cards, bank accounts)
-- - Transaction history (top-ups, deductions, refunds)
-- - Call/SMS logs with pricing (Twilio integration)
-- - Usage alerts and spending limits
-- ============================================================================

-- ============================================================================
-- STEP 1: ENUMS
-- ============================================================================

-- Payment method types
CREATE TYPE public.payment_method_type AS ENUM (
    'card',
    'bank_account',
    'paypal',
    'apple_pay',
    'google_pay'
);

-- Payment status
CREATE TYPE public.payment_status AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded',
    'canceled'
);

-- Transaction types
CREATE TYPE public.transaction_type AS ENUM (
    'topup',
    'deduction',
    'refund',
    'adjustment'
);

-- Call direction
CREATE TYPE public.call_direction AS ENUM (
    'inbound',
    'outbound'
);

-- Call status
CREATE TYPE public.call_status AS ENUM (
    'queued',
    'ringing',
    'in_progress',
    'completed',
    'busy',
    'failed',
    'no_answer',
    'canceled'
);

-- Message direction
CREATE TYPE public.message_direction AS ENUM (
    'inbound',
    'outbound'
);

-- Message status
CREATE TYPE public.message_status AS ENUM (
    'queued',
    'sent',
    'delivered',
    'failed',
    'undelivered'
);

-- ============================================================================
-- STEP 2: EXTEND ACCOUNTS TABLE WITH WALLET
-- ============================================================================

-- Add wallet balance columns to existing accounts table
ALTER TABLE public.accounts
ADD COLUMN IF NOT EXISTS wallet_balance NUMERIC(10, 2) DEFAULT 0.00 NOT NULL,
ADD COLUMN IF NOT EXISTS wallet_currency TEXT DEFAULT 'EUR' NOT NULL,
ADD COLUMN IF NOT EXISTS low_balance_threshold NUMERIC(10, 2) DEFAULT 5.00,
ADD COLUMN IF NOT EXISTS auto_reload_enabled BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS auto_reload_amount NUMERIC(10, 2) DEFAULT 10.00,
ADD COLUMN IF NOT EXISTS auto_reload_threshold NUMERIC(10, 2) DEFAULT 5.00;

-- Add index for wallet operations
CREATE INDEX IF NOT EXISTS idx_accounts_wallet_balance 
ON public.accounts(wallet_balance);

-- Add check constraint for positive balance
ALTER TABLE public.accounts
ADD CONSTRAINT check_wallet_balance_positive 
CHECK (wallet_balance >= 0);

-- ============================================================================
-- STEP 3: PAYMENT METHODS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    type public.payment_method_type NOT NULL,
    
    -- Card details (encrypted/tokenized in production)
    card_last4 TEXT,
    card_brand TEXT,
    card_exp_month INTEGER,
    card_exp_year INTEGER,
    
    -- Bank account details
    bank_name TEXT,
    account_last4 TEXT,
    
    -- Digital wallet details
    wallet_email TEXT,
    
    -- Payment provider tokens
    stripe_payment_method_id TEXT,
    stripe_customer_id TEXT,
    
    -- Metadata
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    billing_name TEXT,
    billing_address JSONB,
    
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_payment_methods_account_id ON public.payment_methods(account_id);
CREATE INDEX idx_payment_methods_is_default ON public.payment_methods(is_default);
CREATE INDEX idx_payment_methods_stripe_customer ON public.payment_methods(stripe_customer_id);

-- RLS Policies
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_view_account_payment_methods"
ON public.payment_methods FOR SELECT TO authenticated
USING (is_account_member(account_id));

CREATE POLICY "admins_manage_payment_methods"
ON public.payment_methods FOR ALL TO authenticated
USING (is_account_admin(account_id))
WITH CHECK (is_account_admin(account_id));

-- ============================================================================
-- STEP 4: PAYMENTS TABLE (Stripe Transaction Records)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    payment_method_id UUID REFERENCES public.payment_methods(id) ON DELETE SET NULL,
    
    -- Payment details
    amount NUMERIC(10, 2) NOT NULL,
    currency TEXT DEFAULT 'EUR' NOT NULL,
    status public.payment_status DEFAULT 'pending' NOT NULL,
    type TEXT NOT NULL, -- 'topup', 'subscription', 'addon'
    
    -- Stripe integration
    stripe_payment_intent_id TEXT,
    stripe_charge_id TEXT,
    stripe_invoice_id TEXT,
    
    -- Related records
    subscription_id UUID REFERENCES public.account_subscriptions(id),
    addon_id UUID REFERENCES public.addons(id),
    
    -- Metadata
    description TEXT,
    metadata JSONB,
    failure_reason TEXT,
    receipt_url TEXT,
    
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_payments_account_id ON public.payments(account_id);
CREATE INDEX idx_payments_status ON public.payments(status);
CREATE INDEX idx_payments_created_at ON public.payments(created_at DESC);
CREATE INDEX idx_payments_stripe_payment_intent ON public.payments(stripe_payment_intent_id);

-- RLS Policies
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_view_account_payments"
ON public.payments FOR SELECT TO authenticated
USING (is_account_member(account_id));

CREATE POLICY "admins_manage_payments"
ON public.payments FOR ALL TO authenticated
USING (is_account_admin(account_id))
WITH CHECK (is_account_admin(account_id));

-- ============================================================================
-- STEP 5: TRANSACTIONS TABLE (Wallet Operations)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    
    -- Transaction details
    type public.transaction_type NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    currency TEXT DEFAULT 'EUR' NOT NULL,
    
    -- Balance tracking
    balance_before NUMERIC(10, 2) NOT NULL,
    balance_after NUMERIC(10, 2) NOT NULL,
    
    -- Related records
    payment_id UUID REFERENCES public.payments(id),
    call_id UUID, -- Will reference calls table
    message_id UUID, -- Will reference messages table
    
    -- Metadata
    description TEXT NOT NULL,
    metadata JSONB,
    
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_transactions_account_id ON public.transactions(account_id);
CREATE INDEX idx_transactions_type ON public.transactions(type);
CREATE INDEX idx_transactions_created_at ON public.transactions(created_at DESC);

-- RLS Policies
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_view_account_transactions"
ON public.transactions FOR SELECT TO authenticated
USING (is_account_member(account_id));

-- Prevent direct modifications (managed by functions)
CREATE POLICY "no_direct_modifications"
ON public.transactions FOR ALL TO authenticated
USING (false);

-- ============================================================================
-- STEP 6: CALLS TABLE (Twilio Call Logs)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.calls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    phone_number_id UUID REFERENCES public.phone_numbers(id) ON DELETE SET NULL,
    
    -- Call details
    from_number TEXT NOT NULL,
    to_number TEXT NOT NULL,
    direction public.call_direction NOT NULL,
    status public.call_status DEFAULT 'queued' NOT NULL,
    
    -- Twilio integration
    twilio_call_sid TEXT UNIQUE,
    twilio_account_sid TEXT,
    
    -- Timing
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    duration_seconds INTEGER DEFAULT 0,
    
    -- Billing
    price NUMERIC(10, 4),
    price_currency TEXT DEFAULT 'EUR',
    price_unit TEXT, -- 'per_minute', 'per_call'
    
    -- Call quality
    quality_score INTEGER, -- 1-5 rating
    recording_url TEXT,
    
    -- Metadata
    metadata JSONB,
    
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_calls_account_id ON public.calls(account_id);
CREATE INDEX idx_calls_phone_number_id ON public.calls(phone_number_id);
CREATE INDEX idx_calls_status ON public.calls(status);
CREATE INDEX idx_calls_created_at ON public.calls(created_at DESC);
CREATE INDEX idx_calls_twilio_sid ON public.calls(twilio_call_sid);
CREATE INDEX idx_calls_from_number ON public.calls(from_number);
CREATE INDEX idx_calls_to_number ON public.calls(to_number);

-- RLS Policies
ALTER TABLE public.calls ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_view_account_calls"
ON public.calls FOR SELECT TO authenticated
USING (is_account_member(account_id));

CREATE POLICY "admins_manage_calls"
ON public.calls FOR ALL TO authenticated
USING (is_account_admin(account_id))
WITH CHECK (is_account_admin(account_id));

-- ============================================================================
-- STEP 7: MESSAGES TABLE (SMS Logs)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    phone_number_id UUID REFERENCES public.phone_numbers(id) ON DELETE SET NULL,
    
    -- Message details
    from_number TEXT NOT NULL,
    to_number TEXT NOT NULL,
    body TEXT NOT NULL,
    direction public.message_direction NOT NULL,
    status public.message_status DEFAULT 'queued' NOT NULL,
    
    -- Twilio integration
    twilio_message_sid TEXT UNIQUE,
    twilio_account_sid TEXT,
    
    -- Media attachments
    media_urls TEXT[],
    num_media INTEGER DEFAULT 0,
    
    -- Billing
    price NUMERIC(10, 4),
    price_currency TEXT DEFAULT 'EUR',
    
    -- Metadata
    error_code TEXT,
    error_message TEXT,
    metadata JSONB,
    
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_messages_account_id ON public.messages(account_id);
CREATE INDEX idx_messages_phone_number_id ON public.messages(phone_number_id);
CREATE INDEX idx_messages_status ON public.messages(status);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX idx_messages_twilio_sid ON public.messages(twilio_message_sid);
CREATE INDEX idx_messages_from_number ON public.messages(from_number);
CREATE INDEX idx_messages_to_number ON public.messages(to_number);

-- RLS Policies
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_view_account_messages"
ON public.messages FOR SELECT TO authenticated
USING (is_account_member(account_id));

CREATE POLICY "admins_manage_messages"
ON public.messages FOR ALL TO authenticated
USING (is_account_admin(account_id))
WITH CHECK (is_account_admin(account_id));

-- ============================================================================
-- STEP 8: USAGE ALERTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.usage_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    
    -- Alert configuration
    alert_type TEXT NOT NULL, -- 'low_balance', 'spending_limit', 'usage_threshold'
    threshold_amount NUMERIC(10, 2),
    threshold_percentage INTEGER,
    
    -- Alert state
    is_enabled BOOLEAN DEFAULT true,
    last_triggered_at TIMESTAMPTZ,
    trigger_count INTEGER DEFAULT 0,
    
    -- Notification settings
    notify_email BOOLEAN DEFAULT true,
    notify_sms BOOLEAN DEFAULT false,
    notify_push BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_usage_alerts_account_id ON public.usage_alerts(account_id);
CREATE INDEX idx_usage_alerts_is_enabled ON public.usage_alerts(is_enabled);

-- RLS Policies
ALTER TABLE public.usage_alerts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_manage_own_alerts"
ON public.usage_alerts FOR ALL TO authenticated
USING (is_account_member(account_id))
WITH CHECK (is_account_member(account_id));

-- ============================================================================
-- STEP 9: ADD FOREIGN KEY CONSTRAINTS TO TRANSACTIONS
-- ============================================================================

ALTER TABLE public.transactions
ADD CONSTRAINT fk_transactions_call_id 
FOREIGN KEY (call_id) REFERENCES public.calls(id) ON DELETE SET NULL;

ALTER TABLE public.transactions
ADD CONSTRAINT fk_transactions_message_id 
FOREIGN KEY (message_id) REFERENCES public.messages(id) ON DELETE SET NULL;

-- ============================================================================
-- STEP 10: WALLET OPERATION FUNCTIONS
-- ============================================================================

-- Function to add funds to wallet (top-up)
CREATE OR REPLACE FUNCTION public.wallet_topup(
    p_account_id UUID,
    p_amount NUMERIC,
    p_payment_id UUID,
    p_description TEXT DEFAULT 'Wallet top-up'
)
RETURNS public.transactions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    v_balance_before NUMERIC;
    v_balance_after NUMERIC;
    v_transaction public.transactions;
BEGIN
    -- Get current balance
    SELECT wallet_balance INTO v_balance_before
    FROM public.accounts
    WHERE id = p_account_id
    FOR UPDATE;
    
    -- Calculate new balance
    v_balance_after := v_balance_before + p_amount;
    
    -- Update account balance
    UPDATE public.accounts
    SET wallet_balance = v_balance_after,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_account_id;
    
    -- Create transaction record
    INSERT INTO public.transactions (
        account_id,
        type,
        amount,
        balance_before,
        balance_after,
        payment_id,
        description
    ) VALUES (
        p_account_id,
        'topup',
        p_amount,
        v_balance_before,
        v_balance_after,
        p_payment_id,
        p_description
    )
    RETURNING * INTO v_transaction;
    
    RETURN v_transaction;
END;
$$;

-- Function to deduct funds from wallet (usage)
CREATE OR REPLACE FUNCTION public.wallet_deduct(
    p_account_id UUID,
    p_amount NUMERIC,
    p_description TEXT,
    p_call_id UUID DEFAULT NULL,
    p_message_id UUID DEFAULT NULL
)
RETURNS public.transactions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    v_balance_before NUMERIC;
    v_balance_after NUMERIC;
    v_transaction public.transactions;
BEGIN
    -- Get current balance
    SELECT wallet_balance INTO v_balance_before
    FROM public.accounts
    WHERE id = p_account_id
    FOR UPDATE;
    
    -- Check sufficient balance
    IF v_balance_before < p_amount THEN
        RAISE EXCEPTION 'Insufficient wallet balance';
    END IF;
    
    -- Calculate new balance
    v_balance_after := v_balance_before - p_amount;
    
    -- Update account balance
    UPDATE public.accounts
    SET wallet_balance = v_balance_after,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_account_id;
    
    -- Create transaction record
    INSERT INTO public.transactions (
        account_id,
        type,
        amount,
        balance_before,
        balance_after,
        call_id,
        message_id,
        description
    ) VALUES (
        p_account_id,
        'deduction',
        p_amount,
        v_balance_before,
        v_balance_after,
        p_call_id,
        p_message_id,
        p_description
    )
    RETURNING * INTO v_transaction;
    
    RETURN v_transaction;
END;
$$;

-- Function to get billing summary for account
CREATE OR REPLACE FUNCTION public.get_billing_summary(
    p_account_id UUID,
    p_start_date TIMESTAMPTZ DEFAULT NULL,
    p_end_date TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE (
    wallet_balance NUMERIC,
    total_spent NUMERIC,
    total_topups NUMERIC,
    call_count BIGINT,
    call_cost NUMERIC,
    message_count BIGINT,
    message_cost NUMERIC,
    subscription_cost NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.wallet_balance,
        COALESCE(SUM(CASE WHEN t.type = 'deduction' THEN t.amount ELSE 0 END), 0) AS total_spent,
        COALESCE(SUM(CASE WHEN t.type = 'topup' THEN t.amount ELSE 0 END), 0) AS total_topups,
        COUNT(DISTINCT c.id) AS call_count,
        COALESCE(SUM(c.price), 0) AS call_cost,
        COUNT(DISTINCT m.id) AS message_count,
        COALESCE(SUM(m.price), 0) AS message_cost,
        COALESCE((
            SELECT SUM(pl.price_monthly)
            FROM public.account_subscriptions sub
            JOIN public.plans pl ON pl.id = sub.plan_id
            WHERE sub.account_id = p_account_id
            AND sub.status = 'active'
        ), 0) AS subscription_cost
    FROM public.accounts a
    LEFT JOIN public.transactions t ON t.account_id = a.id
        AND (p_start_date IS NULL OR t.created_at >= p_start_date)
        AND (p_end_date IS NULL OR t.created_at <= p_end_date)
    LEFT JOIN public.calls c ON c.account_id = a.id
        AND (p_start_date IS NULL OR c.created_at >= p_start_date)
        AND (p_end_date IS NULL OR c.created_at <= p_end_date)
    LEFT JOIN public.messages m ON m.account_id = a.id
        AND (p_start_date IS NULL OR m.created_at >= p_start_date)
        AND (p_end_date IS NULL OR m.created_at <= p_end_date)
    WHERE a.id = p_account_id
    GROUP BY a.id, a.wallet_balance;
END;
$$;

-- ============================================================================
-- STEP 11: TRIGGERS FOR UPDATED_AT
-- ============================================================================

CREATE TRIGGER on_payment_methods_updated
BEFORE UPDATE ON public.payment_methods
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER on_payments_updated
BEFORE UPDATE ON public.payments
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER on_calls_updated
BEFORE UPDATE ON public.calls
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER on_messages_updated
BEFORE UPDATE ON public.messages
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER on_usage_alerts_updated
BEFORE UPDATE ON public.usage_alerts
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================================
-- STEP 12: MOCK DATA FOR TESTING
-- ============================================================================

-- Get existing account IDs
DO $$
DECLARE
    v_acme_id UUID;
    v_tech_id UUID;
    v_payment_method_id UUID;
    v_payment_id UUID;
    v_phone_number_id UUID;
BEGIN
    -- Get existing account IDs
    SELECT id INTO v_acme_id FROM public.accounts WHERE slug = 'acme-corp';
    SELECT id INTO v_tech_id FROM public.accounts WHERE slug = 'tech-startup';
    SELECT id INTO v_phone_number_id FROM public.phone_numbers WHERE account_id = v_acme_id LIMIT 1;
    
    -- Add initial wallet balance to existing accounts
    UPDATE public.accounts
    SET wallet_balance = 50.00,
        wallet_currency = 'EUR',
        low_balance_threshold = 10.00,
        auto_reload_enabled = true,
        auto_reload_amount = 20.00,
        auto_reload_threshold = 5.00
    WHERE id = v_acme_id;
    
    UPDATE public.accounts
    SET wallet_balance = 25.00,
        wallet_currency = 'EUR',
        low_balance_threshold = 5.00
    WHERE id = v_tech_id;
    
    -- Insert payment methods
    INSERT INTO public.payment_methods (id, account_id, type, card_last4, card_brand, card_exp_month, card_exp_year, is_default, billing_name)
    VALUES 
        (gen_random_uuid(), v_acme_id, 'card', '4242', 'Visa', 12, 2026, true, 'John Doe'),
        (gen_random_uuid(), v_acme_id, 'card', '5555', 'Mastercard', 6, 2025, false, 'John Doe')
    RETURNING id INTO v_payment_method_id;
    
    -- Insert payment records
    INSERT INTO public.payments (id, account_id, payment_method_id, amount, currency, status, type, description, completed_at)
    VALUES
        (gen_random_uuid(), v_acme_id, v_payment_method_id, 50.00, 'EUR', 'completed', 'topup', 'Initial wallet top-up', CURRENT_TIMESTAMP - INTERVAL '7 days')
    RETURNING id INTO v_payment_id;
    
    -- Insert initial transaction (using function)
    PERFORM public.wallet_topup(v_acme_id, 50.00, v_payment_id, 'Initial wallet top-up');
    
    -- Insert call logs
    INSERT INTO public.calls (account_id, phone_number_id, from_number, to_number, direction, status, twilio_call_sid, duration_seconds, price, price_currency, started_at, ended_at)
    VALUES
        (v_acme_id, v_phone_number_id, '+1234567890', '+9876543210', 'outbound', 'completed', 'CA' || md5(random()::text), 180, 0.15, 'EUR', CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '3 minutes'),
        (v_acme_id, v_phone_number_id, '+9876543210', '+1234567890', 'inbound', 'completed', 'CA' || md5(random()::text), 120, 0.10, 'EUR', CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '2 minutes');
    
    -- Insert message logs
    INSERT INTO public.messages (account_id, phone_number_id, from_number, to_number, body, direction, status, twilio_message_sid, price, price_currency, sent_at, delivered_at)
    VALUES
        (v_acme_id, v_phone_number_id, '+1234567890', '+9876543210', 'Test message', 'outbound', 'delivered', 'SM' || md5(random()::text), 0.05, 'EUR', CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '5 seconds'),
        (v_acme_id, v_phone_number_id, '+9876543210', '+1234567890', 'Reply message', 'inbound', 'delivered', 'SM' || md5(random()::text), 0.05, 'EUR', CURRENT_TIMESTAMP - INTERVAL '1 hour', CURRENT_TIMESTAMP - INTERVAL '1 hour' + INTERVAL '3 seconds');
    
    -- Insert usage alerts
    INSERT INTO public.usage_alerts (account_id, alert_type, threshold_amount, is_enabled)
    VALUES
        (v_acme_id, 'low_balance', 10.00, true),
        (v_acme_id, 'spending_limit', 100.00, true);
        
END $$;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- Created tables: payment_methods, payments, transactions, calls, messages, usage_alerts
-- Extended: accounts table with wallet balance columns
-- Created functions: wallet_topup, wallet_deduct, get_billing_summary
-- Created RLS policies for all new tables
-- Added mock data for testing
-- ============================================================================