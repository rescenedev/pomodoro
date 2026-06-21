import SwiftUI

/// Large gradient-filled primary action (play / pause).
struct PrimaryControlButton: View {
    let systemName: String
    let gradient: LinearGradient
    let glow: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 84, height: 84)
                .background(Circle().fill(gradient))
                .shadow(color: glow.opacity(0.5), radius: 12)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.92))
    }
}

/// Small circular secondary action (reset / skip).
struct CircleControlButton: View {
    let systemName: String
    let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: size, height: size)
                .background(Circle().fill(Color.primary.opacity(0.08)))
        }
        .buttonStyle(PressableButtonStyle(scale: 0.9))
    }
}

/// Scales the label down briefly while pressed — the touch equivalent of hover.
struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.92

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
