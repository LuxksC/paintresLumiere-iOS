import SwiftUI

// MARK: - Button Style (Figma: Primary · Secondary · Ghost · Destructive · Loading)

enum PLButtonType {
    case primary
    case secondary
    case ghost
    case destructive
    case loading
}

struct PLButton: View {

    let title: String
    let type: PLButtonType
    let action: () -> Void

    init(_ title: String, type: PLButtonType = .primary, action: @escaping () -> Void) {
        self.title  = title
        self.type   = type
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            buttonContent
                .frame(maxWidth: .infinity)
                .frame(height: PLSize.buttonHeight)
                .background(backgroundColor)
                .overlay {
                    RoundedRectangle(cornerRadius: PLRadius.button)
                        .stroke(borderColor, lineWidth: borderWidth)
                }
                .clipShape(.rect(cornerRadius: PLRadius.button))
        }
        .disabled(type == .loading)
    }

    // MARK: - Sub-views

    private var buttonContent: some View {
        HStack(spacing: 8) {
            if type == .loading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(PLColor.backgroundPrimary)
                    .scaleEffect(0.85)
            }
            Text(type == .loading ? "Loading..." : title)
                .font(PLFont.button())
                .foregroundStyle(foregroundColor)
        }
    }

    // MARK: - Style helpers

    private var backgroundColor: Color {
        switch type {
        case .primary, .loading: PLColor.goldMid
        case .secondary, .ghost: .clear
        case .destructive:       PLColor.errorBackground
        }
    }

    private var foregroundColor: Color {
        switch type {
        case .primary, .loading: PLColor.backgroundPrimary
        case .secondary:         PLColor.goldBright
        case .ghost:             PLColor.textPrimary
        case .destructive:       PLColor.textPrimary
        }
    }

    private var borderColor: Color {
        switch type {
        case .secondary: PLColor.goldMid
        case .ghost:     PLColor.borderSubtle
        default:         .clear
        }
    }

    private var borderWidth: CGFloat {
        switch type {
        case .secondary, .ghost: 1.5
        default:                 0
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        PLButton("Login") {}
        PLButton("Create Account", type: .secondary) {}
        PLButton("Continue with Google", type: .ghost) {}
        PLButton("Delete Account", type: .destructive) {}
        PLButton("", type: .loading) {}
    }
    .padding()
    .background(PLColor.backgroundPrimary)
}
