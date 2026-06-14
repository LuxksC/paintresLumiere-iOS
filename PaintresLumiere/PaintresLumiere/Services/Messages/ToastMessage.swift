import Foundation

// MARK: - ToastMessage
//
// Payload shown by `MessagesService`. The `icon` is an SF Symbol name; if
// `nil` is passed, the type's `defaultIcon` is used.

struct ToastMessage: Identifiable, Hashable {
    let id: UUID
    let icon: String?
    let title: String
    let subtitle: String?
    let type: ToastType

    init(
        id: UUID = UUID(),
        icon: String? = nil,
        title: String,
        subtitle: String? = nil,
        type: ToastType
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.type = type
    }

    var resolvedIcon: String { icon ?? type.defaultIcon }
}
