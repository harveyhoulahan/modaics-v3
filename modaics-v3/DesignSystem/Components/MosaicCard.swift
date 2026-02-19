import SwiftUI

// MARK: - MosaicCard
// Cream background, subtle shadow, warm and editorial
// Like a page from Kinfolk magazine

public struct MosaicCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let showShadow: Bool
    
    public init(
        padding: CGFloat = MosaicLayout.margin,
        showShadow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.showShadow = showShadow
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(MosaicColors.backgroundSecondary)
            .cornerRadius(MosaicLayout.cornerRadius)
            .conditionalShadow(show: showShadow)
    }
}

extension View {
    @ViewBuilder
    func conditionalShadow(show: Bool) -> some View {
        if show {
            self.mosaicShadow(MosaicLayout.shadowSmall)
        } else {
            self
        }
    }
}

// MARK: - Feature Card Variant

public struct MosaicFeatureCard: View {
    let image: Image?
    let title: String
    let subtitle: String?
    let description: String?
    let action: (() -> Void)?
    
    public init(
        image: Image? = nil,
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.action = action
    }
    
    public var body: some View {
        MosaicCard {
            VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
                // Image placeholder
                if let image = image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(MosaicLayout.cornerRadiusSmall)
                } else {
                    RoundedRectangle(cornerRadius: MosaicLayout.cornerRadiusSmall)
                        .fill(MosaicColors.terracotta.opacity(0.15))
                        .frame(height: 180)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundColor(MosaicColors.terracotta.opacity(0.5))
                        )
                }
                
                // Content
                VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(MosaicTypography.caption)
                            .foregroundColor(MosaicColors.textSecondary)
                    }
                    
                    Text(title)
                        .font(MosaicTypography.headline2)
                        .foregroundColor(MosaicColors.textPrimary)
                    
                    if let description = description {
                        Text(description)
                            .font(MosaicTypography.body)
                            .foregroundColor(MosaicColors.textSecondary)
                            .lineLimit(3)
                    }
                }
            }
        }
        .onTapGesture {
            action?()
        }
    }
}

// MARK: - Story Card Variant

public struct MosaicStoryCard: View {
    let title: String
    let excerpt: String
    let metadata: String?
    
    public init(
        title: String,
        excerpt: String,
        metadata: String? = nil
    ) {
        self.title = title
        self.excerpt = excerpt
        self.metadata = metadata
    }
    
    public var body: some View {
        MosaicCard(padding: MosaicLayout.marginGenerous, showShadow: false) {
            VStack(alignment: .leading, spacing: MosaicLayout.groupSpacing) {
                VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
                    Text(title)
                        .font(MosaicTypography.headline)
                        .foregroundColor(MosaicColors.textPrimary)
                    
                    Text(excerpt)
                        .mosaicStory()
                }
                
                if let metadata = metadata {
                    Text(metadata)
                        .font(MosaicTypography.finePrint)
                        .foregroundColor(MosaicColors.textTertiary)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius)
                .stroke(MosaicColors.border, lineWidth: 1)
        )
    }
}

// MARK: - Product Card Variant

public struct MosaicProductCard: View {
    let name: String
    let detail: String
    let price: String?
    let image: Image?
    
    public init(
        name: String,
        detail: String,
        price: String? = nil,
        image: Image? = nil
    ) {
        self.name = name
        self.detail = detail
        self.price = price
        self.image = image
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
            // Image area
            ZStack(alignment: .topTrailing) {
                if let image = image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(MosaicLayout.cornerRadius)
                } else {
                    RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius)
                        .fill(MosaicColors.oatmeal)
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "tshirt")
                                .font(.system(size: 40))
                                .foregroundColor(MosaicColors.textTertiary)
                        )
                }
                
                MosaicIconButton(icon: "heart", size: 36) {}
                    .padding(MosaicLayout.tightSpacing)
            }
            
            // Info
            VStack(alignment: .leading, spacing: MosaicLayout.microSpacing) {
                Text(name)
                    .font(MosaicTypography.label)
                    .foregroundColor(MosaicColors.textPrimary)
                
                Text(detail)
                    .font(MosaicTypography.caption)
                    .foregroundColor(MosaicColors.textSecondary)
                
                if let price = price {
                    Text(price)
                        .font(MosaicTypography.bodyEmphasis)
                        .foregroundColor(MosaicColors.textPrimary)
                        .padding(.top, MosaicLayout.tightSpacing)
                }
            }
        }
    }
}

// MARK: - SwiftUI Preview
#Preview {
    ScrollView {
        VStack(spacing: MosaicLayout.sectionSpacing) {
            Text("Mosaic Cards")
                .font(MosaicTypography.display)
                .foregroundColor(MosaicColors.textPrimary)
                .generousMargins()
            
            // Basic card
            MosaicCard {
                VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
                    Text("Basic Card")
                        .font(MosaicTypography.headline)
                        .foregroundColor(MosaicColors.textPrimary)
                    Text("Cream background with subtle shadow. No gradients, flat matte finish.")
                        .mosaicBody()
                }
            }
            .generousMargins()
            
            // Feature card
            MosaicFeatureCard(
                title: "The Linen Collection",
                subtitle: "Summer 2026",
                description: "Breathable, natural fibers woven in Portugal. Each piece tells a story of Mediterranean summers."
            )
            .generousMargins()
            
            // Story card
            MosaicStoryCard(
                title: "Behind the Seams",
                excerpt: "Every garment in our collection carries the imprint of the artisan who created it. We believe in transparency—knowing who made your clothes, where the materials came from, and the journey each piece took to reach you.",
                metadata: "Read time: 4 minutes • By Elena Maris"
            )
            .generousMargins()
            
            // Product card
            MosaicProductCard(
                name: "Terracotta Shirt",
                detail: "Portuguese Linen",
                price: "$148"
            )
            .generousMargins()
            
            // Grid of product cards
            MosaicGrid {
                ForEach(0..<4) { _ in
                    MosaicProductCard(
                        name: "Canvas Tote",
                        detail: "Organic Cotton",
                        price: "$89"
                    )
                }
            }
        }
        .padding(.vertical, MosaicLayout.sectionSpacing)
    }
    .background(MosaicColors.backgroundPrimary)
}
