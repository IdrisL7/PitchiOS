import Foundation
import Supabase

final class ProfileService: Sendable {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchProfile(userId: UUID) async throws -> Profile? {
        let response: [Profile] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .execute()
            .value
        return response.first
    }

    func createProfile(_ profile: Profile) async throws -> Profile {
        try await client
            .from("profiles")
            .insert(profile)
            .select()
            .single()
            .execute()
            .value
    }

    func updateProfile(_ profile: Profile) async throws -> Profile {
        try await client
            .from("profiles")
            .update(profile)
            .eq("id", value: profile.id.uuidString)
            .select()
            .single()
            .execute()
            .value
    }
}
