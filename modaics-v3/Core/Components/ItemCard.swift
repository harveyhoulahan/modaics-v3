import SwiftUI
import PhotosUI

// MARK: - ItemCard
/// Reusable card component for displaying garment/item previews
public struct ItemCard: View {
    let title: String
    let subtitle: String?
    let imageURL: URL?
    let price: Decimal?
    let condition: ModaicsCondition?
    let sustainabilityScore: Int?
    let isLoading: Bool
    
    public init(
        title: String,
        subtitle: String? = nil,
        imageURL: URL? = nil,
        price: Decimal? = nil,
        condition: ModaicsCondition? = nil,
        sustainabilityScore: Int? = nil,
        isLoading: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.price = price
        self.condition = condition
        self.sustainabilityScore = sustainabilityScore
        self.isLoading = isLoading
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image container
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(Color.modaicsSurface)
                    .aspectRatio(3/4, contentMode: .fit)
                    .overlay(
                        Group {
                            if isLoading {
                                ProgressView()
                                    .tint(.luxeGold)
                            } else if let url = imageURL {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .tint(.luxeGold)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        Image(systemName: "photo")
                                            .font(.system(size: 32))
                                            .foregroundColor(.sageMuted)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundColor(.sageMuted)
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Sustainability badge
                if let score = sustainabilityScore {
                    SustainabilityBadge(score: score)
                        .padding(8)
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageWhite)
                    .lineLimit(1)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                        .lineLimit(1)
                }
                
                HStack {
                    if let condition = condition {
                        Text(condition.displayName)
                            .font(.forestCaptionSmall)
                            .textCase(.uppercase)
                            .foregroundColor(.modaicsFern)
                    }
                    
                    Spacer()
                    
                    if let price = price {
                        Text("$") + Text(String(describing: price))
                            .font(.forestBodyMedium)
                            .foregroundColor(.luxeGold)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.modaicsSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
        )
    }
}

// MARK: - Sustainability Badge
struct SustainabilityBadge: View {
    let score: Int
    
    var color: Color {
        switch score {
        case 80...100: return .modaicsEco
        case 60..<80: return .modaicsFern
        case 40..<60: return .luxeGold
        default: return .sageMuted
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 8))
            Text("\(score)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
        }
        .foregroundColor(.modaicsBackground)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color)
        .cornerRadius(4)
    }
}

// MARK: - Preview Card for Create Flow
public struct PreviewCard: View {
    let images: [UIImage]
    let title: String
    let category: ModaicsCategory?
    let price: Decimal?
    let condition: ModaicsCondition?
    
    public var body: some View {
        VStack(spacing: 12) {
            // Image gallery
            if !images.isEmpty {
                TabView {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Rectangle()
                    .fill(Color.modaicsSurface)
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.sageMuted)
                            Text("NO IMAGES")
                                .font(.forestCaptionMedium)
                                .foregroundColor(.sageMuted)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Details
            VStack(alignment: .leading, spacing: 8) {
                Text(title.isEmpty ? "UNTITLED ITEM" : title)
                    .font(.forestHeadlineMedium)
                    .foregroundColor(title.isEmpty ? .sageMuted : .sageWhite)
                
                HStack {
                    if let category = category {
                        Text(category.displayName)
                            .font(.forestCaptionMedium)
                            .textCase(.uppercase)
                            .foregroundColor(.modaicsFern)
                    }
                    
                    if let condition = condition {
                        Text("•")
                            .foregroundColor(.sageMuted)
                        Text(condition.displayName)
                            .font(.forestCaptionMedium)
                            .textCase(.uppercase)
                            .foregroundColor(.sageMuted)
                    }
                }
                
                if let price = price, price > 0 {
                    HStack(spacing: 2) {
                        Text("$")
                            .font(.forestHeadlineSmall)
                        Text("\( NSDecimalNumber(decimal: price).stringValue)")
                            .font(.forestHeadlineSmall)
                    }
                    .foregroundColor(.luxeGold)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.modaicsSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
        )
    }
}

// MARK: - Condition Display Extension
extension ModaicsCondition {
    var displayName: String {
        switch self {
        case .newWithTags: return "NEW WITH TAGS"
        case .newWithoutTags: return "NEW"
        case .excellent: return "EXCELLENT"
        case .veryGood: return "VERY GOOD"
        case .good: return "GOOD"
        case .fair: return "FAIR"
        case .vintage: return "VINTAGE"
        case .needsRepair: return "NEEDS REPAIR"
        }
    }
}

extension ModaicsCategory {
    var displayName: String {
        switch self {
        case .tops: return "TOPS"
        case .bottoms: return "BOTTOMS"
        case .dresses: return "DRESSES"
        case .outerwear: return "OUTERWEAR"
        case .activewear: return "ACTIVEWEAR"
        case .loungewear: return "LOUNGEWEAR"
        case .formal: return "FORMAL"
        case .accessories: return "ACCESSORIES"
        case .shoes: return "SHOES"
        case .jewelry: return "JEWELRY"
        case .bags: return "BAGS"
        case .vintage: return "VINTAGE"
        case .other: return "OTHER"
        }
    }
}
