import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY")!

serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization")
    if (!authHeader) {
      return new Response("Unauthorized", { status: 401 })
    }

    const { message } = await req.json()
    if (!message) {
      return new Response("Missing message", { status: 400 })
    }

    const openaiRes = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${OPENAI_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-5-mini",
        messages: [
          {
            role: "system",
            content:
              "You are the AI assistant for FhoneOS, helping with calls, messaging, and support.",
          },
          { role: "user", content: message },
        ],
        reasoning_effort: "minimal",
      }),
    })

    if (!openaiRes.ok) {
      const text = await openaiRes.text()
      console.error("OpenAI error", text)
      return new Response("OpenAI error", { status: 500 })
    }

    const data = await openaiRes.json()
    const reply =
      data.choices?.[0]?.message?.content ??
      "Sorry, I could not generate a response."

    return new Response(JSON.stringify({ reply }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    })
  } catch (err) {
    console.error(err)
    return new Response("Server error", { status: 500 })
  }
})