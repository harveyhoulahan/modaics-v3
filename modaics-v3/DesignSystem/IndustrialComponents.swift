import SwiftUI

// MARK: - Industrial Components
// Reusable UI components with industrial design system

// MARK: - Buttons

enum IndustrialButtonStyle {
    case primary
    case secondary
    case ghost
    case destructive
    case chrome
}

struct IndustrialButton: View {
    let title: String
    let icon: String?
    let style: IndustrialButtonStyle
    let size: IndustrialButtonSize
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        style: IndustrialButtonStyle = .primary,
        size: IndustrialButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: IndustrialLayout.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(size.iconFont)
                }
                
                Text(title)
                    .font(size.font)
                    .tracking(0.5)
            }
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .frame(minWidth: IndustrialLayout.Width.buttonMin)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(IndustrialLayout.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: IndustrialLayout.CornerRadius.sm)
                    .stroke(borderColor, lineWidth: IndustrialLayout.BorderWidth.thin)
            )
            .opacity(isEnabled ? 1.0 : IndustrialLayout.Opacity.disabled)
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return .modaicsRed
        case .secondary: return .modaicsSurface
        case .ghost: return .clear
        case .destructive: return .modaicsRedDark
        case .chrome: return .modaicsChrome2.opacity(0.2)
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary: return .modaicsTextMain
        case .ghost: return .modaicsRed
        case .chrome: return .modaicsChrome1
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary: return .modaicsRedLight
        case .secondary: return .modaicsBorderStrong
        case .ghost: return .clear
        case .destructive: return .modaicsRed
        case .chrome: return .modaicsChrome3
        }
    }
}

enum IndustrialButtonSize {
    case small, medium, large
    
    var height: CGFloat {
        switch self {
        case .small: return IndustrialLayout.Height.buttonSmall
        case .medium: return IndustrialLayout.Height.button
        case .large: return IndustrialLayout.Height.buttonLarge
        }
    }
    
    var font: Font {
        switch self {
        case .small: return IndustrialTypography.buttonSmall
        case .medium: return IndustrialTypography.buttonMedium
        case .large: return IndustrialTypography.buttonLarge
        }
    }
    
    var iconFont: Font {
        switch self {
        case .small: return .system(size: 12, design: .monospaced)
        case .medium: return .system(size: 14, design: .monospaced)
        case .large: return .system(size: 16, design: .monospaced)
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return IndustrialLayout.Padding.button - 4
        case .medium: return IndustrialLayout.Padding.button
        case .large: return IndustrialLayout.Padding.buttonLarge
        }
    }
}

// MARK: - Card Component

struct IndustrialCard<Content: View>: View {
    let content: Content
    let backgroundColor: Color
    let borderColor: Color
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadow: IndustrialLayout.ShadowStyle
    
    init(
        backgroundColor: Color = .modaicsSurface,
        borderColor: Color = .modaicsBorder,
        padding: CGFloat = IndustrialLayout.Padding.card,
        cornerRadius: CGFloat = IndustrialLayout.CornerRadius.md,
        shadow: IndustrialLayout.ShadowStyle = IndustrialLayout.Shadow.none,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadow = shadow
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: IndustrialLayout.BorderWidth.thin)
            )
            .industrialShadow(shadow)
    }
}

// MARK: - Text Field Component

struct IndustrialTextField: View {
    let placeholder: String
    let icon: String?
    @Binding var text: String
    let isSecure: Bool
    let isEnabled: Bool
    let keyboardType: UIKeyboardType
    
    init(
        _ placeholder: String,
        icon: String? = nil,
        text: Binding<String>,
        isSecure: Bool = false,
        isEnabled: Bool = true,
        keyboardType: UIKeyboardType = .default
    ) {
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.isSecure = isSecure
        self.isEnabled = isEnabled
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        HStack(spacing: IndustrialLayout.Spacing.md) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.modaicsTextMuted)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(IndustrialTypography.input)
                    .foregroundColor(.modaicsTextMain)
                    .disabled(!isEnabled)
            } else {
                TextField(placeholder, text: $text)
                    .font(IndustrialTypography.input)
                    .foregroundColor(.modaicsTextMain)
                    .disabled(!isEnabled)
                    .keyboardType(keyboardType)
            }
        }
        .padding(.horizontal, IndustrialLayout.Padding.input)
        .frame(height: IndustrialLayout.Height.input)
        .background(Color.modaicsDarkBlueSecondary)
        .cornerRadius(IndustrialLayout.CornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: IndustrialLayout.CornerRadius.sm)
                .stroke(Color.modaicsBorderChrome, lineWidth: IndustrialLayout.BorderWidth.thin)
        )
        .opacity(isEnabled ? 1.0 : IndustrialLayout.Opacity.disabled)
    }
}

// MARK: - Tag/Badge Component

struct IndustrialTag: View {
    let text: String
    let style: IndustrialTagStyle
    let icon: String?
    let isRemovable: Bool
    let onRemove: (() -> Void)?
    
    init(
        _ text: String,
        style: IndustrialTagStyle = .default,
        icon: String? = nil,
        isRemovable: Bool = false,
        onRemove: (() -> Void)? = nil
    ) {
        self.text = text
        self.style = style
        self.icon = icon
        self.isRemovable = isRemovable
        self.onRemove = onRemove
    }
    
    var body: some View {
        HStack(spacing: IndustrialLayout.Spacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10, design: .monospaced))
            }
            
            Text(text)
                .font(IndustrialTypography.labelSmall)
            
            if isRemovable {
                Button(action: { onRemove?() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, design: .monospaced))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, IndustrialLayout.Spacing.sm)
        .padding(.vertical, IndustrialLayout.Spacing.xs)
        .background(style.backgroundColor)
        .foregroundColor(style.foregroundColor)
        .cornerRadius(IndustrialLayout.CornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: IndustrialLayout.CornerRadius.sm)
                .stroke(style.borderColor, lineWidth: IndustrialLayout.BorderWidth.hairline)
        )
    }
}

enum IndustrialTagStyle {
    case `default`
    case accent
    case success
    case warning
    case error
    case chrome
    
    var backgroundColor: Color {
        switch self {
        case .default: return .modaicsSurface
        case .accent: return .modaicsRed.opacity(0.15)
        case .success: return .modaicsSuccess.opacity(0.15)
        case .warning: return .modaicsWarning.opacity(0.15)
        case .error: return .modaicsError.opacity(0.15)
        case .chrome: return .modaicsChrome4.opacity(0.3)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .default: return .modaicsTextSecondary
        case .accent: return .modaicsRedLight
        case .success: return .modaicsSuccess
        case .warning: return .modaicsWarning
        case .error: return .modaicsError
        case .chrome: return .modaicsChrome2
        }
    }
    
    var borderColor: Color {
        switch self {
        case .default: return .modaicsBorder
        case .accent: return .modaicsRed.opacity(0.3)
        case .success: return .modaicsSuccess.opacity(0.3)
        case .warning: return .modaicsWarning.opacity(0.3)
        case .error: return .modaicsError.opacity(0.3)
        case .chrome: return .modaicsChrome3
        }
    }
}

// MARK: - Section Header Component

struct IndustrialSectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        _ title: String,
        subtitle: String? = nil,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.actionTitle = actionTitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: IndustrialLayout.Spacing.xs) {
            HStack {
                Text(title)
                    .font(IndustrialTypography.heading3)
                    .foregroundColor(.modaicsTextMain)
                
                Spacer()
                
                if let action = action, let actionTitle = actionTitle {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(IndustrialTypography.labelMedium)
                            .foregroundColor(.modaicsRed)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(IndustrialTypography.bodySmall)
                    .foregroundColor(.modaicsTextMuted)
            }
        }
        .padding(.vertical, IndustrialLayout.Spacing.sm)
    }
}

// MARK: - List Row Component

struct IndustrialListRow<Leading: View, Trailing: View>: View {
    let title: String
    let subtitle: String?
    let leading: Leading?
    let trailing: Trailing?
    let showChevron: Bool
    let onTap: (() -> Void)?
    
    init(
        title: String,
        subtitle: String? = nil,
        showChevron: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder leading: () -> Leading? = { nil },
        @ViewBuilder trailing: () -> Trailing? = { nil }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showChevron = showChevron
        self.onTap = onTap
        self.leading = leading()
        self.trailing = trailing()
    }
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: IndustrialLayout.Spacing.md) {
                if let leading = leading {
                    leading
                }
                
                VStack(alignment: .leading, spacing: IndustrialLayout.Spacing.xs) {
                    Text(title)
                        .font(IndustrialTypography.bodyMedium)
                        .foregroundColor(.modaicsTextMain)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(IndustrialTypography.caption)
                            .foregroundColor(.modaicsTextMuted)
                    }
                }
                
                Spacer()
                
                if let trailing = trailing {
                    trailing
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.modaicsTextMuted)
                }
            }
            .padding(.vertical, IndustrialLayout.Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onTap == nil)
    }
}

// MARK: - Icon Button Component

struct IndustrialIconButton: View {
    let icon: String
    let style: IndustrialButtonStyle
    let size: IndustrialIconButtonSize
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(size.font)
                .foregroundColor(foregroundColor)
                .frame(width: size.dimension, height: size.dimension)
                .background(backgroundColor)
                .cornerRadius(IndustrialLayout.CornerRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: IndustrialLayout.CornerRadius.sm)
                        .stroke(borderColor, lineWidth: IndustrialLayout.BorderWidth.thin)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return .modaicsRed
        case .secondary: return .modaicsSurface
        case .ghost: return .clear
        case .destructive: return .modaicsRedDark
        case .chrome: return .modaicsChrome4.opacity(0.3)
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary: return .modaicsTextMain
        case .ghost: return .modaicsRed
        case .chrome: return .modaicsChrome2
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary: return .modaicsRedLight
        case .secondary: return .modaicsBorderStrong
        case .ghost: return .clear
        case .destructive: return .modaicsRed
        case .chrome: return .modaicsChrome3
        }
    }
}

enum IndustrialIconButtonSize {
    case small, medium, large
    
    var dimension: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 44
        case .large: return 56
        }
    }
    
    var font: Font {
        switch self {
        case .small: return .system(size: 14, design: .monospaced)
        case .medium: return .system(size: 18, design: .monospaced)
        case .large: return .system(size: 24, design: .monospaced)
        }
    }
}

// MARK: - Toggle Component

struct IndustrialToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(IndustrialTypography.bodyMedium)
                .foregroundColor(.modaicsTextMain)
        }
        .toggleStyle(IndustrialToggleStyle())
    }
}

struct IndustrialToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: IndustrialLayout.CornerRadius.full)
                    .fill(configuration.isOn ? Color.modaicsRed : Color.modaicsBorder)
                    .frame(width: 48, height: 28)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 22, height: 22)
                    .offset(x: configuration.isOn ? 9 : -9)
                    .animation(IndustrialLayout.Animation.fast, value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

// MARK: - Divider Component

struct IndustrialDivider: View {
    var color: Color = .modaicsBorder
    var lineWidth: CGFloat = IndustrialLayout.BorderWidth.thin
    var padding: CGFloat = IndustrialLayout.Spacing.lg
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: lineWidth)
            .padding(.vertical, padding)
    }
}

// MARK: - Empty State Component

struct IndustrialEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String?
    let buttonAction: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        buttonAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        VStack(spacing: IndustrialLayout.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48, design: .monospaced))
                .foregroundColor(.modaicsChrome3)
            
            Text(title)
                .font(IndustrialTypography.heading3)
                .foregroundColor(.modaicsTextMain)
            
            Text(message)
                .font(IndustrialTypography.bodyMedium)
                .foregroundColor(.modaicsTextMuted)
                .multilineTextAlignment(.center)
            
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                IndustrialButton(buttonTitle, style: .primary, action: buttonAction)
                    .padding(.top, IndustrialLayout.Spacing.md)
            }
        }
        .padding(IndustrialLayout.Padding.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading State Component

struct IndustrialLoadingState: View {
    let message: String
    
    var body: some View {
        VStack(spacing: IndustrialLayout.Spacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .modaicsRed))
                .scaleEffect(1.5)
            
            Text(message)
                .font(IndustrialTypography.bodyMedium)
                .foregroundColor(.modaicsTextMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
