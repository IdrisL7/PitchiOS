import "@supabase/functions-js/edge-runtime.d.ts";

const HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
  "Content-Type": "text/html; charset=utf-8",
  "Cache-Control": "public, max-age=3600",
};

Deno.serve((req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: HEADERS });
  }

  if (req.method === "HEAD") {
    return new Response(null, { status: 200, headers: HEADERS });
  }

  if (req.method !== "GET") {
    return page("Method Not Allowed", "<p>This page only supports GET requests.</p>", 405);
  }

  const url = new URL(req.url);
  const path = url.pathname.toLowerCase();

  if (path.endsWith("/privacy")) {
    return page("PitchOS Privacy Policy", privacyPolicy());
  }

  if (path.endsWith("/terms")) {
    return page(
      "PitchOS Terms of Use",
      `<p>PitchOS uses Apple's standard Terms of Use (EULA).</p>
       <p><a href="https://www.apple.com/legal/internet-services/itunes/dev/stdeula/">View Apple's standard EULA</a></p>`
    );
  }

  return page(
    "PitchOS Legal",
    `<ul>
       <li><a href="/functions/v1/legal/privacy">Privacy Policy</a></li>
       <li><a href="/functions/v1/legal/terms">Terms of Use</a></li>
     </ul>`
  );
});

function page(title: string, body: string, status = 200): Response {
  return new Response(`<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(title)}</title>
  <style>
    body {
      margin: 0;
      padding: 48px 20px;
      background: #0a0d1f;
      color: #f6f8ff;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      line-height: 1.6;
    }
    main {
      max-width: 780px;
      margin: 0 auto;
      background: #121830;
      border: 1px solid rgba(255,255,255,.16);
      border-radius: 20px;
      padding: 28px;
    }
    h1, h2 { line-height: 1.2; }
    a { color: #2e8ff5; }
    .muted { color: #cdd8ec; }
  </style>
</head>
<body>
  <main>
    <h1>${escapeHtml(title)}</h1>
    ${body}
  </main>
</body>
</html>`, { status, headers: HEADERS });
}

function privacyPolicy(): string {
  return `
    <p class="muted">Last updated: May 11, 2026</p>
    <p>PitchOS is an AI-powered pre-sales copilot for iOS. This Privacy Policy explains what information the app uses and how it is handled.</p>

    <h2>Information We Collect</h2>
    <p>When you create an account, PitchOS stores your email address through Supabase Auth and stores profile details you provide, such as your name, role, product, industries, buyer titles, methodology, and differentiators.</p>
    <p>The app may also store deal details, call notes you enter, generated AI outputs, usage counts, and subscription plan status.</p>

    <h2>How Information Is Used</h2>
    <p>PitchOS uses this information to authenticate your account, personalize AI-generated sales preparation, enforce usage limits, and provide saved deal and output history.</p>

    <h2>Third-Party Services</h2>
    <p>PitchOS uses Supabase for authentication and data storage, Apple StoreKit for subscriptions, and an AI provider through a Supabase Edge Function to generate responses. Prompt context needed for a generation may be sent to the AI provider.</p>

    <h2>Account Deletion</h2>
    <p>You can delete your account in the app from Settings → Account → Delete Account. Deleting your account permanently removes your PitchOS account and associated app data.</p>

    <h2>Contact</h2>
    <p>For privacy questions, contact support through the PitchOS App Store listing or website.</p>
  `;
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
