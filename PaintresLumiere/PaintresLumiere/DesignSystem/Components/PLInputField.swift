import SwiftUI

// MARK: - Input Field (Figma: Default · Focused · Filled · Error)

struct PLInputField: View {

    let label: String
    let placeholder: String
    let isSecure: Bool
    let errorMessage: String?

    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var isVisible = false

    init(
        label: String,
        placeholder: String = "",
        text: Binding<String>,
        isSecure: Bool = false,
        errorMessage: String? = nil
    ) {
        self.label        = label
        self.placeholder  = placeholder
        self._text        = text
        self.isSecure     = isSecure
        self.errorMessage = errorMessage
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel
            inputContainer
            if let error = errorMessage, !error.trimmingCharacters(in: .whitespaces).isEmpty {
                errorLabel(error)
            }
        }
    }

    // MARK: - Sub-views

    private var fieldLabel: some View {
        Text(label.uppercased())
            .font(PLFont.label())
            .foregroundStyle(labelColor)
            .tracking(1)
    }

    private var inputContainer: some View {
        HStack {
            textEntry
            if isSecure { revealButton }
        }
        .padding(.horizontal, 14)
        .frame(height: PLSize.inputHeight)
        .background(PLColor.backgroundElevated)
        .overlay {
            RoundedRectangle(cornerRadius: PLRadius.input)
                .stroke(borderColor, lineWidth: borderWidth)
        }
        .clipShape(.rect(cornerRadius: PLRadius.input))
    }

    private var textEntry: some View {
        Group {
            if isSecure && !isVisible {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(PLFont.body())
        .foregroundStyle(text.isEmpty ? PLColor.textDisabled : PLColor.textPrimary)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .focused($isFocused)
    }

    private var revealButton: some View {
        Button("Toggle visibility", systemImage: isVisible ? "eye.slash" : "eye") {
            isVisible.toggle()
        }
        .labelStyle(.iconOnly)
        .foregroundStyle(PLColor.textMuted)
        .font(.system(size: 14))
    }

    private func errorLabel(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.triangle")
            .font(PLFont.caption())
            .foregroundStyle(PLColor.error)
    }

    // MARK: - State helpers

    private var fieldState: FieldState {
        if errorMessage != nil { return .error }
        if isFocused          { return .focused }
        if !text.isEmpty      { return .filled }
        return .default_
    }

    private var labelColor: Color {
        switch fieldState {
        case .error:    PLColor.error
        case .focused:  PLColor.goldBright
        default:        PLColor.textMuted
        }
    }

    private var borderColor: Color {
        switch fieldState {
        case .error:    PLColor.error
        case .focused:  PLColor.goldMid
        case .filled:   PLColor.goldDeep
        case .default_: PLColor.borderSubtle
        }
    }

    private var borderWidth: CGFloat {
        switch fieldState {
        case .error, .focused: 1.5
        case .filled, .default_: 1
        }
    }

    private enum FieldState { case default_, focused, filled, error }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        PLInputField(label: "Email Address", placeholder: "your@email.com", text: .constant(""))
        PLInputField(label: "Email Address", placeholder: "your@email.com", text: .constant("john@example.com"))
        PLInputField(label: "Password", placeholder: "Min. 8 characters", text: .constant(""), isSecure: true)
        PLInputField(label: "Email Address", placeholder: "your@email.com", text: .constant("invalid"),
                     errorMessage: "Please enter a valid email address.")
    }
    .padding()
    .background(PLColor.backgroundPrimary)
}
