import SwiftUI

// MARK: - Sales Methodology

enum SalesMethodology: String, CaseIterable, Identifiable, Codable, Sendable {
    case meddic    = "MEDDIC"
    case meddpicc  = "MEDDPICC"
    case spin      = "SPIN"
    case bant      = "BANT"
    case challenger = "Challenger"
    case sandler   = "Sandler"
    case other     = "Other"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .meddic:
            return "Metrics, Economic Buyer, Decision Criteria, Decision Process, Identify Pain, Champion"
        case .meddpicc:
            return "MEDDIC + Paper Process + Competition — enterprise deal qualification"
        case .spin:
            return "Situation, Problem, Implication, Need-Payoff — pain-first discovery"
        case .bant:
            return "Budget, Authority, Need, Timeline — fast qualification"
        case .challenger:
            return "Teach, Tailor, Take Control — reframe the buyer's thinking"
        case .sandler:
            return "Pain, Budget, Decision — disqualify early, close with conviction"
        case .other:
            return "Custom or hybrid methodology"
        }
    }

    var bestFor: String {
        switch self {
        case .meddic:    return "Enterprise SaaS, complex multi-stakeholder deals"
        case .meddpicc:  return "Large enterprise, long sales cycles, procurement-heavy"
        case .spin:      return "Consultative B2B, professional services, mid-market"
        case .bant:      return "SMB, transactional, short sales cycles"
        case .challenger: return "Competitive markets, status-quo disruption"
        case .sandler:   return "High-value deals, trusted advisor relationships"
        case .other:     return "Flexible — apply your own framework"
        }
    }

    var promptGuidance: String {
        switch self {
        case .meddic:
            return """
            Use the MEDDIC framework throughout: qualify Metrics (quantified business impact), \
            identify the Economic Buyer (who controls budget), surface Decision Criteria \
            (how they will evaluate), map the Decision Process (steps to yes), confirm \
            Identified Pain (critical business problem), and develop a Champion (internal advocate). \
            Every question should advance one of these six dimensions.
            """
        case .meddpicc:
            return """
            Use the MEDDPICC framework: all MEDDIC dimensions plus Paper Process \
            (procurement, legal, security review steps) and Competition (who else is in the deal \
            and what criteria favour them). Surface paper process blockers early — \
            'What does your procurement review typically look like for a purchase at this level?' \
            Map competition without disparaging — understand their evaluation criteria instead.
            """
        case .spin:
            return """
            Use the SPIN sequence: open with Situation questions to establish context (keep brief), \
            move to Problem questions to surface explicit pain, then Implication questions to \
            amplify the cost of inaction ('What happens to the team if this isn't solved by Q3?'), \
            and close with Need-Payoff questions that let the buyer articulate the value themselves \
            ('How much time would that save your team each week?'). Never pitch — let them sell themselves.
            """
        case .bant:
            return """
            Qualify efficiently using BANT: confirm Budget (has it been allocated or is this exploratory?), \
            Authority (is this person the decision-maker or do others need to approve?), \
            Need (is the pain specific and urgent, or vague?), and Timeline (is there a driver — \
            a deadline, a renewal, a headcount freeze?). Use BANT to disqualify fast and \
            focus effort on winnable deals.
            """
        case .challenger:
            return """
            Use the Challenger approach: Teach something they didn't know about their own business \
            (a cost they haven't measured, a risk they've underweighted), Tailor the insight \
            to their specific role and priorities, then Take Control of the next step with a \
            concrete recommendation — not a question. Reframe the status quo as the risk, \
            not the change. The goal is to make inaction feel more dangerous than action.
            """
        case .sandler:
            return """
            Use the Sandler framework: establish equal business stature (you are the expert they \
            need, not a vendor pitching). Surface Pain at three levels — surface, business impact, \
            personal impact on the buyer. Confirm Budget early and honestly. Map the Decision \
            process and get explicit up-front contracts ('If this solves the problem and fits \
            the budget, is there any reason we wouldn't move forward?'). \
            Disqualify ruthlessly — only advance deals where all three are confirmed.
            """
        case .other:
            return """
            Apply discovery best practices: ask open-ended questions, quantify pain where possible, \
            identify the decision-maker and process, and always anchor the conversation to the \
            cost of the status quo rather than your solution's features.
            """
        }
    }

    var accentColor: Color {
        switch self {
        case .meddic:    return Color(red: 0.20, green: 0.52, blue: 0.98)  // blue
        case .meddpicc:  return Color(red: 0.44, green: 0.28, blue: 0.98)  // indigo
        case .spin:      return Color(red: 0.20, green: 0.78, blue: 0.60)  // teal
        case .bant:      return Color(red: 0.98, green: 0.65, blue: 0.20)  // amber
        case .challenger: return Color(red: 0.98, green: 0.30, blue: 0.40) // red
        case .sandler:   return Color(red: 0.60, green: 0.20, blue: 0.98)  // purple
        case .other:     return Color.secondary
        }
    }

    /// Returns the recommended methodology for a given vertical.
    static func recommended(for vertical: SalesVertical) -> SalesMethodology {
        switch vertical {
        case .enterprise:      return .meddic
        case .recruitment:     return .spin
        case .accountancy:     return .spin
        case .estateAgents:    return .spin
        case .ecommerce:       return .bant
        case .marketingAgency: return .spin
        case .aiAgency:        return .sandler
        }
    }
}
