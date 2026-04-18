import Swinject

// MARK: - Dependency Container

final class DependencyContainer {

    let assembler: Assembler

    init() {
        assembler = Assembler([
            NetworkAssembly(),
            ServicesAssembly(),
            AuthAssembly(),
            MainAssembly()
        ])
    }

    var resolver: Resolver { assembler.resolver }
}
