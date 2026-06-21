import SwiftUI

/// Large gradient-filled primary action (play / pause).
struct PrimaryControlButton: View {
    let systemName: String
    let gradient: LinearGradient
    let glow: Color
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 68, height: 68)
                .background(Circle().fill(gradient))
                .shadow(color: glow.opacity(hovering ? 0.7 : 0.45), radius: hovering ? 16 : 10)
                .scaleEffect(hovering ? 1.06 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: hovering)
    }
}

/// Small circular secondary action (reset / skip).
struct CircleControlButton: View {
    let systemName: String
    let size: CGFloat
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(hovering ? .primary : .secondary)
                .frame(width: size, height: size)
                .background(
                    Circle().fill(Color.primary.opacity(hovering ? 0.12 : 0.07))
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.15), value: hovering)
    }
}

/// Subtle text+icon footer action.
struct FooterButton: View {
    let systemName: String
    let label: String
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: systemName)
                Text(label)
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(hovering ? .primary : .secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Color.primary.opacity(hovering ? 0.10 : 0))
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.15), value: hovering)
    }
}
