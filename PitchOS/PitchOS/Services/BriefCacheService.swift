import Foundation

struct CachedBrief: Codable, Equatable, Sendable {
    let userId: UUID
    let dealId: UUID?
    let briefText: String
    let promptVersion: String
    let createdAt: Date
}

/// Stores the latest completed brief per user/deal so it can be read without a network.
/// The cache is additive: Supabase remains the source of truth for saved outputs.
actor BriefCacheService {
    static let shared = BriefCacheService()

    private let rootURL: URL

    init(rootURL: URL? = nil) {
        if let rootURL {
            self.rootURL = rootURL
        } else {
            let applicationSupport = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first!
            self.rootURL = applicationSupport
                .appendingPathComponent("PitchOS", isDirectory: true)
                .appendingPathComponent("BriefCache", isDirectory: true)
        }
    }

    func save(_ brief: CachedBrief) throws {
        guard !brief.briefText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let directory = userDirectory(for: brief.userId)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        let data = try JSONEncoder().encode(brief)
        let url = fileURL(userId: brief.userId, dealId: brief.dealId)
        try data.write(to: url, options: .atomic)
        try? FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
            ofItemAtPath: url.path
        )
    }

    func load(userId: UUID, dealId: UUID?) throws -> CachedBrief? {
        let url = fileURL(userId: userId, dealId: dealId)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(CachedBrief.self, from: data)
        } catch {
            // A partial or old cache must never block the live brief screen.
            try? FileManager.default.removeItem(at: url)
            return nil
        }
    }

    func remove(userId: UUID, dealId: UUID?) throws {
        let url = fileURL(userId: userId, dealId: dealId)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }

    func clear(userId: UUID) throws {
        let directory = userDirectory(for: userId)
        guard FileManager.default.fileExists(atPath: directory.path) else { return }
        try FileManager.default.removeItem(at: directory)
    }

    private func userDirectory(for userId: UUID) -> URL {
        rootURL.appendingPathComponent(userId.uuidString, isDirectory: true)
    }

    private func fileURL(userId: UUID, dealId: UUID?) -> URL {
        let filename = "\(dealId?.uuidString ?? "standalone").json"
        return userDirectory(for: userId).appendingPathComponent(filename)
    }
}
