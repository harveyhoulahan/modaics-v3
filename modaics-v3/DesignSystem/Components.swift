import SwiftUI

// MARK: - Editorial Button Styles

/// Primary button: Solid near-black with warm off-white text. No gradient.
public struct EditorialPrimaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyText(14, weight: .medium))
            .foregroundColor(.warmOffWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.nearBlack.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

/// Secondary button: Ghost button — transparent with thin near-black border
public struct EditorialSecondaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyText(14, weight: .medium))
            .foregroundColor(.nearBlack)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.nearBlack.opacity(0.3), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

/// Accent button: Deep forest green for special moments (e.g. "The Studio" CTA)
public struct EditorialAccentButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyText(14, weight: .medium))
            .foregroundColor(.warmOffWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.forestDeep.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

// MARK: - Card Modifier - Simplified

public struct EditorialCardModifier: ViewModifier {
    var hasBorder: Bool = false

    public func body(content: Content) -> some View {
        content
            .background(Color.ivory)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .overlay(
                hasBorder ?
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.warmDivider, lineWidth: 0.5)
                    : nil
            )
    }
}

// MARK: - Legacy Card Styles (bridged to new system)

public struct ModaicsCardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content.modifier(EditorialCardModifier(hasBorder: false))
    }
}

public struct ModaicsElevatedCardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content.modifier(EditorialCardModifier(hasBorder: true))
    }
}

// MARK: - Legacy Button Styles (bridged to new system)

public struct ModaicsPrimaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(EditorialPrimaryButtonStyle())
    }
}

public struct ModaicsSecondaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(EditorialSecondaryButtonStyle())
    }
}

public struct ModaicsGhostButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(EditorialSecondaryButtonStyle())
    }
}

public struct ModaicsIconButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let iconColor: Color
    let size: CGFloat
    
    public init(
        backgroundColor: Color = Color.ivory,
        iconColor: Color = Color.nearBlack,
        size: CGFloat = 44
    ) {
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
        self.size = size
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.4, weight: .regular))
            .foregroundColor(iconColor)
            .frame(width: size, height: size)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.warmDivider, lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

// MARK: - Tag/Badge Styles (simplified)

public struct ModaicsTagStyle: ViewModifier {
    let color: Color
    
    public init(color: Color = .agedBrass) {
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        content
            .font(.captionSmall)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(color.opacity(0.5), lineWidth: 0.5)
            )
    }
}

public struct ModaicsBadgeStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.system(size: 9, weight: .medium))
            .foregroundColor(.warmOffWhite)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(RoundedRectangle(cornerRadius: 2).fill(Color.nearBlack))
    }
}

// MARK: - Input Field Styles

public struct ModaicsInputStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.bodyMedium)
            .foregroundColor(.nearBlack)
            .padding(14)
            .background(Color.ivory)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.warmDivider, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

// MARK: - View Extensions

public extension View {
    func modaicsCard() -> some View {
        modifier(EditorialCardModifier(hasBorder: false))
    }
    
    func modaicsElevatedCard() -> some View {
        modifier(EditorialCardModifier(hasBorder: true))
    }
    
    func editorialCard(hasBorder: Bool = false) -> some View {
        modifier(EditorialCardModifier(hasBorder: hasBorder))
    }
    
    func modaicsTag(color: Color = .agedBrass) -> some View {
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
        self.buttonStyle(EditorialPrimaryButtonStyle())
    }
    
    func modaicsSecondary() -> some View {
        self.buttonStyle(EditorialSecondaryButtonStyle())
    }
    
    func modaicsGhost() -> some View {
        self.buttonStyle(EditorialSecondaryButtonStyle())
    }
    
    func editorialPrimary() -> some View {
        self.buttonStyle(EditorialPrimaryButtonStyle())
    }
    
    func editorialSecondary() -> some View {
        self.buttonStyle(EditorialSecondaryButtonStyle())
    }
    
    func editorialAccent() -> some View {
        self.buttonStyle(EditorialAccentButtonStyle())
    }
}

// MARK: - Animation Updates

public extension Animation {
    static var editorialSpring: Animation {
        .spring(response: 0.5, dampingFraction: 0.8)
    }
    static var editorialFade: Animation {
        .easeInOut(duration: 0.25)
    }

    // Legacy bridges
    static var forestSpring: Animation { .editorialSpring }
    static var forestElegant: Animation { .editorialFade }
    static var modaicsSpring: Animation { .editorialSpring }
    static var modaicsSmoothSpring: Animation { .editorialFade }
    static var modaicsElastic: Animation { .editorialSpring }
}

// MARK: - Corner Radius Constants

public enum EditorialRadius {
    static let none: CGFloat = 0
    static let subtle: CGFloat = 2     // Default for cards, buttons, inputs
    static let small: CGFloat = 4      // Max for any UI element
}

// Legacy bridge
public enum ForestRadius {
    static let small: CGFloat = 2
    static let medium: CGFloat = 2
    static let large: CGFloat = 4
}
