import Foundation

@MainActor
@Observable
final class ObjectionHandlerViewModel {
    var objectionText = ""
    var responseText = ""
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

    var canGenerate: Bool {
        !objectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isStreaming
    }

    func generateResponse() async {
        guard canGenerate else { return }

        guard await usageService.canGenerate(userId: profile.id, plan: profile.plan) else {
            error = UsageService.limitMessage
            HapticService.shared.error()
            return
        }

        isStreaming = true
        responseText = ""
        error = nil

        var tokenCount = 0

        do {
            let stream = aiService.streamObjectionResponse(
                objection: objectionText,
                profile: profile,
                deal: deal
            )

            for try await chunk in stream {
                responseText += chunk.text
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
                type: .objection,
                input: ["objection": objectionText],
                output: responseText,
                promptVersion: Prompts.ObjectionHandler.version,
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
    }

    func rate(_ rating: Int) async {
        guard let outputId = lastOutputId else { return }
        try? await outputService.rateOutput(id: outputId, rating: rating)
    }

    func clear() {
        objectionText = ""
        responseText = ""
        error = nil
        lastOutputId = nil
    }
}
