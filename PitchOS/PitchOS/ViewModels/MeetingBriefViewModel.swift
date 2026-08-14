import Foundation

@MainActor
@Observable
final class MeetingBriefViewModel {
    var briefText = ""
    var isStreaming = false
    var error: String?
    var lastOutputId: UUID?
    var isCachedLocally = false
    var cachedAt: Date?

    private let aiService: AIService
    private let outputService: OutputService
    private let usageService: UsageService
    private let ratingPromptService: RatingPromptService
    private let briefCacheService: BriefCacheService
    private let profile: Profile
    var deal: Deal?

    init(
        aiService: AIService,
        outputService: OutputService,
        usageService: UsageService,
        ratingPromptService: RatingPromptService = .shared,
        briefCacheService: BriefCacheService = .shared,
        profile: Profile,
        deal: Deal? = nil
    ) {
        self.aiService = aiService
        self.outputService = outputService
        self.usageService = usageService
        self.ratingPromptService = ratingPromptService
        self.briefCacheService = briefCacheService
        self.profile = profile
        self.deal = deal
    }

    var canGenerate: Bool { !isStreaming }
    var hasContent: Bool { !briefText.isEmpty }

    func loadCachedBrief() async {
        guard briefText.isEmpty, !isStreaming else { return }

        do {
            guard let cached = try await briefCacheService.load(
                userId: profile.id,
                dealId: deal?.id
            ) else { return }

            briefText = cached.briefText
            cachedAt = cached.createdAt
            isCachedLocally = true
        } catch {
            // A cache read must never block the live generation path.
        }
    }

    func generate() async {
        guard await usageService.canGenerate(userId: profile.id, plan: profile.plan) else {
            error = UsageService.limitMessage
            HapticService.shared.error()
            return
        }

        isStreaming = true
        briefText = ""
        isCachedLocally = false
        cachedAt = nil
        error = nil

        var tokenCount = 0

        do {
            let stream = aiService.streamMeetingBrief(profile: profile, deal: deal)

            for try await chunk in stream {
                briefText += chunk.text
                tokenCount += 1
                if tokenCount % 20 == 0 {
                    HapticService.shared.tokenArrived()
                }
            }

            HapticService.shared.generationComplete()

            let generatedAt = Date()
            let cachedBrief = CachedBrief(
                userId: profile.id,
                dealId: deal?.id,
                briefText: briefText,
                promptVersion: Prompts.MeetingBrief.version,
                createdAt: generatedAt
            )
            do {
                try await briefCacheService.save(cachedBrief)
                isCachedLocally = true
                cachedAt = generatedAt
            } catch {
                // Keep the generated brief usable even if local storage fails.
            }

            let output = Output(
                id: UUID(),
                userId: profile.id,
                dealId: deal?.id,
                type: .brief,
                input: ["deal_context": deal?.contextString ?? ""],
                output: briefText,
                promptVersion: Prompts.MeetingBrief.version,
                rating: nil,
                createdAt: Date()
            )
            let saved = try await outputService.saveOutput(output)
            lastOutputId = saved.id
            ratingPromptService.recordSuccessfulBrief()
        } catch {
            handleError(error)
        }

        isStreaming = false
    }

    private func handleError(_ error: Error) {
        self.error = error.friendlyMessage
        HapticService.shared.error()
    }

    func rate(_ rating: Int) async {
        guard let id = lastOutputId else { return }
        try? await outputService.rateOutput(id: id, rating: rating)
    }

    func clear() {
        briefText = ""
        error = nil
        lastOutputId = nil
        isCachedLocally = false
        cachedAt = nil
    }
}
