import SwiftUI

// MARK: - Modaics Layout
/// Consistent spacing, sizing, and layout values
public enum ModaicsLayout {
    
    // MARK: - Spacing
    
    /// 2pt - micro spacing
    public static let microSpacing: CGFloat = 2
    
    /// 4pt - extra extra small
    public static let xxsmall: CGFloat = 4
    
    /// 6pt - extra small tight
    public static let tightSpacing: CGFloat = 6
    
    /// 8pt - extra small
    public static let xsmall: CGFloat = 8
    
    /// 12pt - small (item spacing)
    public static let small: CGFloat = 12
    
    /// 12pt - item spacing alias
    public static let itemSpacing: CGFloat = 12
    
    /// 16pt - medium
    public static let medium: CGFloat = 16
    
    /// 20pt - standard margin
    public static let margin: CGFloat = 20
    
    /// 24pt - large
    public static let large: CGFloat = 24
    
    /// 32pt - extra large
    public static let xlarge: CGFloat = 32
    
    /// 48pt - extra extra large
    public static let xxlarge: CGFloat = 48
    
    /// 64pt - extra extra extra large
    public static let xxxlarge: CGFloat = 64
    
    // MARK: - Corner Radius
    
    /// 4pt - small radius
    public static let cornerRadiusSmall: CGFloat = 4
    
    /// 8pt - medium radius
    public static let cornerRadiusMedium: CGFloat = 8
    
    /// 12pt - large radius (cards)
    public static let cornerRadius: CGFloat = 12
    
    /// 16pt - extra large radius
    public static let cornerRadiusLarge: CGFloat = 16
    
    /// 24pt - button radius
    public static let cornerRadiusButton: CGFloat = 24
    
    /// 999pt - fully rounded
    public static let cornerRadiusRound: CGFloat = 999
    
    // MARK: - Shadows
    
    /// Small shadow for subtle elevation
    public static let shadowSmall = ShadowStyle(
        color: Color.black.opacity(0.08),
        radius: 4,
        x: 0,
        y: 2
    )
    
    /// Medium shadow for cards
    public static let shadowMedium = ShadowStyle(
        color: Color.black.opacity(0.1),
        radius: 8,
        x: 0,
        y: 4
    )
    
    /// Large shadow for prominent elevation
    public static let shadowLarge = ShadowStyle(
        color: Color.black.opacity(0.12),
        radius: 16,
        x: 0,
        y: 8
    )
    
    /// Extra large shadow for modals
    public static let shadowXLarge = ShadowStyle(
        color: Color.black.opacity(0.15),
        radius: 24,
        x: 0,
        y: 12
    )
    
    // MARK: - Grid
    
    /// Standard grid columns for mosaic layout
    public static let mosaicColumns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 12)
    ]
    
    /// Collection grid columns
    public static let collectionColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
}

// MARK: - Shadow Style

public struct ShadowStyle {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    
    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

// MARK: - View Extensions for Layout

public extension View {
    
    /// Applies a mosaic shadow style
    func modaicsShadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
    
    /// Applies small shadow
    func modaicsShadowSmall() -> some View {
        modaicsShadow(ModaicsLayout.shadowSmall)
    }
    
    /// Applies medium shadow
    func modaicsShadowMedium() -> some View {
        modaicsShadow(ModaicsLayout.shadowMedium)
    }
    
    /// Applies large shadow
    func modaicsShadowLarge() -> some View {
        modaicsShadow(ModaicsLayout.shadowLarge)
    }
    
    /// Standard card padding
    func modaicsCardPadding() -> some View {
        self.padding(ModaicsLayout.margin)
    }
    
    /// Standard screen padding
    func modaicsScreenPadding() -> some View {
        self.padding(.horizontal, ModaicsLayout.large)
            .padding(.vertical, ModaicsLayout.medium)
    }
}

// MARK: - Animations

public extension Animation {
    
    /// Quick animation (0.15s)
    static let modaicsQuick = Animation.easeInOut(duration: 0.15)
    
    /// Standard animation (0.3s)
    static let modaicsStandard = Animation.easeInOut(duration: 0.3)
    
    /// Smooth spring animation
    static let modaicsSmooth = Animation.spring(response: 0.4, dampingFraction: 0.8)
    
    /// Bouncy spring animation
    static let modaicsBouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
}
