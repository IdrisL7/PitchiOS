import Foundation

/// Calls Supabase Edge Functions that proxy to Claude API, returning streamed responses.
final class AIService: Sendable {
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    // MARK: - Objection Handler

    func streamObjectionResponse(
        objection: String,
        profile: Profile,
        deal: Deal? = nil
    ) -> AsyncThrowingStream<StreamChunk, Error> {
        let body: [String: String] = [
            "type": "objection",
            "objection": objection,
            "profileContext": Prompts.systemPrompt(profile: profile),
            "userPrompt": Prompts.ObjectionHandler.userPrompt(
                objection: objection,
                dealContext: deal?.contextString,
                vertical: profile.vertical
            ),
            "promptVersion": Prompts.ObjectionHandler.version
        ]
        return streamFromEdgeFunction("generate", body: body)
    }

    // MARK: - Post-Call Summary

    func streamPostCallSummary(
        notes: String,
        profile: Profile,
        deal: Deal? = nil
    ) -> AsyncThrowingStream<StreamChunk, Error> {
        let body: [String: String] = [
            "type": "summary",
            "notes": notes,
            "profileContext": Prompts.systemPrompt(profile: profile),
            "userPrompt": Prompts.PostCallSummary.userPrompt(
                notes: notes,
                dealContext: deal?.contextString
            ),
            "promptVersion": Prompts.PostCallSummary.version
        ]
        return streamFromEdgeFunction("generate", body: body)
    }

    // MARK: - Follow-Up Email

    func streamFollowUpEmail(
        summary: String,
        profile: Profile,
        deal: Deal? = nil
    ) -> AsyncThrowingStream<StreamChunk, Error> {
        let body: [String: String] = [
            "type": "email",
            "summary": summary,
            "profileContext": Prompts.systemPrompt(profile: profile),
            "userPrompt": Prompts.FollowUpEmail.userPrompt(
                summary: summary,
                dealContext: deal?.contextString
            ),
            "promptVersion": Prompts.FollowUpEmail.version
        ]
        return streamFromEdgeFunction("generate", body: body)
    }

    // MARK: - Discovery Questions

    func streamDiscoveryQuestions(
        profile: Profile,
        deal: Deal? = nil
    ) -> AsyncThrowingStream<StreamChunk, Error> {
        let body: [String: String] = [
            "type": "questions",
            "profileContext": Prompts.systemPrompt(profile: profile),
            "userPrompt": Prompts.DiscoveryQuestions.userPrompt(
                dealContext: deal?.contextString,
                vertical: profile.vertical,
                methodology: profile.methodology,
                methodologyGuidance: profile.salesMethodology.promptGuidance
            ),
            "promptVersion": Prompts.DiscoveryQuestions.version
        ]
        return streamFromEdgeFunction("generate", body: body)
    }

    // MARK: - Meeting Brief

    func streamMeetingBrief(
        profile: Profile,
        deal: Deal? = nil
    ) -> AsyncThrowingStream<StreamChunk, Error> {
        let body: [String: String] = [
            "type": "brief",
            "profileContext": Prompts.systemPrompt(profile: profile),
            "userPrompt": Prompts.MeetingBrief.userPrompt(
                dealContext: deal?.contextString
            ),
            "promptVersion": Prompts.MeetingBrief.version
        ]
        return streamFromEdgeFunction("generate", body: body)
    }

    // MARK: - Private Streaming

    private func streamFromEdgeFunction(
        _ functionName: String,
        body: [String: String]
    ) -> AsyncThrowingStream<StreamChunk, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let token: String
                    do {
                        token = try await authService.accessToken()
                    } catch {
                        throw AIServiceError.unauthorized
                    }

                    var request = URLRequest(
                        url: URL(string: "\(AppConfig.supabaseURL)/functions/v1/\(functionName)")!
                    )
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = try JSONEncoder().encode(body)

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw AIServiceError.invalidResponse
                    }

                    guard httpResponse.statusCode == 200 else {
                        if httpResponse.statusCode == 429 {
                            throw AIServiceError.quotaExceeded
                        }
                        throw AIServiceError.serverError(statusCode: httpResponse.statusCode)
                    }

                    let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type")
                    guard Self.isEventStream(contentType) else {
                        let detail = try await Self.readFirstMeaningfulLine(from: bytes)
                        throw AIServiceError.serverError(
                            statusCode: httpResponse.statusCode,
                            detail: detail
                        )
                    }

                    var chunksYielded = 0
                    for try await line in bytes.lines {
                        if Task.isCancelled { break }

                        if let chunk = StreamingParser.parse(line: line) {
                            continuation.yield(chunk)
                            chunksYielded += 1
                            if chunk.isComplete {
                                break
                            }
                        }
                    }

                    try Self.validateCompletedStream(chunksYielded)

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    static func isEventStream(_ contentType: String?) -> Bool {
        guard let contentType else { return false }
        return contentType.localizedCaseInsensitiveContains("text/event-stream")
    }

    static func validateCompletedStream(_ chunksYielded: Int) throws {
        guard chunksYielded > 0 else {
            throw AIServiceError.invalidResponse
        }
    }

    static func readFirstMeaningfulLine(
        from bytes: URLSession.AsyncBytes
    ) async throws -> String {
        for try await line in bytes.lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return trimmed
            }
        }

        return ""
    }
}

enum AIServiceError: LocalizedError {
    case invalidResponse
    case quotaExceeded
    case serverError(statusCode: Int, detail: String = "")
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .quotaExceeded:
            return "You've reached your monthly generation limit. Upgrade to continue."
        case .serverError(let code, let detail):
            let trimmedDetail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedDetail.isEmpty {
                return "Server error (HTTP \(code)). Please try again."
            }
            return "Server error (HTTP \(code)): \(trimmedDetail)"
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        }
    }
}
