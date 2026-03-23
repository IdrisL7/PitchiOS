import Foundation

extension Error {
    /// Returns a user-facing message suitable for display in the UI.
    /// Maps network, auth, and AI errors to plain-English strings.
    var friendlyMessage: String {
        // Check our own error types first
        if let aiError = self as? AIServiceError {
            return aiError.errorDescription ?? localizedDescription
        }

        // URLError — network-level failures
        if let urlError = self as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "No internet connection. Check your network and try again."
            case .timedOut:
                return "Request timed out. Please try again."
            case .cannotConnectToHost, .cannotFindHost:
                return "Cannot reach the server. Please try again later."
            case .userAuthenticationRequired:
                return "Your session has expired. Please sign in again."
            default:
                break
            }
        }

        // Auth error string patterns (Supabase / GoTrue)
        let msg = localizedDescription.lowercased()
        if msg.contains("jwt expired") || msg.contains("invalid jwt") || msg.contains("not authenticated") {
            return "Your session has expired. Please sign in again."
        }
        if msg.contains("no internet") || msg.contains("offline") {
            return "No internet connection. Check your network and try again."
        }

        return localizedDescription
    }

    /// Returns true when this error indicates the user's auth session is no longer valid.
    var isSessionExpired: Bool {
        if let aiError = self as? AIServiceError, case .unauthorized = aiError { return true }
        let msg = localizedDescription.lowercased()
        return msg.contains("jwt expired") || msg.contains("invalid jwt") || msg.contains("not authenticated")
    }
}
