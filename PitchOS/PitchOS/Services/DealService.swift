import Foundation
import Supabase

final class DealService: Sendable {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchDeals(userId: UUID) async throws -> [Deal] {
        try await client
            .from("deals")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("updated_at", ascending: false)
            .execute()
            .value
    }

    func createDeal(_ deal: Deal) async throws -> Deal {
        try await client
            .from("deals")
            .insert(deal)
            .select()
            .single()
            .execute()
            .value
    }

    func updateDeal(_ deal: Deal) async throws -> Deal {
        try await client
            .from("deals")
            .update(deal)
            .eq("id", value: deal.id.uuidString)
            .select()
            .single()
            .execute()
            .value
    }

    func deleteDeal(id: UUID) async throws {
        try await client
            .from("deals")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}
