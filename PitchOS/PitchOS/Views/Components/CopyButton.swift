import SwiftUI

/// A button that copies text to the clipboard with haptic feedback and a brief confirmation.
struct CopyButton: View {
    let text: String
    let label: String

    @State private var copied = false

    init(_ label: String = "Copy", text: String) {
        self.label = label
        self.text = text
    }

    var body: some View {
        Button {
            UIPasteboard.general.string = text
            HapticService.shared.copied()
            copied = true
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                copied = false
            }
        } label: {
            Label(copied ? "Copied" : label, systemImage: copied ? "checkmark" : "doc.on.doc")
                .font(.subheadline)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.bordered)
        .tint(copied ? Color.pitchSuccess : Color.pitchAccent)
        .disabled(text.isEmpty)
    }
}

#Preview {
    CopyButton("Copy Response", text: "Hello, world!")
        .padding()
        .appBackground()
}
