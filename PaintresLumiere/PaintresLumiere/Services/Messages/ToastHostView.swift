import SwiftUI

// MARK: - ToastHostView
//
// Tight container for the active toast. Sized intrinsically — height is 0
// when no toast is visible, and grows to the toast's natural size when one
// is shown. `MessagesService.attach(to:)` adds the wrapping
// `UIHostingController.view` as a subview of the main app window, anchored
// to the top safe area, so empty areas of the screen never absorb touches.

struct ToastHostView: View {

    @Bindable var service: MessagesService

    var body: some View {
        VStack(spacing: 0) {
            if let message = service.currentMessage {
                ToastView(message: message) {
                    service.dismissCurrent()
                }
                .id(message.id)
                .padding(.horizontal, PLSpacing.md)
                .padding(.top, PLSpacing.xs)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.snappy(duration: 0.25), value: service.currentMessage?.id)
    }
}
