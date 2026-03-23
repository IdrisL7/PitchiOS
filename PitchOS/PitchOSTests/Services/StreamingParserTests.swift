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
