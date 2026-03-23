import SwiftUI

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    var isAIContent: Bool = false
    var isStreaming: Bool = false
    var cornerRadius: CGFloat = Radius.md

    @Environment(\.colorScheme) private var colorScheme
    @State private var glowPhase: CGFloat = 0

    // Border opacity adapts so the stroke is visible in both modes
    private var borderOpacity: Double { colorScheme == .dark ? 1.0 : 0.5 }

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                isAIContent
                                    ? LinearGradient(
                                        colors: [
                                            Color.pitchAccent.opacity(0.4 * borderOpacity),
                                            Color.pitchPurple.opacity(0.3 * borderOpacity),
                                            Color.primary.opacity(0.06)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [
                                            Color.primary.opacity(0.10 * borderOpacity),
                                            Color.primary.opacity(0.03)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                lineWidth: 1
                            )
                    }
            }
            .shadow(
                color: isAIContent
                    ? Color.pitchPurple.opacity(isStreaming ? 0.35 + glowPhase * 0.15 : 0.15)
                    : Color.black.opacity(0.25),
                radius: isAIContent ? (isStreaming ? 20 : 12) : 8,
                x: 0,
                y: 4
            )
            .onChange(of: isStreaming) { _, streaming in
                if streaming {
                    withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                        glowPhase = 1
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.4)) {
                        glowPhase = 0
                    }
                }
            }
    }
}

extension View {
    func glassCard(isAIContent: Bool = false, isStreaming: Bool = false, cornerRadius: CGFloat = Radius.md) -> some View {
        modifier(GlassCardModifier(isAIContent: isAIContent, isStreaming: isStreaming, cornerRadius: cornerRadius))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        Text("Regular glass card")
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard()

        Text("AI content card (idle)")
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(isAIContent: true)

        Text("AI content card (streaming)")
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(isAIContent: true, isStreaming: true)
    }
    .padding()
    .appBackground()
}
