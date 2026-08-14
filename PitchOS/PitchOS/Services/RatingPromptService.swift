import Foundation
import StoreKit
import UIKit

/// Requests an App Store rating after three successful meeting-brief generations.
/// The count and one-prompt-per-version guard live in UserDefaults so a failed
/// generation can never advance the trigger.
@MainActor
final class RatingPromptService {
    static let threshold = 3
    static let shared = RatingPromptService()

    private let defaults: UserDefaults
    private let versionProvider: () -> String
    private let requestReview: @MainActor () -> Void

    init(
        defaults: UserDefaults = .standard,
        versionProvider: @escaping () -> String = { AppConfig.appVersion },
        requestReview: @escaping @MainActor () -> Void = RatingPromptService.requestStoreReview
    ) {
        self.defaults = defaults
        self.versionProvider = versionProvider
        self.requestReview = requestReview
    }

    var successfulBriefCount: Int {
        defaults.integer(forKey: countKey(for: versionProvider()))
    }

    var hasPromptedForCurrentVersion: Bool {
        defaults.bool(forKey: promptedKey(for: versionProvider()))
    }

    /// Records a generation only after the caller has confirmed it completed
    /// and persisted successfully. Errors must not call this method.
    func recordSuccessfulBrief() {
        let version = versionProvider()
        let promptedKey = promptedKey(for: version)
        guard !defaults.bool(forKey: promptedKey) else { return }

        let countKey = countKey(for: version)
        let nextCount = defaults.integer(forKey: countKey) + 1
        defaults.set(nextCount, forKey: countKey)

        guard nextCount >= Self.threshold else { return }

        // Set the guard before invoking StoreKit so a re-entrant success cannot
        // request more than once for this app version.
        defaults.set(true, forKey: promptedKey)
        requestReview()
    }

    private func countKey(for version: String) -> String {
        "pitchos.ratingPrompt.successCount.\(version)"
    }

    private func promptedKey(for version: String) -> String {
        "pitchos.ratingPrompt.prompted.\(version)"
    }

    private static func requestStoreReview() {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first(where: { $0.activationState == .foregroundActive })
            ?? scenes.first(where: { $0.activationState == .foregroundInactive })
        guard let scene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}
