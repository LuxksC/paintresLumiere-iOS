import SwiftUI

// MARK: - PLColorSelector
//
// Horizontal row of color swatches. Bind to the currently-selected color
// and pass the colors available for the current SKU group. Colors present
// in `colors` but absent from `enabled` are rendered dimmed and are not
// tappable — that's how we tell the user "this color exists for this
// product, just not in the size you've picked".

struct PLColorSelector: View {

    let colors: [ProductColor]
    let enabled: Set<ProductColor>
    @Binding var selection: ProductColor?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PLSpacing.md) {
                ForEach(colors, id: \.self) { color in
                    swatch(for: color)
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }

    private func swatch(for color: ProductColor) -> some View {
        let isSelected = selection == color
        let isEnabled = enabled.contains(color)

        return Button {
            selection = color
        } label: {
            ZStack {
                Circle()
                    .fill(color.swatch)
                    .frame(width: 32, height: 32)
                    .overlay {
                        if color.needsSwatchOutline {
                            Circle().stroke(PLColor.borderSubtle, lineWidth: 1)
                        }
                    }
                if isSelected {
                    Circle()
                        .stroke(PLColor.goldBright, lineWidth: 2)
                        .frame(width: 42, height: 42)
                }
            }
            .frame(width: 44, height: 44)
            .opacity(isEnabled ? 1 : 0.3)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(Text(color.displayName))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview {
    StatefulPreview()
        .padding()
        .background(PLColor.backgroundPrimary)
}

private struct StatefulPreview: View {
    @State private var selection: ProductColor? = .gold
    var body: some View {
        PLColorSelector(
            colors: ProductColor.allCases,
            enabled: [.gold, .silver, .rose, .black],
            selection: $selection
        )
    }
}
