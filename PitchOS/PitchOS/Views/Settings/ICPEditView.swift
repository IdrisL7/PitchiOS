import SwiftUI

struct ICPEditView: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {

                // Vertical quick-start — first so it can pre-fill everything below
                VerticalQuickStartSection(viewModel: viewModel)

                fieldCard("Identity") {
                    VStack(spacing: Spacing.sm) {
                        labeledField("Name", text: $viewModel.profile.name)
                        Divider().opacity(0.3)
                        labeledField("Role", text: $viewModel.profile.role)
                    }
                }

                fieldCard("Product") {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Description")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField(
                            "Describe what you sell in 1-2 sentences",
                            text: $viewModel.profile.product,
                            axis: .vertical
                        )
                        .lineLimit(3...6)
                        .font(.body)
                    }
                }

                fieldCard("Sales Methodology") {
                    Picker("Methodology", selection: $viewModel.profile.methodology) {
                        ForEach(OnboardingViewModel.methodologies, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.pitchAccent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let error = viewModel.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Color.pitchDanger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.sm)
                }

                if viewModel.saveSuccess {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.pitchSuccess)
                        Text("Profile updated")
                            .font(.subheadline)
                            .foregroundStyle(Color.pitchSuccess)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.sm)
                }
            }
            .padding(Spacing.md)
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        await viewModel.saveProfile()
                        if viewModel.saveSuccess { dismiss() }
                    }
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

    private func labeledField(_ label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)
            TextField(label, text: text)
                .font(.body)
        }
    }
}
