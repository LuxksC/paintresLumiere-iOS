import SwiftUI

// MARK: - Login View (pixel-accurate to Figma)

struct LoginView: View {

    @Bindable var viewModel: LoginViewModel

    var body: some View {
        ZStack {
            backgroundLayer
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    BrandHeader()
                        .padding(.top, 82)
                    welcomeCopy
                    PLDivider().padding(.top, PLSpacing.lg)
                    fieldsSection
                    forgotPasswordButton
                    PLDivider().padding(.top, PLSpacing.lg)
                    loginButton
                    PLOrDivider("ou").padding(.vertical, PLSpacing.md)
                    googleButton
                    PLDivider().padding(.top, PLSpacing.lg)
                    signUpFooter
                    Spacer(minLength: PLSpacing.xxl)
                }
                .padding(.horizontal, PLSpacing.xl)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Sub-views

    private var backgroundLayer: some View {
        ZStack {
            PLColor.backgroundPrimary
            RadialGradient(
                colors: [Color(hex: "795911").opacity(0.18), PLColor.backgroundPrimary],
                center: UnitPoint(x: 0.5, y: 0.85),
                startRadius: 0,
                endRadius: 320
            )
        }
        .ignoresSafeArea()
    }

    private var welcomeCopy: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome back.")
                .font(PLFont.h2())
                .foregroundStyle(PLColor.textPrimary)
            Text("Sign in to continue your craft.")
                .font(PLFont.body())
                .foregroundStyle(PLColor.textMuted)
        }
        .padding(.top, PLSpacing.xxl)
    }

    private var fieldsSection: some View {
        VStack(spacing: PLSpacing.sm) {
            PLInputField(
                label: "Email Address",
                placeholder: "your@email.com",
                text: $viewModel.email,
                errorMessage: viewModel.errorMessage != nil ? " " : nil
            )
            PLInputField(
                label: "Password",
                placeholder: "Your password",
                text: $viewModel.password,
                isSecure: true,
                errorMessage: viewModel.errorMessage
            )
        }
        .padding(.top, PLSpacing.md)
    }

    private var forgotPasswordButton: some View {
        HStack {
            Spacer()
            Button("Forgot password?") {
                viewModel.requestForgotPassword()
            }
            .font(PLFont.link())
            .foregroundStyle(PLColor.goldMid)
        }
        .padding(.top, PLSpacing.sm)
    }

    private var loginButton: some View {
        PLButton("Login", type: viewModel.isLoading ? .loading : .primary) {
            viewModel.login()
        }
        .disabled(!viewModel.canSubmit)
        .padding(.top, PLSpacing.lg)
    }

    private var googleButton: some View {
        PLButton("Continue with Google", type: .ghost) {
            viewModel.requestGoogleSignIn()
        }
    }

    private var signUpFooter: some View {
        HStack(spacing: 4) {
            Spacer()
            Text("Não tem uma conta?")
                .font(PLFont.link())
                .foregroundStyle(PLColor.textMuted)
            Button("Criar conta") { viewModel.requestSignUp() }
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(PLColor.goldBright)
            Spacer()
        }
        .padding(.top, PLSpacing.md)
    }
}

// MARK: - Brand Header (reusable across auth screens)

struct BrandHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Rectangle()
                .fill(PLColor.goldAntique.opacity(0.6))
                .frame(width: 80, height: 1)
            Text("Paintres Lumière")
                .font(PLFont.display())
                .foregroundStyle(PLColor.goldBright)
            Text("LASER CUT STUDIO")
                .font(PLFont.label())
                .foregroundStyle(PLColor.textMuted)
                .tracking(2.5)
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView(viewModel: LoginViewModel(authService: PreviewAuthService()))
}
