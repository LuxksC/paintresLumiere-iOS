import UIKit
import Swinject
import GoogleSignIn

final class AppDelegate: NSObject, UIApplicationDelegate {

  private var dependencyContainer: DependencyContainer?

  /// Resolver exposed so CoordinatorView can resolve its dependencies.
  var resolver: Resolver? { dependencyContainer?.resolver }

  func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
      dependencyContainer = DependencyContainer()
      configureTabBarAppearance()
      return true
  }

  // MARK: - Appearance

  private func configureTabBarAppearance() {
      let appearance = UITabBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = PLColor.UI.backgroundElevated

      let normal   = PLColor.UI.textDisabled
      let selected = PLColor.UI.goldBright

      let item = UITabBarItemAppearance()
      item.normal.iconColor   = normal
      item.selected.iconColor = selected
      item.normal.titleTextAttributes   = [.foregroundColor: normal]
      item.selected.titleTextAttributes = [.foregroundColor: selected]

      appearance.stackedLayoutAppearance     = item
      appearance.inlineLayoutAppearance      = item
      appearance.compactInlineLayoutAppearance = item

      UITabBar.appearance().standardAppearance  = appearance
      UITabBar.appearance().scrollEdgeAppearance = appearance
  }
}
