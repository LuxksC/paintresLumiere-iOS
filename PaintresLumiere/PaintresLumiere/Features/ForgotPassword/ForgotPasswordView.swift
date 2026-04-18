import SwiftUI

// MARK: - ForgotPassword View

struct ForgotPasswordView: View {

    @Bindable var viewModel: ForgotPasswordViewModel

    var body: some View {
        ZStack {
            PLColor.backgroundPrimary.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    backButton
                    header
                    PLDivider().padding(.vertical, PLSpacing.lg)
                    if let success = viewModel.successMessage {
                        SuccessStateView(message: success, onBack: { viewModel.goBack() })
                    } else {
                        formContent
                    }
                }
                .padding(.horizontal, PLSpacing.xl)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Sub-views

    private var backButton: some View {
        Button("← Back") { viewModel.goBack() }
            .font(PLFont.navLink())
            .foregroundStyle(PLColor.goldMid)
            .padding(.top, PLSpacing.md)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Reset Password")
                .font(PLFont.h1())
                .foregroundStyle(PLColor.textPrimary)
            Text("Enter your email and we'll send you a reset link.")
                .font(PLFont.body())
                .foregroundStyle(PLColor.textMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, PLSpacing.md)
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: PLSpacing.lg) {
            PLInputField(
                label: "Email Address",
                placeholder: "your@email.com",
                text: $viewModel.email,
                errorMessage: viewModel.emailError
            )
            PLButton("Send Reset Link", type: viewModel.isLoading ? .loading : .primary) {
                viewModel.sendResetLink()
            }
            .disabled(viewModel.email.isEmpty || viewModel.isLoading)
        }
    }
}

// MARK: - Success State

struct SuccessStateView: View {
    let message: String
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PLSpacing.md) {
            Label(message, systemImage: "checkmark.circle.fill")
                .font(PLFont.body())
                .foregroundStyle(PLColor.success)
                .padding(PLSpacing.md)
                .background(PLColor.success.opacity(0.1))
                .clipShape(.rect(cornerRadius: PLRadius.card))

            Text("Didn't receive it? Check your spam folder or try again.")
                .font(PLFont.caption())
                .foregroundStyle(PLColor.textMuted)

            PLButton("Back to Sign In", action: onBack)
                .padding(.top, PLSpacing.sm)
        }
    }
}

// MARK: - Preview

#Preview {
    ForgotPasswordView(viewModel: ForgotPasswordViewModel(authService: PreviewAuthService()))
}
