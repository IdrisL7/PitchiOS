import Foundation

// MARK: - User Plan

enum UserPlan: String, Codable, Sendable, CaseIterable {
    case free = "free"
    case pro  = "pro"
    case team = "team"

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro:  return "Pro"
        case .team: return "Team"
        }
    }

    var icon: String {
        switch self {
        case .free: return "person.fill"
        case .pro:  return "bolt.fill"
        case .team: return "person.3.fill"
        }
    }

    /// `true` for paid plans — no generation cap.
    var isUnlimited: Bool { self == .pro || self == .team }

    var monthlyLimit: Int {
        switch self {
        case .free: return AppConfig.freeGenerationsPerMonth
        case .pro, .team: return Int.max
        }
    }
}

// MARK: - Profile

struct Profile: Codable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var role: String
    var product: String
    var industries: [String]
    var buyerTitles: [String]
    var methodology: String
    var differentiators: [String]
    var plan: UserPlan
    var vertical: String
    // Team metadata — nil for free / pro
    var teamName: String?
    var teamSeatCount: Int?
    var teamSeatUsed: Int?
    var teamIsAdmin: Bool
    let createdAt: Date
    var updatedAt: Date

    /// Typed access to the stored vertical string.
    var salesVertical: SalesVertical {
        SalesVertical(rawValue: vertical) ?? .enterprise
    }

    /// Typed access to the stored methodology string.
    var salesMethodology: SalesMethodology {
        SalesMethodology(rawValue: methodology) ?? .meddic
    }

    enum CodingKeys: String, CodingKey {
        case id, name, role, product, industries, plan, vertical
        case buyerTitles    = "buyer_titles"
        case methodology    = "methodologies"
        case differentiators
        case teamName       = "team_name"
        case teamSeatCount  = "team_seat_count"
        case teamSeatUsed   = "team_seat_used"
        case teamIsAdmin    = "team_is_admin"
        case createdAt      = "created_at"
        case updatedAt      = "updated_at"
    }

    // Custom decoder — gracefully handles columns absent in older rows.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id              = try  c.decode(UUID.self,     forKey: .id)
        name            = try  c.decode(String.self,   forKey: .name)
        role            = try  c.decode(String.self,   forKey: .role)
        product         = try  c.decode(String.self,   forKey: .product)
        industries      = try  c.decode([String].self, forKey: .industries)
        buyerTitles     = try  c.decode([String].self, forKey: .buyerTitles)
        methodology     = try  c.decode(String.self,   forKey: .methodology)
        differentiators = try  c.decode([String].self, forKey: .differentiators)
        plan            = (try? c.decode(UserPlan.self,  forKey: .plan))         ?? .free
        vertical        = (try? c.decode(String.self,   forKey: .vertical))      ?? SalesVertical.enterprise.rawValue
        teamName        = try? c.decode(String.self,     forKey: .teamName)
        teamSeatCount   = try? c.decode(Int.self,        forKey: .teamSeatCount)
        teamSeatUsed    = try? c.decode(Int.self,        forKey: .teamSeatUsed)
        teamIsAdmin     = (try? c.decode(Bool.self,      forKey: .teamIsAdmin))  ?? false
        createdAt       = try  c.decode(Date.self,     forKey: .createdAt)
        updatedAt       = try  c.decode(Date.self,     forKey: .updatedAt)
    }

    // Memberwise init used by previews / tests / AppState.preview
    init(
        id: UUID,
        name: String,
        role: String,
        product: String,
        industries: [String],
        buyerTitles: [String],
        methodology: String,
        differentiators: [String],
        plan: UserPlan = .free,
        vertical: String = SalesVertical.enterprise.rawValue,
        teamName: String? = nil,
        teamSeatCount: Int? = nil,
        teamSeatUsed: Int? = nil,
        teamIsAdmin: Bool = false,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id              = id
        self.name            = name
        self.role            = role
        self.product         = product
        self.industries      = industries
        self.buyerTitles     = buyerTitles
        self.methodology     = methodology
        self.differentiators = differentiators
        self.plan            = plan
        self.vertical        = vertical
        self.teamName        = teamName
        self.teamSeatCount   = teamSeatCount
        self.teamSeatUsed    = teamSeatUsed
        self.teamIsAdmin     = teamIsAdmin
        self.createdAt       = createdAt
        self.updatedAt       = updatedAt
    }

    /// Renders the ICP context block injected into every AI prompt.
    var promptContext: String {
        """
        The user's context:
        - Name: \(name)
        - Role: \(role)
        - Product they sell: \(product)
        - Sales vertical: \(vertical)
        - Target industries: \(industries.joined(separator: ", "))
        - Primary buyer titles: \(buyerTitles.joined(separator: ", "))
        - Sales methodology: \(methodology)
        - Top 3 differentiators: \(differentiators.joined(separator: "; "))

        Methodology guidance:
        \(salesMethodology.promptGuidance)
        """
    }
}
