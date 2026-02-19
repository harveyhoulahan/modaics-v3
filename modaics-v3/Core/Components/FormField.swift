import SwiftUI

// MARK: - FormField
/// Reusable form text field with consistent styling
public struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let isRequired: Bool
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    let autocapitalization: TextInputAutocapitalization
    let validation: ((String) -> String?)?
    
    @State private var isEditing: Bool = false
    @State private var errorMessage: String?
    @FocusState private var isFocused: Bool
    
    public init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        isRequired: Bool = false,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences,
        validation: ((String) -> String?)? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.validation = validation
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            HStack(spacing: 4) {
                Text(title.uppercased())
                    .font(.forestCaptionSmall)
                    .foregroundColor(.luxeGold)
                    .tracking(1.5)
                
                if isRequired {
                    Text("*")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.red)
                }
            }
            
            // Input field
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(isFocused ? .luxeGold : .sageMuted)
                        .frame(width: 20)
                }
                
                if isSecure {
                    SecureField("", text: $text)
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageWhite)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholder)
                                .font(.forestBodyMedium)
                                .foregroundColor(.sageMuted)
                        }
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                        .onChange(of: text) { _ in
                            validate()
                        }
                } else {
                    TextField("", text: $text)
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageWhite)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholder)
                                .font(.forestBodyMedium)
                                .foregroundColor(.sageMuted)
                        }
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                        .onChange(of: text) { _ in
                            validate()
                        }
                }
                
                // Clear button
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        errorMessage = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.sageMuted)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.modaicsSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        errorMessage != nil ? Color.red :
                        isFocused ? Color.luxeGold :
                        Color.luxeGold.opacity(0.2),
                        lineWidth: errorMessage != nil ? 1.5 : 1
                    )
            )
            
            // Error message
            if let error = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                    Text(error)
                        .font(.forestCaptionSmall)
                }
                .foregroundColor(.red)
            }
        }
    }
    
    private func validate() {
        guard let validation = validation else { return }
        errorMessage = validation(text)
    }
}

// MARK: - TextArea Field
public struct TextAreaField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let isRequired: Bool
    
    @FocusState private var isFocused: Bool
    
    public init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        minHeight: CGFloat = 100,
        maxHeight: CGFloat = 200,
        isRequired: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.isRequired = isRequired
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            HStack(spacing: 4) {
                Text(title.uppercased())
                    .font(.forestCaptionSmall)
                    .foregroundColor(.luxeGold)
                    .tracking(1.5)
                
                if isRequired {
                    Text("*")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.red)
                }
            }
            
            // Text area
            TextEditor(text: $text)
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(minHeight: minHeight, maxHeight: maxHeight)
                .focused($isFocused)
                .overlay(
                    Group {
                        if text.isEmpty {
                            VStack {
                                HStack {
                                    Text(placeholder)
                                        .font(.forestBodyMedium)
                                        .foregroundColor(.sageMuted)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }
                )
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.modaicsSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isFocused ? Color.luxeGold : Color.luxeGold.opacity(0.2),
                            lineWidth: 1
                        )
                )
        }
    }
}

// MARK: - Picker Field
public struct PickerField<T: Hashable & CustomStringConvertible>: View {
    let title: String
    @Binding var selection: T
    let options: [T]
    let icon: String?
    
    public init(
        title: String,
        selection: Binding<T>,
        options: [T],
        icon: String? = nil
    ) {
        self.title = title
        self._selection = selection
        self.options = options
        self.icon = icon
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.forestCaptionSmall)
                .foregroundColor(.luxeGold)
                .tracking(1.5)
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                    }) {
                        Text(option.description)
                        if selection == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(.luxeGold)
                            .frame(width: 20)
                    }
                    
                    Text(selection.description)
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageWhite)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.sageMuted)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.modaicsSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.luxeGold.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Helper Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview
struct FormField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            FormField(
                title: "Email",
                placeholder: "Enter your email",
                text: .constant(""),
                icon: "envelope",
                isRequired: true,
                keyboardType: .emailAddress,
                autocapitalization: .never,
                validation: { text in
                    if text.isEmpty { return "Email is required" }
                    if !text.contains("@") { return "Invalid email format" }
                    return nil
                }
            )
            
            FormField(
                title: "Password",
                placeholder: "Enter password",
                text: .constant(""),
                icon: "lock",
                isRequired: true,
                isSecure: true
            )
            
            TextAreaField(
                title: "Description",
                placeholder: "Enter description...",
                text: .constant(""),
                isRequired: true
            )
        }
        .padding()
        .background(Color.modaicsBackground)
        .preferredColorScheme(.dark)
    }
}
