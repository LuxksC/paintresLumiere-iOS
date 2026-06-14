import SwiftUI

// MARK: - PLPageIndicator
//
// Dots indicator for image carousels. Auto-hides when there is only one
// page (or none) so callers don't have to gate the view themselves.

struct PLPageIndicator: View {

    let count: Int
    let activeIndex: Int

    var body: some View {
        if count > 1 {
            HStack(spacing: 6) {
                ForEach(0..<count, id: \.self) { index in
                    Capsule()
                        .fill(index == activeIndex ? PLColor.goldBright : PLColor.textDisabled)
                        .frame(width: index == activeIndex ? 18 : 6, height: 6)
                        .animation(.snappy(duration: 0.2), value: activeIndex)
                }
            }
            .accessibilityLabel("Image \(activeIndex + 1) of \(count)")
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: PLSpacing.lg) {
        PLPageIndicator(count: 3, activeIndex: 0)
        PLPageIndicator(count: 5, activeIndex: 2)
        PLPageIndicator(count: 1, activeIndex: 0)
    }
    .padding()
    .background(PLColor.backgroundPrimary)
}
