import Foundation
import UIKit

// MARK: - MessagesServiceProtocol
//
// Centralized entry point for toast messages. Inject this into ViewModels
// so they don't reach into UIKit directly. Default-toast convenience methods
// keep call sites short and consistent.

@MainActor
protocol MessagesServiceProtocol: AnyObject {
    /// Enqueues a fully custom toast. Multiple shows in quick succession are
    /// queued and shown one at a time.
    func show(_ message: ToastMessage)

    /// Dismisses the toast currently on screen, if any, and advances the queue.
    func dismissCurrent()

    /// Attaches the toast overlay to the given window scene. Must be called
    /// once per scene, typically from `SceneDelegate`.
    func attach(to scene: UIWindowScene)

    // MARK: Default toasts

    func showNetworkError()
    func showGenericError()
    func showAddedToCart(productName: String)
    func showComingSoon()
}
