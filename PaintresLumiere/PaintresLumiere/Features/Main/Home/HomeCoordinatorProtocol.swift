import Foundation

// MARK: - HomeCoordinatorProtocol
//
// Navigation events emitted by the Home feature. Implemented by
// `HomeCoordinator`; the ViewModel calls these without knowing which
// coordinator concrete type it is talking to.

@MainActor
protocol HomeCoordinatorProtocol: AnyObject {
    func homeDidSelectProduct(sku: String)
    func homeDidTapNotifications()
    func homeDidTapCart()
}
