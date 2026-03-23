import Foundation
import Supabase
import Auth

extension Notification.Name {
    static let sessionExpired = Notification.Name("PitchOS.sessionExpired")
}

@MainActor
@Observable
final class AppState {
    // Auth state
    var currentUser: User?
    var profile: Profile?
    var isLoading = true

    // Appearance
    var colorSchemePreference: ColorSchemePreference = {
        let raw = UserDefaults.standard.string(forKey: "pitchos.colorScheme") ?? "system"
        return ColorSchemePreference(rawValue: raw) ?? .system
    }()

    func setColorSchemePreference(_ pref: ColorSchemePreference) {
        colorSchemePreference = pref
        UserDefaults.standard.set(pref.rawValue, forKey: "pitchos.colorScheme")
    }

    // Computed
    var isAuthenticated: Bool { currentUser != nil }
    var isOnboarded: Bool { profile != nil }
    var currentUserId: UUID? { currentUser?.id }
    var isPro: Bool { profile?.plan == .pro }

    #if DEBUG
    /// Flip the in-memory plan without touching the DB — useful for simulator testing.
    func simulatePlan(_ plan: UserPlan) {
        profile?.plan = plan
    }
    #endif

    // Services
    let supabase: SupabaseClient
    let authService: AuthService
    let aiService: AIService
    let profileService: ProfileService
    let dealService: DealService
    let outputService: OutputService
    let speechService: SpeechService
    let usageService: UsageService

    init() {
        let client = SupabaseClient(
            supabaseURL: URL(string: AppConfig.supabaseURL)!,
            supabaseKey: AppConfig.supabaseAnonKey
        )
        self.supabase = client

        self.authService = AuthService(client: client)
        self.aiService = AIService(authService: authService)
        self.profileService = ProfileService(client: client)
        self.dealService = DealService(client: client)
        self.outputService = OutputService(client: client)
        self.speechService = SpeechService()
        self.usageService = UsageService(client: client)
    }

    /// Call when a 401/auth-expiry error is detected anywhere in the app.
    /// Clears session state so `ContentView` routes back to `LoginView`.
    func handleSessionExpiry() {
        currentUser = nil
        profile = nil
    }

    /// Loads the current session and profile on app launch
    func loadSession() async {
        isLoading = true

        #if DEBUG
        // Auto-login with test account — sign-in result used directly
        if currentUser == nil {
            if let session = try? await supabase.auth.signIn(
                email: "test@pitchos.dev",
                password: "PitchOS123x"
            ) {
                currentUser = session.user
                profile = try? await profileService.fetchProfile(userId: session.user.id)
                isLoading = false
                return
            }
        }
        #endif

        do {
            let session = try await supabase.auth.session
            currentUser = session.user

            if let userId = currentUser?.id {
                profile = try await profileService.fetchProfile(userId: userId)
            }
        } catch {
            currentUser = nil
            profile = nil
        }

        isLoading = false
    }

    /// For SwiftUI previews
    static var preview: AppState {
        let state = AppState()
        state.isLoading = false
        state.profile = Profile(
            id: UUID(),
            name: "Sarah Chen",
            role: "Solutions Engineer",
            product: "DataSync — real-time data integration for enterprise finance",
            industries: ["FinTech", "HRTech"],
            buyerTitles: ["VP Engineering", "CTO"],
            methodology: "MEDDIC",
            differentiators: [
                "Sub-100ms real-time sync",
                "No-code integration builder",
                "SOC 2 Type II certified"
            ],
            createdAt: Date(),
            updatedAt: Date()
        )
        return state
    }
}
