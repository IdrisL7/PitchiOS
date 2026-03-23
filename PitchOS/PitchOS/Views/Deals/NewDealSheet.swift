import SwiftUI

struct NewDealSheet: View {
    @Bindable var viewModel: DealListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    fieldCard("Company") {
                        TextField("e.g. Acme Financial", text: $viewModel.newCompanyName)
                            .font(.body)
                            .autocorrectionDisabled()
                    }

                    fieldCard("Contact (optional)") {
                        VStack(spacing: Spacing.sm) {
                            TextField("Contact name", text: $viewModel.newContactName)
                                .font(.body)
                            Divider().opacity(0.3)
                            TextField("Role (e.g. VP Engineering)", text: $viewModel.newContactRole)
                                .font(.body)
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
            .navigationTitle("New Deal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.pitchAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            if await viewModel.createDeal() != nil { dismiss() }
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.pitchAccent)
                    .disabled(viewModel.newCompanyName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func fieldCard(_ title: String, @ViewBuilder content: () -> some View) -> some View {
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
}
