import Foundation

// MARK: - ProfileViewModel

@Observable
@MainActor
final class ProfileViewModel {

    var isLoading: Bool = false

    weak var coordinator: (any ProfileCoordinatorProtocol)?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Actions

    func logout() {
        isLoading = true
        Task {
            try? await authService.logout()
            isLoading = false
            coordinator?.profileDidRequestLogout()
        }
    }

    func deleteAccount() {
        isLoading = true
        Task {
            do {
                try await authService.deleteAccount()
                coordinator?.profileDidRequestLogout()
            } catch {
                isLoading = false
            }
        }
    }
}
