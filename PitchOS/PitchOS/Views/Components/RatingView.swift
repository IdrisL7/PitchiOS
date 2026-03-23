import SwiftUI

/// Thumbs up / thumbs down rating for AI outputs.
struct RatingView: View {
    let onRate: (Int) -> Void

    @State private var currentRating: Int?

    var body: some View {
        HStack(spacing: 12) {
            Text("Was this helpful?")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                currentRating = 1
                onRate(1)
            } label: {
                Image(systemName: currentRating == 1 ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .foregroundStyle(currentRating == 1 ? .green : .secondary)
            }

            Button {
                currentRating = -1
                onRate(-1)
            } label: {
                Image(systemName: currentRating == -1 ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .foregroundStyle(currentRating == -1 ? .red : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RatingView { rating in
        print("Rated: \(rating)")
    }
}
