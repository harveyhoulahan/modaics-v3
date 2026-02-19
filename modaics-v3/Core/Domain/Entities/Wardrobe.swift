import Foundation

// MARK: - Wardrobe
/// The Mosaic - a user's curated collection of garments
/// Represents their intentional, story-driven closet
public struct Wardrobe: Identifiable, Codable, Hashable {
    public let id: UUID
    
    // MARK: - Identity
    
    /// Owner of this wardrobe
    public var ownerId: UUID
    
    /// Custom name for the wardrobe
    public var name: String
    
    /// Public description/about
    public var description: String
    
    /// Is this wardrobe publicly viewable
    public var isPublic: Bool
    
    // MARK: - Collection
    
    /// All garment IDs in the wardrobe
    public var garmentIds: [UUID]
    
    /// Custom organization/collections within the wardrobe
    public var collections: [WardrobeCollection]
    
    /// Tags used for organization
    public var tags: [WardrobeTag]
    
    // MARK: - Statistics
    
    /// Total item count (cached for quick access)
    public var totalItems: Int
    
    /// Number of items currently listed for exchange
    public var listedItems: Int
    
    /// Estimated total value of the wardrobe
    public var estimatedValue: Decimal
    
    /// Estimated original retail value
    public var originalValue: Decimal
    
    /// Value saved by buying secondhand
    public var savingsValue: Decimal
    
    /// Carbon footprint offset
    public var carbonSavedKg: Double
    
    /// Water saved in liters
    public var waterSavedLiters: Double
    
    /// Items given second life (kept from landfill)
    public var itemsCirculated: Int
    
    // MARK: - Style Analysis
    
    /// AI-generated style insights
    public var styleInsights: StyleInsights?
    
    /// Color palette analysis
    public var colorPalette: [ColorFrequency]
    
    /// Brand distribution
    public var brandBreakdown: [BrandFrequency]
    
    /// Category distribution
    public var categoryBreakdown: [CategoryFrequency]
    
    /// Most worn/liked items
    public var favoriteItems: [UUID]
    
    /// Wardrobe gaps identified
    public var suggestedAdditions: [WardrobeSuggestion]
    
    /// Items that could be listed
    public var listingSuggestions: [UUID]
    
    // MARK: - Metadata
    
    /// When the wardrobe was created
    public var createdAt: Date
    
    /// Last update time
    public var updatedAt: Date
    
    /// Last time style analysis was run
    public var lastAnalyzedAt: Date?
    
    /// View count (if public)
    public var viewCount: Int
    
    /// Save/bookmark count
    public var saveCount: Int
    
    public init(
        id: UUID = UUID(),
        ownerId: UUID,
        name: String,
        description: String = "",
        isPublic: Bool = false,
        garmentIds: [UUID] = [],
        collections: [WardrobeCollection] = [],
        tags: [WardrobeTag] = [],
        totalItems: Int = 0,
        listedItems: Int = 0,
        estimatedValue: Decimal = 0,
        originalValue: Decimal = 0,
        savingsValue: Decimal = 0,
        carbonSavedKg: Double = 0,
        waterSavedLiters: Double = 0,
        itemsCirculated: Int = 0,
        styleInsights: StyleInsights? = nil,
        colorPalette: [ColorFrequency] = [],
        brandBreakdown: [BrandFrequency] = [],
        categoryBreakdown: [CategoryFrequency] = [],
        favoriteItems: [UUID] = [],
        suggestedAdditions: [WardrobeSuggestion] = [],
        listingSuggestions: [UUID] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastAnalyzedAt: Date? = nil,
        viewCount: Int = 0,
        saveCount: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.description = description
        self.isPublic = isPublic
        self.garmentIds = garmentIds
        self.collections = collections
        self.tags = tags
        self.totalItems = totalItems
        self.listedItems = listedItems
        self.estimatedValue = estimatedValue
        self.originalValue = originalValue
        self.savingsValue = savingsValue
        self.carbonSavedKg = carbonSavedKg
        self.waterSavedLiters = waterSavedLiters
        self.itemsCirculated = itemsCirculated
        self.styleInsights = styleInsights
        self.colorPalette = colorPalette
        self.brandBreakdown = brandBreakdown
        self.categoryBreakdown = categoryBreakdown
        self.favoriteItems = favoriteItems
        self.suggestedAdditions = suggestedAdditions
        self.listingSuggestions = listingSuggestions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastAnalyzedAt = lastAnalyzedAt
        self.viewCount = viewCount
        self.saveCount = saveCount
    }
}

// MARK: - Supporting Types

public struct WardrobeCollection: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var description: String
    public var garmentIds: [UUID]
    public var coverImageURL: URL?
    public var isSmartCollection: Bool
    public var smartCriteria: SmartCriteria?
    public var sortOrder: Int
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        garmentIds: [UUID] = [],
        coverImageURL: URL? = nil,
        isSmartCollection: Bool = false,
        smartCriteria: SmartCriteria? = nil,
        sortOrder: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.garmentIds = garmentIds
        self.coverImageURL = coverImageURL
        self.isSmartCollection = isSmartCollection
        self.smartCriteria = smartCriteria
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
}

public struct SmartCriteria: Codable, Hashable {
    public var categories: [Category]?
    public var colors: [String]?
    public var brands: [String]?
    public var conditions: [Condition]?
    public var tags: [String]?
    public var dateAddedAfter: Date?
    public var dateAddedBefore: Date?
    
    public init(
        categories: [Category]? = nil,
        colors: [String]? = nil,
        brands: [String]? = nil,
        conditions: [Condition]? = nil,
        tags: [String]? = nil,
        dateAddedAfter: Date? = nil,
        dateAddedBefore: Date? = nil
    ) {
        self.categories = categories
        self.colors = colors
        self.brands = brands
        self.conditions = conditions
        self.tags = tags
        self.dateAddedAfter = dateAddedAfter
        self.dateAddedBefore = dateAddedBefore
    }
}

public struct WardrobeTag: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var color: String
    public var garmentCount: Int
    
    public init(id: UUID = UUID(), name: String, color: String = "#6B7280", garmentCount: Int = 0) {
        self.id = id
        self.name = name
        self.color = color
        self.garmentCount = garmentCount
    }
}

public struct StyleInsights: Codable, Hashable {
    public var dominantAesthetic: Aesthetic?
    public var styleProfile: String
    public var cohesionScore: Double // 0-100
    public var versatilityScore: Double // 0-100
    public var sustainabilityScore: Double // 0-100
    public var keyPieces: [UUID]
    public var styleKeywords: [String]
    public var seasonalReadiness: [Season: Double]
    public var outfitSuggestions: [OutfitSuggestion]
    
    public init(
        dominantAesthetic: Aesthetic? = nil,
        styleProfile: String = "",
        cohesionScore: Double = 0,
        versatilityScore: Double = 0,
        sustainabilityScore: Double = 0,
        keyPieces: [UUID] = [],
        styleKeywords: [String] = [],
        seasonalReadiness: [Season: Double] = [:],
        outfitSuggestions: [OutfitSuggestion] = []
    ) {
        self.dominantAesthetic = dominantAesthetic
        self.styleProfile = styleProfile
        self.cohesionScore = cohesionScore
        self.versatilityScore = versatilityScore
        self.sustainabilityScore = sustainabilityScore
        self.keyPieces = keyPieces
        self.styleKeywords = styleKeywords
        self.seasonalReadiness = seasonalReadiness
        self.outfitSuggestions = outfitSuggestions
    }
}

public enum Season: String, Codable, CaseIterable, Hashable {
    case spring = "spring"
    case summer = "summer"
    case fall = "fall"
    case winter = "winter"
}

public struct OutfitSuggestion: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var garmentIds: [UUID]
    public var occasion: String
    public var weather: String?
    public var notes: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        garmentIds: [UUID],
        occasion: String,
        weather: String? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.garmentIds = garmentIds
        self.occasion = occasion
        self.weather = weather
        self.notes = notes
    }
}

public struct ColorFrequency: Codable, Hashable, Identifiable {
    public let id: UUID
    public var color: String
    public var hex: String?
    public var count: Int
    public var percentage: Double
    
    public init(id: UUID = UUID(), color: String, hex: String? = nil, count: Int, percentage: Double) {
        self.id = id
        self.color = color
        self.hex = hex
        self.count = count
        self.percentage = percentage
    }
}

public struct BrandFrequency: Codable, Hashable, Identifiable {
    public let id: UUID
    public var brandName: String
    public var count: Int
    public var percentage: Double
    
    public init(id: UUID = UUID(), brandName: String, count: Int, percentage: Double) {
        self.id = id
        self.brandName = brandName
        self.count = count
        self.percentage = percentage
    }
}

public struct CategoryFrequency: Codable, Hashable, Identifiable {
    public let id: UUID
    public var category: Category
    public var count: Int
    public var percentage: Double
    
    public init(id: UUID = UUID(), category: Category, count: Int, percentage: Double) {
        self.id = id
        self.category = category
        self.count = count
        self.percentage = percentage
    }
}

public struct WardrobeSuggestion: Identifiable, Codable, Hashable {
    public let id: UUID
    public var category: Category
    public var description: String
    public var reason: String
    public var priority: SuggestionPriority
    public var examples: [String]
    
    public init(
        id: UUID = UUID(),
        category: Category,
        description: String,
        reason: String,
        priority: SuggestionPriority = .medium,
        examples: [String] = []
    ) {
        self.id = id
        self.category = category
        self.description = description
        self.reason = reason
        self.priority = priority
        self.examples = examples
    }
}

public enum SuggestionPriority: String, Codable, CaseIterable, Hashable {
    case low = "low"
    case medium = "medium"
    case high = "high"
}

// MARK: - Sample Data

public extension Wardrobe {
    static let sample = Wardrobe(
        ownerId: UUID(),
        name: "Elara's Intentional Collection",
        description: "A curated wardrobe built over 5 years of intentional acquisition. Every piece has a story.",
        isPublic: true,
        garmentIds: [UUID(), UUID(), UUID()],
        collections: [
            WardrobeCollection(
                name: "Vintage Finds",
                description: "Pre-2000 pieces with history",
                garmentIds: [UUID()],
                sortOrder: 0
            ),
            WardrobeCollection(
                name: "Special Occasion",
                description: "Wedding guests, galas, and celebrations",
                garmentIds: [UUID()],
                sortOrder: 1
            ),
            WardrobeCollection(
                name: "Everyday Staples",
                description: "The workhorses of my wardrobe",
                isSmartCollection: true,
                smartCriteria: SmartCriteria(conditions: [.excellent, .veryGood, .good])
            )
        ],
        tags: [
            WardrobeTag(name: "Favorites", color: "#F59E0B", garmentCount: 12),
            WardrobeTag(name: "To Sell", color: "#EF4444", garmentCount: 5),
            WardrobeTag(name: "Repairs Needed", color: "#8B5CF6", garmentCount: 2)
        ],
        totalItems: 47,
        listedItems: 5,
        estimatedValue: 8750.00,
        originalValue: 15200.00,
        savingsValue: 6450.00,
        carbonSavedKg: 850.5,
        waterSavedLiters: 42500,
        itemsCirculated: 23,
        styleInsights: StyleInsights(
            dominantAesthetic: .vintage,
            styleProfile: "Curated vintage-modern with sustainable luxury touches",
            cohesionScore: 85,
            versatilityScore: 78,
            sustainabilityScore: 92,
            styleKeywords: ["Vintage", "Minimalist", "Quality over quantity", "Neutral palette"],
            seasonalReadiness: [
                .spring: 0.75,
                .summer: 0.60,
                .fall: 0.95,
                .winter: 0.80
            ]
        ),
        colorPalette: [
            ColorFrequency(color: "Black", hex: "#1a1a1a", count: 15, percentage: 32),
            ColorFrequency(color: "Cream", hex: "#FFFDD0", count: 8, percentage: 17),
            ColorFrequency(color: "Navy", hex: "#000080", count: 6, percentage: 13),
            ColorFrequency(color: "Rust", hex: "#B7410E", count: 4, percentage: 9)
        ],
        categoryBreakdown: [
            CategoryFrequency(category: .tops, count: 18, percentage: 38),
            CategoryFrequency(category: .bottoms, count: 12, percentage: 26),
            CategoryFrequency(category: .outerwear, count: 6, percentage: 13),
            CategoryFrequency(category: .dresses, count: 8, percentage: 17)
        ],
        suggestedAdditions: [
            WardrobeSuggestion(
                category: .shoes,
                description: "Classic leather ankle boots in tan or cognac",
                reason: "Current shoe collection lacks versatile neutral boots for transitional weather",
                priority: .high,
                examples: ["Chelsea boots", "Stacked heel ankle boots"]
            ),
            WardrobeSuggestion(
                category: .accessories,
                description: "Quality leather belt in black or cognac",
                reason: "Only one belt currently - limits styling options",
                priority: .medium
            )
        ]
    )
}