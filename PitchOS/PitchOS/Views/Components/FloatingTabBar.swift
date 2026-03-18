import SwiftUI

// MARK: - Tab Definition

enum AppTab: String, CaseIterable {
    case deals    = "Deals"
    case generate = "Generate"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .deals:    return "briefcase.fill"
        case .generate: return "sparkles"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Floating Tab Bar

struct FloatingTabBar: View {
    @Binding var selected: AppTab
    @Namespace private var indicator

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 8)
        .padding(.horizontal, Spacing.xl)
    }

    @ViewBuilder
    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                selected = tab
            }
            HapticService.shared.selectionChanged()
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    if selected == tab {
                        Capsule()
                            .fill(Color.pitchAccent.opacity(0.18))
                            .matchedGeometryEffect(id: "indicator", in: indicator)
                            .frame(height: 32)
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: 16, weight: selected == tab ? .semibold : .regular))
                        .foregroundStyle(selected == tab ? Color.pitchAccent : Color.secondary)
                        .frame(height: 32)
                }

                Text(tab.rawValue)
                    .font(.rounded(.caption2, weight: selected == tab ? .semibold : .regular))
                    .foregroundStyle(selected == tab ? Color.pitchAccent : Color.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var tab: AppTab = .deals

    VStack {
        Spacer()
        FloatingTabBar(selected: $tab)
        Spacer().frame(height: 20)
    }
    .appBackground()
}
