import Foundation
import Supabase

final class UsageService: Sendable {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Public API

    /// Count of AI generations made this calendar month.
    /// Reads directly from the `outputs` table — no separate increment step required.
    func currentUsage(userId: UUID) async throws -> Int {
        struct CountRow: Decodable { let id: UUID }

        let formatter = ISO8601DateFormatter()
        let startOfMonth = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: Date())
        )!

        let rows: [CountRow] = try await client
            .from("outputs")
            .select("id")
            .eq("user_id", value: userId.uuidString)
            .gte("created_at", value: formatter.string(from: startOfMonth))
            .execute()
            .value

        return rows.count
    }

    /// Returns `false` when the user has hit the monthly cap for their plan.
    /// Paid plans are unlimited. Errors fail open.
    func canGenerate(userId: UUID, plan: UserPlan = .free) async -> Bool {
        guard !plan.isUnlimited else { return true }
        guard let usage = try? await currentUsage(userId: userId) else { return true }
        return usage < plan.monthlyLimit
    }

    /// Human-readable limit message.
    static var limitMessage: String {
        "You've used all \(AppConfig.freeGenerationsPerMonth) free generations this month. Upgrade to Pro to continue."
    }
}
