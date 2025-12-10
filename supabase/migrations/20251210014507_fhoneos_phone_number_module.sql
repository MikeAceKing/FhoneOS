-- Location: supabase/migrations/20251210014507_fhoneos_phone_number_module.sql
-- Schema Analysis: Extends existing FhoneOS tenant architecture with phone number purchase and usage tracking
-- Integration Type: PARTIAL_EXISTS - Extends existing phone_numbers, accounts, addons tables
-- Dependencies: accounts, phone_numbers, user_profiles, addons

-- 1. Add wallet balance to existing accounts table
ALTER TABLE public.accounts
ADD COLUMN IF NOT EXISTS wallet_balance NUMERIC DEFAULT 0.00;

-- 2. Create wallet transactions table for tracking balance changes
CREATE TABLE public.wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('credit', 'debit')),
    description TEXT NOT NULL,
    reference_id UUID,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Create usage records table for call/SMS/data tracking
CREATE TABLE public.usage_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    phone_number_id UUID NOT NULL REFERENCES public.phone_numbers(id) ON DELETE CASCADE,
    usage_type TEXT NOT NULL CHECK (usage_type IN ('call', 'sms', 'data')),
    quantity NUMERIC NOT NULL,
    cost NUMERIC NOT NULL,
    direction TEXT CHECK (direction IN ('inbound', 'outbound')),
    duration_seconds INTEGER,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create number purchases table for purchase history
CREATE TABLE public.number_purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
    phone_number_id UUID NOT NULL REFERENCES public.phone_numbers(id) ON DELETE CASCADE,
    purchase_price NUMERIC NOT NULL,
    monthly_cost NUMERIC NOT NULL,
    purchase_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    activation_date TIMESTAMPTZ,
    receipt_url TEXT
);

-- 5. Essential Indexes
CREATE INDEX idx_wallet_transactions_account_id ON public.wallet_transactions(account_id);
CREATE INDEX idx_wallet_transactions_created_at ON public.wallet_transactions(created_at);
CREATE INDEX idx_usage_records_account_id ON public.usage_records(account_id);
CREATE INDEX idx_usage_records_phone_number_id ON public.usage_records(phone_number_id);
CREATE INDEX idx_usage_records_created_at ON public.usage_records(created_at);
CREATE INDEX idx_number_purchases_account_id ON public.number_purchases(account_id);
CREATE INDEX idx_number_purchases_phone_number_id ON public.number_purchases(phone_number_id);

-- 6. Enable RLS
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usage_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.number_purchases ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies using existing is_account_member function

CREATE POLICY "users_view_account_wallet_transactions"
ON public.wallet_transactions
FOR SELECT
TO authenticated
USING (is_account_member(account_id));

CREATE POLICY "users_view_account_usage_records"
ON public.usage_records
FOR SELECT
TO authenticated
USING (is_account_member(account_id));

CREATE POLICY "users_view_account_number_purchases"
ON public.number_purchases
FOR SELECT
TO authenticated
USING (is_account_member(account_id));

CREATE POLICY "admins_manage_wallet_transactions"
ON public.wallet_transactions
FOR ALL
TO authenticated
USING (is_account_admin(account_id))
WITH CHECK (is_account_admin(account_id));

CREATE POLICY "admins_manage_usage_records"
ON public.usage_records
FOR ALL
TO authenticated
USING (is_account_admin(account_id))
WITH CHECK (is_account_admin(account_id));

CREATE POLICY "admins_manage_number_purchases"
ON public.number_purchases
FOR ALL
TO authenticated
USING (is_account_admin(account_id))
WITH CHECK (is_account_admin(account_id));

-- 8. Helper function for wallet balance updates
CREATE OR REPLACE FUNCTION public.update_wallet_balance()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    IF NEW.transaction_type = 'credit' THEN
        UPDATE public.accounts
        SET wallet_balance = wallet_balance + NEW.amount
        WHERE id = NEW.account_id;
    ELSIF NEW.transaction_type = 'debit' THEN
        UPDATE public.accounts
        SET wallet_balance = wallet_balance - NEW.amount
        WHERE id = NEW.account_id;
    END IF;
    RETURN NEW;
END;
$func$;

-- 9. Trigger for automatic wallet balance updates
CREATE TRIGGER on_wallet_transaction_insert
AFTER INSERT ON public.wallet_transactions
FOR EACH ROW
EXECUTE FUNCTION public.update_wallet_balance();

-- 10. Mock data for testing (using existing account)
DO $$
DECLARE
    existing_account_id UUID;
    existing_phone_id UUID;
BEGIN
    SELECT id INTO existing_account_id FROM public.accounts LIMIT 1;
    SELECT id INTO existing_phone_id FROM public.phone_numbers LIMIT 1;
    
    IF existing_account_id IS NOT NULL THEN
        UPDATE public.accounts
        SET wallet_balance = 50.00
        WHERE id = existing_account_id;
        
        INSERT INTO public.wallet_transactions (account_id, amount, transaction_type, description)
        VALUES
            (existing_account_id, 50.00, 'credit', 'Initial wallet top-up'),
            (existing_account_id, 5.00, 'debit', 'Phone number purchase fee');
        
        IF existing_phone_id IS NOT NULL THEN
            INSERT INTO public.number_purchases (account_id, phone_number_id, purchase_price, monthly_cost)
            VALUES (existing_account_id, existing_phone_id, 5.00, 2.50);
            
            INSERT INTO public.usage_records (account_id, phone_number_id, usage_type, quantity, cost, direction, duration_seconds)
            VALUES
                (existing_account_id, existing_phone_id, 'call', 1, 0.15, 'outbound', 120),
                (existing_account_id, existing_phone_id, 'sms', 5, 0.25, 'outbound', NULL),
                (existing_account_id, existing_phone_id, 'call', 1, 0.00, 'inbound', 45);
        END IF;
    END IF;
END $$;