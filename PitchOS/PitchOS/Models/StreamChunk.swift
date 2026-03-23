import Foundation

struct StreamChunk: Sendable {
    let text: String
    let isComplete: Bool
}

/// Represents a Claude SSE event
struct SSEEvent: Decodable {
    let type: String
    let delta: Delta?
    let index: Int?

    struct Delta: Decodable {
        let type: String?
        let text: String?
    }
}
