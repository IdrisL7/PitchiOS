import SwiftUI

/// Displays the structured Acknowledge → Reframe → Advance response with glass + AI glow treatment.
struct ObjectionResponseCard: View {
    let text: String
    let isStreaming: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.pitchAccent)
                Text("AI Response")
                    .font(.rounded(.subheadline, weight: .semibold))
                Spacer()
                if isStreaming {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.7)
                            .tint(Color.pitchPurple)
                        Text("Generating")
                            .font(.caption2)
                            .foregroundStyle(Color.pitchPurple)
                    }
                }
            }
            .padding(.bottom, Spacing.sm + 4)

            Divider()
                .opacity(0.3)
                .padding(.bottom, Spacing.sm + 4)

            StreamingTextView(text: text, isStreaming: isStreaming)
        }
        .padding(Spacing.md)
        .glassCard(isAIContent: true, isStreaming: isStreaming)
    }
}

#Preview {
    ObjectionResponseCard(
        text: """
        Acknowledge:
        That's a valid point — Workday is a strong player and switching platforms carries real risk.

        Reframe:
        Most customers run us alongside Workday, not replacing it. The analytics layer is where teams lose 15-20 hours per month on manual work. We eliminate that.

        Advance:
        Would it be useful to see a 15-minute side-by-side showing how the integration works with your existing Workday setup?
        """,
        isStreaming: false
    )
    .padding()
    .appBackground()
}
