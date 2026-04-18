import Swinject
import Foundation

// MARK: - Network Assembly
//
// Registers low-level networking dependencies.
// APIClient is scoped as a container singleton — one shared URLSession for the app.

final class NetworkAssembly: Assembly {

    func assemble(container: Container) {
        container.register(APIClientProtocol.self) { _ in
            APIClient()
        }.inObjectScope(.container)
    }
}
