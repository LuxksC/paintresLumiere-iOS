import SwiftUI
import Swinject

// MARK: - MainTabView
//
// Root view for the logged-in experience. Displays Home, Library, and Profile tabs.
// Uses the iOS 18+ Tab API as required by CLAUDE.md.

struct MainTabView: View {

    var coordinator: NavigationCoordinator
    let resolver: Resolver

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            Tab("Library", systemImage: "books.vertical") {
                LibraryView()
            }
            Tab("Profile", systemImage: "person") {
                ProfileScreenView(coordinator: coordinator, resolver: resolver)
            }
        }
        .tint(PLColor.goldBright)
    }
}

// MARK: - Profile Screen Wrapper

private struct ProfileScreenView: View {

    @State private var viewModel: ProfileViewModel
    let coordinator: NavigationCoordinator

    init(coordinator: NavigationCoordinator, resolver: Resolver) {
        self.coordinator = coordinator
        let authService = resolver.resolve(AuthServiceProtocol.self)
            ?? AuthService(apiClient: APIClient(), keychain: KeychainService.shared)
        _viewModel = State(initialValue:
            resolver.resolve(ProfileViewModel.self) ?? ProfileViewModel(authService: authService)
        )
    }

    var body: some View {
        ProfileView(viewModel: viewModel)
            .onAppear { viewModel.coordinator = coordinator }
    }
}
