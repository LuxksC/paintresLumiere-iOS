import SwiftUI
import UIKit

// MARK: - MessagesService
//
// Toast presenter. Installs a SwiftUI host as a subview of the active
// scene's main window, anchored to its safe area top and sized to its own
// content. Because the host view is only as tall as the visible toast,
// touches in empty areas of the screen never reach it — they fall straight
// through to whatever the app is showing underneath.
//
// Sits above the tab bar and any pushed view controller (subviews added
// directly to the window draw on top of the rootViewController's view).

@Observable
@MainActor
final class MessagesService: MessagesServiceProtocol {

    static let displayDuration: Duration = .seconds(3)

    private(set) var currentMessage: ToastMessage?

    private var queue: [ToastMessage] = []
    private var dismissTask: Task<Void, Never>?
    private var hostingController: UIHostingController<ToastHostView>?

    nonisolated init() {}

    // MARK: - Attachment

    func attach(to scene: UIWindowScene) {
        guard hostingController == nil else { return }
        guard let appWindow = scene.windows.first else { return }

        let host = UIHostingController(rootView: ToastHostView(service: self))
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.sizingOptions = .intrinsicContentSize

        appWindow.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: appWindow.safeAreaLayoutGuide.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: appWindow.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: appWindow.trailingAnchor),
        ])

        hostingController = host
    }

    // MARK: - Custom toasts

    func show(_ message: ToastMessage) {
        queue.append(message)
        showNextIfIdle()
    }

    func dismissCurrent() {
        dismissTask?.cancel()
        dismissTask = nil
        currentMessage = nil
        // Advance after the dismiss animation has time to play.
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            showNextIfIdle()
        }
    }

    // MARK: - Default toasts

    func showNetworkError() {
        show(ToastMessage(
            title: "Connection lost",
            subtitle: "Check your internet and try again.",
            type: .error
        ))
    }

    func showGenericError() {
        show(ToastMessage(
            title: "Something went wrong",
            subtitle: "Please try again in a moment.",
            type: .error
        ))
    }

    func showAddedToCart(productName: String) {
        show(ToastMessage(
            icon: "bag.fill",
            title: "Added to cart",
            subtitle: productName,
            type: .success
        ))
    }

    func showComingSoon() {
        show(ToastMessage(
            title: "Coming soon",
            subtitle: "This feature is under construction.",
            type: .warning
        ))
    }

    // MARK: - Queue management

    private func showNextIfIdle() {
        guard currentMessage == nil, !queue.isEmpty else { return }
        let next = queue.removeFirst()
        currentMessage = next
        dismissTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: Self.displayDuration)
            guard !Task.isCancelled, let self else { return }
            guard self.currentMessage?.id == next.id else { return }
            self.currentMessage = nil
            try? await Task.sleep(for: .milliseconds(250))
            self.showNextIfIdle()
        }
    }
}
