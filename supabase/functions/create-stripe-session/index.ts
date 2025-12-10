import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import Stripe from "https://esm.sh/stripe@16.0.0?target=deno";
import { createClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
});

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

Deno.serve(async (req) => {
  try {
    const supabaseAuthHeader = req.headers.get("Authorization");
    if (!supabaseAuthHeader) {
      return new Response("Unauthorized", { status: 401 });
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    const { data: { user }, error: authError } = await supabase.auth.getUser(
      supabaseAuthHeader.replace("Bearer ", "")
    );

    if (authError || !user) {
      return new Response("Unauthorized", { status: 401 });
    }

    const { plan_id } = await req.json();

    // Get plan details from Supabase
    const { data: plan, error: planError } = await supabase
      .from("plans")
      .select("*")
      .eq("id", plan_id)
      .single();

    if (planError || !plan) {
      return new Response("Plan not found", { status: 404 });
    }

    // Get or create account for user
    const { data: accountUser } = await supabase
      .from("account_users")
      .select("account_id")
      .eq("user_id", user.id)
      .single();

    if (!accountUser) {
      return new Response("Account not found", { status: 404 });
    }

    const accountId = accountUser.account_id;

    // Get account details
    const { data: account } = await supabase
      .from("accounts")
      .select("billing_email")
      .eq("id", accountId)
      .single();

    // Create or retrieve Stripe customer
    const { data: existingSub } = await supabase
      .from("account_subscriptions")
      .select("stripe_customer_id")
      .eq("account_id", accountId)
      .not("stripe_customer_id", "is", null)
      .single();

    let customerId = existingSub?.stripe_customer_id;

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: account?.billing_email || user.email,
        metadata: {
          account_id: accountId,
          user_id: user.id,
        },
      });
      customerId = customer.id;
    }

    // Create Stripe checkout session
    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      mode: "subscription",
      payment_method_types: ["card"],
      line_items: [
        {
          price: plan.stripe_price_id,
          quantity: 1,
        },
      ],
      success_url: `${req.headers.get("origin")}/billing-payment-center?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${req.headers.get("origin")}/billing-payment-center?canceled=true`,
      metadata: {
        account_id: accountId,
        plan_id: plan.id,
        user_id: user.id,
      },
    });

    return new Response(
      JSON.stringify({
        sessionId: session.id,
        url: session.url,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (err) {
    console.error("Stripe session creation error:", err);
    return new Response("Server error", { status: 500 });
  }
});