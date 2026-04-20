import UIKit
import GoogleSignIn

// MARK: - SceneDelegate

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
      guard let windowScene = scene as? UIWindowScene,
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let resolver = appDelegate.resolver else {
        return
      }

      let appWindow = UIWindow(windowScene: windowScene)

      appCoordinator = AppCoordinator(window: appWindow, resolver: resolver)
      appCoordinator?.start()

      appWindow.makeKeyAndVisible()
      
      window = appWindow
    }

    // MARK: - URL Handling (Google Sign-In)

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            GIDSignIn.sharedInstance.handle(context.url)
        }
    }
}
