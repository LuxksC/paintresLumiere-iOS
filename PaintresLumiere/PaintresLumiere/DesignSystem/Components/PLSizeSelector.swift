import SwiftUI

// MARK: - PLSizeSelector
//
// Horizontal row of pill buttons representing the discrete sizes available
// for the current SKU group. Sizes are passed as strings (already formatted
// by `ProductDimensions.compactLabel`). The `enabled` set behaves the same
// way as in `PLColorSelector` — unavailable sizes are dimmed and not
// tappable so the user can still see that the size exists for other colors.

struct PLSizeSelector: View {

    let sizes: [String]
    let enabled: Set<String>
    @Binding var selection: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PLSpacing.sm) {
                ForEach(sizes, id: \.self) { size in
                    pill(for: size)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private func pill(for size: String) -> some View {
        let isSelected = selection == size
        let isEnabled = enabled.contains(size)

        return Button {
            selection = size
        } label: {
            Text(size)
                .font(PLFont.button())
                .foregroundStyle(foreground(isSelected: isSelected))
                .padding(.horizontal, PLSpacing.md)
                .frame(minHeight: 36)
                .background(background(isSelected: isSelected))
                .overlay {
                    RoundedRectangle(cornerRadius: PLRadius.button)
                        .stroke(border(isSelected: isSelected), lineWidth: 1.5)
                }
                .clipShape(.rect(cornerRadius: PLRadius.button))
                .opacity(isEnabled ? 1 : 0.3)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Style helpers

    private func foreground(isSelected: Bool) -> Color {
        isSelected ? PLColor.backgroundPrimary : PLColor.textPrimary
    }

    private func background(isSelected: Bool) -> Color {
        isSelected ? PLColor.goldMid : .clear
    }

    private func border(isSelected: Bool) -> Color {
        isSelected ? .clear : PLColor.borderSubtle
    }
}

// MARK: - Preview

#Preview {
    StatefulPreview()
        .padding()
        .background(PLColor.backgroundPrimary)
}

private struct StatefulPreview: View {
    @State private var selection: String? = "200 × 80 × 3mm"
    var body: some View {
        PLSizeSelector(
            sizes: ["200 × 80 × 3mm", "300 × 120 × 5mm", "400 × 160 × 5mm"],
            enabled: ["200 × 80 × 3mm", "300 × 120 × 5mm"],
            selection: $selection
        )
    }
}
