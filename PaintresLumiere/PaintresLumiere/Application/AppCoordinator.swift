import UIKit
import Swinject

// MARK: - AppCoordinator

/// Root coordinator. Owns the UIWindow and switches between the Auth and
/// Main flows based on authentication state. Never exposed to screens.
final class AppCoordinator: Coordinator {

  private let window: UIWindow
  private let resolver: Resolver
  private let keychain: KeychainService

  private var authCoordinator: AuthCoordinator?
  private var mainTabCoordinator: MainTabCoordinator?

  init(window: UIWindow, resolver: Resolver) {
    self.window = window
    self.resolver = resolver
    self.keychain = resolver.resolve(KeychainService.self) ?? KeychainService.shared
  }

  func start() {
    if keychain.isAuthenticated {
        showMain(animated: false)
    } else {
        showAuth(animated: false)
    }
  }

  // MARK: - Flow transitions

  private func showAuth(animated: Bool) {
    let coordinator = AuthCoordinator(resolver: resolver)
    coordinator.onAuthenticated = { [weak self] in
        self?.showMain(animated: true)
    }
    authCoordinator = coordinator
    mainTabCoordinator = nil
    coordinator.start()
    setRoot(coordinator.navigationController, animated: animated)
    window.rootViewController = coordinator.navigationController
  }

  private func showMain(animated: Bool) {
    let coordinator = MainTabCoordinator(resolver: resolver)
    coordinator.onLoggedOut = { [weak self] in
        self?.showAuth(animated: true)
    }
    mainTabCoordinator = coordinator
    authCoordinator = nil
    coordinator.start()
    setRoot(coordinator.tabBarController, animated: animated)
    window.rootViewController = coordinator.tabBarController
  }

  private func setRoot(_ viewController: UIViewController, animated: Bool) {
    guard animated else {
      window.rootViewController = viewController
      return
    }
    UIView.transition(
      with: window,
      duration: 0.3,
      options: .transitionCrossDissolve,
      animations: { self.window.rootViewController = viewController }
    )
  }
}
