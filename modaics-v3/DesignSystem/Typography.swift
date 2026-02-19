import SwiftUI

// MARK: - Modaics v3.0 Typography System
// Editorial feel: Aesop + Kinfolk magazine + Le Labo
// System fonts styled for warmth, generous line height, no bold weights

public struct MosaicTypography {
    
    // MARK: - Font Definitions
    
    /// Large display headlines - Hero moments, splash screens
    public static let display = Font.system(.largeTitle, design: .serif)
    
    /// Primary headlines - Section headers, story titles
    public static let headline = Font.system(.title, design: .serif)
    
    /// Secondary headlines - Card titles, feature names
    public static let headline2 = Font.system(.title2, design: .serif)
    
    /// Tertiary headlines - Subsection headers
    public static let headline3 = Font.system(.title3, design: .serif)
    
    /// Body text - Primary reading content
    public static let body = Font.system(.body, design: .serif)
    
    /// Body text with medium weight for emphasis (no bold)
    public static let bodyEmphasis = Font.system(.body, design: .serif).weight(.medium)
    
    /// Large body for featured paragraphs
    public static let bodyLarge = Font.system(.title3, design: .serif)
    
    /// Small body for captions and metadata
    public static let caption = Font.system(.callout, design: .serif)
    
    /// Fine print - Dates, tags, subtle details
    public static let finePrint = Font.system(.footnote, design: .serif)
    
    /// Labels - Buttons, navigation
    public static let label = Font.system(.subheadline, design: .serif).weight(.medium)
    
    /// Story text - Multi-line garment narratives, generous spacing
    public static let story = Font.system(.body, design: .serif)
    
    // MARK: - Line Heights (Multipliers)
    
    /// Generous line height for editorial feel (1.6-1.8)
    public static let lineHeightRelaxed: CGFloat = 1.7
    
    /// Standard line height for UI elements
    public static let lineHeightStandard: CGFloat = 1.4
    
    /// Tight line height for compact UI
    public static let lineHeightTight: CGFloat = 1.2
    
    /// Story/reading line height - maximum comfort
    public static let lineHeightStory: CGFloat = 1.8
}

// MARK: - View Modifiers

public struct HeadlineStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(MosaicTypography.headline)
            .foregroundColor(MosaicColors.textPrimary)
            .lineSpacing(4)
    }
}

public struct BodyStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(MosaicTypography.body)
            .foregroundColor(MosaicColors.textPrimary)
            .lineSpacing(6)
    }
}

public struct StoryStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(MosaicTypography.story)
            .foregroundColor(MosaicColors.textPrimary)
            .lineSpacing(10)
            .lineLimit(nil)
    }
}

public struct CaptionStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(MosaicTypography.caption)
            .foregroundColor(MosaicColors.textSecondary)
            .lineSpacing(2)
    }
}

public struct LabelStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(MosaicTypography.label)
            .foregroundColor(MosaicColors.textPrimary)
            .tracking(0.5)
    }
}

// MARK: - SwiftUI Extensions

extension View {
    /// Apply headline typography style
    public func mosaicHeadline() -> some View {
        modifier(HeadlineStyle())
    }
    
    /// Apply body typography style
    public func mosaicBody() -> some View {
        modifier(BodyStyle())
    }
    
    /// Apply story/reading typography style with generous spacing
    public func mosaicStory() -> some View {
        modifier(StoryStyle())
    }
    
    /// Apply caption typography style
    public func mosaicCaption() -> some View {
        modifier(CaptionStyle())
    }
    
    /// Apply label typography style
    public func mosaicLabel() -> some View {
        modifier(LabelStyle())
    }
    
    /// Set custom line height multiplier
    public func lineHeight(_ multiplier: CGFloat) -> some View {
        self.lineSpacing(self.font?.pointSize ?? 16 * (multiplier - 1) ?? 0)
    }
}

// MARK: - Text Helpers

public struct MosaicText {
    
    /// Create a headline text view
    public static func headline(_ text: String) -> some View {
        Text(text)
            .mosaicHeadline()
    }
    
    /// Create a body text view
    public static func body(_ text: String) -> some View {
        Text(text)
            .mosaicBody()
    }
    
    /// Create a story text view for garment narratives
    public static func story(_ text: String) -> some View {
        Text(text)
            .mosaicStory()
    }
    
    /// Create a caption text view
    public static func caption(_ text: String) -> some View {
        Text(text)
            .mosaicCaption()
    }
    
    /// Create a label text view
    public static func label(_ text: String) -> some View {
        Text(text)
            .mosaicLabel()
    }
}

// MARK: - SwiftUI Preview
#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 32) {
            Text("Typography")
                .font(MosaicTypography.display)
                .foregroundColor(MosaicColors.textPrimary)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Display LargeTitle")
                    .font(MosaicTypography.display)
                    .foregroundColor(MosaicColors.textPrimary)
                
                Text("Headline Title")
                    .font(MosaicTypography.headline)
                    .foregroundColor(MosaicColors.textPrimary)
                
                Text("Headline 2")
                    .font(MosaicTypography.headline2)
                    .foregroundColor(MosaicColors.textPrimary)
                
                Text("Headline 3")
                    .font(MosaicTypography.headline3)
                    .foregroundColor(MosaicColors.textPrimary)
            }
            
            Divider()
                .background(MosaicColors.divider)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Body text with generous line spacing for that editorial magazine feel. Notice how the serif font creates warmth and sophistication.")
                    .mosaicBody()
                
                Text("Body Emphasis (Medium)")
                    .font(MosaicTypography.bodyEmphasis)
                    .foregroundColor(MosaicColors.textPrimary)
                
                Text("Body Large")
                    .font(MosaicTypography.bodyLarge)
                    .foregroundColor(MosaicColors.textPrimary)
            }
            
            Divider()
                .background(MosaicColors.divider)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Story Style - For garment narratives and longer content blocks. The line height is generous at 1.8 for comfortable reading. This is how you tell the story behind each piece, where it came from, who made it, and why it matters.")
                    .mosaicStory()
            }
            
            Divider()
                .background(MosaicColors.divider)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Caption Style")
                    .mosaicCaption()
                
                Text("Label Style")
                    .mosaicLabel()
                
                Text("Fine Print")
                    .font(MosaicTypography.finePrint)
                    .foregroundColor(MosaicColors.textTertiary)
            }
        }
        .padding()
    }
    .background(MosaicColors.backgroundPrimary)
}
