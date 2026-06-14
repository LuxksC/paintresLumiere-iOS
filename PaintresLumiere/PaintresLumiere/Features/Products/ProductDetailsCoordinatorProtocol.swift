import Foundation

// MARK: - ProductDetailsCoordinatorProtocol

@MainActor
protocol ProductDetailsCoordinatorProtocol: AnyObject {
    func productDetailsDidRequestDismiss()
}
