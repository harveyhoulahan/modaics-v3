import SwiftUI

// MARK: - Modaics Design System
// Dark Green Porsche Theme

public struct ModaicsTheme {
    // MARK: - Colors
    public static let background = Color(hex: "#0A140F")
    public static let surface = Color(hex: "#162B21")
    public static let surfaceSecondary = Color(hex: "#1E3A2B")
    public static let gold = Color(hex: "#D9BD6B")
    public static let goldDark = Color(hex: "#B8A05A")
    
    public static let sageWhite = Color(hex: "#F5F7F3")
    public static let sageGray = Color(hex: "#B8C9B0")
    public static let sageMuted = Color(hex: "#8BA888")
    
    public static let ecoGreen = Color(hex: "#3DDC84")
    public static let ecoGreenDark = Color(hex: "#2DB86A")
    
    public static let error = Color(hex: "#FF6B6B")
    public static let success = Color(hex: "#4ADE80")
    public static let warning = Color(hex: "#FBBF24")
    
    // MARK: - Typography
    public static func largeTitle() -> Font {
        Font.system(.largeTitle, design: .monospaced).weight(.bold)
    }
    
    public static func title() -> Font {
        Font.system(.title, design: .monospaced).weight(.semibold)
    }
    
    public static func title2() -> Font {
        Font.system(.title2, design: .monospaced).weight(.semibold)
    }
    
    public static func title3() -> Font {
        Font.system(.title3, design: .monospaced).weight(.medium)
    }
    
    public static func headline() -> Font {
        Font.system(.headline, design: .monospaced).weight(.semibold)
    }
    
    public static func body() -> Font {
        Font.system(.body, design: .monospaced)
    }
    
    public static func callout() -> Font {
        Font.system(.callout, design: .monospaced)
    }
    
    public static func subheadline() -> Font {
        Font.system(.subheadline, design: .monospaced)
    }
    
    public static func footnote() -> Font {
        Font.system(.footnote, design: .monospaced)
    }
    
    public static func caption() -> Font {
        Font.system(.caption, design: .monospaced)
    }
    
    // MARK: - Header Style (ALL CAPS + tracking)
    public static func headerText(_ text: String) -> some View {
        Text(text.uppercased())
            .font(headline())
            .tracking(2)
    }
    
    // MARK: - Layout
    public static let cornerRadius: CGFloat = 8
    public static let cornerRadiusLarge: CGFloat = 12
    public static let paddingSmall: CGFloat = 8
    public static let paddingMedium: CGFloat = 16
    public static let paddingLarge: CGFloat = 24
    
    // MARK: - Shadows
    public static let shadowSmall = ShadowStyle(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    public static let shadowMedium = ShadowStyle(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
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

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers
public struct ModaicsCardModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(ModaicsTheme.surface)
            .cornerRadius(ModaicsTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: ModaicsTheme.cornerRadius)
                    .stroke(ModaicsTheme.gold.opacity(0.1), lineWidth: 1)
            )
    }
}

public struct ModaicsButtonModifier: ViewModifier {
    let isPrimary: Bool
    
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, ModaicsTheme.paddingMedium)
            .padding(.vertical, ModaicsTheme.paddingSmall)
            .background(isPrimary ? ModaicsTheme.gold : ModaicsTheme.surface)
            .foregroundColor(isPrimary ? ModaicsTheme.background : ModaicsTheme.sageWhite)
            .cornerRadius(ModaicsTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: ModaicsTheme.cornerRadius)
                    .stroke(isPrimary ? Color.clear : ModaicsTheme.gold.opacity(0.3), lineWidth: 1)
            )
    }
}

extension View {
    public func modaicsCard() -> some View {
        modifier(ModaicsCardModifier())
    }
    
    public func modaicsButton(primary: Bool = true) -> some View {
        modifier(ModaicsButtonModifier(isPrimary: primary))
    }
}
