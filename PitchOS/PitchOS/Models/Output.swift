import Foundation

struct Output: Codable, Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    var dealId: UUID?
    var type: OutputType
    var input: [String: String]
    var output: String
    var promptVersion: String
    var rating: Int?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case dealId = "deal_id"
        case type, input, output
        case promptVersion = "prompt_version"
        case rating
        case createdAt = "created_at"
    }
}

enum OutputType: String, Codable, CaseIterable, Sendable {
    case objection
    case summary
    case email
    case questions
    case brief
    case demoNarrative = "demo_narrative"

    var displayName: String {
        switch self {
        case .objection: "Objection Response"
        case .summary: "Call Summary"
        case .email: "Follow-up Email"
        case .questions: "Discovery Questions"
        case .brief: "Prospect Brief"
        case .demoNarrative: "Demo Narrative"
        }
    }
}
