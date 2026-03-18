import Foundation

@MainActor
@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var error: String?

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func signIn() async -> Bool {
        guard validate() else { return false }
        isLoading = true
        error = nil

        do {
            _ = try await authService.signIn(email: email, password: password)
            isLoading = false
            return true
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func signUp() async -> Bool {
        guard validate() else { return false }
        isLoading = true
        error = nil

        do {
            _ = try await authService.signUp(email: email, password: password)
            isLoading = false
            return true
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            return false
        }
    }

    private func validate() -> Bool {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error = "Please enter your email address."
            return false
        }
        if password.count < 8 {
            error = "Password must be at least 8 characters."
            return false
        }
        return true
    }
}
