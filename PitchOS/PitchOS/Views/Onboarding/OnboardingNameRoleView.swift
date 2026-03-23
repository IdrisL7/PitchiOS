import SwiftUI

struct OnboardingNameRoleView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Who are you?")
                        .font(.title2.bold())
                    Text("This helps PitchOS calibrate every AI output to sound like it came from you.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Your name")
                        .font(.subheadline.weight(.medium))
                    TextField("e.g. Sarah Chen", text: $viewModel.name)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Your role")
                        .font(.subheadline.weight(.medium))
                    TextField("e.g. Solutions Engineer, Account Executive", text: $viewModel.role)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding()
        }
    }
}
