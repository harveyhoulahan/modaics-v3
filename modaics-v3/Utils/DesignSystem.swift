import SwiftUI

// MARK: - Design System
/// Central design system for the Modaics app
/// Warm, editorial aesthetic with terracotta accents
enum DesignSystem {
    
    // MARK: - Colors
    enum Colors {
        /// Primary app background - warm sand
        static let warmSand = SwiftUI.Color(red: 0.96, green: 0.94, blue: 0.90)
        
        /// Card/elevated surface background - paper
        static let paper = SwiftUI.Color(red: 0.98, green: 0.97, blue: 0.95)
        
        /// Primary accent - terracotta
        static let terracotta = SwiftUI.Color(red: 0.80, green: 0.38, blue: 0.27)
        
        /// Primary text - charcoal
        static let charcoal = SwiftUI.Color(red: 0.20, green: 0.18, blue: 0.16)
        
        /// Secondary text
        static let stone = SwiftUI.Color(red: 0.50, green: 0.47, blue: 0.44)
        
        /// Success state
        static let sage = SwiftUI.Color(red: 0.47, green: 0.58, blue: 0.47)
        
        /// Error state
        static let rust = SwiftUI.Color(red: 0.71, green: 0.28, blue: 0.21)
        
        /// Warning state
        static let ochre = SwiftUI.Color(red: 0.80, green: 0.52, blue: 0.25)
        
        /// No pure white - use paper instead
        static let pureWhite = paper
    }
    
    // MARK: - Typography
    enum Typography {
        /// Large display title (for splash, hero sections)
        static let splashTitle: Font = .custom("PlayfairDisplay-Bold", size: 42)
        
        /// Large title (for screen headers)
        static let largeTitle: Font = .custom("PlayfairDisplay-Bold", size: 32)
        
        /// Medium title
        static let title: Font = .custom("PlayfairDisplay-SemiBold", size: 24)
        
        /// Section headers
        static let sectionTitle: Font = .custom("PlayfairDisplay-SemiBold", size: 20)
        
        /// Card titles
        static let cardTitle: Font = .custom("PlayfairDisplay-Medium", size: 18)
        
        /// Body text large
        static let bodyLarge: Font = .custom("Inter-Regular", size: 17)
        
        /// Body text
        static let body: Font = .custom("Inter-Regular", size: 15)
        
        /// Button text
        static let button: Font = .custom("Inter-SemiBold", size: 16)
        
        /// Caption text
        static let caption: Font = .custom("Inter-Medium", size: 13)
        
        /// Small text
        static let small: Font = .custom("Inter-Regular", size: 12)
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xxxsmall: CGFloat = 2
        static let xxsmall: CGFloat = 4
        static let xsmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xlarge: CGFloat = 32
        static let xxlarge: CGFloat = 48
        static let xxxlarge: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let xlarge: CGFloat = 16
        static let round: CGFloat = 999
    }
    
    // MARK: - Shadows
    enum Shadows {
        static let small = ShadowStyle(
            color: SwiftUI.Color.black.opacity(0.08),
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let medium = ShadowStyle(
            color: SwiftUI.Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let large = ShadowStyle(
            color: SwiftUI.Color.black.opacity(0.12),
            radius: 16,
            x: 0,
            y: 8
        )
    }
    
    struct ShadowStyle {
        let color: SwiftUI.Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
        
        func apply<V: View>(to view: V) -> some View {
            view.shadow(color: color, radius: radius, x: x, y: y)
        }
    }
    
    // MARK: - Animations
    enum Animations {
        static let quick = Animation.easeInOut(duration: 0.15)
        static let standard = Animation.easeInOut(duration: 0.3)
        static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
    }
    
    // MARK: - Gradients
    enum Gradients {
        static let warmOverlay = LinearGradient(
            colors: [
                Colors.warmSand.opacity(0),
                Colors.warmSand.opacity(0.8),
                Colors.warmSand
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let terracottaAccent = LinearGradient(
            colors: [Colors.terracotta, Colors.terracotta.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - View Extensions
extension View {
    func designSystemCardStyle() -> some View {
        self
            .background(DesignSystem.Colors.paper)
            .cornerRadius(DesignSystem.CornerRadius.large)
            .shadow(
                color: DesignSystem.Shadows.medium.color,
                radius: DesignSystem.Shadows.medium.radius,
                x: DesignSystem.Shadows.medium.x,
                y: DesignSystem.Shadows.medium.y
            )
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.button)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.xlarge)
            .padding(.vertical, DesignSystem.Spacing.medium)
            .background(DesignSystem.Colors.terracotta)
            .cornerRadius(DesignSystem.CornerRadius.large)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.button)
            .foregroundColor(DesignSystem.Colors.terracotta)
            .padding(.horizontal, DesignSystem.Spacing.xlarge)
            .padding(.vertical, DesignSystem.Spacing.medium)
            .background(DesignSystem.Colors.terracotta.opacity(0.1))
            .cornerRadius(DesignSystem.CornerRadius.large)
    }
}
