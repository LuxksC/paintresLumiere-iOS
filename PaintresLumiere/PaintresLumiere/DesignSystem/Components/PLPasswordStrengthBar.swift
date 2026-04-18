import SwiftUI

// MARK: - Password Strength Bar

enum PasswordStrength {
    case none, weak, moderate, strong

    var label: String {
        switch self {
        case .none:     ""
        case .weak:     "Weak"
        case .moderate: "Moderate strength"
        case .strong:   "Strong"
        }
    }

    var color: Color {
        switch self {
        case .none:     PLColor.backgroundHighlight
        case .weak:     PLColor.error
        case .moderate: PLColor.goldMid
        case .strong:   PLColor.success
        }
    }

    var fraction: CGFloat {
        switch self {
        case .none:     0
        case .weak:     0.33
        case .moderate: 0.55
        case .strong:   1.0
        }
    }

    static func evaluate(_ password: String) -> PasswordStrength {
        guard password.count >= 8 else { return password.isEmpty ? .none : .weak }
        let hasUpper  = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasDigit  = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSymbol = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        let score = [hasUpper, hasDigit, hasSymbol].filter { $0 }.count
        if score >= 2 { return .strong }
        if score == 1 { return .moderate }
        return .weak
    }
}

struct PLPasswordStrengthBar: View {
    let password: String

    private var strength: PasswordStrength { PasswordStrength.evaluate(password) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            strengthBar
            if !strength.label.isEmpty {
                Text(strength.label)
                    .font(PLFont.caption())
                    .foregroundStyle(strength.color)
            }
        }
    }

    private var strengthBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(PLColor.backgroundHighlight).frame(height: 4)
                Capsule()
                    .fill(strength.color)
                    .frame(width: geo.size.width * strength.fraction, height: 4)
                    .animation(.easeInOut(duration: 0.3), value: strength.fraction)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        PLPasswordStrengthBar(password: "")
        PLPasswordStrengthBar(password: "abc")
        PLPasswordStrengthBar(password: "abcde123")
        PLPasswordStrengthBar(password: "Abcde123!")
    }
    .padding()
    .background(PLColor.backgroundPrimary)
}
