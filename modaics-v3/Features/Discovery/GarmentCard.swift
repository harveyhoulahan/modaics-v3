import SwiftUI

// MARK: - GarmentCard (Dark Green Porsche)
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
            VStack(alignment: .leading, spacing: 12) {
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
                .padding(12)
        }
        .frame(height: 200)
        .background(Color.modaicsSurface)
        .cornerRadius(12)
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
        )
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
            Color.modaicsSurface
            
            VStack(spacing: 8) {
                Image(systemName: "hanger")
                    .font(.system(size: 40))
                    .foregroundColor(.sageSubtle)
                
                Text(garment.category.rawValue.uppercased())
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
            }
        }
    }
    
    // MARK: - Favorite Button
    
    private var favoriteButton: some View {
        Button(action: onFavoriteToggle) {
            ZStack {
                Circle()
                    .fill(Color.modaicsSurface.opacity(0.9))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
                    )
                
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isFavorite ? .luxeGold : .sageWhite)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Info Container
    
    private var infoContainer: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title
            Text(garment.title.uppercased())
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
                .lineLimit(1)
            
            // Brand (if available)
            if let brand = garment.brand {
                Text(brand.name.uppercased())
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
                    .lineLimit(1)
                    .tracking(1)
            }
            
            // Condition & Price Row
            HStack(spacing: 8) {
                conditionBadge
                Spacer()
                priceView
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }
    
    private var conditionBadge: some View {
        Text(garment.condition.displayName.uppercased())
            .font(.forestCaptionSmall)
            .foregroundColor(.modaicsFern)
            .tracking(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.modaicsFern.opacity(0.15))
            )
    }
    
    private var priceView: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if let listingPrice = garment.listingPrice {
                Text("\(listingPrice, format: .currency(code: "USD"))")
                    .font(.forestBodyMedium)
                    .foregroundColor(.luxeGold)
                
                if let originalPrice = garment.originalPrice, originalPrice > listingPrice {
                    Text("\(originalPrice, format: .currency(code: "USD"))")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageMuted)
                        .strikethrough()
                }
            } else {
                Text("TRADE ONLY")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.emerald)
                    .tracking(1)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct GarmentCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 16) {
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
        .background(Color.modaicsBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif