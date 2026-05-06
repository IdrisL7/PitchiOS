import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const CLAUDE_API_KEY           = Deno.env.get("CLAUDE_API_KEY") ?? Deno.env.get("ANTHROPIC_API_KEY");
const SUPABASE_URL             = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const CLAUDE_API_URL           = "https://api.anthropic.com/v1/messages";

// Model routing by output type
const MODEL_MAP: Record<string, string> = {
  objection: "claude-haiku-4-5-20251001",
  summary:   "claude-sonnet-4-6",
  email:     "claude-haiku-4-5-20251001",
  questions: "claude-haiku-4-5-20251001",
  brief:     "claude-sonnet-4-6",
};

// Max tokens per type — keeps costs predictable
const MAX_TOKENS_MAP: Record<string, number> = {
  objection: 512,
  summary:   1024,
  email:     768,
  questions: 1024,
  brief:     1024,
};

const CORS_HEADERS = {
  "Access-Control-Allow-Origin":  "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Authorization, Content-Type",
};

Deno.serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  // ── Auth: verify the Supabase JWT ────────────────────────────────────────
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return json({ error: "Missing or malformed Authorization header" }, 401);
  }

  const token = authHeader.slice(7);

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
  });

  const { data: { user }, error: authError } = await supabase.auth.getUser(token);
  if (authError || !user) {
    return json({ error: "Unauthorized — invalid or expired token" }, 401);
  }
  // ─────────────────────────────────────────────────────────────────────────

  if (!CLAUDE_API_KEY) {
    return json({ error: "CLAUDE_API_KEY not configured on server" }, 500);
  }

  let body: Record<string, string>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON body" }, 400);
  }

  const { type, profileContext, userPrompt } = body;
  if (!type || !userPrompt) {
    return json({ error: "Missing required fields: type, userPrompt" }, 400);
  }

  const model     = MODEL_MAP[type]      ?? "claude-haiku-4-5-20251001";
  const maxTokens = MAX_TOKENS_MAP[type] ?? 512;

  const claudeRequest = {
    model,
    max_tokens: maxTokens,
    stream: true,
    system: profileContext ?? "",
    messages: [{ role: "user", content: userPrompt }],
  };

  const claudeResponse = await fetch(CLAUDE_API_URL, {
    method: "POST",
    headers: {
      "Content-Type":      "application/json",
      "x-api-key":         CLAUDE_API_KEY,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify(claudeRequest),
  });

  if (!claudeResponse.ok) {
    const status = claudeResponse.status;
    if (status === 429) return json({ error: "Claude rate limit exceeded" }, 429);
    const detail = await claudeResponse.text();
    return json({ error: `Claude API error ${status}`, detail }, status);
  }

  // Pipe SSE stream directly back to iOS client
  return new Response(claudeResponse.body, {
    status: 200,
    headers: {
      ...CORS_HEADERS,
      "Content-Type":  "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection":    "keep-alive",
    },
  });
});

// ── Helpers ──────────────────────────────────────────────────────────────────

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}
