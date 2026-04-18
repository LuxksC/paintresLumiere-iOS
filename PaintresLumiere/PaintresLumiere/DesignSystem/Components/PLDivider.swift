import SwiftUI

// MARK: - Dividers and separators

struct PLDivider: View {
    var body: some View {
        Rectangle()
            .fill(PLColor.borderSubtle)
            .frame(height: 1)
    }
}

struct PLOrDivider: View {
    let label: String

    init(_ label: String = "or") {
        self.label = label
    }

    var body: some View {
        HStack(spacing: 12) {
            PLDivider()
            Text(label)
                .font(PLFont.caption())
                .foregroundColor(PLColor.textMuted)
            PLDivider()
        }
    }
}
