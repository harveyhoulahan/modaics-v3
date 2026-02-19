import SwiftUI

// MARK: - Garment Card Layout Types

public enum GarmentCardLayout {
    case featured      // Large, full-width with prominent story
    case compactLeft   // Image left, text right
    case compactRight  // Image right, text left
    case minimal       // Small, centered, condensed
}

// MARK: - Garment Card
// Photo + story excerpt with terracotta accents
// Kinfolk magazine aesthetic - warm, intentional, artful

public struct GarmentCard: View {
    let garment: Garment
    let layout: GarmentCardLayout
    let onTap: () -> Void
    let onFavorite: () -> Void
    
    @State private var isPressed = false
    @State private var isFavorited = false
    
    public init(
        garment: Garment,
        layout: GarmentCardLayout = .featured,
        onTap: @escaping () -> Void = {},
        onFavorite: @escaping () -> Void = {}
    ) {
        self.garment = garment
        self.layout = layout
        self.onTap = onTap
        self.onFavorite = onFavorite
        self._isFavorited = State(initialValue: false)
    }
    
    public var body: some View {
        Button(action: onTap) {
            cardContent
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .opacity(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    // MARK: - Card Content
    
    @ViewBuilder
    private var cardContent: some View {
        switch layout {
        case .featured:
            featuredLayout
        case .compactLeft:
            compactLayout(imageOnLeft: true)
        case .compactRight:
            compactLayout(imageOnLeft: false)
        case .minimal:
            minimalLayout
        }
    }
    
    // MARK: - Featured Layout
    
    private var featuredLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo with terracotta accent
            ZStack(alignment: .topTrailing) {
                PhotoFrame(
                    garment.coverImage.map { Image(uiImage: $0) },
                    style: .editorial,
                    aspectRatio: .portrait
                )
                
                // Favorite button
                favoriteButton
                    .padding(MosaicLayout.itemSpacing)
            }
            
            // Story excerpt
            VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
                // Category tag with terracotta
                HStack {
                    Text(garment.category.displayName)
                        .font(MosaicTypography.finePrint)
                        .foregroundColor(MosaicColors.terracotta)
                        .tracking(1)
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    if let condition = garment.conditionDisplay {
                        ConditionBadge(condition: condition)
                    }
                }
                
                // Title
                Text(garment.title)
                    .font(MosaicTypography.headline2)
                    .foregroundColor(MosaicColors.textPrimary)
                    .lineLimit(2)
                
                // Story excerpt
                if !garment.story.narrative.isEmpty {
                    Text(garment.story.narrative)
                        .font(MosaicTypography.body)
                        .foregroundColor(MosaicColors.textSecondary)
                        .lineSpacing(6)
                        .lineLimit(3)
                }
                
                // Exchange info
                exchangeInfo
            }
            .padding(MosaicLayout.margin)
            .background(MosaicColors.cream)
        }
        .background(MosaicColors.cream)
        .cornerRadius(MosaicLayout.cornerRadius)
        .mosaicShadow(MosaicLayout.shadowSmall)
        .overlay(
            // Terracotta accent line
            Rectangle()
                .fill(MosaicColors.terracotta)
                .frame(width: 4)
                .offset(x: -2),
            alignment: .leading
        )
    }
    
    // MARK: - Compact Layout
    
    private func compactLayout(imageOnLeft: Bool) -> some View {
        HStack(spacing: 0) {
            if imageOnLeft {
                compactImage
                compactContent
            } else {
                compactContent
                compactImage
            }
        }
        .background(MosaicColors.cream)
        .cornerRadius(MosaicLayout.cornerRadius)
        .mosaicShadow(MosaicLayout.shadowSmall)
        .overlay(
            // Terracotta accent line
            Rectangle()
                .fill(MosaicColors.terracotta)
                .frame(width: 3)
                .offset(x: imageOnLeft ? -1.5 : 1.5),
            alignment: imageOnLeft ? .leading : .trailing
        )
    }
    
    private var compactImage: some View {
        PhotoFrame(
            garment.coverImage.map { Image(uiImage: $0) },
            style: .minimal,
            aspectRatio: .square
        )
        .frame(width: 140)
        .clipped()
    }
    
    private var compactContent: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
            Text(garment.category.displayName)
                .font(MosaicTypography.finePrint)
                .foregroundColor(MosaicColors.terracotta)
                .tracking(1)
                .textCase(.uppercase)
            
            Text(garment.title)
                .font(MosaicTypography.headline3)
                .foregroundColor(MosaicColors.textPrimary)
                .lineLimit(2)
            
            if !garment.story.narrative.isEmpty {
                Text(garment.story.narrative)
                    .font(MosaicTypography.caption)
                    .foregroundColor(MosaicColors.textSecondary)
                    .lineLimit(2)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            compactExchangeInfo
        }
        .padding(MosaicLayout.itemSpacing)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Minimal Layout
    
    private var minimalLayout: some View {
        HStack(spacing: MosaicLayout.itemSpacing) {
            // Small image
            PhotoFrame(
                garment.coverImage.map { Image(uiImage: $0) },
                style: .minimal,
                aspectRatio: .square
            )
            .frame(width: 80, height: 80)
            
            // Content
            VStack(alignment: .leading, spacing: MosaicLayout.microSpacing) {
                Text(garment.title)
                    .font(MosaicTypography.label)
                    .foregroundColor(MosaicColors.textPrimary)
                    .lineLimit(1)
                
                Text(garment.story.narrative)
                    .font(MosaicTypography.finePrint)
                    .foregroundColor(MosaicColors.textSecondary)
                    .lineLimit(2)
                    .lineSpacing(3)
                
                if let price = garment.displayPrice {
                    Text(price)
                        .font(MosaicTypography.caption)
                        .foregroundColor(MosaicColors.terracotta)
                }
            }
            
            Spacer()
            
            // Mini favorite button
            Button(action: {
                isFavorited.toggle()
                onFavorite()
            }) {
                Image(systemName: isFavorited ? "heart.fill" : "heart")
                    .font(.system(size: 14))
                    .foregroundColor(isFavorited ? MosaicColors.terracotta : MosaicColors.textTertiary)
            }
        }
        .padding(MosaicLayout.itemSpacing)
        .background(MosaicColors.cream)
        .cornerRadius(MosaicLayout.cornerRadiusSmall)
    }
    
    // MARK: - Exchange Info
    
    private var exchangeInfo: some View {
        HStack(spacing: MosaicLayout.itemSpacing) {
            if let price = garment.displayPrice {
                Text(price)
                    .font(MosaicTypography.bodyEmphasis)
                    .foregroundColor(MosaicColors.textPrimary)
            }
            
            Spacer()
            
            if let exchangeType = garment.exchangeType {
                ExchangeTypeBadge(type: exchangeType)
            }
            
            if let size = garment.size.label {
                SizeBadge(size: size)
            }
        }
    }
    
    private var compactExchangeInfo: some View {
        HStack(spacing: MosaicLayout.tightSpacing) {
            if let price = garment.displayPrice {
                Text(price)
                    .font(MosaicTypography.label)
                    .foregroundColor(MosaicColors.textPrimary)
            }
            
            Spacer()
            
            if let size = garment.size.label {
                Text(size)
                    .font(MosaicTypography.finePrint)
                    .foregroundColor(MosaicColors.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(MosaicColors.oatmeal)
                    .cornerRadius(4)
            }
        }
    }
    
    // MARK: - Favorite Button
    
    private var favoriteButton: some View {
        Button(action: {
            isFavorited.toggle()
            onFavorite()
        }) {
            ZStack {
                Circle()
                    .fill(MosaicColors.cream)
                    .frame(width: 36, height: 36)
                
                Image(systemName: isFavorited ? "heart.fill" : "heart")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isFavorited ? MosaicColors.terracotta : MosaicColors.textSecondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Badges

struct ConditionBadge: View {
    let condition: String
    
    var body: some View {
        Text(condition)
            .font(MosaicTypography.finePrint)
            .foregroundColor(MosaicColors.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(MosaicColors.oatmeal)
            .cornerRadius(MosaicLayout.cornerRadiusSmall)
    }
}

struct ExchangeTypeBadge: View {
    let type: ExchangeType
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.iconName)
                .font(.system(size: 10))
            Text(type.displayName)
                .font(MosaicTypography.finePrint)
        }
        .foregroundColor(MosaicColors.deepOlive)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(MosaicColors.sage.opacity(0.3))
        .cornerRadius(MosaicLayout.cornerRadiusSmall)
    }
}

struct SizeBadge: View {
    let size: String
    
    var body: some View {
        Text(size)
            .font(MosaicTypography.finePrint)
            .foregroundColor(MosaicColors.textPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(MosaicColors.oatmeal)
            .cornerRadius(MosaicLayout.cornerRadiusSmall)
    }
}

// MARK: - Extensions

extension Garment {
    var coverImage: UIImage? {
        // In real implementation, would load from URL
        nil
    }
    
    var displayPrice: String? {
        guard let price = listingPrice ?? suggestedPrice else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSDecimalNumber)
    }
    
    var conditionDisplay: String? {
        switch condition {
        case .newWithTags: return "New with tags"
        case .newWithoutTags: return "New"
        case .excellent: return "Excellent"
        case .veryGood: return "Very good"
        case .good: return "Good"
        case .fair: return "Fair"
        case .vintage: return "Vintage"
        case .needsRepair: return "Needs repair"
        }
    }
}

extension Category {
    var displayName: String {
        switch self {
        case .tops: return "Tops"
        case .bottoms: return "Bottoms"
        case .dresses: return "Dresses"
        case .outerwear: return "Outerwear"
        case .activewear: return "Activewear"
        case .loungewear: return "Loungewear"
        case .formal: return "Formal"
        case .accessories: return "Accessories"
        case .shoes: return "Shoes"
        case .jewelry: return "Jewelry"
        case .bags: return "Bags"
        case .vintage: return "Vintage"
        case .other: return "Other"
        }
    }
}

extension ExchangeType {
    var displayName: String {
        switch self {
        case .sell: return "For Sale"
        case .trade: return "Trade"
        case .sellOrTrade: return "Sell or Trade"
        }
    }
    
    var iconName: String {
        switch self {
        case .sell: return "dollarsign.circle"
        case .trade: return "arrow.left.arrow.right"
        case .sellOrTrade: return "bag"
        }
    }
}

// MARK: - Preview

#Preview("Featured") {
    ScrollView {
        GarmentCard(
            garment: .sample,
            layout: .featured
        )
        .padding()
    }
    .background(MosaicColors.backgroundPrimary)
}

#Preview("Compact Left") {
    ScrollView {
        GarmentCard(
            garment: .sample,
            layout: .compactLeft
        )
        .padding()
    }
    .background(MosaicColors.backgroundPrimary)
}

#Preview("Compact Right") {
    ScrollView {
        GarmentCard(
            garment: .sample,
            layout: .compactRight
        )
        .padding()
    }
    .background(MosaicColors.backgroundPrimary)
}

#Preview("Minimal") {
    ScrollView {
        GarmentCard(
            garment: .sample,
            layout: .minimal
        )
        .padding()
    }
    .background(MosaicColors.backgroundPrimary)
}