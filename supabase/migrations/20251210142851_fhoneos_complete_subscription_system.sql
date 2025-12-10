-- Location: supabase/migrations/20251210142851_fhoneos_complete_subscription_system.sql
-- Schema Analysis: Existing schema has plans, addons, account_subscriptions, user_profiles, accounts
-- Integration Type: Enhancement - Adding FhoneOS subscription data and AI configurations
-- Dependencies: plans, addons, account_subscriptions (existing)

-- 1. Add AI level configuration to plans table (MODIFICATIVE - safe with default)
ALTER TABLE public.plans
ADD COLUMN IF NOT EXISTS ai_level TEXT DEFAULT 'none';

ALTER TABLE public.plans  
ADD COLUMN IF NOT EXISTS numbers_included INTEGER DEFAULT 0;

ALTER TABLE public.plans
ADD COLUMN IF NOT EXISTS ai_prompts_included INTEGER DEFAULT 0;

-- 2. Add payment type tracking to account_subscriptions (MODIFICATIVE - safe with default)
ALTER TABLE public.account_subscriptions
ADD COLUMN IF NOT EXISTS payment_type TEXT DEFAULT 'monthly_term';

-- 3. Create indexes for new columns
CREATE INDEX IF NOT EXISTS idx_plans_ai_level ON public.plans(ai_level);
CREATE INDEX IF NOT EXISTS idx_account_subscriptions_payment_type ON public.account_subscriptions(payment_type);

-- 4. Insert FhoneOS subscription plans (ADDITIVE - complete 4-tier system)
DO $$
BEGIN
    -- Update existing FhoneOS plans or insert new ones
    INSERT INTO public.plans (code, name, description, price_monthly, price_yearly, minutes_included, sms_included, ai_level, numbers_included, ai_prompts_included, profit_margin_eur, is_active)
    VALUES
        ('fhoneos_basic', 'FhoneOS Basic', '1 EU phone number, 200 minutes, 200 SMS, No AI', 15.00, 180.00, 200, 200, 'none', 1, 0, 9.60, true),
        ('fhoneos_plus', 'FhoneOS Plus', '1 EU/USA phone number, 400 minutes, 500 SMS, AI Basis (100 prompts)', 25.00, 300.00, 400, 500, 'ai_lite', 1, 100, 12.90, true),
        ('fhoneos_pro', 'FhoneOS Pro', '1 EU/USA phone number, 900 minutes, 1000 SMS, Full AI (unlimited light use)', 49.00, 588.00, 900, 1000, 'ai_full', 1, 0, 23.40, true),
        ('fhoneos_ultimate', 'FhoneOS Ultimate', '1 EU + 1 USA number, 2000 min, 2000 SMS, Premium AI with Voicemail-AI, Call recordings, AI-IVR', 99.00, 1188.00, 2000, 2000, 'ai_premium', 2, 0, 43.00, true)
    ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        price_monthly = EXCLUDED.price_monthly,
        price_yearly = EXCLUDED.price_yearly,
        minutes_included = EXCLUDED.minutes_included,
        sms_included = EXCLUDED.sms_included,
        ai_level = EXCLUDED.ai_level,
        numbers_included = EXCLUDED.numbers_included,
        ai_prompts_included = EXCLUDED.ai_prompts_included,
        profit_margin_eur = EXCLUDED.profit_margin_eur,
        is_active = EXCLUDED.is_active;
END $$;

-- 5. Insert FhoneOS add-ons (ADDITIVE - AI, numbers, usage bundles)
DO $$
BEGIN
    -- AI Add-ons
    INSERT INTO public.addons (code, name, type, price, description, is_active)
    VALUES
        ('ai_lite_addon', 'AI Lite (100 prompts)', 'feature', 5.00, 'Basic AI functionality with 100 monthly prompts', true),
        ('ai_pro_addon', 'AI Pro (1000 prompts)', 'feature', 15.00, 'Advanced AI with 1000 monthly prompts', true),
        ('ai_unlimited_addon', 'AI Unlimited', 'feature', 25.00, 'Unlimited AI prompts and premium features', true)
    ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name,
        price = EXCLUDED.price,
        description = EXCLUDED.description;

    -- Extra Phone Numbers
    INSERT INTO public.addons (code, name, type, price, description, is_active)
    VALUES
        ('extra_eu_number', 'Extra EU Phone Number', 'phone_number', 5.00, 'Additional European phone number', true),
        ('extra_usa_number', 'Extra USA Phone Number', 'phone_number', 3.00, 'Additional USA phone number', true),
        ('extra_intl_number', 'Extra International Number', 'phone_number', 7.00, 'Additional international phone number', true)
    ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name,
        price = EXCLUDED.price,
        description = EXCLUDED.description;

    -- Extra Usage Bundles
    INSERT INTO public.addons (code, name, type, price, description, is_active)
    VALUES
        ('bundle_100min', '+100 Minutes Bundle', 'integration', 3.00, 'Add 100 extra call minutes', true),
        ('bundle_500min', '+500 Minutes Bundle', 'integration', 10.00, 'Add 500 extra call minutes', true),
        ('bundle_100sms', '+100 SMS Bundle', 'integration', 2.00, 'Add 100 extra SMS messages', true),
        ('bundle_500sms', '+500 SMS Bundle', 'integration', 7.00, 'Add 500 extra SMS messages', true)
    ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name,
        price = EXCLUDED.price,
        description = EXCLUDED.description;
END $$;

-- 6. Comments for documentation
COMMENT ON COLUMN public.plans.ai_level IS 'AI capability tier: none, ai_lite, ai_full, ai_premium';
COMMENT ON COLUMN public.plans.numbers_included IS 'Number of phone numbers included in the plan';
COMMENT ON COLUMN public.plans.ai_prompts_included IS 'Monthly AI prompt quota (0 = unlimited for premium)';
COMMENT ON COLUMN public.account_subscriptions.payment_type IS 'Payment structure: yearly_full (paid in full) or monthly_term (12 monthly payments)';