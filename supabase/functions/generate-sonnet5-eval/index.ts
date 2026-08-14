import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const CLAUDE_API_KEY = Deno.env.get("CLAUDE_API_KEY") ??
  Deno.env.get("ANTHROPIC_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const CLAUDE_API_URL = "https://api.anthropic.com/v1/messages";

// Isolated evaluation candidate. The live generate function remains unchanged.
const MODEL_MAP: Record<string, string> = {
  objection: "claude-haiku-4-5-20251001",
  summary: "claude-sonnet-5",
  email: "claude-sonnet-5",
  questions: "claude-haiku-4-5-20251001",
  brief: "claude-sonnet-5",
};

const MAX_TOKENS_MAP: Record<string, number> = {
  objection: 512,
  summary: 1024,
  email: 768,
  questions: 1024,
  brief: 1024,
};

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Authorization, Content-Type",
};

const FORMAT_GUARD: Record<string, string> = {
  brief: `

MANDATORY OUTPUT CONTRACT:
- Use these labels exactly, including the trailing colon: Prospect Snapshot:, Likely Priorities:, Key Risks:, Recommended Focus:, Suggested First Question:
- Do not use Markdown headings, bold markers, horizontal rules, tables, or pipe characters.
- Obey the word limit in the user request.`,
  summary: `

MANDATORY OUTPUT CONTRACT:
- Use these labels exactly, including the trailing colon: Summary:, Action Items:, Commitments Made:, Recommended Next Step:
- Do not use Markdown headings, bold markers, horizontal rules, tables, or pipe characters.
- Obey the word limit in the user request.`,
  email: `

MANDATORY EMAIL CONTRACT:
- The PitchOS profile user is the sender. Write the sender's actions as "I" or "we", never as their name or in the third person.
- The Contact named in Deal context is the recipient. Start with that contact's first name and express the contact's actions as "you" or "your", never in the third person.
- If Deal context has no Contact, use a named prospect from the summary only when exactly one is unambiguous; otherwise use a neutral greeting and do not guess.
- Never output brackets, placeholders, Markdown, or a horizontal rule. If a sender or recipient name is unavailable, omit it.
- Preserve every owner, quantity, qualifier, and deadline exactly. Changing grammatical person must never transfer responsibility.
- Thank the recipient for the conversation without naming or characterising the meeting. Do not infer a meeting type from a completed milestone.
- If a commercial request was not accepted, say only that it was not agreed or accepted. Do not turn that absence into a refusal, approval, willingness, or new negotiating position.
- Do not generalise a specific unaccepted term into a claim about all pricing. Mention general pricing status only when the source explicitly states it, and do not add future implications.
- Do not omit an explicitly mentioned requested, rejected, or unaccepted commercial term.
- Do not invent, accept, or strengthen commitments, commercial terms, owners, dates, or outcomes.
- The entire response, including subject, greeting, and sign-off, must be 120 words or fewer.`,
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return json({ error: "Missing or malformed Authorization header" }, 401);
  }

  const token = authHeader.slice(7);
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
  });

  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser(token);
  if (authError || !user) {
    return json({ error: "Unauthorized — invalid or expired token" }, 401);
  }

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

  const model = MODEL_MAP[type] ?? "claude-haiku-4-5-20251001";
  const maxTokens = MAX_TOKENS_MAP[type] ?? 512;
  const usesSonnet5 = model === "claude-sonnet-5";
  const systemPrompt = `${profileContext ?? ""}${FORMAT_GUARD[type] ?? ""}`;

  const claudeResponse = await fetch(CLAUDE_API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": CLAUDE_API_KEY,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model,
      max_tokens: maxTokens,
      stream: true,
      ...(usesSonnet5 ? { thinking: { type: "disabled" } } : {}),
      system: systemPrompt,
      messages: [{ role: "user", content: userPrompt }],
    }),
  });

  if (!claudeResponse.ok) {
    const status = claudeResponse.status;
    if (status === 429) {
      return json({ error: "Claude rate limit exceeded" }, 429);
    }
    const detail = await claudeResponse.text();
    return json({ error: `Claude API error ${status}`, detail }, status);
  }

  return new Response(claudeResponse.body, {
    status: 200,
    headers: {
      ...CORS_HEADERS,
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      Connection: "keep-alive",
    },
  });
});

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}
