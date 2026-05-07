import Foundation

@MainActor
@Observable
final class PostCallViewModel {
    // Input
    var notesText = ""
    var isRecordingVoice = false

    // Summary output
    var summaryText = ""
    var isSummaryStreaming = false

    // Follow-up email output
    var emailText = ""
    var isEmailStreaming = false

    // State
    var error: String?
    var lastSummaryOutputId: UUID?
    var lastEmailOutputId: UUID?

    private let aiService: AIService
    private let outputService: OutputService
    private let speechService: SpeechService
    private let usageService: UsageService
    private let profile: Profile
    private let draftKey: String
    var deal: Deal?

    init(
        aiService: AIService,
        outputService: OutputService,
        speechService: SpeechService,
        usageService: UsageService,
        profile: Profile,
        deal: Deal? = nil
    ) {
        self.aiService = aiService
        self.outputService = outputService
        self.speechService = speechService
        self.usageService = usageService
        self.profile = profile
        self.deal = deal
        self.draftKey = Self.draftKey(profileId: profile.id, dealId: deal?.id)

        restoreDraft()
    }

    var canGenerateSummary: Bool {
        !notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSummaryStreaming
    }

    var canGenerateEmail: Bool {
        !summaryText.isEmpty && !isEmailStreaming
    }

    // MARK: - Voice Input

    func toggleVoiceRecording() async {
        if speechService.isRecording {
            await speechService.stopRecording()
            if !speechService.transcript.isEmpty {
                if !notesText.isEmpty { notesText += "\n" }
                notesText += speechService.transcript
            }
            isRecordingVoice = false
        } else {
            let authorized = await speechService.requestAuthorization()
            guard authorized else {
                error = "Microphone access is required for voice-to-text."
                return
            }
            do {
                try await Task.sleep(for: .milliseconds(250))
                try speechService.startRecording()
                isRecordingVoice = true
            } catch {
                speechService.cancelRecording()
                isRecordingVoice = false
                self.error = speechService.error ?? "Voice input could not start. Please type your notes instead."
            }
        }
    }

    // MARK: - Summary Generation

    func generateSummary() async {
        guard canGenerateSummary else { return }

        guard await usageService.canGenerate(userId: profile.id, plan: profile.plan) else {
            error = UsageService.limitMessage
            HapticService.shared.error()
            return
        }

        isSummaryStreaming = true
        summaryText = ""
        error = nil

        var tokenCount = 0

        do {
            let stream = aiService.streamPostCallSummary(
                notes: notesText,
                profile: profile,
                deal: deal
            )

            for try await chunk in stream {
                summaryText += chunk.text
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
                type: .summary,
                input: ["notes": notesText],
                output: summaryText,
                promptVersion: Prompts.PostCallSummary.version,
                rating: nil,
                createdAt: Date()
            )
            let saved = try await outputService.saveOutput(output)
            lastSummaryOutputId = saved.id
            persistDraft()
        } catch {
            handleError(error)
        }

        isSummaryStreaming = false
    }

    // MARK: - Follow-Up Email Generation

    func generateFollowUpEmail() async {
        guard canGenerateEmail else { return }

        guard await usageService.canGenerate(userId: profile.id, plan: profile.plan) else {
            error = UsageService.limitMessage
            HapticService.shared.error()
            return
        }

        isEmailStreaming = true
        emailText = ""
        error = nil

        var tokenCount = 0

        do {
            let stream = aiService.streamFollowUpEmail(
                summary: summaryText,
                profile: profile,
                deal: deal
            )

            for try await chunk in stream {
                emailText += chunk.text
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
                type: .email,
                input: ["summary": summaryText],
                output: emailText,
                promptVersion: Prompts.FollowUpEmail.version,
                rating: nil,
                createdAt: Date()
            )
            let saved = try await outputService.saveOutput(output)
            lastEmailOutputId = saved.id
            persistDraft()
        } catch {
            handleError(error)
        }

        isEmailStreaming = false
    }

    private func handleError(_ error: Error) {
        self.error = error.friendlyMessage
        HapticService.shared.error()
    }

    func persistDraft() {
        let draft = PostCallDraft(
            notesText: notesText,
            summaryText: summaryText,
            emailText: emailText,
            lastSummaryOutputId: lastSummaryOutputId,
            lastEmailOutputId: lastEmailOutputId
        )

        if draft.isEmpty {
            UserDefaults.standard.removeObject(forKey: draftKey)
            return
        }

        if let data = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(data, forKey: draftKey)
        }
    }

    private func restoreDraft() {
        guard
            let data = UserDefaults.standard.data(forKey: draftKey),
            let draft = try? JSONDecoder().decode(PostCallDraft.self, from: data)
        else { return }

        notesText = draft.notesText
        summaryText = draft.summaryText
        emailText = draft.emailText
        lastSummaryOutputId = draft.lastSummaryOutputId
        lastEmailOutputId = draft.lastEmailOutputId
    }

    private static func draftKey(profileId: UUID, dealId: UUID?) -> String {
        let context = dealId?.uuidString ?? "standalone"
        return "pitchos.postcall.draft.\(profileId.uuidString).\(context)"
    }

    static func clearDrafts(profileId: UUID) {
        let prefix = "pitchos.postcall.draft.\(profileId.uuidString)."
        for key in UserDefaults.standard.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}

private struct PostCallDraft: Codable {
    var notesText: String
    var summaryText: String
    var emailText: String
    var lastSummaryOutputId: UUID?
    var lastEmailOutputId: UUID?

    var isEmpty: Bool {
        notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && summaryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && emailText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
