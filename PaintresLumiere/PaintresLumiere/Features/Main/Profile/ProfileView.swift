import SwiftUI

// MARK: - Profile View

struct ProfileView: View {

    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        ZStack {
            PLColor.backgroundPrimary.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    profileHeader
                    PLDivider().padding(.vertical, PLSpacing.lg)
                    avatarSection
                    PLDivider().padding(.vertical, PLSpacing.lg)
                    settingsMenu
                    PLDivider().padding(.vertical, PLSpacing.lg)
                    accountActions
                    Spacer(minLength: PLSpacing.xxl)
                }
                .padding(.horizontal, PLSpacing.xl)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Sub-views

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Profile")
                .font(PLFont.h1())
                .foregroundStyle(PLColor.textPrimary)
                .padding(.top, PLSpacing.sm)
            Text("YOUR ACCOUNT")
                .font(PLFont.label())
                .foregroundStyle(PLColor.textMuted)
                .tracking(1.5)
        }
    }

    private var avatarSection: some View {
        HStack(spacing: PLSpacing.md) {
            AvatarView()
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Name")
                    .font(PLFont.h2())
                    .foregroundStyle(PLColor.textPrimary)
                Text("your@email.com")
                    .font(PLFont.body())
                    .foregroundStyle(PLColor.textMuted)
            }
        }
    }

    private var settingsMenu: some View {
        VStack(spacing: 0) {
            ProfileRow(icon: "person.crop.circle", title: "Edit Profile")
            ProfileRow(icon: "bell", title: "Notifications")
            ProfileRow(icon: "lock.shield", title: "Security")
            ProfileRow(icon: "questionmark.circle", title: "Help & Support")
        }
        .background(PLColor.backgroundElevated)
        .clipShape(.rect(cornerRadius: PLRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: PLRadius.card)
                .stroke(PLColor.borderSubtle, lineWidth: 1)
        }
    }

    private var accountActions: some View {
        VStack(spacing: PLSpacing.sm) {
            PLButton("Log Out", type: .ghost) {
                viewModel.logout()
            }
            PLButton("Delete Account", type: .destructive) {
                viewModel.deleteAccount()
            }
        }
    }
}

// MARK: - Avatar View

struct AvatarView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(PLColor.backgroundElevated)
                .frame(width: 64, height: 64)
                .overlay(Circle().stroke(PLColor.goldAntique, lineWidth: 1))
            Image(systemName: "person.fill")
                .font(.system(size: 28))
                .foregroundStyle(PLColor.goldMid)
        }
    }
}

// MARK: - Profile Row

struct ProfileRow: View {
    let icon: String
    let title: String

    var body: some View {
        Button {
            // TODO: navigate to sub-screen
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(PLColor.goldMid)
                    .frame(width: 20)
                Text(title)
                    .font(PLFont.body())
                    .foregroundStyle(PLColor.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(PLColor.textDisabled)
                    .font(.system(.caption))
            }
            .padding(PLSpacing.md)
        }
        .overlay(PLDivider().padding(.leading, PLSpacing.xl + 20), alignment: .bottom)
    }
}

// MARK: - Preview

#Preview {
    ProfileView(viewModel: ProfileViewModel(authService: PreviewAuthService()))
}
