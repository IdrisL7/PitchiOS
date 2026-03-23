import SwiftUI

/// Deal stage pill with optional freshness indicator dot.
struct StageBadge: View {
    let stage: DealStage
    let outcome: DealOutcome?

    @State private var dotPulse = false

    // Freshness: show active dot for Discovery/Demo (hot deals)
    private var isActive: Bool {
        outcome == nil && (stage == .discovery || stage == .demo)
    }

    private var stageColor: Color {
        switch stage {
        case .discovery:  return Color.pitchAccent
        case .demo:       return Color.pitchPurple
        case .evaluation: return Color.pitchWarning
        case .negotiation: return Color(red: 1.0, green: 0.5, blue: 0.2)
        case .closed:     return Color.pitchSuccess
        }
    }

    private var outcomeColor: Color? {
        switch outcome {
        case .won:        return Color.pitchSuccess
        case .lost:       return Color.pitchDanger
        case .stalled:    return Color.pitchWarning
        case .progressed: return Color.pitchAccent
        case .none:       return nil
        }
    }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            // Active freshness dot
            if isActive {
                Circle()
                    .fill(stageColor)
                    .frame(width: 6, height: 6)
                    .scaleEffect(dotPulse ? 1.3 : 0.85)
                    .animation(
                        .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                        value: dotPulse
                    )
                    .onAppear { dotPulse = true }
            }

            Text(outcome?.displayName ?? stage.displayName)
                .font(.rounded(.caption, weight: .semibold))
                .foregroundStyle(outcomeColor ?? stageColor)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke((outcomeColor ?? stageColor).opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        StageBadge(stage: .discovery, outcome: nil)
        StageBadge(stage: .demo, outcome: nil)
        StageBadge(stage: .evaluation, outcome: nil)
        StageBadge(stage: .negotiation, outcome: nil)
        StageBadge(stage: .closed, outcome: .won)
        StageBadge(stage: .closed, outcome: .lost)
        StageBadge(stage: .evaluation, outcome: .stalled)
    }
    .padding()
    .appBackground()
}
