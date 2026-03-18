import SwiftUI

/// Full-width primary action button with shimmer effect while loading.
struct GenerateButton: View {
    let title: String
    let icon: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    @State private var shimmerOffset: CGFloat = -1

    init(
        _ title: String,
        icon: String = "sparkles",
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // Gradient background
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isDisabled
                                ? [Color.white.opacity(0.08), Color.white.opacity(0.05)]
                                : [Color.pitchAccent, Color.pitchPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Shimmer overlay while loading
                if isLoading {
                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: shimmerOffset - 0.2),
                                    .init(color: .white.opacity(0.25), location: shimmerOffset),
                                    .init(color: .clear, location: shimmerOffset + 0.2)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                // Label
                HStack(spacing: Spacing.sm) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
                        Text("Generating…")
                            .font(.rounded(.callout, weight: .semibold))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                        Text(title)
                            .font(.rounded(.callout, weight: .semibold))
                    }
                }
                .foregroundStyle(isDisabled ? Color.white.opacity(0.35) : .white)
                .padding(.vertical, 14)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .disabled(isDisabled || isLoading)
        .onChange(of: isLoading) { _, loading in
            if loading {
                runShimmer()
            }
        }
    }

    private func runShimmer() {
        shimmerOffset = -1
        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
            shimmerOffset = 2
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        GenerateButton("Handle Objection", icon: "bolt.fill") {}
        GenerateButton("Generating…", isLoading: true) {}
        GenerateButton("Generate Summary", icon: "sparkles", isDisabled: true) {}
    }
    .padding()
    .appBackground()
}
