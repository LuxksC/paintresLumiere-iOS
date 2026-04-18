import SwiftUI

// MARK: - Badge (Ready · Draft · Processing · Error)

enum PLBadgeStatus {
    case ready, draft, processing, error

    var label: String {
        switch self {
        case .ready:      "Ready"
        case .draft:      "Draft"
        case .processing: "Processing"
        case .error:      "Error"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .ready:      PLColor.success.opacity(0.15)
        case .draft:      PLColor.backgroundHighlight
        case .processing: PLColor.goldAntique.opacity(0.2)
        case .error:      PLColor.errorBackground
        }
    }

    var foregroundColor: Color {
        switch self {
        case .ready:      PLColor.success
        case .draft:      PLColor.textMuted
        case .processing: PLColor.goldMid
        case .error:      PLColor.error
        }
    }
}

struct PLBadge: View {
    let status: PLBadgeStatus

    var body: some View {
        Text(status.label)
            .font(PLFont.label())
            .tracking(0.5)
            .foregroundStyle(status.foregroundColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(status.backgroundColor)
            .clipShape(.rect(cornerRadius: PLRadius.badge))
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 8) {
        PLBadge(status: .ready)
        PLBadge(status: .draft)
        PLBadge(status: .processing)
        PLBadge(status: .error)
    }
    .padding()
    .background(PLColor.backgroundPrimary)
}
