import SwiftUI

// MARK: - GarmentCard
/// Card component for displaying a garment in the discovery feed
public struct GarmentCard: View {
    
    // MARK: - Properties
    
    let garment: ModaicsGarment
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    let onTap: () -> Void
    
    // MARK: - Initialization
    
    public init(
        garment: ModaicsGarment,
        isFavorite: Bool = false,
        onFavoriteToggle: @escaping () -> Void = {},
        onTap: @escaping () -> Void = {}
    ) {
        self.garment = garment
        self.isFavorite = isFavorite
        self.onFavoriteToggle = onFavoriteToggle
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: ModaicsLayout.small) {
                // Image Container
                imageContainer
                
                // Info Container
                infoContainer
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Image Container
    
    private var imageContainer: some View {
        ZStack(alignment: .topTrailing) {
            // Image or Placeholder
            garmentImage
            
            // Favorite Button
            favoriteButton
                .padding(ModaicsLayout.small)
        }
        .frame(height: 200)
        .background(Color.modaicsOatmeal)
        .cornerRadius(ModaicsLayout.cornerRadius)
        .clipped()
    }
    
    private var garmentImage: some View {
        Group {
            if let imageURL = garment.coverImageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        placeholderView
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Color.modaicsOatmeal
            
            VStack(spacing: ModaicsLayout.small) {
                Image(systemName: "hanger")
                    .font(.system(size: 40))
                    .foregroundColor(.modaicsStone)
                
                Text(garment.category.rawValue.capitalized)
                    .font(.modaicsCaption)
                    .foregroundColor(.modaicsTextSecondary)
            }
        }
    }
    
    // MARK: - Favorite Button
    
    private var favoriteButton: some View {
        Button(action: onFavoriteToggle) {
            ZStack {
                Circle()
                    .fill(Color.modaicsPaper.opacity(0.9))
                    .frame(width: 36, height: 36)
                
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isFavorite ? .modaicsTerracotta : .modaicsCharcoal)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Info Container
    
    private var infoContainer: some View {
        VStack(alignment: .leading, spacing: ModaicsLayout.tightSpacing) {
            // Title
            Text(garment.title)
                .font(.modaicsCardTitle)
                .foregroundColor(.modaicsTextPrimary)
                .lineLimit(1)
            
            // Brand (if available)
            if let brand = garment.brand {
                Text(brand.name)
                    .font(.modaicsCaption)
                    .foregroundColor(.modaicsTextSecondary)
                    .lineLimit(1)
            }
            
            // Condition & Price Row
            HStack(spacing: ModaicsLayout.xsmall) {
                conditionBadge
                Spacer()
                priceView
            }
        }
        .padding(.horizontal, ModaicsLayout.xsmall)
        .padding(.bottom, ModaicsLayout.xsmall)
    }
    
    private var conditionBadge: some View {
        Text(garment.condition.displayName)
            .font(.modaicsFinePrint)
            .foregroundColor(.modaicsDeepOlive)
            .padding(.horizontal, ModaicsLayout.tightSpacing)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.modaicsDeepOlive.opacity(0.12))
            )
    }
    
    private var priceView: some View {
        HStack(alignment: .firstTextBaseline, spacing: ModaicsLayout.xxsmall) {
            if let listingPrice = garment.listingPrice {
                Text("\(listingPrice, format: .currency(code: "USD"))")
                    .font(.modaicsBodySemiBold)
                    .foregroundColor(.modaicsCharcoal)
                
                if let originalPrice = garment.originalPrice, originalPrice > listingPrice {
                    Text("\(originalPrice, format: .currency(code: "USD"))")
                        .font(.modaicsCaptionRegular)
                        .foregroundColor(.modaicsTextSecondary)
                        .strikethrough()
                }
            } else {
                Text("Trade Only")
                    .font(.modaicsCaption)
                    .foregroundColor(.modaicsSage)
            }
        }
    }
}

// MARK: - ModaicsCondition Display Name Extension

private extension ModaicsCondition {
    var displayName: String {
        switch self {
        case .newWithTags:
            return "NWT"
        case .newWithoutTags:
            return "New"
        case .excellent:
            return "Excellent"
        case .veryGood:
            return "Very Good"
        case .good:
            return "Good"
        case .fair:
            return "Fair"
        case .vintage:
            return "Vintage"
        case .needsRepair:
            return "Repair"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct GarmentCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: ModaicsLayout.medium) {
            GarmentCard(
                garment: ModaicsGarment(
                    id: UUID(),
                    title: "Vintage Silk Blouse",
                    description: "Beautiful silk blouse",
                    storyId: UUID(),
                    condition: .excellent,
                    originalPrice: 180.00,
                    listingPrice: 85.00,
                    category: .tops,
                    size: ModaicsSize(label: "S", system: .us),
                    ownerId: UUID(),
                    isListed: true,
                    exchangeType: .sell
                ),
                isFavorite: false
            )
            
            GarmentCard(
                garment: ModaicsGarment(
                    id: UUID(),
                    title: "Oversized Wool Coat",
                    description: "Cozy coat",
                    storyId: UUID(),
                    condition: .veryGood,
                    originalPrice: 450.00,
                    listingPrice: 220.00,
                    category: .outerwear,
                    size: ModaicsSize(label: "M", system: .us),
                    ownerId: UUID(),
                    isListed: true,
                    exchangeType: .sellOrTrade
                ),
                isFavorite: true
            )
        }
        .padding()
        .background(Color.modaicsWarmSand)
        .previewLayout(.sizeThatFits)
    }
}
#endif
