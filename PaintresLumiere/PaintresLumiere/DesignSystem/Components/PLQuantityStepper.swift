import SwiftUI

// MARK: - PLQuantityStepper
//
// Compact "− N +" stepper used in the product details footer. The value is
// clamped to `range`; the minus/plus buttons disable themselves at the
// bounds so callers don't need to guard their handlers.

struct PLQuantityStepper: View {

    @Binding var value: Int
    let range: ClosedRange<Int>

    init(value: Binding<Int>, range: ClosedRange<Int> = 1...99) {
        self._value = value
        self.range = range
    }

    var body: some View {
        HStack(spacing: 0) {
            stepButton(systemImage: "minus", isEnabled: value > range.lowerBound) {
                if value > range.lowerBound { value -= 1 }
            }

            Text("\(value)")
                .font(PLFont.button())
                .foregroundStyle(PLColor.textPrimary)
                .frame(minWidth: 28)
                .monospacedDigit()

            stepButton(systemImage: "plus", isEnabled: value < range.upperBound) {
                if value < range.upperBound { value += 1 }
            }
        }
        .padding(.horizontal, 4)
        .frame(height: 40)
        .background(PLColor.backgroundElevated)
        .overlay {
            RoundedRectangle(cornerRadius: PLRadius.button)
                .stroke(PLColor.borderSubtle, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: PLRadius.button))
    }

    private func stepButton(systemImage: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(.callout, weight: .semibold))
                .foregroundStyle(isEnabled ? PLColor.textPrimary : PLColor.textDisabled)
                .frame(width: 32, height: 32)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

// MARK: - Preview

#Preview {
    StatefulPreview()
        .padding()
        .background(PLColor.backgroundPrimary)
}

private struct StatefulPreview: View {
    @State private var value: Int = 1
    var body: some View {
        PLQuantityStepper(value: $value, range: 1...5)
    }
}
