import Foundation
import Supabase

final class OutputService: Sendable {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchOutputs(dealId: UUID) async throws -> [Output] {
        try await client
            .from("outputs")
            .select()
            .eq("deal_id", value: dealId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func fetchOutputs(userId: UUID, type: OutputType? = nil) async throws -> [Output] {
        var query = client
            .from("outputs")
            .select()
            .eq("user_id", value: userId.uuidString)

        if let type {
            query = query.eq("type", value: type.rawValue)
        }

        return try await query
            .order("created_at", ascending: false)
            .limit(50)
            .execute()
            .value
    }

    func saveOutput(_ output: Output) async throws -> Output {
        try await client
            .from("outputs")
            .insert(output)
            .select()
            .single()
            .execute()
            .value
    }

    func rateOutput(id: UUID, rating: Int) async throws {
        try await client
            .from("outputs")
            .update(["rating": rating])
            .eq("id", value: id.uuidString)
            .execute()
    }
}
