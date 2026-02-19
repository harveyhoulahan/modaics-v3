import SwiftUI

// MARK: - Card Styles (Dark Green Porsche)

public struct ModaicsCardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(Color.modaicsSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
            )
    }
}

public struct ModaicsElevatedCardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(Color.modaicsSurface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
            )
    }
}

// MARK: - Button Styles (Dark Green Porsche)

public struct ModaicsPrimaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.forestBodyMedium)
            .foregroundColor(Color.modaicsBackground)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.luxeGold)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

public struct ModaicsSecondaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.forestBodyMedium)
            .foregroundColor(Color.luxeGold)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.modaicsSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.luxeGold.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

public struct ModaicsGhostButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.forestBodyMedium)
            .foregroundColor(Color.sageWhite)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

public struct ModaicsIconButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let iconColor: Color
    let size: CGFloat
    
    public init(
        backgroundColor: Color = Color.modaicsSurface,
        iconColor: Color = Color.sageWhite,
        size: CGFloat = 44
    ) {
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
        self.size = size
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundColor(iconColor)
            .frame(width: size, height: size)
            .background(backgroundColor)
            .cornerRadius(size / 4)
            .overlay(
                RoundedRectangle(cornerRadius: size / 4)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

// MARK: - Tag/Badge Styles

public struct ModaicsTagStyle: ViewModifier {
    let color: Color
    
    public init(color: Color = .luxeGold) {
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        content
            .font(.forestCaptionSmall)
            .textCase(.uppercase)
            .tracking(1)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}

public struct ModaicsBadgeStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundColor(Color.modaicsBackground)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color.luxeGold))
    }
}

// MARK: - Input Field Styles

public struct ModaicsInputStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.forestBodyMedium)
            .foregroundColor(Color.sageWhite)
            .padding(14)
            .background(Color.modaicsSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
            )
            .cornerRadius(8)
    }
}

// MARK: - View Extensions

public extension View {
    func modaicsCard() -> some View {
        modifier(ModaicsCardStyle())
    }
    
    func modaicsElevatedCard() -> some View {
        modifier(ModaicsElevatedCardStyle())
    }
    
    func modaicsTag(color: Color = .luxeGold) -> some View {
        modifier(ModaicsTagStyle(color: color))
    }
    
    func modaicsBadge() -> some View {
        modifier(ModaicsBadgeStyle())
    }
    
    func modaicsInput() -> some View {
        modifier(ModaicsInputStyle())
    }
}

public extension Button {
    func modaicsPrimary() -> some View {
        self.buttonStyle(ModaicsPrimaryButtonStyle())
    }
    
    func modaicsSecondary() -> some View {
        self.buttonStyle(ModaicsSecondaryButtonStyle())
    }
    
    func modaicsGhost() -> some View {
        self.buttonStyle(ModaicsGhostButtonStyle())
    }
}

// MARK: - Placeholder Extension
public extension View {
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