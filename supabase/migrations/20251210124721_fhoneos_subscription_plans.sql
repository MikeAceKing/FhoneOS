-- Location: supabase/migrations/20251210124721_fhoneos_subscription_plans.sql
-- Schema Analysis: Extending existing plans table with FhoneOS bundle details
-- Integration Type: Extension (PARTIAL_EXISTS)
-- Dependencies: plans, account_subscriptions, usage_records

-- =====================================================
-- STEP 1: Extend plans table with FhoneOS bundle fields
-- =====================================================

ALTER TABLE public.plans
ADD COLUMN IF NOT EXISTS minutes_included INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS sms_included INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS stripe_price_id TEXT,
ADD COLUMN IF NOT EXISTS profit_margin_eur NUMERIC(10,2) DEFAULT 0;

-- Add comment for new columns
COMMENT ON COLUMN public.plans.minutes_included IS 'Number of included calling minutes per month';
COMMENT ON COLUMN public.plans.sms_included IS 'Number of included SMS per month';
COMMENT ON COLUMN public.plans.stripe_price_id IS 'Stripe Price ID for subscription';
COMMENT ON COLUMN public.plans.profit_margin_eur IS 'Expected profit margin in EUR';

-- =====================================================
-- STEP 2: Extend account_subscriptions with Stripe tracking
-- =====================================================

ALTER TABLE public.account_subscriptions
ADD COLUMN IF NOT EXISTS stripe_customer_id TEXT,
ADD COLUMN IF NOT EXISTS stripe_subscription_id TEXT,
ADD COLUMN IF NOT EXISTS current_period_start TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS current_period_end TIMESTAMPTZ;

-- Add indexes for Stripe lookups
CREATE INDEX IF NOT EXISTS idx_subscriptions_stripe_customer 
ON public.account_subscriptions(stripe_customer_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_stripe_subscription 
ON public.account_subscriptions(stripe_subscription_id);

-- =====================================================
-- STEP 3: Ensure usage_records supports minute/SMS tracking
-- =====================================================

-- Add constraint to ensure usage_type is valid
ALTER TABLE public.usage_records
DROP CONSTRAINT IF EXISTS chk_usage_type;

ALTER TABLE public.usage_records
ADD CONSTRAINT chk_usage_type CHECK (usage_type IN ('call', 'sms', 'data'));

-- =====================================================
-- STEP 4: Insert FhoneOS subscription plans
-- =====================================================

DO $$
DECLARE
    basic_plan_id UUID := gen_random_uuid();
    plus_plan_id UUID := gen_random_uuid();
    pro_plan_id UUID := gen_random_uuid();
BEGIN
    -- Insert FhoneOS Basic Plan
    INSERT INTO public.plans (
        id, code, name, description,
        price_monthly, minutes_included, sms_included,
        stripe_price_id, profit_margin_eur, is_active
    ) VALUES (
        basic_plan_id,
        'fhoneos_basic',
        'FhoneOS Basic',
        '1 phone number, 200 minutes, 200 SMS',
        15.00,
        200,
        200,
        'price_fhoneos_basic_monthly',
        9.60,
        true
    ) ON CONFLICT (code) DO UPDATE SET
        price_monthly = EXCLUDED.price_monthly,
        minutes_included = EXCLUDED.minutes_included,
        sms_included = EXCLUDED.sms_included,
        profit_margin_eur = EXCLUDED.profit_margin_eur;

    -- Insert FhoneOS Plus Plan
    INSERT INTO public.plans (
        id, code, name, description,
        price_monthly, minutes_included, sms_included,
        stripe_price_id, profit_margin_eur, is_active
    ) VALUES (
        plus_plan_id,
        'fhoneos_plus',
        'FhoneOS Plus',
        '1 phone number, 400 minutes, 500 SMS',
        20.00,
        400,
        500,
        'price_fhoneos_plus_monthly',
        9.40,
        true
    ) ON CONFLICT (code) DO UPDATE SET
        price_monthly = EXCLUDED.price_monthly,
        minutes_included = EXCLUDED.minutes_included,
        sms_included = EXCLUDED.sms_included,
        profit_margin_eur = EXCLUDED.profit_margin_eur;

    -- Insert FhoneOS Pro Plan
    INSERT INTO public.plans (
        id, code, name, description,
        price_monthly, minutes_included, sms_included,
        stripe_price_id, profit_margin_eur, is_active
    ) VALUES (
        pro_plan_id,
        'fhoneos_pro',
        'FhoneOS Pro',
        '1 phone number, 900 minutes, 1000 SMS',
        30.00,
        900,
        1000,
        'price_fhoneos_pro_monthly',
        8.40,
        true
    ) ON CONFLICT (code) DO UPDATE SET
        price_monthly = EXCLUDED.price_monthly,
        minutes_included = EXCLUDED.minutes_included,
        sms_included = EXCLUDED.sms_included,
        profit_margin_eur = EXCLUDED.profit_margin_eur;

    RAISE NOTICE 'FhoneOS subscription plans created successfully';
END $$;

-- =====================================================
-- STEP 5: Helper function to check bundle usage limits
-- =====================================================

CREATE OR REPLACE FUNCTION public.check_bundle_limit(
    p_account_id UUID,
    p_usage_type TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_minutes_used INT := 0;
    v_sms_used INT := 0;
    v_minutes_included INT := 0;
    v_sms_included INT := 0;
    v_period_start TIMESTAMPTZ;
    v_period_end TIMESTAMPTZ;
BEGIN
    -- Get current subscription details
    SELECT 
        p.minutes_included,
        p.sms_included,
        asub.current_period_start,
        asub.current_period_end
    INTO 
        v_minutes_included,
        v_sms_included,
        v_period_start,
        v_period_end
    FROM public.account_subscriptions asub
    JOIN public.plans p ON asub.plan_id = p.id
    WHERE asub.account_id = p_account_id
    AND asub.status = 'active'
    ORDER BY asub.created_at DESC
    LIMIT 1;

    -- If no active subscription, return error
    IF v_period_start IS NULL THEN
        RETURN jsonb_build_object(
            'allowed', false,
            'reason', 'No active subscription found'
        );
    END IF;

    -- Calculate usage in current period
    SELECT 
        COALESCE(SUM(CASE WHEN usage_type = 'call' THEN CEIL(duration_seconds / 60.0) ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN usage_type = 'sms' THEN quantity ELSE 0 END), 0)
    INTO v_minutes_used, v_sms_used
    FROM public.usage_records
    WHERE account_id = p_account_id
    AND created_at >= v_period_start
    AND created_at <= v_period_end;

    -- Check limits based on usage type
    IF p_usage_type = 'call' THEN
        IF v_minutes_used >= v_minutes_included THEN
            RETURN jsonb_build_object(
                'allowed', false,
                'reason', 'Monthly minute limit reached',
                'used', v_minutes_used,
                'limit', v_minutes_included
            );
        END IF;
    ELSIF p_usage_type = 'sms' THEN
        IF v_sms_used >= v_sms_included THEN
            RETURN jsonb_build_object(
                'allowed', false,
                'reason', 'Monthly SMS limit reached',
                'used', v_sms_used,
                'limit', v_sms_included
            );
        END IF;
    END IF;

    RETURN jsonb_build_object(
        'allowed', true,
        'minutes_used', v_minutes_used,
        'minutes_limit', v_minutes_included,
        'sms_used', v_sms_used,
        'sms_limit', v_sms_included
    );
END;
$$;

COMMENT ON FUNCTION public.check_bundle_limit IS 'Checks if account has remaining minutes/SMS in current billing period';