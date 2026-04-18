import SwiftUI

// MARK: - Library View

struct LibraryView: View {

    var body: some View {
        ZStack {
            PLColor.backgroundPrimary.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                LibraryHeaderView()
                PLDivider()
                    .padding(.horizontal, PLSpacing.xl)
                    .padding(.vertical, PLSpacing.md)
                Spacer()
                LibraryEmptyStateView()
                Spacer()
            }
        }
    }
}

// MARK: - Library Header

struct LibraryHeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Library")
                    .font(PLFont.h1())
                    .foregroundStyle(PLColor.textPrimary)
                Text("YOUR SVG FILES")
                    .font(PLFont.label())
                    .foregroundStyle(PLColor.textMuted)
                    .tracking(1.5)
            }
            Spacer()
            Button("Upload SVG", systemImage: "plus") { /* TODO: upload */ }
                .labelStyle(.iconOnly)
                .foregroundStyle(PLColor.goldBright)
                .font(.system(.title3, weight: .semibold))
        }
        .padding(.horizontal, PLSpacing.xl)
        .padding(.top, PLSpacing.sm)
    }
}

// MARK: - Library Empty State

struct LibraryEmptyStateView: View {
    var body: some View {
        VStack(spacing: PLSpacing.md) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 48))
                .foregroundStyle(PLColor.goldAntique)
            Text("Your library is empty")
                .font(PLFont.h2())
                .foregroundStyle(PLColor.textPrimary)
            Text("Upload SVG files to build your collection.")
                .font(PLFont.body())
                .foregroundStyle(PLColor.textMuted)
                .multilineTextAlignment(.center)
            PLButton("Upload SVG") { /* TODO: open file picker */ }
                .frame(maxWidth: 200)
                .padding(.top, PLSpacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, PLSpacing.xl)
    }
}

// MARK: - Preview

#Preview {
    LibraryView()
}
