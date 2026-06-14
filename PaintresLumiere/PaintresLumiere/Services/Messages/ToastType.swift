import SwiftUI

// MARK: - ToastType
//
// Semantic category of a toast. Drives the toast's accent color, default
// icon, and any future haptic feedback. Three buckets are enough for now —
// `info` can be added later if needed.

enum ToastType: Hashable {
    case success
    case warning
    case error

    var foregroundColor: Color {
        switch self {
        case .success: PLColor.success
        case .warning: PLColor.warning
        case .error:   PLColor.error
        }
    }

    var backgroundColor: Color {
        switch self {
        case .success: PLColor.successBackground
        case .warning: PLColor.warningBackground
        case .error:   PLColor.errorBackground
        }
    }

    var defaultIcon: String {
        switch self {
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error:   "xmark.octagon.fill"
        }
    }
}
