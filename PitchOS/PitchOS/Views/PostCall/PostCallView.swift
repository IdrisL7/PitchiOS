import SwiftUI

struct PostCallView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: PostCallViewModel?
    @State private var selectedTab: PostCallTab = .notes

    var deal: Deal?

    enum PostCallTab: String, CaseIterable {
        case notes   = "Notes"
        case summary = "Summary"
        case email   = "Follow-up"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            Picker("Section", selection: $selectedTab) {
                ForEach(PostCallTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(Spacing.md)
            .onChange(of: selectedTab) { _, _ in
                HapticService.shared.selectionChanged()
            }

            if let vm = viewModel {
                ScrollView {
                    switch selectedTab {
                    case .notes:
                        notesSection(vm)
                    case .summary:
                        summarySection(vm)
                    case .email:
                        emailSection(vm)
                    }
                }
            } else {
                ProgressView()
                    .tint(Color.pitchAccent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Post-Call")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil, let profile = appState.profile {
                viewModel = PostCallViewModel(
                    aiService: appState.aiService,
                    outputService: appState.outputService,
                    speechService: appState.speechService,
                    usageService: appState.usageService,
                    profile: profile,
                    deal: deal
                )
            }
        }
    }

    // MARK: - Notes Tab

    @ViewBuilder
    private func notesSection(_ vm: PostCallViewModel) -> some View {
        VStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Call Notes")
                    .font(.rounded(.headline, weight: .semibold))
                Text("Type or dictate your notes, then generate a structured summary.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Voice input
            HStack {
                VoiceInputButton(isRecording: vm.isRecordingVoice) {
                    Task { await vm.toggleVoiceRecording() }
                }
                if vm.isRecordingVoice {
                    Text("Listening…")
                        .font(.subheadline)
                        .foregroundStyle(Color.pitchDanger)
                }
                Spacer()
            }

            // Text input
            TextEditor(text: Bindable(vm).notesText)
                .frame(minHeight: 200)
                .scrollContentBackground(.hidden)
                .padding(Spacing.sm)
                .glassCard()

            // Generate button
            GenerateButton(
                "Generate Summary",
                icon: "sparkles",
                isLoading: vm.isSummaryStreaming,
                isDisabled: !vm.canGenerateSummary
            ) {
                Task {
                    await vm.generateSummary()
                    selectedTab = .summary
                }
            }

            if let error = vm.error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.pitchDanger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(Spacing.md)
    }

    // MARK: - Summary Tab

    @ViewBuilder
    private func summarySection(_ vm: PostCallViewModel) -> some View {
        VStack(spacing: Spacing.md) {
            if vm.summaryText.isEmpty && !vm.isSummaryStreaming {
                ContentUnavailableView {
                    Label("No Summary Yet", systemImage: "doc.text")
                } description: {
                    Text("Add your call notes and tap Generate Summary.")
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Color.pitchAccent)
                        Text("Call Summary")
                            .font(.rounded(.subheadline, weight: .semibold))
                        Spacer()
                        if vm.isSummaryStreaming {
                            HStack(spacing: 4) {
                                ProgressView().scaleEffect(0.7).tint(Color.pitchPurple)
                                Text("Generating").font(.caption2).foregroundStyle(Color.pitchPurple)
                            }
                        }
                    }
                    .padding(.bottom, Spacing.sm + 4)

                    Divider().opacity(0.3).padding(.bottom, Spacing.sm + 4)

                    StreamingTextView(text: vm.summaryText, isStreaming: vm.isSummaryStreaming)
                }
                .padding(Spacing.md)
                .glassCard(isAIContent: true, isStreaming: vm.isSummaryStreaming)

                if !vm.isSummaryStreaming && !vm.summaryText.isEmpty {
                    HStack {
                        CopyButton("Copy Summary", text: vm.summaryText)
                        Spacer()
                        Button("Generate Email") {
                            Task {
                                await vm.generateFollowUpEmail()
                                selectedTab = .email
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(Color.pitchAccent)
                        .disabled(!vm.canGenerateEmail)
                    }
                }
            }
        }
        .padding(Spacing.md)
    }

    // MARK: - Email Tab

    @ViewBuilder
    private func emailSection(_ vm: PostCallViewModel) -> some View {
        VStack(spacing: Spacing.md) {
            if vm.emailText.isEmpty && !vm.isEmailStreaming {
                ContentUnavailableView {
                    Label("No Email Draft Yet", systemImage: "envelope")
                } description: {
                    Text("Generate a summary first, then create the follow-up email.")
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(Color.pitchAccent)
                        Text("Follow-Up Email")
                            .font(.rounded(.subheadline, weight: .semibold))
                        Spacer()
                        if vm.isEmailStreaming {
                            HStack(spacing: 4) {
                                ProgressView().scaleEffect(0.7).tint(Color.pitchPurple)
                                Text("Generating").font(.caption2).foregroundStyle(Color.pitchPurple)
                            }
                        }
                    }
                    .padding(.bottom, Spacing.sm + 4)

                    Divider().opacity(0.3).padding(.bottom, Spacing.sm + 4)

                    StreamingTextView(text: vm.emailText, isStreaming: vm.isEmailStreaming)
                }
                .padding(Spacing.md)
                .glassCard(isAIContent: true, isStreaming: vm.isEmailStreaming)

                if !vm.isEmailStreaming && !vm.emailText.isEmpty {
                    CopyButton("Copy Email", text: vm.emailText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(Spacing.md)
    }
}
