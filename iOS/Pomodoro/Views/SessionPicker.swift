import SwiftUI

/// A segmented pill control for switching between session types.
struct SessionPicker: View {
    let selection: SessionType
    let onSelect: (SessionType) -> Void

    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(SessionType.allCases) { session in
                let isSelected = session == selection
                Button {
                    onSelect(session)
                } label: {
                    Text(session.shortTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(session.gradient)
                                    .matchedGeometryEffect(id: "pill", in: namespace)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Capsule().fill(Color.primary.opacity(0.07)))
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selection)
    }
}
