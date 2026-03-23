import SwiftUI

struct OnboardingProductView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What do you sell?")
                        .font(.title2.bold())
                    Text("Describe your product or platform in one or two sentences. This context makes every AI output specific to your solution.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Product / Platform")
                        .font(.subheadline.weight(.medium))
                    TextField(
                        "e.g. DataSync — a real-time data integration platform for enterprise finance teams",
                        text: $viewModel.product,
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                }
            }
            .padding()
        }
    }
}
