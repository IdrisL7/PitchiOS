import Foundation

// MARK: - Sales Vertical

/// Source: Mike Scully @Mike_Scully_ / casuallyconvert.com AI Services cheat sheet
/// + enterprise SaaS pre-sales best practices

enum SalesVertical: String, CaseIterable, Identifiable, Codable, Sendable {
    case enterprise      = "Enterprise SaaS"
    case recruitment     = "Recruitment"
    case accountancy     = "Accountancy"
    case estateAgents    = "Estate Agents"
    case ecommerce       = "eCommerce"
    case marketingAgency = "Marketing Agency"
    case aiAgency        = "AI Services / Agency"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .enterprise:      return "🏢"
        case .recruitment:     return "👥"
        case .accountancy:     return "📊"
        case .estateAgents:    return "🏠"
        case .ecommerce:       return "🛒"
        case .marketingAgency: return "📣"
        case .aiAgency:        return "🤖"
        }
    }
}

// MARK: - Template data per vertical

struct VerticalTemplate: Sendable {
    let vertical: SalesVertical
    let buyerTitles: [String]
    let industries: [String]
    let topPains: [String]
    let differentiators: [String]
    let discoveryQuestions: [String]   // pinned to top of question bank
    let roiHook: String                // injected into the system prompt
    let commonObjections: [String]     // pre-loaded into objection context
    let methodology: String
}

// MARK: - Template library

enum VerticalTemplates {

    static func template(for vertical: SalesVertical) -> VerticalTemplate {
        switch vertical {
        case .enterprise:      return enterpriseSaaS
        case .recruitment:     return recruitment
        case .accountancy:     return accountancy
        case .estateAgents:    return estateAgents
        case .ecommerce:       return ecommerce
        case .marketingAgency: return marketingAgency
        case .aiAgency:        return aiAgency
        }
    }

    // MARK: Enterprise SaaS (default)
    static let enterpriseSaaS = VerticalTemplate(
        vertical: .enterprise,
        buyerTitles: ["VP of Sales", "Chief Revenue Officer", "Head of Solutions", "VP Engineering", "CPTO"],
        industries: ["FinTech", "HRTech", "MedTech", "LegalTech", "GovTech"],
        topPains: [
            "Long sales cycles with poor visibility at each stage",
            "SEs and AEs spending 60%+ of time on non-selling admin",
            "Inconsistent demo quality across the team",
            "Poor post-call follow-through losing warm deals"
        ],
        differentiators: [
            "AI-native workflow built for enterprise sales motion",
            "ICP-calibrated outputs — not generic prompts",
            "Native iOS — works in the field, not just at a desk"
        ],
        discoveryQuestions: [
            "If you don't solve this with automation, what does that look like?",
            "What's eating most of your team's non-selling time right now?",
            "How does your team currently prep for discovery calls?",
            "What happens to deal momentum when follow-ups are slow?",
            "How do you currently handle objections your team hasn't seen before?"
        ],
        roiHook: "The cost of manual prep and admin across your SE team is measurable. If each SE spends 8 hours/week on non-selling work, that's [X × hourly rate × 52] in senior staff time every year — before accounting for deals lost to poor preparation.",
        commonObjections: [
            "We already use ChatGPT",
            "It's too expensive right now",
            "We need to think about it",
            "Our team already has a process"
        ],
        methodology: SalesMethodology.meddic.rawValue
    )

    // MARK: Recruitment
    static let recruitment = VerticalTemplate(
        vertical: .recruitment,
        buyerTitles: ["Head of Talent", "VP People", "Talent Acquisition Manager", "Recruitment Director", "People Operations Lead"],
        industries: ["Staffing", "Executive Search", "In-house Talent", "RPO"],
        topPains: [
            "Manual CV screening consuming hours of recruiter time daily",
            "Slow candidate follow-up losing top talent to competitors",
            "Inconsistent candidate experience across the team",
            "No visibility on which job specs attract quality applications"
        ],
        differentiators: [
            "Reduces CV screening time by automating initial triage",
            "Follow-up templates that feel personal, sent in seconds",
            "Candidate pipeline visibility without spreadsheets"
        ],
        discoveryQuestions: [
            "If you don't solve this with automation, what does that look like?",
            "How many CVs does your team manually screen per week?",
            "What's your average response time to a new candidate application?",
            "How much of a recruiter's week is spent on admin vs. actual placement work?",
            "What's the cost to you when a strong candidate ghosts because follow-up was slow?",
            "How do you currently track where candidates are dropping out of the funnel?",
            "What would your team do with 10 extra hours a week?"
        ],
        roiHook: "At minimum wage, one full-time hire to handle CV screening and follow-up costs £27K/year in salary alone — before NI, pension, and management overhead. If automation handles 80% of that work, the ROI calculation is straightforward.",
        commonObjections: [
            "We already use an ATS for this",
            "It's too expensive right now",
            "We tried automation before and it felt impersonal",
            "What if it breaks during a live campaign?"
        ],
        methodology: SalesMethodology.spin.rawValue
    )

    // MARK: Accountancy
    static let accountancy = VerticalTemplate(
        vertical: .accountancy,
        buyerTitles: ["Managing Partner", "Practice Manager", "Head of Operations", "Finance Director", "Client Services Director"],
        industries: ["Accounting Practice", "Bookkeeping", "Tax Advisory", "Audit", "CFO Services"],
        topPains: [
            "Senior accountants spending billable hours on data entry",
            "Chasing clients for documents delays every month-end close",
            "Manual reconciliation creates errors and rework cycles",
            "No automated reminders means staff have to follow up manually"
        ],
        differentiators: [
            "Automates document chasing — clients get reminders without staff involvement",
            "Reduces data entry time so senior staff focus on advisory work",
            "Month-end close happens faster with less manual coordination"
        ],
        discoveryQuestions: [
            "If you don't solve this with automation, what does that look like?",
            "What percentage of your team's week is spent chasing clients for documents?",
            "How long does your average month-end close take from data receipt to sign-off?",
            "How much of a qualified accountant's time is spent on data entry vs advisory work?",
            "What's the cost to your practice when month-end is delayed by missing documents?",
            "How do you currently send reminders to clients about outstanding items?",
            "If you could give your senior staff 6 hours a week back, what would they do with it?"
        ],
        roiHook: "In most practices, qualified accountants spend 2–3 hours daily on tasks a system could handle. At a blended rate of £45/hour, that's £450/week per person — or £23K/year — in senior staff time spent on admin that produces no advisory value.",
        commonObjections: [
            "We already use Xero / QuickBooks for this",
            "Our clients won't trust automated communications",
            "It's too expensive for a firm our size",
            "We need to think about it — it's a busy period"
        ],
        methodology: SalesMethodology.spin.rawValue
    )

    // MARK: Estate Agents
    static let estateAgents = VerticalTemplate(
        vertical: .estateAgents,
        buyerTitles: ["Branch Manager", "Director", "Head of Sales", "Lettings Manager", "Operations Director"],
        industries: ["Residential Sales", "Lettings", "Commercial Property", "Property Management", "New Homes"],
        topPains: [
            "Slow response to new enquiries losing instructions to faster competitors",
            "Manual property-to-buyer matching consuming negotiator time",
            "Follow-up calls not happening because staff are too busy",
            "No automated nurture for buyers not yet ready to commit"
        ],
        differentiators: [
            "First response to new enquiry in under 6 minutes, not 6 hours",
            "Automated buyer-property matching frees negotiator time for hot leads",
            "Systematic follow-up nurture that works even when staff are on viewings"
        ],
        discoveryQuestions: [
            "If you don't solve this with automation, what does that look like?",
            "What's your average response time to a new buyer or vendor enquiry?",
            "How much of a negotiator's day is spent on manual admin vs. client-facing work?",
            "How many enquiries do you lose each month because follow-up was too slow?",
            "What's an instruction worth to your branch on average?",
            "How do you currently nurture buyers who aren't ready to act yet?",
            "The first agent to respond wins most instructions — how does your team stack up?"
        ],
        roiHook: "Research shows the first agent to respond wins 70–80% of instructions. If your branch receives 40 enquiries/month and you're second to respond on 30%, you're losing 12 potential instructions. At an average fee of £4,500, that's £54K/year in missed revenue from slow response alone.",
        commonObjections: [
            "We already have a CRM that handles this",
            "Our clients expect to speak to a person, not a bot",
            "It's too expensive for our branch size",
            "We tried something like this before and it didn't work"
        ],
        methodology: SalesMethodology.spin.rawValue
    )

    // MARK: eCommerce
    static let ecommerce = VerticalTemplate(
        vertical: .ecommerce,
        buyerTitles: ["COO", "Head of Finance", "eCommerce Director", "CFO", "Operations Manager"],
        industries: ["DTC eCommerce", "Marketplace Seller", "Subscription Commerce", "Wholesale", "Consumer Goods"],
        topPains: [
            "P&L reporting built in spreadsheets — manual, error-prone, always delayed",
            "No real-time visibility on margin by channel or SKU",
            "Finance team closing the books days late every month",
            "Data sitting in Shopify, Amazon, and spreadsheets — never in one place"
        ],
        differentiators: [
            "Automated P&L that pulls from all channels into one view",
            "Real-time margin visibility by SKU, channel, and campaign",
            "Month-end close in hours, not days"
        ],
        discoveryQuestions: [
            "If you don't solve this with automation, what does that look like?",
            "How long does your monthly P&L take to produce from first data pull to sign-off?",
            "How many systems does your finance team pull data from manually each month?",
            "Do you have real-time visibility on margin by SKU and channel, or is that a monthly exercise?",
            "When you need to make a pricing or inventory decision, how quickly can you get the data?",
            "What's the cost to your business when a margin issue isn't caught until month-end?",
            "What would your CFO do with 3 extra days each month?"
        ],
        roiHook: "If your finance team spends 3 days on manual reporting every month, that's 36 days/year — equivalent to 1.5 months of a senior finance salary — spent producing a report that could be automated. The build cost pays for itself in under 6 months.",
        commonObjections: [
            "We already have an accountant who does this",
            "It's too expensive for where we are right now",
            "Our data is too messy to automate",
            "We need to think about it — we're in a busy trading period"
        ],
        methodology: SalesMethodology.spin.rawValue
    )

    // MARK: Marketing Agency
    static let marketingAgency = VerticalTemplate(
        vertical: .marketingAgency,
        buyerTitles: ["Agency Director", "Head of Client Services", "Managing Director", "Head of Paid Media", "Client Partnerships Director"],
        industries: ["Digital Agency", "Performance Marketing", "PR & Comms", "Content Agency", "Full-Service Agency"],
        topPains: [
            "Client reporting built manually in PowerPoint every month",
            "No live dashboard — clients email asking for numbers",
            "Account managers spending 30% of their time on report production",
            "Reporting delays create renewal risk conversations"
        ],
        differentiators: [
            "Live client dashboards that replace monthly PDF reports",
            "Account managers spend time on strategy, not spreadsheets",
            "Reporting becomes a retention tool, not a chore"
        ],
        discoveryQuestions: [
            "If you don't solve this with automation, what does that look like?",
            "How much of an account manager's week currently goes on reporting?",
            "How do your clients currently access campaign performance between reports?",
            "How often do clients email or call asking for numbers you have to pull manually?",
            "Has slow or unclear reporting ever created a renewal risk with a client?",
            "What would your team do with 10 extra hours a week per account manager?",
            "What would it do for client satisfaction if they had a live dashboard instead of a monthly PDF?"
        ],
        roiHook: "If each account manager spends 8 hours/month on manual reporting across their client portfolio, and you have 5 AMs, that's 480 hours/year — 60 working days — spent producing something a dashboard could replace. At a blended AM rate of £40/hour, that's £19,200/year in team time on a task that should be automated.",
        commonObjections: [
            "We already use Looker Studio / Google Data Studio for this",
            "Our clients like receiving a monthly report — it's a touchpoint",
            "It's too expensive to set up for each client",
            "We tried a dashboard tool before and clients didn't use it"
        ],
        methodology: SalesMethodology.spin.rawValue
    )

    // MARK: AI Services / Agency
    /// The secondary PitchOS user — selling automation services to SMBs.
    /// Source: Mike Scully @Mike_Scully_ / casuallyconvert.com "Become an Integrator" guide.
    static let aiAgency = VerticalTemplate(
        vertical: .aiAgency,
        buyerTitles: ["Operations Manager", "Business Owner", "Managing Director", "Head of Operations", "Office Manager"],
        industries: ["Professional Services", "SMB Retail", "Healthcare Practice", "Legal Practice", "Property"],
        topPains: [
            "Manual processes that could be automated but haven't been",
            "Staff spending time on repetitive admin instead of value-adding work",
            "No visibility on operational bottlenecks until something breaks",
            "Business owner still involved in work that should run without them"
        ],
        differentiators: [
            "End-to-end automation that runs without your team touching it",
            "Built for your specific workflow — not a generic tool",
            "You pay once or retain monthly — the system works 24/7"
        ],
        discoveryQuestions: [
            // THE closing question from the cheat sheet — always pinned first
            "If you don't solve this with automation, what does that look like?",
            "What's eating most of your team's time right now?",
            "If you hired someone full-time to handle this, what would that cost?",
            "What happens to this process when your key person is on holiday?",
            "How much of the owner's time is still involved in day-to-day operations?",
            "What would you do with 20 hours a week back in your business?",
            "Have you tried solving this before? What happened?"
        ],
        roiHook: "The ROI calculation is straightforward: hiring someone full-time to do this work costs minimum wage × 37.5hrs × 52 weeks = £27K+/year in salary alone — before NI, pension, and management time. A one-time automation build at £5–12K pays for itself in under 6 months and runs forever.",
        // All 4 objections verbatim from the Mike Scully cheat sheet
        commonObjections: [
            "We already use ChatGPT",
            "It's too expensive right now",
            "We need to think about it",
            "What if it breaks?"
        ],
        methodology: SalesMethodology.sandler.rawValue
    )
}

// MARK: - Curated Objections
// Verbatim responses from Mike Scully @Mike_Scully_ / casuallyconvert.com
// Pre-loaded into objection handler context for each vertical.

struct CuratedObjection: Identifiable, Sendable {
    let id: UUID
    let objection: String
    let response: String
    let vertical: SalesVertical?  // nil = universal

    init(objection: String, response: String, vertical: SalesVertical? = nil) {
        self.id       = UUID()
        self.objection = objection
        self.response  = response
        self.vertical  = vertical
    }
}

enum CuratedObjections {

    static let universal: [CuratedObjection] = [
        CuratedObjection(
            objection: "We already use ChatGPT",
            response: "Using a tool and building a system around it are different. I build the workflow that runs 24/7 without your team touching it."
        ),
        CuratedObjection(
            objection: "It's too expensive right now",
            response: "What's the cost of keeping it manual? One full-time hire costs more than this every year, forever."
        ),
        CuratedObjection(
            objection: "We need to think about it",
            response: "While you do, the manual process costs you X hours this week. When's the right time to start saving them?"
        ),
        CuratedObjection(
            objection: "What if it breaks?",
            response: "The retainer covers that. You're not buying software, you're buying a managed service."
        ),
    ]

    static let enterpriseSaaS: [CuratedObjection] = [
        CuratedObjection(
            objection: "Our team already has a process",
            response: "Most teams do. The question is whether the process is costing you deals. How much time does your team spend on prep and admin per call right now?",
            vertical: .enterprise
        ),
        CuratedObjection(
            objection: "The team won't adopt another tool",
            response: "That's a fair concern. Adoption comes down to whether the tool saves time on day one. Every feature in PitchOS is built around saving time in the workflow your team already has.",
            vertical: .enterprise
        ),
    ]

    static func objections(for vertical: SalesVertical) -> [CuratedObjection] {
        switch vertical {
        case .enterprise: return universal + enterpriseSaaS
        default:          return universal
        }
    }
}
