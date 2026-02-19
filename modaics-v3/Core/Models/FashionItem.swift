import Foundation

// MARK: - Category Enum
// Shared with Create page - must match exactly
public enum Category: String, CaseIterable, Codable, Identifiable {
    case tops = "TOPS"
    case bottoms = "BOTTOMS"
    case outerwear = "OUTERWEAR"
    case dresses = "DRESSES"
    case shoes = "SHOES"
    case accessories = "ACCESSORIES"
    case bags = "BAGS"
    case activewear = "ACTIVEWEAR"
    case swimwear = "SWIMWEAR"
    case formal = "FORMAL"
    case vintage = "VINTAGE"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .tops: return "tshirt"
        case .bottoms: return "arrow.down.circle"
        case .outerwear: return "jacket"
        case .dresses: return "person.fill"
        case .shoes: return "shoe"
        case .accessories: return "eyeglasses"
        case .bags: return "bag"
        case .activewear: return "figure.run"
        case .swimwear: return "water.waves"
        case .formal: return "crown"
        case .vintage: return "clock.arrow.circlepath"
        }
    }
    
    public var displayName: String {
        switch self {
        case .tops: return "TOPS"
        case .bottoms: return "BOTTOMS"
        case .outerwear: return "OUTERWEAR"
        case .dresses: return "DRESSES"
        case .shoes: return "SHOES"
        case .accessories: return "ACCESSORIES"
        case .bags: return "BAGS"
        case .activewear: return "ACTIVEWEAR"
        case .swimwear: return "SWIMWEAR"
        case .formal: return "FORMAL"
        case .vintage: return "VINTAGE"
        }
    }
}

// MARK: - Condition Enum
// Shared with Create page - must match exactly
public enum Condition: String, CaseIterable, Codable, Identifiable {
    case new = "NEW"
    case likeNew = "LIKE_NEW"
    case excellent = "EXCELLENT"
    case good = "GOOD"
    case fair = "FAIR"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .new: return "NEW WITH TAGS"
        case .likeNew: return "LIKE NEW"
        case .excellent: return "EXCELLENT"
        case .good: return "GOOD"
        case .fair: return "FAIR"
        }
    }
    
    public var shortName: String {
        switch self {
        case .new: return "NEW"
        case .likeNew: return "LIKE NEW"
        case .excellent: return "EXCELLENT"
        case .good: return "GOOD"
        case .fair: return "FAIR"
        }
    }
}

// MARK: - Size Enum
public enum Size: String, CaseIterable, Codable, Identifiable {
    case xs = "XS"
    case s = "S"
    case m = "M"
    case l = "L"
    case xl = "XL"
    case xxl = "XXL"
    case xxxl = "XXXL"
    case os = "ONE SIZE"
    
    // Shoe sizes
    case w5 = "W 5"
    case w6 = "W 6"
    case w7 = "W 7"
    case w8 = "W 8"
    case w9 = "W 9"
    case w10 = "W 10"
    case w11 = "W 11"
    case m7 = "M 7"
    case m8 = "M 8"
    case m9 = "M 9"
    case m10 = "M 10"
    case m11 = "M 11"
    case m12 = "M 12"
    
    public var id: String { rawValue }
    
    public var displayName: String { rawValue }
}

// MARK: - FashionItem Model
// Shared with Create page
public struct FashionItem: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let brand: String
    public let name: String
    public let description: String
    public let price: Double
    public let originalPrice: Double?
    public let category: Category
    public let condition: Condition
    public let size: Size
    public let images: [String]
    public let sellerId: String
    public let sellerName: String
    public let sellerAvatar: String?
    public let sustainabilityScore: Int // 0-100
    public let materials: [String]
    public let isVintage: Bool
    public let isRecycled: Bool
    public let createdAt: Date
    public let likes: Int
    public let isLiked: Bool
    
    public init(
        id: String,
        brand: String,
        name: String,
        description: String,
        price: Double,
        originalPrice: Double? = nil,
        category: Category,
        condition: Condition,
        size: Size,
        images: [String],
        sellerId: String,
        sellerName: String,
        sellerAvatar: String? = nil,
        sustainabilityScore: Int = 0,
        materials: [String] = [],
        isVintage: Bool = false,
        isRecycled: Bool = false,
        createdAt: Date = Date(),
        likes: Int = 0,
        isLiked: Bool = false
    ) {
        self.id = id
        self.brand = brand
        self.name = name
        self.description = description
        self.price = price
        self.originalPrice = originalPrice
        self.category = category
        self.condition = condition
        self.size = size
        self.images = images
        self.sellerId = sellerId
        self.sellerName = sellerName
        self.sellerAvatar = sellerAvatar
        self.sustainabilityScore = sustainabilityScore
        self.materials = materials
        self.isVintage = isVintage
        self.isRecycled = isRecycled
        self.createdAt = createdAt
        self.likes = likes
        self.isLiked = isLiked
    }
    
    public var formattedPrice: String {
        String(format: "$%.0f", price)
    }
    
    public var formattedOriginalPrice: String? {
        guard let originalPrice = originalPrice else { return nil }
        return String(format: "$%.0f", originalPrice)
    }
    
    public var discountPercentage: Int? {
        guard let originalPrice = originalPrice, originalPrice > price else { return nil }
        return Int(((originalPrice - price) / originalPrice) * 100)
    }
    
    public var sustainabilityBadge: String? {
        if sustainabilityScore >= 80 {
            return "ECO-EXCELLENT"
        } else if sustainabilityScore >= 60 {
            return "ECO-FRIENDLY"
        } else if isVintage || isRecycled {
            return "SUSTAINABLE"
        }
        return nil
    }
    
    // Mock data for preview/testing
    public static let sampleItems: [FashionItem] = [
        FashionItem(
            id: "1",
            brand: "REISS",
            name: "WOOL BLEND OVERCOAT",
            description: "Classic wool blend overcoat in camel",
            price: 245,
            originalPrice: 450,
            category: .outerwear,
            condition: .excellent,
            size: .m,
            images: ["https://example.com/coat1.jpg"],
            sellerId: "user1",
            sellerName: "StyleCurator",
            sustainabilityScore: 75,
            materials: ["Wool", "Cashmere"],
            isVintage: false,
            isRecycled: false,
            likes: 42,
            isLiked: true
        ),
        FashionItem(
            id: "2",
            brand: "GANNI",
            name: "RECYCLED WOOL SWEATER",
            description: "Chunky knit sweater made from recycled wool",
            price: 180,
            originalPrice: 295,
            category: .tops,
            condition: .likeNew,
            size: .s,
            images: ["https://example.com/sweater1.jpg"],
            sellerId: "user2",
            sellerName: "EcoChic",
            sustainabilityScore: 92,
            materials: ["Recycled Wool"],
            isVintage: false,
            isRecycled: true,
            likes: 89,
            isLiked: false
        )
    ]
}