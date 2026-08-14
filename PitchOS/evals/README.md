# Generate Edge Function eval set

This frozen eval set is the quality gate for changing the model routing in the
PitchOS `generate` Edge Function.

## Baseline

- Production project: `pitchos-prod` (`ipdyauprajeoyhhatiqm`)
- Function: `generate`
- Deployed version: 5
- Deployed bundle SHA-256:
  `25b7c32611e8432c60f728d903c11ac72b4f81ef5c814adda4fc9878383297c6`
- Brief and summary model: `claude-sonnet-4-6`
- Questions and email model: `claude-haiku-4-5-20251001`
- Function authentication: Supabase JWT required
- Candidate model for the first comparison: `claude-sonnet-5` for brief and
  summary only

The model identifiers above are internal implementation evidence. They are not
approved public website or App Store claims.

## Cases

`generate-v1.json` contains eight fictional, replayable request bodies:

- two meeting briefs
- two discovery-question banks
- two post-call summaries
- two follow-up emails

The cases cover professional services automation and cybersecurity SaaS,
different deal stages, two sales methodologies, sparse notes, numeric ROI
evidence, explicit owners, deadlines, and buyer objections.

## Pass criteria

For every output:

1. The request succeeds and produces non-empty text.
2. Every case-specific required string is present.
3. No forbidden Markdown token is present.
4. The output stays within the case word limit where one is specified.

For the candidate model:

1. Format compliance must not regress against version 5.
2. A human blind review must rate the candidate equal or better on at least
   five of the eight cases.
3. Any regression in factual restraint, owner attribution, next-step clarity,
   or mobile readability blocks deployment even if the majority threshold is
   met.

## Run state

Inputs are frozen and the version 5 baseline was captured on
2026-08-08T22:59:15Z through an authenticated DevRemote simulator session. The
JWT remained inside the app process. The capture called the Edge Function
directly and did not insert deals or generated-output records.

Raw outputs and transport evidence are in `baseline-v5.json`. Run the
deterministic checks from this directory with:

```sh
node validate.mjs generate-v1.json baseline-v5.json
```

The baseline result is 4/8 passing:

| Case | Transport | Format and word-limit result |
| --- | --- | --- |
| brief-professional-services-discovery | Pass | Fail: five required labels omit trailing colons |
| brief-cybersecurity-negotiation | Pass | Fail: five required labels omit trailing colons |
| questions-professional-services-meddic | Pass | Pass |
| questions-cybersecurity-spin | Pass | Pass |
| summary-professional-services-pilot | Pass | Fail: required labels omit colons, pipe token present, 272/260 words |
| summary-cybersecurity-review | Pass | Fail: four required labels omit trailing colons |
| email-professional-services-pilot | Pass | Pass |
| email-cybersecurity-review | Pass | Pass |

All eight requests returned HTTP 200 with `text/event-stream`, non-empty text,
and a complete stream. The candidate must be compared against these raw
version 5 outputs. Production deployment remains a separate Idris approval
point after the blind comparison.

## Sonnet 5 candidate

The candidate was deployed only to the authenticated, unreferenced
`generate-sonnet5-eval` endpoint. The live `generate` function remained at
version 5 throughout.

Three isolated configurations were measured:

| Candidate | Configuration | Deterministic result |
| --- | --- | --- |
| `candidate-sonnet5-v1.json` | Model ID change only | 4/8; new Markdown regressions |
| `candidate-sonnet5-v2.json` | Sonnet 5 adaptive thinking disabled | 4/8; summary Markdown regressions remained |
| `candidate-sonnet5-v3.json` | Thinking disabled plus exact brief/summary output contracts | 8/8 |

Candidate version 3 is the only configuration eligible for human review. Its
isolated Edge Function bundle SHA-256 is
`d5b83b539c4042e8e1d8d67ff76432872bd637dd75f75f65e393ef8b0b77f4f4`.
All eight version 3 requests returned HTTP 200, `text/event-stream`, non-empty
text, and complete streams. This establishes deterministic compliance only,
not subjective quality or production approval.

Complete the blinded comparison in `blind-review.md`. A production routing
change remains blocked until at least five of eight cases are equal or better
and no case has a blocking factual-restraint, attribution, clarity, format, or
mobile-readability regression.

## Human blind-review result

Idris completed the blind review on 2026-08-09. The concealed mapping alternated
by case: candidate was A in cases 1, 3, 5, and 7, and B in cases 2, 4, 6, and 8.

| Measure | Result |
| --- | --- |
| Raw A/B tally | A 7, B 1, no ties |
| Decoded candidate result | Candidate 5, baseline 3 |
| Sonnet-changed cases only | Candidate 3/4 |
| Candidate blockers | 1, in unchanged Haiku email case 8 |
| Baseline blockers | 2, in cases 2 and 7 |

The candidate meets the numerical 5/8 threshold and the Sonnet 5 outputs have
no human-identified blocker. The complete endpoint run does not meet the
no-blocker requirement because candidate case 8 emitted `Dear [Client Name]`,
mischaracterised the negotiation call as the technical-validation meeting, and
referred to likely recipient Marcus in the third person. Email remains routed
to Haiku 4.5 in both functions, so this is not attributable to the Sonnet 5
model change. It exposes a shared prompt defect and stochastic reliability risk.

Recommendation: do not update the live function yet. First require follow-up
emails to be first-person from the user, address the named contact when the
recipient is unambiguous, avoid placeholders when a name is available, and not
relabel the meeting. Re-run the two email cases multiple times, then repeat the
blocked review gate before production deployment.

## Email defect remediation

The email gate now tests sendability and factual ownership rather than only
transport, word count, and the presence of `Subject:`. It requires the deal
contact to be addressed as the recipient, the profile user to remain the
sender, each party's actions to retain their owner, quantities and deadlines to
remain exact, and unaccepted commercial terms to remain unaccepted without
being turned into a refusal, approval, or new negotiating position. Bracketed
placeholders, inferred meeting labels, Markdown separators, and missing named
commercial terms are explicit failures. `validate.mjs` now supports required
and forbidden regular-expression checks for these constraints.

Repeated authenticated tests showed that the prompt contract alone was not
enough for Haiku 4.5: its strongest run passed only 4/10 under the complete
ownership and factual-restraint gate. Routing email to Sonnet 5 with thinking
disabled materially improved compliance.

The first apparent 10/10 isolated result, stored in
`email-guard-sonnet5-final.json`, exposed a checker gap during the first live
production smoke: several Marcus emails added `No pricing was agreed` even
though the source mentioned only an unaccepted discount and termination
clause. Expanding the gate to forbid that cross-case commercial fact correctly
rescored the isolated run at 7/10. This file is retained as falsification
evidence, not as a passing result.

Production versions 7 through 9 were measured and retained as negative-path
evidence. Version 7 still injected the general pricing claim. Version 8 removed
that hallucination but passed only 7/10 because three emails exceeded the
140-word safety gate. Version 9 passed 9/10, with one 149-word outlier. Replacing
the soft margin with a hard 120-word generation target produced the final
passing deployment.

Production `generate` version 10 is ACTIVE with JWT verification enabled and
bundle SHA-256
`0635a0a80fed0c99c747c4cc7a553f2f8265cbdb8d2709a6ed2a74b1728cc8dd`.
The authenticated in-app production capture in
`email-guard-production-v10.json` passes 10/10 under the expanded gate. All ten
requests returned HTTP 200, `text/event-stream`, non-empty text, and complete
streams. Outputs were 103 to 127 words. The pre-change rollback reference is
production version 5 with bundle SHA-256
`25b7c32611e8432c60f728d903c11ac72b4f81ef5c814adda4fc9878383297c6`.
