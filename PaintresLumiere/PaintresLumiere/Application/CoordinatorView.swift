import SwiftUI
import Swinject

// MARK: - CoordinatorView
//
// Root SwiftUI view. Owns NavigationCoordinator and switches between the
// Auth and Main flows by observing coordinator.isAuthenticated.
// Replaces the UIKit SceneDelegate + AppCoordinator + UINavigationController stack.

struct CoordinatorView: View {

    @State private var coordinator: NavigationCoordinator
    private let resolver: Resolver

    init(resolver: Resolver) {
        self.resolver = resolver
        let keychain = resolver.resolve(KeychainService.self) ?? KeychainService.shared
        _coordinator = State(initialValue: NavigationCoordinator(keychain: keychain))
    }

    var body: some View {
        Group {
            if coordinator.isAuthenticated {
                MainTabView(coordinator: coordinator, resolver: resolver)
            } else {
                AuthFlowView(coordinator: coordinator, resolver: resolver)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.isAuthenticated)
    }
}
