import SwiftUI

// MARK: - Home View

struct HomeView: View {

    var body: some View {
        ZStack {
            PLColor.backgroundPrimary.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HomeHeaderView()
                    PLDivider().padding(.vertical, PLSpacing.md)
                    welcomeSection
                    quickActionsSection
                    recentFilesSection
                }
                .padding(.horizontal, PLSpacing.xl)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Sub-views

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: PLSpacing.xs) {
            Text("Good to see you back.")
                .font(PLFont.h1())
                .foregroundStyle(PLColor.textPrimary)
            Text("Start by uploading an SVG or generate a new design from your library.")
                .font(PLFont.body())
                .foregroundStyle(PLColor.textMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var quickActionsSection: some View {
        HStack(spacing: PLSpacing.md) {
            QuickActionCard(icon: "arrow.up.doc", title: "Upload SVG", subtitle: "Add a new file")
            QuickActionCard(icon: "wand.and.stars", title: "Generate", subtitle: "Combine & create")
        }
        .padding(.top, PLSpacing.lg)
    }

    private var recentFilesSection: some View {
        VStack(alignment: .leading, spacing: PLSpacing.md) {
            HStack {
                Text("RECENT FILES")
                    .font(PLFont.label())
                    .foregroundStyle(PLColor.textMuted)
                    .tracking(1)
                Spacer()
                Button("See all") { /* TODO */ }
                    .font(PLFont.caption())
                    .foregroundStyle(PLColor.goldMid)
            }
            .padding(.top, PLSpacing.xl)

            EmptyLibraryPrompt()
        }
    }
}

// MARK: - Home Header

struct HomeHeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Paintres Lumière")
                    .font(PLFont.h2())
                    .foregroundStyle(PLColor.goldBright)
                Text("LASER CUT STUDIO")
                    .font(PLFont.label())
                    .foregroundStyle(PLColor.textMuted)
                    .tracking(2)
            }
            Spacer()
            Button("Notifications", systemImage: "bell") { /* TODO */ }
                .labelStyle(.iconOnly)
                .foregroundStyle(PLColor.textMuted)
                .font(.system(.title3))
        }
        .padding(.top, PLSpacing.sm)
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: PLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(.title2))
                .foregroundStyle(PLColor.goldMid)
            Text(title)
                .font(PLFont.button())
                .foregroundStyle(PLColor.textPrimary)
            Text(subtitle)
                .font(PLFont.caption())
                .foregroundStyle(PLColor.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PLSpacing.md)
        .background(PLColor.backgroundElevated)
        .overlay {
            RoundedRectangle(cornerRadius: PLRadius.card)
                .stroke(PLColor.borderSubtle, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: PLRadius.card))
    }
}

// MARK: - Empty Library Prompt

struct EmptyLibraryPrompt: View {
    var body: some View {
        VStack(spacing: PLSpacing.md) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(PLColor.goldAntique)
            Text("No files yet")
                .font(PLFont.h2())
                .foregroundStyle(PLColor.textPrimary)
            Text("Upload your first SVG to get started.")
                .font(PLFont.body())
                .foregroundStyle(PLColor.textMuted)
                .multilineTextAlignment(.center)
            PLButton("Upload SVG") { /* TODO: open file picker */ }
                .frame(maxWidth: 200)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PLSpacing.xxl)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
