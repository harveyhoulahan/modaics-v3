import SwiftUI

// MARK: - Industrial Typography System
// Monospaced fonts throughout for industrial/tech aesthetic

struct IndustrialTypography {
    
    // MARK: Font Families
    static let mono = Font.Design.monospaced
    
    // MARK: Display Styles (Large Headers)
    static let displayLarge = Font.system(
        size: 48,
        weight: .bold,
        design: .monospaced
    )
    
    static let displayMedium = Font.system(
        size: 36,
        weight: .bold,
        design: .monospaced
    )
    
    static let displaySmall = Font.system(
        size: 28,
        weight: .bold,
        design: .monospaced
    )
    
    // MARK: Heading Styles
    static let heading1 = Font.system(
        size: 24,
        weight: .semibold,
        design: .monospaced
    )
    
    static let heading2 = Font.system(
        size: 20,
        weight: .semibold,
        design: .monospaced
    )
    
    static let heading3 = Font.system(
        size: 18,
        weight: .medium,
        design: .monospaced
    )
    
    static let heading4 = Font.system(
        size: 16,
        weight: .medium,
        design: .monospaced
    )
    
    // MARK: Body Styles
    static let bodyLarge = Font.system(
        size: 16,
        weight: .regular,
        design: .monospaced
    )
    
    static let bodyMedium = Font.system(
        size: 14,
        weight: .regular,
        design: .monospaced
    )
    
    static let bodySmall = Font.system(
        size: 12,
        weight: .regular,
        design: .monospaced
    )
    
    // MARK: Label Styles (Small Caps Feel)
    static let labelLarge = Font.system(
        size: 14,
        weight: .medium,
        design: .monospaced
    )
    
    static let labelMedium = Font.system(
        size: 12,
        weight: .medium,
        design: .monospaced
    )
    
    static let labelSmall = Font.system(
        size: 10,
        weight: .medium,
        design: .monospaced
    )
    
    // MARK: Caption Styles
    static let caption = Font.system(
        size: 11,
        weight: .regular,
        design: .monospaced
    )
    
    static let captionSmall = Font.system(
        size: 9,
        weight: .regular,
        design: .monospaced
    )
    
    // MARK: Button Text
    static let buttonLarge = Font.system(
        size: 16,
        weight: .semibold,
        design: .monospaced
    )
    
    static let buttonMedium = Font.system(
        size: 14,
        weight: .medium,
        design: .monospaced
    )
    
    static let buttonSmall = Font.system(
        size: 12,
        weight: .medium,
        design: .monospaced
    )
    
    // MARK: Input/Field Text
    static let input = Font.system(
        size: 14,
        weight: .regular,
        design: .monospaced
    )
    
    static let inputPlaceholder = Font.system(
        size: 14,
        weight: .regular,
        design: .monospaced
    )
}

// MARK: - Text Style Extensions
extension Text {
    func industrialDisplay(_ size: IndustrialDisplaySize = .medium) -> some View {
        self.font(size.font)
            .foregroundColor(.modaicsTextMain)
    }
    
    func industrialHeading(_ level: IndustrialHeadingLevel = .h2) -> some View {
        self.font(level.font)
            .foregroundColor(.modaicsTextMain)
    }
    
    func industrialBody(_ size: IndustrialBodySize = .medium) -> some View {
        self.font(size.font)
            .foregroundColor(.modaicsTextSecondary)
    }
    
    func industrialLabel(_ size: IndustrialLabelSize = .medium) -> some View {
        self.font(size.font)
            .foregroundColor(.modaicsTextMuted)
    }
    
    func industrialCaption() -> some View {
        self.font(IndustrialTypography.caption)
            .foregroundColor(.modaicsTextMuted)
    }
}

// MARK: - Typography Enums
enum IndustrialDisplaySize {
    case large, medium, small
    
    var font: Font {
        switch self {
        case .large: return IndustrialTypography.displayLarge
        case .medium: return IndustrialTypography.displayMedium
        case .small: return IndustrialTypography.displaySmall
        }
    }
}

enum IndustrialHeadingLevel {
    case h1, h2, h3, h4
    
    var font: Font {
        switch self {
        case .h1: return IndustrialTypography.heading1
        case .h2: return IndustrialTypography.heading2
        case .h3: return IndustrialTypography.heading3
        case .h4: return IndustrialTypography.heading4
        }
    }
}

enum IndustrialBodySize {
    case large, medium, small
    
    var font: Font {
        switch self {
        case .large: return IndustrialTypography.bodyLarge
        case .medium: return IndustrialTypography.bodyMedium
        case .small: return IndustrialTypography.bodySmall
        }
    }
}

enum IndustrialLabelSize {
    case large, medium, small
    
    var font: Font {
        switch self {
        case .large: return IndustrialTypography.labelLarge
        case .medium: return IndustrialTypography.labelMedium
        case .small: return IndustrialTypography.labelSmall
        }
    }
}

// MARK: - Letter Spacing
extension Text {
    func industrialTracking(_ tracking: IndustrialTracking) -> some View {
        self.tracking(tracking.value)
    }
}

enum IndustrialTracking {
    case tight, normal, wide, extraWide
    
    var value: CGFloat {
        switch self {
        case .tight: return -0.5
        case .normal: return 0
        case .wide: return 1.0
        case .extraWide: return 2.0
        }
    }
}

// MARK: - Line Height
extension View {
    func industrialLineSpacing(_ spacing: IndustrialLineSpacing) -> some View {
        self.lineSpacing(spacing.value)
    }
}

enum IndustrialLineSpacing {
    case tight, normal, relaxed
    
    var value: CGFloat {
        switch self {
        case .tight: return 2
        case .normal: return 6
        case .relaxed: return 12
        }
    }
}
