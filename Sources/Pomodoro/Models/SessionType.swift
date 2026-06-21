import SwiftUI

/// The kind of interval the timer is currently running.
enum SessionType: String, CaseIterable, Identifiable {
    case focus
    case shortBreak
    case longBreak

    var id: String { rawValue }

    var title: String {
        switch self {
        case .focus: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }

    /// Compact label for the pill selector.
    var shortTitle: String {
        switch self {
        case .focus: return "Focus"
        case .shortBreak: return "Short"
        case .longBreak: return "Long"
        }
    }

    /// SF Symbol shown in the menu bar for this session.
    var symbolName: String {
        switch self {
        case .focus: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak: return "figure.walk"
        }
    }

    var accentColor: Color {
        switch self {
        case .focus: return Color(red: 0.98, green: 0.36, blue: 0.42)
        case .shortBreak: return Color(red: 0.20, green: 0.80, blue: 0.60)
        case .longBreak: return Color(red: 0.36, green: 0.62, blue: 0.98)
        }
    }

    /// Secondary color used for the ring/button gradient.
    var accentColorSecondary: Color {
        switch self {
        case .focus: return Color(red: 0.96, green: 0.55, blue: 0.30)
        case .shortBreak: return Color(red: 0.30, green: 0.86, blue: 0.78)
        case .longBreak: return Color(red: 0.52, green: 0.42, blue: 0.96)
        }
    }

    /// Diagonal gradient from primary to secondary accent.
    var gradient: LinearGradient {
        LinearGradient(
            colors: [accentColor, accentColorSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Whether this session counts as a completed focus interval.
    var isFocus: Bool { self == .focus }
}
