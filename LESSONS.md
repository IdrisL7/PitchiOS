# PitchOS — Lessons & Discoveries Log

> Self-evolving reference. Add an entry every time something breaks, a pattern is discovered, or a better approach is found.

---

## Lesson 001 — Never use `sed` to patch Swift files
**Date:** 2026-03-23
**What happened:** Used `sed -i ''` to inject `#if DEBUG` blocks into `ContentView.swift` to swap views for screenshots. The sed patterns matched more than expected, deleted `GenerateView()` from the switch case, and left orphaned `#else`/`#endif` tokens that caused 40+ compile errors.
**Fix:** Restore the file with the Edit tool and revert manually.
**Rule going forward:** Always use the **Edit tool** for Swift file modifications — it diffs precisely, shows the user what changed, and never clobbers surrounding lines. Reserve `sed` only for trivial single-token replacements in non-Swift files (e.g. `.env`, plain text).

---

## Lesson 009 — For screenshot cycling, use Edit tool per view — never sed
**Date:** 2026-03-23
**What happened:** Tried a bash loop using `sed` to inject `#if DEBUG` blocks into ContentView.swift for each screenshot cycle. sed matched multiple lines simultaneously, left orphaned `#else`/`#endif` tokens, and broke the switch statement — 40+ compiler errors.
**Fix:** Use the **Edit tool** for each swap: replace exactly `MainTabView()` with the `#if DEBUG ... #else MainTabView() #endif` block, build, screenshot, then revert with Edit tool again. This is precise, auditable, and never clobbers surrounding syntax.
**Rule:** sed is banned for Swift file mutations. Edit tool only.

---

## Lesson 002 — Screenshot simulator must be iPhone Xs Max / 11 Pro Max for 1242×2688
**Date:** 2026-03-23
**What happened:** iPhone 17 Pro produces 1206×2622 screenshots. App Store Connect requires either 1242×2688 (6.5") or 1290×2796 (6.7").
**Fix:** `xcrun simctl create` with `com.apple.CoreSimulator.SimDeviceType.iPhone-11-Pro-Max` on whatever the latest iOS runtime is. Confirmed output = 1242×2688.
**Note:** The device type exists even if no matching runtime ships with it — use `xcrun simctl list devicetypes | grep "11 Pro Max"` to confirm, then pair with the available runtime.

---

## Lesson 003 — `devBypass()` must exist before patching `loadSession()`
**Date:** 2026-03-23
**What happened:** Adding `devBypass(); return` at the top of `loadSession()` caused a compile error because `devBypass()` was not yet declared.
**Rule:** Always `Grep` for the function before referencing it. If it doesn't exist, define it first in the same `#if DEBUG` block.

---

## Lesson 004 — `git push` requires auth; use `gh auth token` pipe
**Date:** 2026-03-23
**What happened:** `git push` with an `https://` remote returned "Device not configured" because no credential helper is set.
**Fix:** `git remote set-url mine https://$(gh auth token)@github.com/IdrisL7/PitchiOS.git && git push -u mine <branch>` — inlines the token so no interactive prompt is needed.
**Security note:** Token is only in-process memory and is not saved to `.git/config` if you set it inline with `set-url` right before pushing, then change it back.

---

## Lesson 005 — Supabase `secrets set` must run from the linked project directory
**Date:** 2026-03-23
**What happened:** Running `supabase secrets set` from the repo root returned "Cannot find project ref".
**Fix:** `cd PitchOS && supabase secrets set KEY=value` — the `supabase/` directory must be present in the current working directory.

---

## Lesson 006 — Always `Read` a file with the tool before using `Edit`
**Date:** 2026-03-23
**What happened:** Multiple "File has not been read yet" errors when trying to Edit files that were only seen via system-reminder context paste.
**Rule:** Every Edit must be preceded by an explicit `Read` tool call in the same session. The tool tracks which files have been read. System-reminder/summary context does not count.

---

## Lesson 007 — App Store validation requires `UISupportedInterfaceOrientations` in Info.plist
**Date:** 2026-03-23
**What happened:** Upload to App Store Connect failed with: "No orientations were specified in the com.pitchos.PitchOS bundle."
**Fix:** Add to `Info.plist` (or via Build Settings → Custom iOS Target Properties):
```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```
**Note:** For a portrait-only app you only need `UIInterfaceOrientationPortrait`, but Apple requires at least one value explicitly set.

---

## Lesson 008 — `SalesMethodology` rawValues must match stored SwiftData strings exactly
**Date:** 2026-03-23
**What happened:** Concern that existing users might have lowercase `"meddic"` stored in SwiftData vs the enum `rawValue = "MEDDIC"`.
**Finding:** `OnboardingViewModel.methodology` defaults to `"MEDDIC"` (uppercase) and `methodologies` array uses uppercase — so no mismatch for existing users.
**Rule:** Whenever changing an enum that maps to persisted/DB strings, grep all storage sites (`UserDefaults`, SwiftData, Supabase columns) before deciding if a migration is needed.

---

## Patterns & Discoveries

| # | Pattern | Notes |
|---|---------|-------|
| P1 | `@Environment(\.colorScheme)` in modifiers — not passed as state | Avoids prop drilling, works correctly with `.preferredColorScheme()` at root |
| P2 | `#if DEBUG` blocks stripped by compiler at Archive time | Safe for simulator-only cards, dev bypass, debug simulator |
| P3 | `devBypass()` in `loadSession()` — set `isLoading = false`, populate mock profile | Fastest way to screenshot any authenticated view |
| P4 | Supabase edge function `generate` — streams Claude response via `ReadableStream` | Client uses `AsyncStream` bridge in `AIService.swift` |
| P5 | `VerticalTemplates.recommended(for:)` returns `SalesMethodology` — used in `applyTemplate()` | Keeps vertical + methodology logic co-located |
| P6 | `xcrun simctl io <udid> screenshot <path>` — no app restart needed between shots | Launch once, navigate programmatically, fire screenshot each time |
