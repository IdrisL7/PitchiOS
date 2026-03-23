import Foundation

struct Deal: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let userId: UUID
    var companyName: String
    var contactName: String
    var contactRole: String
    var stage: DealStage
    var outcome: DealOutcome?
    var notes: String?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case companyName = "company_name"
        case contactName = "contact_name"
        case contactRole = "contact_role"
        case stage, outcome, notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    /// Context string for AI prompt injection
    var contextString: String {
        """
        Deal context:
        - Company: \(companyName)
        - Contact: \(contactName), \(contactRole)
        - Stage: \(stage.rawValue)
        \(notes.map { "- Notes: \($0)" } ?? "")
        """
    }
}

enum DealStage: String, Codable, CaseIterable, Sendable {
    case discovery
    case demo
    case evaluation
    case negotiation
    case closed

    var displayName: String {
        rawValue.capitalized
    }
}

enum DealOutcome: String, Codable, CaseIterable, Sendable {
    case progressed
    case stalled
    case won
    case lost

    var displayName: String {
        rawValue.capitalized
    }
}
