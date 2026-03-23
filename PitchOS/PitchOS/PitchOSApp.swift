import SwiftUI

@main
struct PitchOSApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .preferredColorScheme(appState.colorSchemePreference.swiftUIColorScheme)
                .task {
                    await appState.loadSession()
                }
        }
    }
}
