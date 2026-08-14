import SwiftUI

struct OnboardingMethodologyView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How do you sell?")
                        .font(.title2.bold())
                    Text("Choose a sales approach to shape your questions and responses. Not sure? Choose General / Not sure — you can refine it later. Add up to 5 differentiators for your product.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Methodology picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sales approach")
                        .font(.subheadline.weight(.medium))

                    Picker("Methodology", selection: $viewModel.methodology) {
                        ForEach(OnboardingViewModel.methodologies, id: \.self) { method in
                            Text(SalesMethodology(rawValue: method)?.displayName ?? method).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Differentiators
                VStack(alignment: .leading, spacing: 12) {
                    Text("Top differentiators (\(viewModel.differentiators.count)/5)")
                        .font(.subheadline.weight(.medium))

                    Text("What makes your product different from competitors?")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(viewModel.differentiators, id: \.self) { diff in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text(diff)
                                .font(.subheadline)
                            Spacer()
                            Button {
                                viewModel.differentiators.removeAll { $0 == diff }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    if viewModel.differentiators.count < 5 {
                        HStack {
                            TextField(
                                "e.g. Only platform with real-time sync under 100ms",
                                text: $viewModel.differentiatorInput
                            )
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                viewModel.addDifferentiator(viewModel.differentiatorInput)
                                viewModel.differentiatorInput = ""
                            }

                            Button("Add") {
                                viewModel.addDifferentiator(viewModel.differentiatorInput)
                                viewModel.differentiatorInput = ""
                            }
                            .disabled(viewModel.differentiatorInput.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
            }
            .padding()
        }
    }
}
