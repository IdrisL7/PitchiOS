import Foundation

/// Parses Server-Sent Events (SSE) lines from the Claude API streaming response.
enum StreamingParser {

    /// Parses a single SSE line into a StreamChunk.
    /// Claude SSE lines look like: `data: {"type":"content_block_delta","delta":{"type":"text_delta","text":"Hello"}}`
    static func parse(line: String) -> StreamChunk? {
        // SSE lines prefixed with "data: "
        guard line.hasPrefix("data: ") else { return nil }

        let jsonString = String(line.dropFirst(6))

        // Claude sends [DONE] when stream is complete (some proxy implementations)
        if jsonString == "[DONE]" {
            return StreamChunk(text: "", isComplete: true)
        }

        guard let data = jsonString.data(using: .utf8) else { return nil }

        do {
            let event = try JSONDecoder().decode(SSEEvent.self, from: data)
            return handleEvent(event)
        } catch {
            // Ignore unparseable lines (e.g., ping events)
            return nil
        }
    }

    private static func handleEvent(_ event: SSEEvent) -> StreamChunk? {
        switch event.type {
        case "content_block_delta":
            guard let text = event.delta?.text else { return nil }
            return StreamChunk(text: text, isComplete: false)

        case "message_stop":
            return StreamChunk(text: "", isComplete: true)

        case "message_start", "content_block_start", "content_block_stop", "message_delta":
            // Valid events but no text to emit
            return nil

        default:
            return nil
        }
    }
}
