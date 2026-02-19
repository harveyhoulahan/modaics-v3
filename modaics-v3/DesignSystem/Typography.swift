import SwiftUI

// MARK: - Modaics Typography
/// Editorial typography system
/// Playfair Display for headings (elegant, editorial)
/// Inter for body text (clean, readable)
public extension Font {
    
    // MARK: - Display Fonts (Playfair Display)
    
    /// Splash/hero title - 42pt bold
    static let modaicsSplashTitle = Font.custom("PlayfairDisplay-Bold", size: 42)
    
    /// Large display - 36pt bold
    static let modaicsDisplayLarge = Font.custom("PlayfairDisplay-Bold", size: 36)
    
    /// Medium display - 32pt bold
    static let modaicsDisplayMedium = Font.custom("PlayfairDisplay-Bold", size: 32)
    
    /// Small display - 28pt bold
    static let modaicsDisplaySmall = Font.custom("PlayfairDisplay-Bold", size: 28)
    
    // MARK: - Heading Fonts (Playfair Display)
    
    /// Large heading - 24pt semi-bold
    static let modaicsHeadingLarge = Font.custom("PlayfairDisplay-SemiBold", size: 24)
    
    /// Medium heading - 20pt semi-bold
    static let modaicsHeadingSemiBold = Font.custom("PlayfairDisplay-SemiBold", size: 20)
    
    /// Heading 1 - 22pt medium
    static let modaicsHeadline1 = Font.custom("PlayfairDisplay-Medium", size: 22)
    
    /// Heading 2 - 20pt medium
    static let modaicsHeadline2 = Font.custom("PlayfairDisplay-Medium", size: 20)
    
    /// Heading 3 - 18pt medium
    static let modaicsHeadline3 = Font.custom("PlayfairDisplay-Medium", size: 18)
    
    /// Card title - 18pt medium
    static let modaicsCardTitle = Font.custom("PlayfairDisplay-Medium", size: 18)
    
    // MARK: - Body Fonts (Inter)
    
    /// Large body - 17pt regular
    static let modaicsBodyLarge = Font.custom("Inter-Regular", size: 17)
    
    /// Body - 15pt regular
    static let modaicsBodyRegular = Font.custom("Inter-Regular", size: 15)
    
    /// Body emphasis - 15pt medium
    static let modaicsBodyEmphasis = Font.custom("Inter-Medium", size: 15)
    
    /// Body semi-bold - 15pt semi-bold
    static let modaicsBodySemiBold = Font.custom("Inter-SemiBold", size: 15)
    
    /// Label - 14pt medium
    static let modaicsLabel = Font.custom("Inter-Medium", size: 14)
    
    // MARK: - Supporting Fonts (Inter)
    
    /// Button text - 16pt semi-bold
    static let modaicsButton = Font.custom("Inter-SemiBold", size: 16)
    
    /// Caption - 13pt medium
    static let modaicsCaption = Font.custom("Inter-Medium", size: 13)
    
    /// Caption regular - 13pt regular
    static let modaicsCaptionRegular = Font.custom("Inter-Regular", size: 13)
    
    /// Fine print - 12pt medium (for tags, labels)
    static let modaicsFinePrint = Font.custom("Inter-Medium", size: 12)
    
    /// Small - 12pt regular
    static let modaicsSmall = Font.custom("Inter-Regular", size: 12)
    
    /// Micro - 11pt regular
    static let modaicsMicro = Font.custom("Inter-Regular", size: 11)
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
