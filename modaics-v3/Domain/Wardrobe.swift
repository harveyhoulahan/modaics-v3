import Foundation

// MARK: - ModaicsWardrobe
/// The Mosaic - a user's curated collection of garments
/// Represents their intentional, story-driven closet
public struct ModaicsWardrobe: Identifiable, Codable, Hashable {
    public let id: UUID
    
    public var ownerId: UUID
    public var name: String
    public var description: String
    public var isPublic: Bool
    
    public var garmentIds: [UUID]
    public var collections: [ModaicsWardrobeCollection]
    public var tags: [ModaicsWardrobeTag]
    
    public var totalItems: Int
    public var listedItems: Int
    public var estimatedValue: Decimal
    public var originalValue: Decimal
    public var savingsValue: Decimal
    public var carbonSavedKg: Double
    public var waterSavedLiters: Double
    public var itemsCirculated: Int
    
    public var styleInsights: ModaicsStyleInsights?
    public var colorPalette: [ModaicsColorFrequency]
    public var brandBreakdown: [ModaicsBrandFrequency]
    public var categoryBreakdown: [ModaicsCategoryFrequency]
    public var favoriteItems: [UUID]
    public var suggestedAdditions: [ModaicsWardrobeSuggestion]
    public var listingSuggestions: [UUID]
    
    public var createdAt: Date
    public var updatedAt: Date
    public var lastAnalyzedAt: Date?
    public var viewCount: Int
    public var saveCount: Int
    
    public init(
        id: UUID = UUID(),
        ownerId: UUID,
        name: String,
        description: String = "",
        isPublic: Bool = false,
        garmentIds: [UUID] = [],
        collections: [ModaicsWardrobeCollection] = [],
        tags: [ModaicsWardrobeTag] = [],
        totalItems: Int = 0,
        listedItems: Int = 0,
        estimatedValue: Decimal = 0,
        originalValue: Decimal = 0,
        savingsValue: Decimal = 0,
        carbonSavedKg: Double = 0,
        waterSavedLiters: Double = 0,
        itemsCirculated: Int = 0,
        styleInsights: ModaicsStyleInsights? = nil,
        colorPalette: [ModaicsColorFrequency] = [],
        brandBreakdown: [ModaicsBrandFrequency] = [],
        categoryBreakdown: [ModaicsCategoryFrequency] = [],
        favoriteItems: [UUID] = [],
        suggestedAdditions: [ModaicsWardrobeSuggestion] = [],
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

public struct ModaicsWardrobeCollection: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var description: String
    public var garmentIds: [UUID]
    public var coverImageURL: URL?
    public var isSmartCollection: Bool
    public var smartCriteria: ModaicsSmartCriteria?
    public var sortOrder: Int
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        garmentIds: [UUID] = [],
        coverImageURL: URL? = nil,
        isSmartCollection: Bool = false,
        smartCriteria: ModaicsSmartCriteria? = nil,
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

public struct ModaicsSmartCriteria: Codable, Hashable {
    public var categories: [ModaicsCategory]?
    public var colors: [String]?
    public var brands: [String]?
    public var conditions: [ModaicsCondition]?
    public var tags: [String]?
    public var dateAddedAfter: Date?
    public var dateAddedBefore: Date?
    
    public init(
        categories: [ModaicsCategory]? = nil,
        colors: [String]? = nil,
        brands: [String]? = nil,
        conditions: [ModaicsCondition]? = nil,
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

public struct ModaicsWardrobeTag: Identifiable, Codable, Hashable {
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

public struct ModaicsStyleInsights: Codable, Hashable {
    public var dominantAesthetic: ModaicsAesthetic?
    public var styleProfile: String
    public var cohesionScore: Double
    public var versatilityScore: Double
    public var sustainabilityScore: Double
    public var keyPieces: [UUID]
    public var styleKeywords: [String]
    public var seasonalReadiness: [ModaicsSeason: Double]
    public var outfitSuggestions: [ModaicsOutfitSuggestion]
    
    public init(
        dominantAesthetic: ModaicsAesthetic? = nil,
        styleProfile: String = "",
        cohesionScore: Double = 0,
        versatilityScore: Double = 0,
        sustainabilityScore: Double = 0,
        keyPieces: [UUID] = [],
        styleKeywords: [String] = [],
        seasonalReadiness: [ModaicsSeason: Double] = [:],
        outfitSuggestions: [ModaicsOutfitSuggestion] = []
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

public enum ModaicsSeason: String, Codable, CaseIterable, Hashable {
    case spring = "spring"
    case summer = "summer"
    case fall = "fall"
    case winter = "winter"
}

public struct ModaicsOutfitSuggestion: Identifiable, Codable, Hashable {
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

public struct ModaicsColorFrequency: Codable, Hashable, Identifiable {
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

public struct ModaicsBrandFrequency: Codable, Hashable, Identifiable {
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

public struct ModaicsCategoryFrequency: Codable, Hashable, Identifiable {
    public let id: UUID
    public var category: ModaicsCategory
    public var count: Int
    public var percentage: Double
    
    public init(id: UUID = UUID(), category: ModaicsCategory, count: Int, percentage: Double) {
        self.id = id
        self.category = category
        self.count = count
        self.percentage = percentage
    }
}

public struct ModaicsWardrobeSuggestion: Identifiable, Codable, Hashable {
    public let id: UUID
    public var category: ModaicsCategory
    public var description: String
    public var reason: String
    public var priority: ModaicsSuggestionPriority
    public var examples: [String]
    
    public init(
        id: UUID = UUID(),
        category: ModaicsCategory,
        description: String,
        reason: String,
        priority: ModaicsSuggestionPriority = .medium,
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

public enum ModaicsSuggestionPriority: String, Codable, CaseIterable, Hashable {
    case low = "low"
    case medium = "medium"
    case high = "high"
}
