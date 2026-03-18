import SwiftUI

struct MeetingBriefView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: MeetingBriefViewModel?

    var deal: Deal?

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Meeting Brief")
                        .font(.rounded(.title2, weight: .bold))
                    Text("A concise pre-call brief so you walk in sharp.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Deal context pill
                if let deal {
                    dealContextPill(deal)
                }

                if let vm = viewModel {
                    // Generate button
                    GenerateButton(
                        "Generate Brief",
                        icon: "doc.badge.gearshape.fill",
                        isLoading: vm.isStreaming,
                        isDisabled: !vm.canGenerate
                    ) {
                        Task { await vm.generate() }
                    }

                    // Error
                    if let error = vm.error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(Color.pitchDanger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Output card
                    if vm.hasContent || vm.isStreaming {
                        aiOutputCard(vm)

                        if !vm.isStreaming && vm.hasContent {
                            HStack {
                                CopyButton("Copy Brief", text: vm.briefText)
                                Spacer()
                                RatingView { rating in Task { await vm.rate(rating) } }
                            }

                            Button("Regenerate") { vm.clear() }
                                .font(.subheadline)
                                .foregroundStyle(Color.pitchAccent)
                        }
                    }
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, 20)
        }
        .navigationTitle("Meeting Brief")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { initViewModel() }
    }

    // MARK: - Sub-views

    private func dealContextPill(_ deal: Deal) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "building.2")
            Text(deal.companyName)
            if !deal.contactName.isEmpty {
                Text("· \(deal.contactName)")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func aiOutputCard(_ vm: MeetingBriefViewModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "doc.badge.gearshape.fill")
                    .foregroundStyle(Color.pitchSuccess)
                Text("Pre-Call Brief")
                    .font(.rounded(.subheadline, weight: .semibold))
                Spacer()
                if vm.isStreaming {
                    HStack(spacing: 4) {
                        ProgressView().scaleEffect(0.7).tint(Color.pitchPurple)
                        Text("Generating").font(.caption2).foregroundStyle(Color.pitchPurple)
                    }
                }
            }
            .padding(.bottom, Spacing.sm + 4)

            Divider().opacity(0.3).padding(.bottom, Spacing.sm + 4)

            StreamingTextView(text: vm.briefText, isStreaming: vm.isStreaming)
        }
        .padding(Spacing.md)
        .glassCard(isAIContent: true, isStreaming: vm.isStreaming)
    }

    private func initViewModel() {
        guard viewModel == nil, let profile = appState.profile else { return }
        viewModel = MeetingBriefViewModel(
            aiService: appState.aiService,
            outputService: appState.outputService,
            usageService: appState.usageService,
            profile: profile,
            deal: deal
        )
    }
}
