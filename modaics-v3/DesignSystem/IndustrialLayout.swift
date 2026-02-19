import SwiftUI

// MARK: - Industrial Layout System
// Consistent spacing and layout constants for industrial design

struct IndustrialLayout {
    
    // MARK: Spacing Scale
    struct Spacing {
        static let zero: CGFloat = 0
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
        static let xxxxl: CGFloat = 64
    }
    
    // MARK: Corner Radius
    struct CornerRadius {
        static let none: CGFloat = 0
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let full: CGFloat = 9999
    }
    
    // MARK: Border Width
    struct BorderWidth {
        static let none: CGFloat = 0
        static let hairline: CGFloat = 0.5
        static let thin: CGFloat = 1
        static let standard: CGFloat = 1.5
        static let thick: CGFloat = 2
        static let heavy: CGFloat = 3
    }
    
    // MARK: Component Heights
    struct Height {
        static let inputSmall: CGFloat = 36
        static let input: CGFloat = 44
        static let inputLarge: CGFloat = 56
        static let buttonSmall: CGFloat = 32
        static let button: CGFloat = 44
        static let buttonLarge: CGFloat = 56
        static let row: CGFloat = 56
        static let rowCompact: CGFloat = 44
        static let toolbar: CGFloat = 56
        static let navigationBar: CGFloat = 64
        static let tabBar: CGFloat = 80
        static let cardMin: CGFloat = 120
    }
    
    // MARK: Component Widths
    struct Width {
        static let buttonMin: CGFloat = 88
        static let buttonIcon: CGFloat = 44
        static let inputMin: CGFloat = 120
        static let avatarSmall: CGFloat = 32
        static let avatar: CGFloat = 44
        static let avatarLarge: CGFloat = 64
        static let iconSmall: CGFloat = 16
        static let icon: CGFloat = 24
        static let iconLarge: CGFloat = 32
    }
    
    // MARK: Padding
    struct Padding {
        static let screen: CGFloat = 16
        static let screenLarge: CGFloat = 24
        static let card: CGFloat = 16
        static let cardLarge: CGFloat = 24
        static let input: CGFloat = 12
        static let button: CGFloat = 16
        static let buttonLarge: CGFloat = 24
        static let listItem: CGFloat = 16
        static let section: CGFloat = 24
    }
    
    // MARK: Shadows
    struct Shadow {
        static let none = ShadowStyle(color: .clear, radius: 0, x: 0, y: 0)
        static let subtle = ShadowStyle(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let standard = ShadowStyle(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        static let elevated = ShadowStyle(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
        static let chrome = ShadowStyle(color: .modaicsChrome3.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    // MARK: Grid
    struct Grid {
        static let columns: Int = 12
        static let gutter: CGFloat = 16
        static let margin: CGFloat = 16
    }
    
    // MARK: Opacity
    struct Opacity {
        static let disabled: Double = 0.4
        static let pressed: Double = 0.7
        static let hover: Double = 0.8
        static let overlay: Double = 0.5
        static let hint: Double = 0.6
    }
    
    // MARK: Animation
    struct Animation {
        static let instant: SwiftUI.Animation = .easeInOut(duration: 0.1)
        static let fast: SwiftUI.Animation = .easeInOut(duration: 0.15)
        static let standard: SwiftUI.Animation = .easeInOut(duration: 0.25)
        static let slow: SwiftUI.Animation = .easeInOut(duration: 0.35)
        static let spring: SwiftUI.Animation = .spring(response: 0.3, dampingFraction: 0.7)
    }
}

// MARK: - View Modifiers for Layout

struct IndustrialShadowModifier: ViewModifier {
    let style: IndustrialLayout.ShadowStyle
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: style.color,
                radius: style.radius,
                x: style.x,
                y: style.y
            )
    }
}

struct IndustrialCardModifier: ViewModifier {
    let backgroundColor: Color
    let borderColor: Color
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let shadow: IndustrialLayout.ShadowStyle
    
    init(
        backgroundColor: Color = .modaicsSurface,
        borderColor: Color = .modaicsBorder,
        cornerRadius: CGFloat = IndustrialLayout.CornerRadius.md,
        borderWidth: CGFloat = IndustrialLayout.BorderWidth.thin,
        shadow: IndustrialLayout.ShadowStyle = IndustrialLayout.Shadow.none
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.shadow = shadow
    }
    
    func body(content: Content) -> some View {
        content
            .padding(IndustrialLayout.Padding.card)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .modifier(IndustrialShadowModifier(style: shadow))
    }
}

// MARK: - View Extensions

extension View {
    func industrialShadow(_ style: IndustrialLayout.ShadowStyle) -> some View {
        self.modifier(IndustrialShadowModifier(style: style))
    }
    
    func industrialCard(
        backgroundColor: Color = .modaicsSurface,
        borderColor: Color = .modaicsBorder,
        cornerRadius: CGFloat = IndustrialLayout.CornerRadius.md,
        borderWidth: CGFloat = IndustrialLayout.BorderWidth.thin,
        shadow: IndustrialLayout.ShadowStyle = IndustrialLayout.Shadow.none
    ) -> some View {
        self.modifier(IndustrialCardModifier(
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            borderWidth: borderWidth,
            shadow: shadow
        ))
    }
    
    func industrialPadding(_ size: IndustrialPaddingSize = .standard) -> some View {
        self.padding(size.value)
    }
}

enum IndustrialPaddingSize {
    case none, xs, sm, md, lg, xl, xxl, screen, standard, card
    
    var value: CGFloat {
        switch self {
        case .none: return IndustrialLayout.Spacing.zero
        case .xs: return IndustrialLayout.Spacing.xs
        case .sm: return IndustrialLayout.Spacing.sm
        case .md: return IndustrialLayout.Spacing.md
        case .lg: return IndustrialLayout.Spacing.lg
        case .xl: return IndustrialLayout.Spacing.xl
        case .xxl: return IndustrialLayout.Spacing.xxl
        case .screen: return IndustrialLayout.Padding.screen
        case .standard: return IndustrialLayout.Spacing.lg
        case .card: return IndustrialLayout.Padding.card
        }
    }
}

// MARK: - Spacer Extensions

extension Spacer {
    static func industrial(_ size: IndustrialSpacerSize) -> some View {
        Spacer(minLength: size.value)
    }
}

enum IndustrialSpacerSize {
    case xs, sm, md, lg, xl, xxl
    
    var value: CGFloat {
        switch self {
        case .xs: return IndustrialLayout.Spacing.xs
        case .sm: return IndustrialLayout.Spacing.sm
        case .md: return IndustrialLayout.Spacing.md
        case .lg: return IndustrialLayout.Spacing.lg
        case .xl: return IndustrialLayout.Spacing.xl
        case .xxl: return IndustrialLayout.Spacing.xxl
        }
    }
}

// MARK: - Divider Style

struct IndustrialDivider: View {
    var color: Color = .modaicsBorder
    var lineWidth: CGFloat = IndustrialLayout.BorderWidth.thin
    var padding: CGFloat = IndustrialLayout.Spacing.lg
    
    var body: some View {
        Divider()
            .background(color)
            .frame(height: lineWidth)
            .padding(.vertical, padding)
    }
}
