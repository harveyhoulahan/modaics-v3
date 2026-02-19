import SwiftUI

// MARK: - Modaics Industrial Typography
/// Industrial typography system
/// Monospace fonts for all text (industrial/technical aesthetic)
public extension Font {
    
    // MARK: - Display Fonts (Monospace)
    
    /// Splash/hero title - 42pt bold monospace
    static let modaicsSplashTitle = Font.system(size: 42, weight: .bold, design: .monospaced)
    
    /// Large display - 36pt bold monospace
    static let modaicsDisplayLarge = Font.system(size: 36, weight: .bold, design: .monospaced)
    
    /// Medium display - 32pt bold monospace
    static let modaicsDisplayMedium = Font.system(size: 32, weight: .bold, design: .monospaced)
    
    /// Small display - 28pt bold monospace
    static let modaicsDisplaySmall = Font.system(size: 28, weight: .bold, design: .monospaced)
    
    // MARK: - Heading Fonts (Monospace)
    
    /// Large heading - 24pt semibold monospace
    static let modaicsHeadingLarge = Font.system(size: 24, weight: .semibold, design: .monospaced)
    
    /// Medium heading - 20pt semibold monospace
    static let modaicsHeadingSemiBold = Font.system(size: 20, weight: .semibold, design: .monospaced)
    
    /// Heading 1 - 22pt medium monospace
    static let modaicsHeadline1 = Font.system(size: 22, weight: .medium, design: .monospaced)
    
    /// Heading 2 - 20pt medium monospace
    static let modaicsHeadline2 = Font.system(size: 20, weight: .medium, design: .monospaced)
    
    /// Heading 3 - 18pt medium monospace
    static let modaicsHeadline3 = Font.system(size: 18, weight: .medium, design: .monospaced)
    
    /// Card title - 18pt medium monospace
    static let modaicsCardTitle = Font.system(size: 18, weight: .medium, design: .monospaced)
    
    // MARK: - Body Fonts (Monospace)
    
    /// Large body - 17pt regular monospace
    static let modaicsBodyLarge = Font.system(size: 17, weight: .regular, design: .monospaced)
    
    /// Body - 15pt regular monospace
    static let modaicsBodyRegular = Font.system(size: 15, weight: .regular, design: .monospaced)
    
    /// Body emphasis - 15pt medium monospace
    static let modaicsBodyEmphasis = Font.system(size: 15, weight: .medium, design: .monospaced)
    
    /// Body semibold - 15pt semibold monospace
    static let modaicsBodySemiBold = Font.system(size: 15, weight: .semibold, design: .monospaced)
    
    /// Label - 14pt medium monospace
    static let modaicsLabel = Font.system(size: 14, weight: .medium, design: .monospaced)
    
    // MARK: - Supporting Fonts (Monospace)
    
    /// Button text - 16pt semibold monospace
    static let modaicsButton = Font.system(size: 16, weight: .semibold, design: .monospaced)
    
    /// Caption - 13pt medium monospace
    static let modaicsCaption = Font.system(size: 13, weight: .medium, design: .monospaced)
    
    /// Caption regular - 13pt regular monospace
    static let modaicsCaptionRegular = Font.system(size: 13, weight: .regular, design: .monospaced)
    
    /// Fine print - 12pt medium monospace (for tags, labels)
    static let modaicsFinePrint = Font.system(size: 12, weight: .medium, design: .monospaced)
    
    /// Small - 12pt regular monospace
    static let modaicsSmall = Font.system(size: 12, weight: .regular, design: .monospaced)
    
    /// Micro - 11pt regular monospace
    static let modaicsMicro = Font.system(size: 11, weight: .regular, design: .monospaced)
    
    /// Tab label - 11pt medium monospace
    static let modaicsTabLabel = Font.system(size: 11, weight: .medium, design: .monospaced)
}

// MARK: - Font Modifiers

public extension View {
    
    /// Applies splash title style
    func modaicsSplashTitleStyle() -> some View {
        self.font(.modaicsSplashTitle)
            .foregroundColor(.modaicsTextPrimary)
    }
    
    /// Applies heading style
    func modaicsHeadingStyle(size: ModaicsHeadingSize = .medium) -> some View {
        self.font(size.font)
            .foregroundColor(.modaicsTextPrimary)
    }
    
    /// Applies body style
    func modaicsBodyStyle(emphasis: ModaicsBodyEmphasis = .regular) -> some View {
        self.font(emphasis.font)
            .foregroundColor(.modaicsTextPrimary)
    }
    
    /// Applies tab label style
    func modaicsTabLabelStyle(isActive: Bool = false) -> some View {
        self.font(.modaicsTabLabel)
            .foregroundColor(isActive ? .modaicsActive : .modaicsInactive)
    }
}

// MARK: - Typography Enums

public enum ModaicsHeadingSize {
    case large, medium, small
    
    var font: Font {
        switch self {
        case .large: return .modaicsHeadingLarge
        case .medium: return .modaicsHeadingSemiBold
        case .small: return .modaicsHeadline3
        }
    }
}

public enum ModaicsBodyEmphasis {
    case regular, medium, semibold
    
    var font: Font {
        switch self {
        case .regular: return .modaicsBodyRegular
        case .medium: return .modaicsBodyEmphasis
        case .semibold: return .modaicsBodySemiBold
        }
    }
}
