import UIKit

/// Centralised haptic feedback — call from any context (not @MainActor-isolated, triggers async on main).
final class HapticService: Sendable {

    static let shared = HapticService()
    private init() {}

    /// Light tick — fired every ~20 tokens during streaming.
    func tokenArrived() {
        fire { UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.4) }
    }

    /// Medium thud — generation finished.
    func generationComplete() {
        fire { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    }

    /// Selection click — tab change, picker change.
    func selectionChanged() {
        fire { UISelectionFeedbackGenerator().selectionChanged() }
    }

    /// Light tick — text copied to clipboard.
    func copied() {
        fire { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    }

    /// Error buzz.
    func error() {
        fire { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    }

    // MARK: - Private

    private func fire(_ block: @escaping @Sendable () -> Void) {
        DispatchQueue.main.async { block() }
    }
}
