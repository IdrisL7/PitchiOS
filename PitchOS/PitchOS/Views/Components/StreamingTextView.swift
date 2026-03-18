import SwiftUI

/// Displays AI-generated text.
/// While streaming: renders plain text with a pulsing cursor.
/// When complete: reveals the full text (no transition needed — it arrives token by token anyway).
struct StreamingTextView: View {
    let text: String
    let isStreaming: Bool

    @State private var cursorVisible = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isStreaming {
                Text("▊")
                    .font(.body)
                    .foregroundStyle(Color.pitchAccent)
                    .opacity(cursorVisible ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                        value: cursorVisible
                    )
                    .onAppear { cursorVisible = false }
            }
        }
    }
}

// MARK: - Preview

#Preview("Streaming") {
    StreamingTextView(
        text: "Acknowledge:\nThat concern about implementation timeline is valid — complexity is a real risk.\n\nReframe:",
        isStreaming: true
    )
    .padding()
    .glassCard(isAIContent: true, isStreaming: true)
    .padding()
    .appBackground()
}

#Preview("Complete") {
    StreamingTextView(
        text: "Acknowledge:\nThat concern about implementation timeline is valid.\n\nReframe:\nMost customers go live within 6 weeks using our guided onboarding.\n\nAdvance:\nShall we walk through a sample project plan together?",
        isStreaming: false
    )
    .padding()
    .glassCard(isAIContent: true)
    .padding()
    .appBackground()
}
