import Foundation

enum Prompts {

    // MARK: - Base System Prompt

    static func systemPrompt(profile: Profile) -> String {
        let template = VerticalTemplates.template(for: profile.salesVertical)
        let pains    = template.topPains.map { "- \($0)" }.joined(separator: "\n")

        return """
        You are PitchOS, an AI assistant built specifically for enterprise B2B solutions engineers \
        and account executives.

        \(profile.promptContext)

        Common pains in the \(profile.vertical) vertical:
        \(pains)

        ROI framing for this vertical:
        \(template.roiHook)

        Your outputs must:
        1. Be precise and directly actionable — no filler, no preamble
        2. Sound like they were written by a senior SE with 10+ years experience
        3. Reflect enterprise B2B norms (formal but warm, data-driven, buyer-centric)
        4. Be formatted for quick reading on mobile (short paragraphs, plain bullets where appropriate)
        5. Never suggest dishonest or manipulative tactics

        Formatting rules — strictly follow these:
        - Write in plain text only. No markdown whatsoever.
        - Do not use ##, **, *, |, ---, or any other markdown syntax.
        - Use plain section labels followed by a colon and a new line, e.g. "Summary:" not "## Summary"
        - Use a dash (-) for bullet points, nothing else.
        - Do not draw tables. Use short numbered lines instead.

        Always calibrate your language and examples to the \(profile.vertical) context.
        """
    }

    // MARK: - Objection Handler
    // v2.2.0 — ROI reframe rule added, vertical-aware context, keep <130 words

    enum ObjectionHandler {
        static let version = "objection_v2.2"

        static func userPrompt(objection: String, dealContext: String?, vertical: String) -> String {
            """
            A prospect has raised this objection during a sales call:

            "\(objection)"

            \(dealContext ?? "")
            Sales vertical: \(vertical)

            Respond using the Acknowledge, Reframe, Advance framework. Keep the total response under 130 words.

            REFRAME RULE — the Reframe section must anchor to ONE of:
            (a) A cost-of-inaction calculation ("while you wait, this process costs X")
            (b) A headcount/hire comparison ("one full-time hire costs more than this annually, forever")
            (c) A time-to-value anchor ("you could start saving X hours/week within 2 weeks")
            Never reframe with features or capability lists. Always reframe with the cost of the status quo.

            Acknowledge:
            1-2 sentences. Validate their concern genuinely. Don't be defensive.

            Reframe:
            2-3 sentences. Anchor to the cost of inaction — a number, a hire comparison, or a time calculation.

            Advance:
            1 sentence moving forward + 1 open question to keep dialogue open. Not a binary yes/no question.

            Tone: confident but not combative.
            Do not use phrases like "great question", "I understand your concern", "absolutely", or "certainly".
            Write in plain text — no markdown, no special characters.
            """
        }
    }

    // MARK: - Post-Call Summary

    enum PostCallSummary {
        static let version = "summary_v1.0"

        static func userPrompt(notes: String, dealContext: String?) -> String {
            """
            The following are notes from a sales call. Generate a structured summary.

            Raw notes:
            \(notes)

            \(dealContext ?? "")

            Output format (plain text only, no markdown, no special characters):

            Summary:
            - [What was discussed]
            - [What mattered most to them]
            - [Where the deal stands]

            Action Items:
            List each item with the owner (SE or prospect name) and an implied deadline, one per line.

            Commitments Made:
            Any promises or commitments made by either party, one per line.

            Recommended Next Step:
            One specific, concrete next action with a suggested timeframe.

            Keep language precise. Avoid vague phrases like "discussed various topics".
            """
        }
    }

    // MARK: - Follow-Up Email

    enum FollowUpEmail {
        static let version = "email_v1.0"

        static func userPrompt(summary: String, dealContext: String?) -> String {
            """
            Based on this call summary, generate a professional follow-up email.

            Call summary:
            \(summary)

            \(dealContext ?? "")

            The email should:
            1. Open with a brief thank-you referencing a specific topic from the call
            2. Recap 2-3 key points discussed
            3. Confirm agreed next steps with owners
            4. Close with a specific call-to-action

            Tone: warm but professional. Enterprise B2B standard. Under 150 words.
            Do not include a subject line — generate one separately at the end prefixed with "Subject: ".
            """
        }
    }

    // MARK: - Discovery Questions
    // v1.4.0 — ROI closing question pinned first, vertical-aware

    enum DiscoveryQuestions {
        static let version = "questions_v1.4"

        static func userPrompt(dealContext: String?, vertical: String, methodology: String) -> String {
            """
            Generate a discovery question bank for this prospect meeting.

            \(dealContext ?? "")
            Sales vertical: \(vertical)
            Sales methodology: \(methodology)

            PINNED QUESTION — always include this as Question 1. It is the single most powerful \
            closing question for any automation or efficiency sale. Never omit it:
            "If you don't solve this problem, what does that look like 12 months from now?"

            Generate 14 additional questions tailored to this specific prospect. \
            Questions should progress through the \(methodology) framework. \
            Calibrate to the prospect's role — a VP asks about outcomes and ROI, \
            a manager asks about process and team impact.

            Format (plain text only):

            The ROI closer (always ask this):
            1. [pinned question verbatim]

            \(methodology) discovery questions:
            2-15. [numbered questions, one per line]

            Each question must be open-ended. No binary yes/no questions. \
            No leading questions that telegraph your solution.
            """
        }
    }

    // MARK: - Business Case
    // v1.2.0 — full ROI framework, vertical-specific hook, calculation shown not just narrative

    enum BusinessCase {
        static let version = "business_case_v1.2"

        private static let roiFramework = """
        ROI calculation — use this order of preference:
        1. Alternative cost: "What would hiring someone to do this manually cost?" \
        Calculate: hourly rate × hours/week × 52 weeks. Compare to annual contract value.
        2. Time recaptured: "How many hours/week does this currently take?" \
        Calculate: hours × loaded hourly rate × 52. Frame as "£X/year of senior staff time on manual work."
        3. Revenue risk: "What deals or instructions are lost due to slow response or poor preparation?" \
        Calculate: losses per quarter × average deal value.
        Always present ROI as "cost of the status quo vs cost of the solution," never as feature lists.
        """

        static func userPrompt(
            dealContext: String?,
            vertical: String,
            roiHook: String,
            hoursPerWeek: Int,
            teamSize: Int,
            hourlyRate: Int,
            contractValue: String
        ) -> String {
            let annualCost = hoursPerWeek * teamSize * hourlyRate * 52
            return """
            Generate a structured business case document.

            \(dealContext ?? "")
            Sales vertical: \(vertical)
            Hours/week on current manual process: \(hoursPerWeek)
            Team size affected: \(teamSize)
            Loaded hourly rate (£): \(hourlyRate)
            Calculated annual cost of status quo: £\(annualCost)
            Solution contract value: \(contractValue)

            \(roiFramework)

            ROI hook for this vertical:
            \(roiHook)

            Format (plain text only, no markdown):

            Executive Summary:
            3 sentences: problem, solution, ROI. Written for C-suite with 30 seconds.

            The Problem:
            2-3 paragraphs. Current manual process and its measurable cost.

            ROI Calculation:
            Manual process cost: £[hours] × £[rate] × [team] × 52 = £[annual cost]
            Solution cost: [contract value]
            Year 1 net saving: £[annual cost minus contract value]
            Payback period: [months]

            The Solution:
            2 paragraphs. What changes. What the team gets back. Outcomes, not features.

            Risks and Mitigations:
            3 bullet points. Risk — Mitigation format.

            Recommended Next Step:
            One specific action with a timeframe.

            Write professionally and directly. Shareable internally without editing.
            """
        }
    }

    // MARK: - Meeting Brief

    enum MeetingBrief {
        static let version = "brief_v1.0"

        static func userPrompt(dealContext: String?) -> String {
            """
            Generate a concise pre-call meeting brief to prepare for a prospect conversation.

            \(dealContext ?? "")

            Structure the brief in plain text using these sections:

            Prospect Snapshot:
            2-3 sentences on who they are, what they do, and why they're talking to us.

            Likely Priorities:
            3-4 bullet points on what this buyer type typically cares about, based on their role and industry.

            Key Risks:
            2-3 potential objections or concerns to anticipate going in.

            Recommended Focus:
            1-2 sentences on the angle most likely to resonate — what to lead with and why.

            Suggested First Question:
            One strong, open-ended question to open the conversation.

            Keep each section tight and specific. No generic filler. Under 200 words total.
            Write in plain text — no markdown, no special characters.
            """
        }
    }
}
