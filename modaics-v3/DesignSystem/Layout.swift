import SwiftUI

// MARK: - Modaics v3.0 Layout System
// Generous margins, asymmetric layouts, mosaic motif helpers
// Mediterranean warmth: spacious, intentional, artful

public struct MosaicLayout {
    
    // MARK: - Margins & Spacing
    
    /// Generous screen margins (15%+ on each side)
    public static let margin: CGFloat = 24
    
    /// Extra generous margins for editorial moments
    public static let marginGenerous: CGFloat = 40
    
    /// Compact margins for dense content
    public static let marginCompact: CGFloat = 16
    
    /// Edge padding for full-bleed content
    public static let edgePadding: CGFloat = 20
    
    // MARK: - Section Spacing
    
    /// Space between major sections
    public static let sectionSpacing: CGFloat = 48
    
    /// Space between content groups
    public static let groupSpacing: CGFloat = 32
    
    /// Space between related items
    public static let itemSpacing: CGFloat = 16
    
    /// Space between tight elements
    public static let tightSpacing: CGFloat = 8
    
    /// Space for micro adjustments
    public static let microSpacing: CGFloat = 4
    
    // MARK: - Corner Radii
    
    /// Standard corner radius for cards
    public static let cornerRadius: CGFloat = 12
    
    /// Generous corner radius for featured elements
    public static let cornerRadiusLarge: CGFloat = 20
    
    /// Subtle corner radius for minimal elements
    public static let cornerRadiusSmall: CGFloat = 8
    
    /// Pill-shaped corners
    public static let cornerRadiusPill: CGFloat = 100
    
    // MARK: - Shadows
    
    /// Subtle shadow for cards (flat, not gradient)
    public static let shadowSmall = ShadowStyle(
        color: MosaicColors.shadow,
        radius: 8,
        x: 0,
        y: 4
    )
    
    /// Medium shadow for elevated elements
    public static let shadowMedium = ShadowStyle(
        color: MosaicColors.shadow,
        radius: 16,
        x: 0,
        y: 8
    )
    
    /// Large shadow for modal/overlays
    public static let shadowLarge = ShadowStyle(
        color: MosaicColors.shadow,
        radius: 24,
        x: 0,
        y: 12
    )
    
    // MARK: - Grid
    
    /// Standard grid columns count
    public static let gridColumns = 2
    
    /// Grid spacing
    public static let gridSpacing: CGFloat = 16
    
    /// Asymmetric golden ratio (for split layouts)
    public static let goldenRatio: CGFloat = 0.618
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

// MARK: - Mosaic Motif Helpers

public struct MosaicMotif {
    
    /// Offset for asymmetric layouts (shifts content off-center)
    public static let asymmetricOffset: CGFloat = 32
    
    /// Creates an asymmetric padding where leading is larger than trailing
    public static func asymmetricLeading(_ value: CGFloat = MosaicLayout.marginGenerous) -> EdgeInsets {
        EdgeInsets(
            top: 0,
            leading: value,
            bottom: 0,
            trailing: MosaicLayout.margin
        )
    }
    
    /// Creates an asymmetric padding where trailing is larger than leading
    public static func asymmetricTrailing(_ value: CGFloat = MosaicLayout.marginGenerous) -> EdgeInsets {
        EdgeInsets(
            top: 0,
            leading: MosaicLayout.margin,
            bottom: 0,
            trailing: value
        )
    }
    
    /// Creates a staggered offset for grid items
    public static func staggeredOffset(for index: Int) -> CGFloat {
        index % 2 == 0 ? 0 : 24
    }
    
    /// Creates a mosaic grid layout with varying item sizes
    public static func mosaicGrid() -> [GridItem] {
        [
            GridItem(.flexible(), spacing: MosaicLayout.gridSpacing),
            GridItem(.flexible(), spacing: MosaicLayout.gridSpacing)
        ]
    }
    
    /// Creates an editorial offset layout (content slightly off-center for artful feel)
    public static func editorialOffset() -> CGFloat {
        -20
    }
}

// MARK: - View Modifiers

public struct GenerousMarginModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, MosaicLayout.margin)
    }
}

public struct CardStyleModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(MosaicLayout.margin)
            .background(MosaicColors.backgroundSecondary)
            .cornerRadius(MosaicLayout.cornerRadius)
            .shadow(
                color: MosaicLayout.shadowSmall.color,
                radius: MosaicLayout.shadowSmall.radius,
                x: MosaicLayout.shadowSmall.x,
                y: MosaicLayout.shadowSmall.y
            )
    }
}

public struct AsymmetricLayoutModifier: ViewModifier {
    let favorLeading: Bool
    
    public func body(content: Content) -> some View {
        content
            .padding(
                favorLeading ?
                MosaicMotif.asymmetricLeading() :
                MosaicMotif.asymmetricTrailing()
            )
    }
}

// MARK: - SwiftUI Extensions

extension View {
    /// Apply generous horizontal margins
    public func generousMargins() -> some View {
        modifier(GenerousMarginModifier())
    }
    
    /// Apply standard card styling
    public func cardStyle() -> some View {
        modifier(CardStyleModifier())
    }
    
    /// Apply asymmetric layout with more space on one side
    public func asymmetric(favorLeading: Bool = true) -> some View {
        modifier(AsymmetricLayoutModifier(favorLeading: favorLeading))
    }
    
    /// Apply mosaic shadow
    public func mosaicShadow(_ style: ShadowStyle = MosaicLayout.shadowSmall) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
    
    /// Apply editorial offset for artful positioning
    public func editorialOffset() -> some View {
        self.offset(x: MosaicMotif.editorialOffset())
    }
}

// MARK: - Layout Containers

public struct GenerousVStack<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    public init(spacing: CGFloat = MosaicLayout.groupSpacing, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .padding(.horizontal, MosaicLayout.margin)
    }
}

public struct AsymmetricContainer<Content: View>: View {
    let favorLeading: Bool
    let content: Content
    
    public init(favorLeading: Bool = true, @ViewBuilder content: () -> Content) {
        self.favorLeading = favorLeading
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(favorLeading ? .leading : .trailing, MosaicLayout.marginGenerous)
            .padding(favorLeading ? .trailing : .leading, MosaicLayout.margin)
    }
}

public struct MosaicGrid<Content: View>: View {
    let columns: Int
    let spacing: CGFloat
    let content: Content
    
    public init(
        columns: Int = MosaicLayout.gridColumns,
        spacing: CGFloat = MosaicLayout.gridSpacing,
        @ViewBuilder content: () -> Content
    ) {
        self.columns = columns
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
            spacing: spacing
        ) {
            content
        }
        .padding(.horizontal, MosaicLayout.margin)
    }
}

// MARK: - SwiftUI Preview
#Preview {
    ScrollView {
        VStack(spacing: MosaicLayout.sectionSpacing) {
            Text("Layout System")
                .font(MosaicTypography.display)
                .foregroundColor(MosaicColors.textPrimary)
                .generousMargins()
            
            // Generous margins demo
            VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
                Text("Generous Margins")
                    .font(MosaicTypography.headline)
                    .foregroundColor(MosaicColors.textPrimary)
                
                RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius)
                    .fill(MosaicColors.terracotta.opacity(0.2))
                    .frame(height: 80)
                    .overlay(
                        Text("15%+ margins create breathing room")
                            .mosaicBody()
                    )
            }
            .generousMargins()
            
            // Card style demo
            VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
                Text("Card Style")
                    .font(MosaicTypography.headline)
                    .foregroundColor(MosaicColors.textPrimary)
                
                Text("Subtle shadows, flat colors, warm cream background")
                    .mosaicBody()
            }
            .cardStyle()
            .generousMargins()
            
            // Asymmetric layout demo
            AsymmetricContainer(favorLeading: true) {
                VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
                    Text("Asymmetric Layout")
                        .font(MosaicTypography.headline)
                        .foregroundColor(MosaicColors.textPrimary)
                    
                    Text("Content shifted off-center for editorial artfulness")
                        .mosaicBody()
                    
                    RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius)
                        .fill(MosaicColors.deepOlive.opacity(0.3))
                        .frame(height: 120)
                }
            }
            
            // Mosaic grid demo
            VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
                Text("Mosaic Grid")
                    .font(MosaicTypography.headline)
                    .foregroundColor(MosaicColors.textPrimary)
                    .generousMargins()
                
                MosaicGrid {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius)
                            .fill(MosaicColors.terracotta.opacity(0.2 + Double(index) * 0.1))
                            .frame(height: 100 + (index % 2 == 0 ? 0 : 40))
                            .offset(y: MosaicMotif.staggeredOffset(for: index))
                    }
                }
            }
        }
        .padding(.vertical, MosaicLayout.sectionSpacing)
    }
    .background(MosaicColors.backgroundPrimary)
}
