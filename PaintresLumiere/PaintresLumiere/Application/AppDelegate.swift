import UIKit
import Swinject

// MARK: - AppDelegate

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    private var dependencyContainer: DependencyContainer?

    var resolver: Resolver? { dependencyContainer?.resolver }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        dependencyContainer = DependencyContainer()
        configureAppearance()
        return true
    }

    // MARK: - Appearance

    private func configureAppearance() {
        configureTabBarAppearance()
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = PLColor.UI.backgroundElevated

        let normal   = PLColor.UI.textDisabled
        let selected = PLColor.UI.goldBright

        let item = UITabBarItemAppearance()
        item.normal.iconColor   = normal
        item.selected.iconColor = selected
        item.normal.titleTextAttributes   = [.foregroundColor: normal,   .font: UIFont.systemFont(ofSize: 11, weight: .semibold)]
        item.selected.titleTextAttributes = [.foregroundColor: selected, .font: UIFont.systemFont(ofSize: 11, weight: .semibold)]

        appearance.stackedLayoutAppearance      = item
        appearance.inlineLayoutAppearance       = item
        appearance.compactInlineLayoutAppearance = item

        UITabBar.appearance().standardAppearance  = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

}
