import SwiftUI
import Swinject

// MARK: - AuthFlowView
//
// Manages the authentication navigation stack.
// Uses NavigationStack with AuthRoute to push SignUp and ForgotPassword screens.

struct AuthFlowView: View {

    @Bindable var coordinator: NavigationCoordinator
    let resolver: Resolver

    var body: some View {
        NavigationStack(path: $coordinator.authPath) {
            LoginScreenView(coordinator: coordinator, resolver: resolver)
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .signUp:
                        SignUpScreenView(coordinator: coordinator, resolver: resolver)
                    case .forgotPassword:
                        ForgotPasswordScreenView(coordinator: coordinator, resolver: resolver)
                    }
                }
        }
    }
}

// MARK: - Screen Wrappers
//
// Each wrapper owns its ViewModel as @State so it survives re-renders.
// The coordinator is assigned in onAppear (MainActor context) to satisfy strict concurrency.

private struct LoginScreenView: View {

    @State private var viewModel: LoginViewModel
    let coordinator: NavigationCoordinator

    init(coordinator: NavigationCoordinator, resolver: Resolver) {
        self.coordinator = coordinator
        let authService = resolver.resolve(AuthServiceProtocol.self)
            ?? AuthService(apiClient: APIClient(), keychain: KeychainService.shared)
        _viewModel = State(initialValue:
            resolver.resolve(LoginViewModel.self) ?? LoginViewModel(authService: authService)
        )
    }

    var body: some View {
        LoginView(viewModel: viewModel)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear { viewModel.coordinator = coordinator }
    }
}

private struct SignUpScreenView: View {

    @State private var viewModel: SignUpViewModel
    let coordinator: NavigationCoordinator

    init(coordinator: NavigationCoordinator, resolver: Resolver) {
        self.coordinator = coordinator
        let authService = resolver.resolve(AuthServiceProtocol.self)
            ?? AuthService(apiClient: APIClient(), keychain: KeychainService.shared)
        _viewModel = State(initialValue:
            resolver.resolve(SignUpViewModel.self) ?? SignUpViewModel(authService: authService)
        )
    }

    var body: some View {
        SignUpView(viewModel: viewModel)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear { viewModel.coordinator = coordinator }
    }
}

private struct ForgotPasswordScreenView: View {

    @State private var viewModel: ForgotPasswordViewModel
    let coordinator: NavigationCoordinator

    init(coordinator: NavigationCoordinator, resolver: Resolver) {
        self.coordinator = coordinator
        let authService = resolver.resolve(AuthServiceProtocol.self)
            ?? AuthService(apiClient: APIClient(), keychain: KeychainService.shared)
        _viewModel = State(initialValue:
            resolver.resolve(ForgotPasswordViewModel.self) ?? ForgotPasswordViewModel(authService: authService)
        )
    }

    var body: some View {
        ForgotPasswordView(viewModel: viewModel)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear { viewModel.coordinator = coordinator }
    }
}
