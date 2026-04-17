import Testing
@testable import PitchOS

@Suite("StreamingParser")
struct StreamingParserTests {

    @Test("Parses content_block_delta with text")
    func parsesTextDelta() {
        let line = #"data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello world"}}"#
        let chunk = StreamingParser.parse(line: line)

        #expect(chunk != nil)
        #expect(chunk?.text == "Hello world")
        #expect(chunk?.isComplete == false)
    }

    @Test("Parses message_stop as complete")
    func parsesMessageStop() {
        let line = #"data: {"type":"message_stop"}"#
        let chunk = StreamingParser.parse(line: line)

        #expect(chunk != nil)
        #expect(chunk?.isComplete == true)
    }

    @Test("Handles [DONE] marker")
    func handlesDoneMarker() {
        let line = "data: [DONE]"
        let chunk = StreamingParser.parse(line: line)

        #expect(chunk != nil)
        #expect(chunk?.isComplete == true)
    }

    @Test("Ignores non-data lines")
    func ignoresNonDataLines() {
        #expect(StreamingParser.parse(line: "event: message_start") == nil)
        #expect(StreamingParser.parse(line: ": ping") == nil)
        #expect(StreamingParser.parse(line: "") == nil)
    }

    @Test("Ignores message_start event")
    func ignoresMessageStart() {
        let line = #"data: {"type":"message_start","message":{"id":"msg_123"}}"#
        let chunk = StreamingParser.parse(line: line)
        #expect(chunk == nil)
    }

    @Test("Ignores content_block_start event")
    func ignoresContentBlockStart() {
        let line = #"data: {"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}}"#
        let chunk = StreamingParser.parse(line: line)
        #expect(chunk == nil)
    }

    @Test("Handles malformed JSON gracefully")
    func handlesMalformedJSON() {
        let line = "data: {not valid json}"
        let chunk = StreamingParser.parse(line: line)
        #expect(chunk == nil)
    }

    @Test("Handles delta with special characters")
    func handlesSpecialCharacters() {
        let line = #"data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"**Acknowledge**: That's a fair point — pricing matters."}}"#
        let chunk = StreamingParser.parse(line: line)

        #expect(chunk?.text == "**Acknowledge**: That's a fair point — pricing matters.")
    }
}

@Suite("AIService")
struct AIServiceTests {

    @Test("Recognizes SSE content type")
    func recognizesEventStreamContentType() {
        #expect(AIService.isEventStream("text/event-stream"))
        #expect(AIService.isEventStream("text/event-stream; charset=utf-8"))
        #expect(AIService.isEventStream("TEXT/EVENT-STREAM"))
    }

    @Test("Rejects non-SSE content types")
    func rejectsNonEventStreamContentType() {
        #expect(AIService.isEventStream("application/json") == false)
        #expect(AIService.isEventStream(nil) == false)
    }

    @Test("Throws invalid response for empty streams")
    func rejectsEmptyStream() throws {
        do {
            try AIService.validateCompletedStream(0)
            Issue.record("Expected validateCompletedStream to throw for an empty stream.")
        } catch let error as AIServiceError {
            guard case .invalidResponse = error else {
                Issue.record("Expected invalidResponse, got \(error).")
                return
            }
        } catch {
            Issue.record("Expected AIServiceError.invalidResponse, got \(error).")
        }
    }

    @Test("Allows non-empty streams")
    func acceptsNonEmptyStream() throws {
        try AIService.validateCompletedStream(1)
    }

    @Test("Includes server error detail when available")
    func includesServerErrorDetail() {
        let error = AIServiceError.serverError(statusCode: 200, detail: #"{"error":"Missing Claude API key"}"#)
        #expect(error.errorDescription == #"Server error (HTTP 200): {"error":"Missing Claude API key"}"#)
    }

    @Test("Maps 401 responses to unauthorized")
    func mapsUnauthorizedStatusCode() {
        let error = AIService.responseError(statusCode: 401)
        guard case .unauthorized = error else {
            Issue.record("Expected unauthorized for HTTP 401, got \(error).")
            return
        }
    }

    @Test("Preserves detail for non-auth server errors")
    func preservesServerErrorDetailFromStatusMapper() {
        let error = AIService.responseError(statusCode: 500, detail: "upstream failed")
        guard case .serverError(let statusCode, let detail) = error else {
            Issue.record("Expected serverError for HTTP 500, got \(error).")
            return
        }

        #expect(statusCode == 500)
        #expect(detail == "upstream failed")
    }
}
