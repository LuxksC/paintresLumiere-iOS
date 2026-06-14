import SwiftUI

// MARK: - ToastView
//
// Visual representation of a single toast. Drag-up to dismiss; auto-dismiss
// is owned by `MessagesService`. Designed to read on the app's dark palette.

struct ToastView: View {

    let message: ToastMessage
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        HStack(alignment: .top, spacing: PLSpacing.md) {
            Image(systemName: message.resolvedIcon)
                .font(.system(.title3, weight: .semibold))
                .foregroundStyle(message.type.foregroundColor)
                .frame(width: 24)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(message.title)
                    .font(PLFont.button())
                    .foregroundStyle(PLColor.textPrimary)
                if let subtitle = message.subtitle {
                    Text(subtitle)
                        .font(PLFont.caption())
                        .foregroundStyle(PLColor.textMuted)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, PLSpacing.md)
        .padding(.vertical, PLSpacing.sm + 2)
        .background {
            RoundedRectangle(cornerRadius: PLRadius.card)
                .fill(message.type.backgroundColor)
                .overlay {
                    RoundedRectangle(cornerRadius: PLRadius.card)
                        .stroke(message.type.foregroundColor.opacity(0.4), lineWidth: 1)
                }
        }
        .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
        .offset(y: min(dragOffset, 0))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    if value.translation.height < -40 {
                        onDismiss()
                    } else {
                        withAnimation(.snappy) { dragOffset = 0 }
                    }
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: PLSpacing.sm) {
        ToastView(
            message: ToastMessage(
                icon: "bag.fill",
                title: "Added to cart",
                subtitle: "Luna · Gold",
                type: .success
            ),
            onDismiss: {}
        )
        ToastView(
            message: ToastMessage(
                title: "Coming soon",
                subtitle: "This feature is under construction.",
                type: .warning
            ),
            onDismiss: {}
        )
        ToastView(
            message: ToastMessage(
                title: "Connection lost",
                subtitle: "Check your internet and try again.",
                type: .error
            ),
            onDismiss: {}
        )
    }
    .padding()
    .background(PLColor.backgroundPrimary)
}
