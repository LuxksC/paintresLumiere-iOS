import SwiftUI

// MARK: - Sign Up View (pixel-accurate to Figma)

struct SignUpView: View {

    @Bindable var viewModel: SignUpViewModel

    var body: some View {
        ZStack {
            PLColor.backgroundPrimary.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    backButton
                    header
                    PLDivider().padding(.vertical, PLSpacing.md)
                    requiredFieldsSection
                    PLDivider().padding(.vertical, PLSpacing.md)
                    optionalFieldsSection
                    if let error = viewModel.generalError { generalErrorView(error) }
                    PLDivider().padding(.vertical, PLSpacing.lg)
                    submitButton
                    signInFooter
                    Spacer(minLength: PLSpacing.xxl)
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
            Text("Create Account")
                .font(PLFont.h1())
                .foregroundStyle(PLColor.textPrimary)
            Text("Join Paintres Lumière and start creating.")
                .font(PLFont.body())
                .foregroundStyle(PLColor.textMuted)
        }
        .padding(.top, PLSpacing.md)
    }

    private var requiredFieldsSection: some View {
        VStack(alignment: .leading, spacing: PLSpacing.md) {
            Text("* required fields")
                .font(PLFont.caption())
                .foregroundStyle(PLColor.textDisabled)

            PLInputField(label: "Name *", placeholder: "Your full name",
                         text: $viewModel.name, errorMessage: viewModel.nameError)

            PLInputField(label: "Email Address *", placeholder: "john@example.com",
                         text: $viewModel.email, errorMessage: viewModel.emailError)

            passwordFields
        }
    }

    private var passwordFields: some View {
        VStack(alignment: .leading, spacing: 4) {
            PLInputField(label: "Password *", placeholder: "Min. 8 characters",
                         text: $viewModel.password, isSecure: true,
                         errorMessage: viewModel.passwordError)
            PLPasswordStrengthBar(password: viewModel.password)
            PLInputField(label: "Confirm Password *", placeholder: "Repeat password",
                         text: $viewModel.confirmPassword, isSecure: true,
                         errorMessage: viewModel.confirmPasswordError)
        }
    }

    private var optionalFieldsSection: some View {
        VStack(alignment: .leading, spacing: PLSpacing.md) {
            Text("OPTIONAL INFORMATION")
                .font(PLFont.label())
                .foregroundStyle(PLColor.textDisabled)
                .tracking(1)

            HStack(spacing: PLSpacing.md) {
                PLInputField(label: "CPF", placeholder: "000.000.000-00", text: $viewModel.cpf)
                PLInputField(label: "CNPJ", placeholder: "00.000.000/0001-00", text: $viewModel.cnpj)
            }

            PLInputField(label: "Phone", placeholder: "+55 (00) 00000-0000", text: $viewModel.phone)
        }
    }

    private func generalErrorView(_ error: String) -> some View {
        Label(error, systemImage: "exclamationmark.triangle")
            .font(PLFont.caption())
            .foregroundStyle(PLColor.error)
            .padding(.top, PLSpacing.sm)
    }

    private var submitButton: some View {
        PLButton("Create Account", type: viewModel.isLoading ? .loading : .primary) {
            viewModel.createAccount()
        }
        .disabled(!viewModel.canSubmit)
    }

    private var signInFooter: some View {
        HStack(spacing: 4) {
            Spacer()
            Text("Already have an account?")
                .font(PLFont.link())
                .foregroundStyle(PLColor.textMuted)
            Button("Sign In") { viewModel.requestSignIn() }
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(PLColor.goldBright)
            Spacer()
        }
        .padding(.top, PLSpacing.md)
    }
}

// MARK: - Preview

#Preview {
    SignUpView(viewModel: SignUpViewModel(authService: PreviewAuthService()))
}
