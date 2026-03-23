// PitchOS — Claude API Proxy Edge Function
// Handles all AI generation types: objection, summary, email, questions
// Streams SSE responses directly from Claude to the iOS client

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CLAUDE_API_KEY = Deno.env.get("CLAUDE_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const FREE_TIER_LIMIT = 50;

// Model selection per output type
const MODEL_MAP: Record<string, string> = {
  objection: "claude-haiku-4-5-20251001", // Fast for live calls
  summary: "claude-sonnet-4-6",
  email: "claude-sonnet-4-6",
  questions: "claude-sonnet-4-6",
};

const MAX_TOKENS_MAP: Record<string, number> = {
  objection: 300,
  summary: 800,
  email: 400,
  questions: 800,
};

Deno.serve(async (req) => {
  // CORS headers for preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Authorization, Content-Type",
      },
    });
  }

  try {
    // 1. Authenticate via Supabase JWT
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization" }), {
        status: 401,
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const token = authHeader.replace("Bearer ", "");
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
      });
    }

    // 2. Check usage quota
    const currentMonth = new Date().toISOString().slice(0, 7); // YYYY-MM
    const { data: usageData } = await supabase
      .from("usage")
      .select("generations")
      .eq("user_id", user.id)
      .eq("month", currentMonth)
      .single();

    const currentUsage = usageData?.generations ?? 0;
    if (currentUsage >= FREE_TIER_LIMIT) {
      return new Response(
        JSON.stringify({ error: "Monthly generation limit reached" }),
        { status: 429 }
      );
    }

    // 3. Parse request
    const { type, profileContext, userPrompt, promptVersion } =
      await req.json();

    const model = MODEL_MAP[type] || "claude-sonnet-4-6";
    const maxTokens = MAX_TOKENS_MAP[type] || 600;

    // 4. Call Claude API with streaming
    const claudeResponse = await fetch(
      "https://api.anthropic.com/v1/messages",
      {
        method: "POST",
        headers: {
          "x-api-key": CLAUDE_API_KEY,
          "anthropic-version": "2023-06-01",
          "content-type": "application/json",
        },
        body: JSON.stringify({
          model,
          max_tokens: maxTokens,
          stream: true,
          system: profileContext,
          messages: [{ role: "user", content: userPrompt }],
        }),
      }
    );

    if (!claudeResponse.ok) {
      const errorText = await claudeResponse.text();
      console.error("Claude API error:", errorText);
      return new Response(
        JSON.stringify({ error: "AI generation failed" }),
        { status: 502 }
      );
    }

    // 5. Increment usage counter
    await supabase.from("usage").upsert(
      {
        user_id: user.id,
        month: currentMonth,
        generations: currentUsage + 1,
      },
      { onConflict: "user_id,month" }
    );

    // 6. Pipe SSE stream directly to client (no buffering)
    return new Response(claudeResponse.body, {
      headers: {
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        Connection: "keep-alive",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (error) {
    console.error("Edge function error:", error);
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
    });
  }
});
