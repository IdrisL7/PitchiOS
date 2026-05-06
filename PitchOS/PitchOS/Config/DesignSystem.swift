import SwiftUI

// MARK: - Colour Scheme Preference

enum ColorSchemePreference: String, CaseIterable {
    case system = "system"
    case light  = "light"
    case dark   = "dark"

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }

    /// Mapped to SwiftUI `ColorScheme?` — `nil` means follow the OS.
    var swiftUIColorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - Plan Badge Colours (SwiftUI extension — kept out of the Foundation model)

extension UserPlan {
    /// Gradient stop colours for the plan badge pill.
    var badgeColors: [Color] {
        switch self {
        case .free: return []
        case .solo: return [Color.pitchAccent, Color.pitchPurple]
        case .pro:  return [Color.pitchAccent, Color.pitchPurple]
        case .team: return [Color.pitchSuccess, Color(red: 0.10, green: 0.70, blue: 0.45)]
        }
    }
}

// MARK: - Colour Tokens

extension Color {
    /// Electric blue — primary AI action colour
    static let pitchAccent = Color(red: 0.18, green: 0.56, blue: 0.96)
    /// Purple — AI glow, streaming indicator
    static let pitchPurple = Color(red: 0.55, green: 0.42, blue: 0.98)
    /// Emerald — won deals, success states
    static let pitchSuccess = Color(red: 0.20, green: 0.84, blue: 0.55)
    /// Amber — stalled deals, warning states
    static let pitchWarning = Color(red: 1.00, green: 0.72, blue: 0.18)
    /// Red — lost deals, error states
    static let pitchDanger = Color(red: 1.00, green: 0.30, blue: 0.30)
}

// MARK: - Typography

extension Font {
    /// SF Pro Rounded variant for headings and UI labels
    static func rounded(_ textStyle: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
        let base = Font.system(textStyle, design: .rounded)
        return base.weight(weight)
    }
}

// MARK: - Spacing Scale

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius Scale

enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 20
    static let pill: CGFloat = 9999
}

// MARK: - App Background

struct AppBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        ZStack {
            if colorScheme == .dark {
                // Deep navy base
                Color(red: 0.04, green: 0.05, blue: 0.12)
                    .ignoresSafeArea()
            } else {
                // Clean off-white with a faint blue tint
                Color(red: 0.96, green: 0.97, blue: 1.00)
                    .ignoresSafeArea()
            }

            // Radial glow from top — softer in light mode
            RadialGradient(
                colors: [
                    Color.pitchAccent.opacity(colorScheme == .dark ? 0.12 : 0.06),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: -0.1),
                startRadius: 0,
                endRadius: 480
            )
            .ignoresSafeArea()

            content
        }
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackgroundModifier())
    }
}
