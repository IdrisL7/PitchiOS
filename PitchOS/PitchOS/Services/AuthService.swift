import Foundation
import Supabase
import Auth

final class AuthService: Sendable {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    var currentUser: User? {
        get async {
            try? await client.auth.session.user
        }
    }

    var currentSession: Session? {
        get async {
            try? await client.auth.session
        }
    }

    func signUp(email: String, password: String) async throws -> User {
        let response = try await client.auth.signUp(email: email, password: password)
        return response.user
    }

    func signIn(email: String, password: String) async throws -> Session {
        try await client.auth.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    /// Access token for Edge Function calls
    func accessToken() async throws -> String {
        let session = try await client.auth.session
        return session.accessToken
    }

    /// Force a session refresh when an edge call rejects the current JWT.
    func refreshSession() async throws -> Session {
        try await client.auth.refreshSession()
    }
}
