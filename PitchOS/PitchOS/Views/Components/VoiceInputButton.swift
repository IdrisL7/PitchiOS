import SwiftUI

/// Microphone toggle button for voice-to-text input.
struct VoiceInputButton: View {
    let isRecording: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isRecording ? "mic.fill" : "mic")
                .font(.title2)
                .foregroundStyle(isRecording ? .red : .accentColor)
                .symbolEffect(.pulse, isActive: isRecording)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isRecording ? Color.red.opacity(0.15) : Color.accentColor.opacity(0.1))
                )
        }
        .accessibilityLabel(isRecording ? "Stop recording" : "Start voice input")
    }
}

#Preview {
    HStack(spacing: 20) {
        VoiceInputButton(isRecording: false) {}
        VoiceInputButton(isRecording: true) {}
    }
}
