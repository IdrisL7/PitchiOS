import SwiftUI

struct DealEditSheet: View {
    @Bindable var viewModel: DealDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    // Stage
                    sectionCard("Deal Stage") {
                        VStack(spacing: Spacing.xs) {
                            ForEach(DealStage.allCases, id: \.self) { stage in
                                stageRow(stage)
                            }
                        }
                    }

                    // Outcome
                    sectionCard("Outcome (optional)") {
                        VStack(spacing: Spacing.xs) {
                            outcomeRow(nil, label: "None")
                            ForEach(DealOutcome.allCases, id: \.self) { outcome in
                                outcomeRow(outcome, label: outcome.displayName)
                            }
                        }
                    }

                    if let error = viewModel.error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(Color.pitchDanger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Spacing.sm)
                    }
                }
                .padding(Spacing.md)
            }
            .navigationTitle("Update Deal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.pitchAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await viewModel.saveEdit() }
                    } label: {
                        if viewModel.isSaving {
                            ProgressView().tint(Color.pitchAccent)
                        } else {
                            Text("Save").fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(Color.pitchAccent)
                    .disabled(viewModel.isSaving)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Section Card

    @ViewBuilder
    private func sectionCard(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.rounded(.footnote, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            content()
        }
        .padding(Spacing.md)
        .glassCard()
    }

    // MARK: - Stage Row

    private func stageRow(_ stage: DealStage) -> some View {
        Button {
            HapticService.shared.selectionChanged()
            viewModel.editStage = stage
        } label: {
            HStack {
                Text(stage.displayName)
                    .font(.rounded(.callout, weight: viewModel.editStage == stage ? .semibold : .regular))
                    .foregroundStyle(viewModel.editStage == stage ? Color.pitchAccent : .primary)
                Spacer()
                if viewModel.editStage == stage {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.pitchAccent)
                }
            }
            .padding(.vertical, Spacing.xs)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Outcome Row

    private func outcomeRow(_ outcome: DealOutcome?, label: String) -> some View {
        let isSelected = viewModel.editOutcome == outcome

        return Button {
            HapticService.shared.selectionChanged()
            viewModel.editOutcome = outcome
        } label: {
            HStack {
                Text(label)
                    .font(.rounded(.callout, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? outcomeColor(outcome) : .primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(outcomeColor(outcome))
                }
            }
            .padding(.vertical, Spacing.xs)
        }
        .buttonStyle(.plain)
    }

    private func outcomeColor(_ outcome: DealOutcome?) -> Color {
        switch outcome {
        case .won:        return Color.pitchSuccess
        case .lost:       return Color.pitchDanger
        case .stalled:    return Color.pitchWarning
        case .progressed: return Color.pitchAccent
        case .none:       return Color.secondary
        }
    }
}
