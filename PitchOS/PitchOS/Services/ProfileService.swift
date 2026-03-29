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
        // Upsert without returning — avoids RLS issues with returning=representation
        try await client
            .from("profiles")
            .upsert(profile, onConflict: "id")
            .execute()

        // Fetch separately using the proven SELECT path
        guard let saved = try await fetchProfile(userId: profile.id) else {
            throw NSError(domain: "ProfileService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Profile saved but could not be loaded. Please try signing in again."])
        }
        return saved
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
