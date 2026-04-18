import Swinject
import SwiftUI
import GoogleSignIn

// MARK: - App Entry Point
//
// CoordinatorView is the root view — it owns NavigationCoordinator and switches
// between Auth and Main flows based on authentication state.
// No SceneDelegate or UIWindow management needed.

@main
struct PaintresLumiereApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
          CoordinatorView(resolver: appDelegate.resolver ?? Assembler().resolver)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
