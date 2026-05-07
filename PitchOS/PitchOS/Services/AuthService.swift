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

    func deleteAccount() async throws {
        let session = try await client.auth.session

        var request = URLRequest(url: URL(string: "\(AppConfig.supabaseURL)/functions/v1/delete-account")!)
        request.httpMethod = "POST"
        request.setValue(AppConfig.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let detail = String(data: data, encoding: .utf8) ?? ""
            throw AuthServiceError.deleteAccountFailed(detail: detail)
        }

        try? await client.auth.signOut()
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

enum AuthServiceError: LocalizedError {
    case invalidResponse
    case deleteAccountFailed(detail: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "We could not complete that request. Please try again."
        case .deleteAccountFailed:
            return "We could not delete your account. Please try again."
        }
    }
}
