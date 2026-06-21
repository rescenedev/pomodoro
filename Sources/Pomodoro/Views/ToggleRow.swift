import SwiftUI

/// A settings row with a left-aligned label and a trailing switch,
/// matching the layout of the numeric/stepper rows.
struct ToggleRow: View {
    let label: String
    @Binding var isOn: Bool
    let tint: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 13))
            Spacer(minLength: 8)
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(tint)
        }
    }
}
