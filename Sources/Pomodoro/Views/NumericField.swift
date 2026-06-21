import SwiftUI

/// An editable, range-clamped integer field with a subtle filled background.
struct NumericField: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let tint: Color

    @State private var text: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        TextField("", text: $text)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.trailing)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(tint)
            .focused($focused)
            .frame(width: 44)
            .padding(.vertical, 5)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color.primary.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(focused ? tint.opacity(0.8) : .clear, lineWidth: 1.5)
                    )
            )
            .onAppear { text = String(value) }
            .onChange(of: value) { _, newValue in
                if !focused { text = String(newValue) }
            }
            .onChange(of: focused) { _, isFocused in
                if !isFocused { commit() }
            }
            .onSubmit { commit() }
    }

    private func commit() {
        let parsed = Int(text.trimmingCharacters(in: .whitespaces)) ?? value
        let clamped = min(max(parsed, range.lowerBound), range.upperBound)
        value = clamped
        text = String(clamped)
    }
}
