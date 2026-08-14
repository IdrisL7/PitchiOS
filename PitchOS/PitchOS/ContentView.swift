import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.isLoading {
                SplashView()
            } else if !appState.isAuthenticated {
                LoginView()
            } else if !appState.isOnboarded {
                OnboardingContainerView()
            } else if ProcessInfo.processInfo.arguments.contains("--screenshot-generate") {
                #if DEBUG
                GenerateView()
                #else
                MainTabView()
                #endif
            } else if ProcessInfo.processInfo.arguments.contains("--screenshot-postcall") {
                #if DEBUG
                NavigationStack { PostCallView() }
                #else
                MainTabView()
                #endif
            } else if ProcessInfo.processInfo.arguments.contains("--screenshot-settings") {
                #if DEBUG
                SettingsView()
                #else
                MainTabView()
                #endif
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut, value: appState.isAuthenticated)
        .animation(.easeInOut, value: appState.isOnboarded)
        .onReceive(NotificationCenter.default.publisher(for: .sessionExpired)) { _ in
            appState.handleSessionExpiry()
        }
    }
}

// MARK: - Splash

private struct SplashView: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "bolt.shield.fill")
                .font(.system(size: 52))
                .foregroundStyle(Color.pitchAccent)
            Text("PitchOS")
                .font(.rounded(.largeTitle, weight: .bold))
                .foregroundStyle(.primary)
            ProgressView()
                .tint(Color.pitchAccent)
        }
        .appBackground()
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab: AppTab = .deals

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .deals:
                    DealListView()
                case .generate:
                    GenerateView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            FloatingTabBar(selected: $selectedTab)
                .padding(.bottom, Spacing.md)
        }
        .appBackground()
    }
}

// MARK: - Generate Hub

struct GenerateView: View {
    @Environment(AppState.self) private var appState
    @State private var startHereDismissed = false

    private struct ToolEntry: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let gradient: [Color]
        let destination: AnyView
    }

    private let beforeCall: [ToolEntry] = [
        ToolEntry(
            title: "Meeting Brief",
            subtitle: "Walk in sharp with a prospect snapshot",
            icon: "doc.badge.gearshape.fill",
            gradient: [Color.pitchSuccess, Color(red: 0.10, green: 0.70, blue: 0.45)],
            destination: AnyView(MeetingBriefView())
        ),
        ToolEntry(
            title: "Discovery Questions",
            subtitle: "15 tailored questions for this buyer",
            icon: "questionmark.bubble.fill",
            gradient: [Color.pitchAccent, Color.pitchPurple],
            destination: AnyView(DiscoveryQuestionsView())
        )
    ]

    private let duringCall: [ToolEntry] = [
        ToolEntry(
            title: "Objection Handler",
            subtitle: "Counter objections in real time",
            icon: "bolt.fill",
            gradient: [Color.pitchWarning, Color(red: 1.0, green: 0.5, blue: 0.1)],
            destination: AnyView(ObjectionHandlerView())
        )
    ]

    private let afterCall: [ToolEntry] = [
        ToolEntry(
            title: "Post-Call Summary",
            subtitle: "Summarise notes & draft the follow-up",
            icon: "doc.text.fill",
            gradient: [Color.pitchPurple, Color(red: 0.75, green: 0.30, blue: 0.90)],
            destination: AnyView(PostCallView())
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    if appState.currentUserId != nil && !startHereDismissed {
                        startHereCard
                    }

                    toolSection("Before the Call", tools: beforeCall)
                    toolSection("During the Call", tools: duringCall)
                    toolSection("After the Call", tools: afterCall)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
                .padding(.bottom, 100)
            }
            .navigationTitle("Generate")
        }
        .onAppear {
            refreshStartHereState()
        }
        .onChange(of: appState.currentUserId) { _, _ in
            refreshStartHereState()
        }
    }

    static func startHereDismissalKey(for userID: UUID?) -> String? {
        guard let userID else { return nil }
        return "pitchos.startHere.dismissed.\(userID.uuidString)"
    }

    private var startHereKey: String? {
        Self.startHereDismissalKey(for: appState.currentUserId)
    }

    private func refreshStartHereState() {
        guard let key = startHereKey else {
            startHereDismissed = false
            return
        }
        startHereDismissed = UserDefaults.standard.bool(forKey: key)
    }

    private var startHereCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label("Start here", systemImage: "sparkles")
                .font(.rounded(.footnote, weight: .semibold))
                .foregroundStyle(Color.pitchAccent)
                .textCase(.uppercase)
                .tracking(0.8)

            Text("Prepare for your next call")
                .font(.rounded(.title3, weight: .bold))

            Text("Start with Meeting Brief. It turns your profile into a concise pre-call plan. Add a deal under Deals when you want company-specific context.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: Spacing.sm) {
                NavigationLink {
                    MeetingBriefView()
                } label: {
                    Label("Open Meeting Brief", systemImage: "arrow.right")
                        .font(.rounded(.callout, weight: .semibold))
                        .foregroundStyle(Color.pitchAccent)
                }

                Spacer()

                Button("Dismiss") {
                    startHereDismissed = true
                    if let startHereKey {
                        UserDefaults.standard.set(true, forKey: startHereKey)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(isAIContent: true)
    }

    @ViewBuilder
    private func toolSection(_ title: String, tools: [ToolEntry]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.rounded(.footnote, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            LazyVGrid(
                columns: tools.count == 1
                    ? [GridItem(.flexible())]
                    : [GridItem(.flexible()), GridItem(.flexible())],
                spacing: Spacing.sm
            ) {
                ForEach(tools) { tool in
                    NavigationLink(destination: tool.destination) {
                        ActionCard(
                            title: tool.title,
                            subtitle: tool.subtitle,
                            icon: tool.icon,
                            gradient: tool.gradient
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState.preview)
}
