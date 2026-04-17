import SwiftUI

/// A tappable glass card with a gradient icon badge — used in Deal detail action grid.
struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]

    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Icon badge
            ZStack {
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.rounded(.subheadline, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .glassCard()
        .contentShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Preview

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
        ActionCard(
            title: "Objection Handler",
            subtitle: "Counter objections in real time",
            icon: "bolt.fill",
            gradient: [Color.pitchAccent, Color.pitchPurple]
        )

        ActionCard(
            title: "Post-Call Summary",
            subtitle: "Summarise notes and draft follow-up",
            icon: "doc.text.fill",
            gradient: [Color.pitchPurple, Color(red: 0.8, green: 0.3, blue: 0.9)]
        )

        ActionCard(
            title: "Discovery Questions",
            subtitle: "Tailored questions for this prospect",
            icon: "questionmark.bubble.fill",
            gradient: [Color.pitchSuccess, Color.pitchAccent]
        )
    }
    .padding()
    .appBackground()
}
