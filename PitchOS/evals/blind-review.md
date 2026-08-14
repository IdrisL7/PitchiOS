# PitchOS blind output review

Review each pair without trying to identify the model. Score the stronger output on factual restraint, instruction compliance, usefulness, clarity, and mobile readability. Choose Tie only when neither output has a meaningful advantage.

| Case | Winner (A/B/Tie) | Blocking issue | Notes |
| --- | --- | --- | --- |
| brief-professional-services-discovery | A | No | A tighter and fully compliant with the 5-section structure. B adds template cruft (Date/Owner header with [AE Name] placeholder) outside the requested structure and introduces "client SLAs", which is not in the deal context (hedged, so not blocking). |
| brief-cybersecurity-negotiation | B | A only | A invents a company descriptor: "mid-market software" appears nowhere in the context — a visible hallucination to a user who knows their own deal. B is factually clean, and its tactics are stronger (multi-year lock as counter-concession, reframing the termination clause as audit-continuity risk). |
| questions-professional-services-meddic | A | No | Both obey Q1-verbatim and open-ended rules. A actually maps to MEDDIC: metrics (3, 5, 15), stakeholders/economic buyer (11), decision process (11, 12), impact (6). B omits decision-process and economic-buyer questions entirely — generic ops discovery, weak methodology compliance. |
| questions-cybersecurity-spin | A | No | B violates the no-leading/no-assumptive instruction repeatedly: Q3 assumes auditors raised concerns, Q7 assumes a spreadsheet error incident occurred, Q14 presumes consolidation is overdue; Q10 also contradicts the fixed-headcount context. A holds the SPIN arc (situation 2-3, problem 4/6, implication 10/13, need-payoff 8/14/15); its unrequested title header is minor. |
| summary-professional-services-pilot | A | No | A is strictly traceable to the raw notes. B invents characterisations ("the conversation was exploratory", "no solution was presented in detail") and an "Account team" owner that does not exist in this context. B's baseline-error-rate coaching is genuinely good strategy, but it is built on top of invented framing, and its divider-heavy layout is worse on mobile. |
| summary-cybersecurity-review | A | No | Both factual with correct owners (Elena legal pack, Marcus procurement call). A wins on next-step usefulness: prepared counter-position and "no drift without a documented counter-offer" is real guidance; B's next step is a restatement. B is leaner and more mobile-friendly, which narrows but does not close the gap. |
| email-professional-services-pilot | A | B only | B refers to the sender in the third person ("Once Idris has reviewed them, he'll prepare...") while signing as [Your name] — the user cannot send this without rewriting it, which defeats the feature. A is first-person, factual, under 150 words, subject line correctly separated. |
| email-cybersecurity-review | A | B only | B opens "Dear [Client Name]" although Marcus is named in the context — a placeholder in a sendable email is a blocker — and mischaracterises the call as "the technical validation meeting" (validation was reported complete; this was a negotiation-stage call). Shared weakness worth logging for prompt work: both outputs third-person Marcus even though he is the likely recipient. A also slightly drifts on timing ("reach out early next week" vs a call scheduled for next week) — minor. |

A candidate is eligible only if it is equal or better in at least five of eight cases and has no blocking regression in factual restraint, owner attribution, next-step clarity, format compliance, or mobile readability.

## 1. brief-professional-services-discovery

Prompt:

    Generate a concise pre-call meeting brief. Deal context: Company: Northbank Conveyancing. Contact: Priya Shah, Operations Director. Stage: discovery. Notes: 22 staff process emailed property documents manually; turnaround varies by fee earner; interested in document checking but has not shared volumes or error rates. Structure the brief using Prospect Snapshot, Likely Priorities, Key Risks, Recommended Focus, and Suggested First Question. Keep it under 200 words.

### Output A

    Prospect Snapshot:
    - Northbank Conveyancing, 22 staff, manual processing of emailed property documents
    - Contact: Priya Shah, Operations Director
    - Stage: discovery; interest in document checking but no volume or error-rate data shared yet

    Likely Priorities:
    - Reducing turnaround variability across fee earners
    - Standardising document handling to improve client experience
    - Freeing fee earner time from manual admin work

    Key Risks:
    - No quantified pain (volumes, error rates, delay costs) — MEDDIC Metrics gap
    - Unclear Economic Buyer beyond Priya; may need managing partner sign-off
    - No confirmed Decision Criteria or Decision Process discussed
    - Risk of framing this as a "nice to have" rather than urgent priority

    Recommended Focus:
    - Quantify the problem: ask for current turnaround times, error/rework rates, and volume of documents processed monthly
    - Identify who else influences or approves technology spend (Champion vs Economic Buyer)
    - Uncover the Compelling Event — client complaints, competitive pressure, or growth plans straining current process
    - Position document checking as a first use case, with workflow automation as expansion path

    Suggested First Question:
    "Can you walk me through what happens from the moment a property document lands in an inbox to when it's fully reviewed and actioned?"

### Output B

    Pre-Call Brief: Northbank Conveyancing / Priya Shah

    Date: Discovery Call
    Owner: [AE Name]

    Prospect Snapshot
    - 22-person firm processing emailed property documents manually
    - Priya Shah, Operations Director, likely owns process efficiency and risk
    - Interest confirmed in document checking; no volume or error data shared yet
    - Turnaround inconsistency flagged across fee earners

    Likely Priorities
    - Reducing turnaround variability to protect client SLAs
    - Reducing exposure to manual checking errors in conveyancing workflows
    - Standardising output quality without adding headcount

    Key Risks (MEDDIC gaps)
    - No metrics shared: volumes, error rates, cost of failure unknown
    - Economic buyer not confirmed: managing partner may hold budget sign-off
    - No decision process or timeline established
    - Compelling event unclear: no deadline or trigger identified

    Recommended Focus
    - Quantify the pain: draw out volume, error frequency, and rework cost
    - Identify who feels the consequences of inconsistency (fee earners, clients, partners)
    - Probe for any recent incident or compliance pressure driving interest now

    Suggested First Question
    - "When turnaround varies between fee earners, where does that tend to cause the most pressure for you operationally, and has anything recently brought that to a head?"

## 2. brief-cybersecurity-negotiation

Prompt:

    Generate a concise pre-call meeting brief. Deal context: Company: Alder Cloud. Contact: Marcus Green, CISO. Stage: negotiation. Notes: Technical validation passed. Procurement wants a 20 percent reduction and a 30-day termination clause. Security team wants deployment before the October audit. No approved concession has been offered. Structure the brief using Prospect Snapshot, Likely Priorities, Key Risks, Recommended Focus, and Suggested First Question. Keep it under 200 words.

### Output A

    Prospect Snapshot
    - Company: Alder Cloud, mid-market software
    - Contact: Marcus Green, CISO
    - Stage: Negotiation, technical validation complete
    - Pressure points: Procurement pushing 20% discount and 30-day termination clause, security team needs deployment ahead of October audit

    Likely Priorities
    - Marcus: Audit readiness, deployment timeline, internal credibility
    - Procurement: Cost control, contract flexibility
    - These priorities are in tension and create leverage

    Key Risks
    - Conceding on price or termination without understanding Marcus's urgency undermines deal value
    - 30-day termination clause signals low confidence in the platform despite passed validation
    - October deadline is a forcing function that works in your favor if used correctly

    Recommended Focus
    - Anchor the conversation on audit risk, not price
    - Tie deployment timeline to contract start date to create urgency around closing now
    - Do not volunteer concessions; surface what Marcus is willing to sponsor internally before adjusting terms
    - If termination clause is non-negotiable, explore structuring it post-deployment stabilization period instead of day one

    Suggested First Question
    - Marcus, given the October audit is the hard deadline, what happens to your security posture review if deployment slips because contract terms stay unresolved through September?

### Output B

    Prospect Snapshot:
    - Alder Cloud, negotiation stage, technical validation complete
    - Contact: Marcus Green, CISO, security-driven urgency ahead of October audit
    - Procurement pushing 20 percent discount and 30-day termination clause, no concessions approved yet

    Likely Priorities:
    - Marcus needs deployment locked in before audit to avoid findings
    - Procurement optimizing cost and contract flexibility, not urgency
    - Internal tension between security timeline and procurement leverage

    Key Risks:
    - 30-day termination clause undermines deal value and renewal predictability
    - Discount request may cascade if granted without offsetting terms
    - Audit deadline pressure could be used against you in final concession push

    Recommended Focus:
    - Reframe termination clause risk: short exit terms jeopardize audit continuity, not just revenue
    - Offer alternative concession (multi-year lock for reduced rate) instead of straight discount
    - Align Marcus and procurement on shared risk: delay equals audit exposure, not just cost

    Suggested First Question:
    "If we can guarantee deployment before your audit, what needs to be true on the contract side for procurement to move forward without the 30-day clause?"

## 3. questions-professional-services-meddic

Prompt:

    Generate a discovery question bank. Deal context: Northbank Conveyancing, Operations Director, discovery stage, 22 staff, manual emailed document checking, volumes and error rates unknown. Sales vertical: professional services. Sales methodology: MEDDIC. Question 1 must be exactly: If you don't solve this problem, what does that look like 12 months from now? Generate 14 additional open-ended questions numbered 2 to 15. Do not use binary or leading questions.

### Output A

    1. If you don't solve this problem, what does that look like 12 months from now?

    2. Walk me through your current document checking process from the moment a file lands in someone's inbox to when it's approved for the next stage.

    3. How many documents does your team typically handle across conveyancing transactions in a given month?

    4. What types of errors or inconsistencies are your team catching during the manual review process?

    5. How much time would you estimate your team spends on document checking activities each week?

    6. When errors do slip through to clients or the next stage, what's the typical impact on your business?

    7. Beyond your operations team, who else in the business is affected when documents don't meet the required standard?

    8. What's driving the decision to look at workflow automation now as opposed to six months or a year ago?

    9. How are your competitors or peer firms handling document management and checking at scale?

    10. What would success look like for your team if you implemented a solution to handle this?

    11. Talk me through the different stakeholders who would need to sign off on or be involved in evaluating a solution like this.

    12. What's your experience been with implementing technology changes across a team of 22 people?

    13. How is your current document checking process documented or standardized across the team?

    14. What tools or systems are currently in your tech stack that new solutions would need to integrate with or work alongside?

    15. If we could measure the impact of solving this problem, what metrics would matter most to your leadership team?

### Output B

    1. If you don't solve this problem, what does that look like 12 months from now?

    2. Can you walk me through how a typical conveyancing file moves through your team from initial receipt to completion?

    3. What does a standard day look like for your team in terms of document handling and checking?

    4. How do you currently track which documents have been reviewed and by whom?

    5. When errors occur in document checking, how do you typically discover them?

    6. What happens when a document gets missed or checked incorrectly before going to a client?

    7. How much time would you estimate your team spends on manual document review each week?

    8. What systems or tools are you currently using to manage your conveyancing workflows?

    9. How do you handle situations where multiple team members need to review the same document?

    10. What does your current audit trail look like for document approvals?

    11. How are new team members trained on your document checking procedures?

    12. What compliance or regulatory requirements are you managing around document handling?

    13. How has the volume of files you're processing changed over the past two years?

    14. What frustrations do your team members express most often about the current document process?

    15. If you could change one thing about how documents flow through your operation, what would it be?

## 4. questions-cybersecurity-spin

Prompt:

    Generate a discovery question bank. Deal context: Beacon Metrics, VP Engineering, evaluation stage, preparing for SOC 2 renewal, currently tracks remediation in spreadsheets, security headcount is fixed this year. Sales vertical: SaaS cybersecurity. Sales methodology: SPIN. Question 1 must be exactly: If you don't solve this problem, what does that look like 12 months from now? Generate 14 additional open-ended questions numbered 2 to 15. Do not use binary or leading questions.

### Output A

    # Discovery Question Bank - Beacon Metrics

    1. If you don't solve this problem, what does that look like 12 months from now?

    2. Walk me through your current SOC 2 renewal process and where you're spending the most time today.

    3. How many security findings or remediation items are you currently tracking across your spreadsheets?

    4. What happens when a remediation task falls through the cracks or gets lost in your current tracking system?

    5. How are you currently communicating remediation status and timelines to your auditors or compliance team?

    6. Tell me about a time when a security issue took longer to resolve than expected—what caused that delay?

    7. With your fixed security headcount, how are you prioritizing which vulnerabilities or findings to address first?

    8. What would change for your team if you had real-time visibility into all active remediation efforts?

    9. How do you currently handle handoffs between your engineering teams and security team on remediation work?

    10. What's the impact on your business if a SOC 2 audit finding isn't resolved before your renewal deadline?

    11. How are you currently measuring whether your remediation efforts are actually closing findings effectively?

    12. What does success look like for your SOC 2 renewal compared to your last one?

    13. How much time do you estimate your team spends manually updating spreadsheets versus actually working on security improvements?

    14. If you could automate one part of your current remediation tracking process, what would have the biggest impact on your team?

    15. What would need to be true about a solution for your team to actually use it consistently throughout your audit cycle?

### Output B

    1. If you don't solve this problem, what does that look like 12 months from now?

    2. Walk me through how your current spreadsheet-based approach handles tracking remediation across your entire software development lifecycle.

    3. When SOC 2 auditors review your remediation process, what specific gaps or concerns have they raised in past cycles?

    4. How are you currently allocating your fixed security headcount across vulnerability identification, remediation tracking, and audit preparation?

    5. What happens when a critical vulnerability is discovered close to your SOC 2 renewal window?

    6. How do you ensure that remediation timelines are actually being met across different engineering teams without dedicated headcount to monitor them?

    7. Tell me about the last time a spreadsheet error or version control issue impacted your security reporting.

    8. What's your current timeline and process for gathering evidence and documentation for your SOC 2 auditors?

    9. How are engineering teams currently notified about vulnerabilities they need to remediate, and how do you track their progress?

    10. What would happen to your audit preparation timeline if you had to onboard a new security team member mid-cycle?

    11. How do you currently prioritize which vulnerabilities get attention first when your security team capacity is limited?

    12. What visibility do your executive stakeholders have into remediation status and security posture trends throughout the year?

    13. How are you planning to handle the compliance requirements and evidence collection for your next SOC 2 renewal given your current manual processes?

    14. What's preventing you from consolidating your security tracking into a more automated system today?

    15. How does your current approach to remediation tracking affect your ability to respond quickly when issues are discovered during customer security assessments?

## 5. summary-professional-services-pilot

Prompt:

    Generate a structured post-call summary. Raw notes: Priya confirmed six fee earners each spend about four hours per week checking incoming packs. Rework happens when names or dates do not match, but no error count is tracked. Priya will send ten anonymised sample packs by Friday. Idris will return a bounded pilot outline and security questions within three business days of receiving them. Managing partner must approve any pilot. No price was agreed. Deal context: Northbank Conveyancing, discovery stage. Output sections: Summary, Action Items, Commitments Made, Recommended Next Step.

### Output A

    Summary:
    Discovery call with Northbank Conveyancing. Priya confirmed six fee earners spend roughly four hours per week each checking incoming packs. Rework is triggered by mismatched names or dates, but error rates are not currently tracked. No pricing has been discussed or agreed. Managing partner approval is required before any pilot can proceed.

    Action Items:
    Priya to send ten anonymised sample packs by Friday.
    Idris to return a bounded pilot outline and security questions within three business days of receiving the sample packs.
    Managing partner approval to be obtained before pilot launch.

    Commitments Made:
    Priya committed to sending ten anonymised sample packs by Friday.
    Idris committed to returning a bounded pilot outline and security questions within three business days of receipt.

    Recommended Next Step:
    Confirm receipt of the sample packs and begin the three business day countdown for the pilot outline and security questions.

### Output B

    Post-Call Summary
    Northbank Conveyancing | Discovery Stage

    ---

    SUMMARY

    Northbank Conveyancing currently has six fee earners each spending approximately four hours per week manually reviewing incoming packs. Rework is triggered by name and date mismatches, though no formal error rate is tracked, so the full scope of the problem is unquantified. The conversation was exploratory. No solution was presented in detail, no pricing was discussed, and no commitments to purchase were made. Key dependencies for progressing to a pilot include managing partner approval and a review of sample pack data.

    ---

    ACTION ITEMS

    Priya: Send ten anonymised sample packs to the team by end of day Friday.
    Idris: Deliver a bounded pilot outline and a list of security questions within three business days of receiving the sample packs.
    Account team: Identify and confirm the managing partner as a required stakeholder for pilot approval, and plan for their inclusion in the next conversation.

    ---

    COMMITMENTS MADE

    Priya committed to providing ten anonymised sample packs by Friday.
    Idris committed to returning a pilot outline and security questions within three business days of receiving those packs.
    No pricing, timeline, or contractual commitments were made by either party.

    ---

    RECOMMENDED NEXT STEP

    Schedule a follow-up call with Priya, Idris, and the managing partner once Idris has delivered the pilot outline. The agenda should cover pilot scope, security requirements, and the approval process. Before that call, use the sample packs to produce a concrete illustration of where automation addresses the name and date mismatch issue, and prepare a method for establishing a baseline error rate, since the absence of tracked errors will otherwise weaken the business case.

## 6. summary-cybersecurity-review

Prompt:

    Generate a structured post-call summary. Raw notes: Marcus said technical validation is complete. Legal needs the data processing addendum and subprocessor list. Procurement requested a 20 percent discount; Marcus did not endorse it. Deployment before the October audit remains the target. Elena from our team will send the legal pack tomorrow. Marcus will schedule a procurement call for next week. No termination clause was accepted. Deal context: Alder Cloud, negotiation stage. Output sections: Summary, Action Items, Commitments Made, Recommended Next Step.

### Output A

    POST-CALL SUMMARY
    Account: Alder Cloud
    Stage: Negotiation

    ---

    SUMMARY

    Technical validation has been completed on the Alder Cloud side. The deal is now primarily held up by two workstreams: legal documentation and procurement terms. Legal requires the data processing addendum and subprocessor list before they can proceed. Procurement submitted a request for a 20 percent discount, which Marcus did not endorse. The customer's target remains deployment prior to their October audit. The termination clause proposed was not accepted.

    ---

    ACTION ITEMS

    Owner: Elena
    Deliver the legal pack, including the data processing addendum and subprocessor list, to Alder Cloud legal team by tomorrow.

    Owner: Marcus (Alder Cloud)
    Schedule a procurement call for next week to address the discount request.

    ---

    COMMITMENTS MADE

    Elena committed to sending the legal pack tomorrow.
    Marcus committed to scheduling the procurement call for next week.
    No termination clause was agreed to or accepted by either party.

    ---

    RECOMMENDED NEXT STEP

    Confirm receipt of the legal pack with Alder Cloud legal and lock in the procurement call date with Marcus. Use the procurement call to counter the 20 percent discount request with a prepared position that protects margin while keeping the October deployment timeline intact. Do not let the discount conversation drift without a documented counter-offer on the table.

### Output B

    Summary:
    Alder Cloud deal (negotiation stage). Technical validation is complete per Marcus. Legal requires the data processing addendum and subprocessor list before proceeding. Procurement asked for a 20 percent discount, which Marcus did not endorse. Target remains deployment before the October audit. No termination clause has been accepted.

    Action Items:
    Elena to send the legal pack (data processing addendum and subprocessor list) tomorrow.
    Marcus to schedule a procurement call for next week.
    Track resolution of the 20 percent discount request ahead of the procurement call.

    Commitments Made:
    Elena committed to sending the legal pack tomorrow.
    Marcus committed to scheduling a procurement call for next week.

    Recommended Next Step:
    Confirm delivery of the legal pack to Alder Cloud's legal team and align on procurement call timing to keep the October audit deployment target on track.

## 7. email-professional-services-pilot

Prompt:

    Generate a professional follow-up email under 150 words. Call summary: Priya confirmed six fee earners spend about four hours each per week checking incoming packs. Priya will send ten anonymised sample packs by Friday. Idris will return a bounded pilot outline and security questions within three business days of receipt. The managing partner must approve any pilot. No price was agreed. End with a separate Subject: line.

### Output A

    Hi Priya,

    Thank you for the productive conversation today. I appreciated you sharing the current workflow details—it's clear that the four hours weekly per fee earner across your team represents a meaningful opportunity for efficiency gains.

    As discussed, I'm looking forward to reviewing the ten anonymised sample packs you'll send by Friday. This will help us understand your specific pack characteristics and processing requirements.

    I'll prepare a bounded pilot outline and security questions within three business days of receipt. We can then move toward formal approval from your managing partner.

    I'm excited about exploring how we can support your team. Please let me know if you need anything from my end in the meantime.

    Best regards,
    [Your name]

    ---

    Subject: Follow-up: Sample Pack Review and Pilot Planning

### Output B

    Hi Priya,

    Thank you for today's call and for sharing those insights. It's clear that the current manual review process—six fee earners spending four hours weekly—represents a meaningful opportunity for optimization.

    We look forward to receiving the ten anonymised sample packs by Friday. Once Idris has reviewed them, he'll prepare a bounded pilot outline and our security questionnaire within three business days. We understand your managing partner will need to approve any pilot phase before we proceed.

    We'll keep next steps straightforward and focused on demonstrating value within your firm's governance framework.

    Thanks again for your time and partnership on this.

    Best regards,
    [Your name]

    ---

    Subject: Follow-up: Sample Packs and Pilot Next Steps

## 8. email-cybersecurity-review

Prompt:

    Generate a professional follow-up email under 150 words. Call summary: Technical validation is complete. Elena will send the data processing addendum and subprocessor list tomorrow. Marcus will schedule a procurement call for next week. Procurement requested a 20 percent discount, but no discount or termination clause was accepted. Deployment before the October audit remains the target. End with a separate Subject: line.

### Output A

    Thank you for the productive call today. We've made excellent progress on your implementation.

    As discussed, Elena will send the data processing addendum and subprocessor list tomorrow for your review. Marcus will reach out early next week to schedule the procurement call.

    Regarding pricing, we appreciate your team's interest in a discount. Our current terms reflect the value and support we provide. We're confident the investment delivers strong ROI, and we're committed to meeting your October audit deadline with a successful deployment.

    Please let us know if you have questions on the documentation or need anything before the procurement conversation.

    We look forward to moving forward together.

    Best regards,

    Subject: Technical Validation Complete – Next Steps

### Output B

    Dear [Client Name],

    Thank you for the productive technical validation meeting. We're pleased to confirm that the implementation remains on track for deployment before your October audit.

    As discussed, Elena will send the data processing addendum and subprocessor list tomorrow for your review. We're committed to addressing any questions promptly.

    Marcus will reach out next week to schedule the procurement call. Regarding the discount request, we appreciate your interest and remain confident that our solution's value and deployment timeline justify the current pricing structure. We're eager to move forward with the established terms.

    Please let us know if you need anything in the interim.

    Best regards,
    [Your Name]

    ---

    Subject: Technical Validation Complete – Next Steps & Procurement Call
