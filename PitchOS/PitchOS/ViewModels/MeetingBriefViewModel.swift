import Foundation

@MainActor
@Observable
final class MeetingBriefViewModel {
    var briefText = ""
    var isStreaming = false
    var error: String?
    var lastOutputId: UUID?

    private let aiService: AIService
    private let outputService: OutputService
    private let usageService: UsageService
    private let profile: Profile
    var deal: Deal?

    init(
        aiService: AIService,
        outputService: OutputService,
        usageService: UsageService,
        profile: Profile,
        deal: Deal? = nil
    ) {
        self.aiService = aiService
        self.outputService = outputService
        self.usageService = usageService
        self.profile = profile
        self.deal = deal
    }

    var canGenerate: Bool { !isStreaming }
    var hasContent: Bool { !briefText.isEmpty }

    func generate() async {
        guard await usageService.canGenerate(userId: profile.id, plan: profile.plan) else {
            error = UsageService.limitMessage
            HapticService.shared.error()
            return
        }

        isStreaming = true
        briefText = ""
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
        } catch {
            handleError(error)
        }

        isStreaming = false
    }

    private func handleError(_ error: Error) {
        self.error = error.friendlyMessage
        HapticService.shared.error()
        if error.isSessionExpired {
            NotificationCenter.default.post(name: .sessionExpired, object: nil)
        }
    }

    func rate(_ rating: Int) async {
        guard let id = lastOutputId else { return }
        try? await outputService.rateOutput(id: id, rating: rating)
    }

    func clear() {
        briefText = ""
        error = nil
        lastOutputId = nil
    }
}
