import SwiftUI

struct OnboardingBuyersView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Who do you sell to?")
                        .font(.title2.bold())
                    Text("Select your target industries and add the buyer titles you typically engage.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Industries
                VStack(alignment: .leading, spacing: 12) {
                    Text("Target industries")
                        .font(.subheadline.weight(.medium))

                    FlowLayout(spacing: 8) {
                        // Preset industry chips
                        ForEach(OnboardingViewModel.commonIndustries, id: \.self) { industry in
                            ChipButton(
                                title: industry,
                                isSelected: viewModel.industries.contains(industry)
                            ) {
                                if viewModel.industries.contains(industry) {
                                    viewModel.industries.removeAll { $0 == industry }
                                } else {
                                    viewModel.addIndustry(industry)
                                }
                            }
                        }
                        // Custom industry chips (not in the preset list)
                        ForEach(viewModel.industries.filter { !OnboardingViewModel.commonIndustries.contains($0) }, id: \.self) { custom in
                            ChipButton(title: "\(custom) ✕", isSelected: true) {
                                viewModel.industries.removeAll { $0 == custom }
                            }
                        }
                    }

                    HStack {
                        TextField("Add custom industry", text: $viewModel.industryInput)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                viewModel.addIndustry(viewModel.industryInput)
                                viewModel.industryInput = ""
                            }
                        Button("Add") {
                            viewModel.addIndustry(viewModel.industryInput)
                            viewModel.industryInput = ""
                        }
                        .disabled(viewModel.industryInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                // Buyer titles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Primary buyer titles")
                        .font(.subheadline.weight(.medium))

                    if !viewModel.buyerTitles.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.buyerTitles, id: \.self) { title in
                                ChipButton(title: title, isSelected: true) {
                                    viewModel.buyerTitles.removeAll { $0 == title }
                                }
                            }
                        }
                    }

                    HStack {
                        TextField("e.g. VP Engineering, CTO, Head of Ops", text: $viewModel.buyerTitleInput)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                viewModel.addBuyerTitle(viewModel.buyerTitleInput)
                                viewModel.buyerTitleInput = ""
                            }
                        Button("Add") {
                            viewModel.addBuyerTitle(viewModel.buyerTitleInput)
                            viewModel.buyerTitleInput = ""
                        }
                        .disabled(viewModel.buyerTitleInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views

struct ChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

/// Simple flow layout for chips/tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}
