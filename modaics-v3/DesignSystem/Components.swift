import SwiftUI

// MARK: - Card Styles

public struct ModaicsCardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(Color.modaicsPaper)
            .cornerRadius(ModaicsLayout.cornerRadius)
            .modaicsShadowMedium()
    }
}

public struct ModaicsElevatedCardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(Color.modaicsPaper)
            .cornerRadius(ModaicsLayout.cornerRadiusLarge)
            .modaicsShadowLarge()
    }
}

public struct ModaicsSubtleCardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(Color.modaicsCream)
            .cornerRadius(ModaicsLayout.cornerRadius)
            .modaicsShadowSmall()
    }
}

// MARK: - Button Styles

public struct ModaicsPrimaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.modaicsButton)
            .foregroundColor(.white)
            .padding(.horizontal, ModaicsLayout.xlarge)
            .padding(.vertical, ModaicsLayout.medium)
            .background(Color.modaicsTerracotta)
            .cornerRadius(ModaicsLayout.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.modaicsQuick, value: configuration.isPressed)
    }
}

public struct ModaicsSecondaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.modaicsButton)
            .foregroundColor(Color.modaicsTerracotta)
            .padding(.horizontal, ModaicsLayout.xlarge)
            .padding(.vertical, ModaicsLayout.medium)
            .background(Color.modaicsTerracotta.opacity(0.1))
            .cornerRadius(ModaicsLayout.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.modaicsQuick, value: configuration.isPressed)
    }
}

public struct ModaicsGhostButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.modaicsButton)
            .foregroundColor(Color.modaicsCharcoal)
            .padding(.horizontal, ModaicsLayout.xlarge)
            .padding(.vertical, ModaicsLayout.medium)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: ModaicsLayout.cornerRadius)
                    .stroke(Color.modaicsCharcoal.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.modaicsQuick, value: configuration.isPressed)
    }
}

public struct ModaicsIconButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let iconColor: Color
    let size: CGFloat
    
    public init(
        backgroundColor: Color = Color.modaicsPaper,
        iconColor: Color = Color.modaicsCharcoal,
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
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.modaicsQuick, value: configuration.isPressed)
    }
}

// MARK: - Input Field Styles

public struct ModaicsInputFieldStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    public func body(content: Content) -> some View {
        content
            .font(.modaicsBodyRegular)
            .padding()
            .background(Color.modaicsPaper)
            .cornerRadius(ModaicsLayout.cornerRadiusMedium)
    }
}

public struct ModaicsTextAreaStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.modaicsBodyRegular)
            .padding()
            .background(Color.modaicsPaper)
            .cornerRadius(ModaicsLayout.cornerRadiusMedium)
            .frame(minHeight: 120)
    }
}

// MARK: - Badge Styles

public struct ModaicsBadgeStyle: ViewModifier {
    let backgroundColor: Color
    let foregroundColor: Color
    
    public init(
        backgroundColor: Color = Color.modaicsOatmeal,
        foregroundColor: Color = Color.modaicsTextPrimary
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    public func body(content: Content) -> some View {
        content
            .font(.modaicsFinePrint)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(4)
    }
}

public struct ModaicsTagStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.modaicsFinePrint)
            .foregroundColor(Color.modaicsTerracotta)
            .tracking(1)
            .textCase(.uppercase)
    }
}

// MARK: - List Styles

public struct ModaicsListRowStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, ModaicsLayout.large)
            .padding(.vertical, ModaicsLayout.medium)
            .background(Color.modaicsPaper)
    }
}

// MARK: - View Extensions

public extension View {
    
    // MARK: - Card Styles
    
    /// Standard card style with paper background and medium shadow
    func modaicsCard() -> some View {
        modifier(ModaicsCardStyle())
    }
    
    /// Elevated card style with larger shadow
    func modaicsElevatedCard() -> some View {
        modifier(ModaicsElevatedCardStyle())
    }
    
    /// Subtle card style with cream background
    func modaicsSubtleCard() -> some View {
        modifier(ModaicsSubtleCardStyle())
    }
    
    // MARK: - Input Styles
    
    /// Standard input field styling
    func modaicsInputField() -> some View {
        modifier(ModaicsInputFieldStyle())
    }
    
    /// Text area styling
    func modaicsTextArea() -> some View {
        modifier(ModaicsTextAreaStyle())
    }
    
    // MARK: - Badge Styles
    
    /// Badge styling with custom colors
    func modaicsBadge(
        backgroundColor: Color = Color.modaicsOatmeal,
        foregroundColor: Color = Color.modaicsTextPrimary
    ) -> some View {
        modifier(ModaicsBadgeStyle(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor
        ))
    }
    
    /// Terracotta accent badge
    func modaicsAccentBadge() -> some View {
        modifier(ModaicsBadgeStyle(
            backgroundColor: Color.modaicsTerracotta.opacity(0.1),
            foregroundColor: Color.modaicsTerracotta
        ))
    }
    
    /// Tag style (uppercase, tracked, terracotta)
    func modaicsTag() -> some View {
        modifier(ModaicsTagStyle())
    }
    
    // MARK: - List Styles
    
    /// Standard list row styling
    func modaicsListRow() -> some View {
        modifier(ModaicsListRowStyle())
    }
    
    // MARK: - Press Effect
    
    /// Adds a subtle press effect
    func modaicsPressable() -> some View {
        self.buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Button Style Extensions

public extension Button {
    
    /// Primary terracotta button
    func modaicsPrimary() -> some View {
        self.buttonStyle(ModaicsPrimaryButtonStyle())
    }
    
    /// Secondary outlined button
    func modaicsSecondary() -> some View {
        self.buttonStyle(ModaicsSecondaryButtonStyle())
    }
    
    /// Ghost bordered button
    func modaicsGhost() -> some View {
        self.buttonStyle(ModaicsGhostButtonStyle())
    }
}

// MARK: - Reusable Components

public struct ModaicsDivider: View {
    public var body: some View {
        Rectangle()
            .fill(Color.modaicsCharcoal.opacity(0.2))
            .frame(height: 1)
    }
}

public struct ModaicsTerracottaAccentLine: View {
    let alignment: Alignment
    let width: CGFloat
    
    public init(alignment: Alignment = .leading, width: CGFloat = 4) {
        self.alignment = alignment
        self.width = width
    }
    
    public var body: some View {
        Rectangle()
            .fill(Color.modaicsTerracotta)
            .frame(width: width)
    }
}

public struct ModaicsLoadingIndicator: View {
    @State private var isAnimating = false
    
    public init() {}
    
    public var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.modaicsTerracotta, lineWidth: 2)
            .frame(width: 24, height: 24)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

public struct ModaicsEmptyState: View {
    let icon: String
    let title: String
    let message: String
    
    public init(icon: String, title: String, message: String) {
        self.icon = icon
        self.title = title
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: ModaicsLayout.large) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(Color.modaicsStone)
            
            VStack(spacing: ModaicsLayout.small) {
                Text(title)
                    .font(.modaicsHeadingSemiBold)
                    .foregroundColor(Color.modaicsTextPrimary)
                
                Text(message)
                    .font(.modaicsBodyRegular)
                    .foregroundColor(Color.modaicsTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}
