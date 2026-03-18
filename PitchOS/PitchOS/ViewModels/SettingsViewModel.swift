import Foundation

@MainActor
@Observable
final class SettingsViewModel {
    var profile: Profile
    var isSaving = false
    var error: String?
    var saveSuccess = false

    private let profileService: ProfileService
    private let authService: AuthService

    init(profile: Profile, profileService: ProfileService, authService: AuthService) {
        self.profile = profile
        self.profileService = profileService
        self.authService = authService
    }

    func saveProfile() async {
        isSaving = true
        error = nil
        saveSuccess = false

        do {
            profile.updatedAt = Date()
            profile = try await profileService.updateProfile(profile)
            saveSuccess = true
        } catch {
            self.error = error.localizedDescription
        }

        isSaving = false
    }

    func signOut() async throws {
        try await authService.signOut()
    }
}
