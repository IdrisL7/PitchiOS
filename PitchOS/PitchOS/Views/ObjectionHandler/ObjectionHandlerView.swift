import SwiftUI

struct ObjectionHandlerView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: ObjectionHandlerViewModel?

    var deal: Deal?

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Objection Handler")
                        .font(.rounded(.title2, weight: .bold))
                    Text("Type the objection — get a structured response in seconds.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Deal context pill
                if let deal {
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

                if let vm = viewModel {
                    VStack(spacing: Spacing.md) {
                        // Input field
                        TextField(
                            "e.g. \"We're already using Workday for this\"",
                            text: Bindable(vm).objectionText,
                            axis: .vertical
                        )
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...5)

                        // Generate button
                        GenerateButton(
                            "Handle Objection",
                            icon: "bolt.fill",
                            isLoading: vm.isStreaming,
                            isDisabled: !vm.canGenerate
                        ) {
                            Task { await vm.generateResponse() }
                        }
                    }

                    // Error
                    if let error = vm.error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(Color.pitchDanger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Response card
                    if !vm.responseText.isEmpty || vm.isStreaming {
                        ObjectionResponseCard(
                            text: vm.responseText,
                            isStreaming: vm.isStreaming
                        )

                        if !vm.isStreaming {
                            HStack {
                                CopyButton("Copy Response", text: vm.responseText)
                                Spacer()
                                RatingView { rating in
                                    Task { await vm.rate(rating) }
                                }
                            }
                        }
                    }

                    // New objection
                    if !vm.responseText.isEmpty && !vm.isStreaming {
                        Button("New Objection") {
                            vm.clear()
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.pitchAccent)
                    }
                }
            }
            .padding(Spacing.md)
            .padding(.bottom, 20)
        }
        .navigationTitle("Objection Handler")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil, let profile = appState.profile {
                viewModel = ObjectionHandlerViewModel(
                    aiService: appState.aiService,
                    outputService: appState.outputService,
                    usageService: appState.usageService,
                    profile: profile,
                    deal: deal
                )
            }
        }
    }
}
