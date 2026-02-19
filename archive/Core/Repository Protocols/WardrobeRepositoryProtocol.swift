import Foundation

// MARK: - WardrobeRepositoryProtocol
/// Repository protocol for wardrobe management operations
/// Handles wardrobe CRUD, collections, and analytics
public protocol WardrobeRepositoryProtocol: Sendable {
    
    // MARK: - Wardrobe CRUD
    
    /// Get wardrobe by ID
    func get(by id: UUID) async throws -> Wardrobe
    
    /// Get wardrobe by owner ID
    func getByOwner(userId: UUID) async throws -> Wardrobe
    
    /// Create a new wardrobe
    func create(_ wardrobe: Wardrobe) async throws -> Wardrobe
    
    /// Update a wardrobe
    func update(_ wardrobe: Wardrobe) async throws -> Wardrobe
    
    /// Delete a wardrobe
    func delete(id: UUID) async throws
    
    /// Check if user has a wardrobe
    func existsForUser(userId: UUID) async throws -> Bool
    
    // MARK: - Garment Management
    
    /// Add a garment to wardrobe
    func addGarment(wardrobeId: UUID, garmentId: UUID) async throws -> Wardrobe
    
    /// Remove a garment from wardrobe
    func removeGarment(wardrobeId: UUID, garmentId: UUID) async throws -> Wardrobe
    
    /// Add multiple garments at once
    func addGarments(wardrobeId: UUID, garmentIds: [UUID]) async throws -> Wardrobe
    
    /// Remove multiple garments at once
    func removeGarments(wardrobeId: UUID, garmentIds: [UUID]) async throws -> Wardrobe
    
    /// Move garment to another collection
    func moveGarment(garmentId: UUID, from: UUID?, to: UUID?) async throws
    
    /// Check if garment is in wardrobe
    func contains(wardrobeId: UUID, garmentId: UUID) async throws -> Bool
    
    // MARK: - Collections
    
    /// Create a new collection
    func createCollection(wardrobeId: UUID, collection: WardrobeCollection) async throws -> WardrobeCollection
    
    /// Update a collection
    func updateCollection(wardrobeId: UUID, collection: WardrobeCollection) async throws -> WardrobeCollection
    
    /// Delete a collection
    func deleteCollection(wardrobeId: UUID, collectionId: UUID) async throws
    
    /// Add garment to collection
    func addToCollection(collectionId: UUID, garmentId: UUID) async throws
    
    /// Remove garment from collection
    func removeFromCollection(collectionId: UUID, garmentId: UUID) async throws
    
    /// Reorder collections
    func reorderCollections(wardrobeId: UUID, collectionIds: [UUID]) async throws
    
    /// Get garments in a collection
    func getCollectionGarments(collectionId: UUID) async throws -> [Garment]
    
    // MARK: - Tags
    
    /// Create a new tag
    func createTag(wardrobeId: UUID, tag: WardrobeTag) async throws -> WardrobeTag
    
    /// Update a tag
    func updateTag(wardrobeId: UUID, tag: WardrobeTag) async throws -> WardrobeTag
    
    /// Delete a tag
    func deleteTag(wardrobeId: UUID, tagId: UUID) async throws
    
    /// Tag a garment
    func tagGarment(wardrobeId: UUID, garmentId: UUID, tagId: UUID) async throws
    
    /// Untag a garment
    func untagGarment(wardrobeId: UUID, garmentId: UUID, tagId: UUID) async throws
    
    /// Get garments by tag
    func getGarmentsByTag(tagId: UUID) async throws -> [Garment]
    
    // MARK: - Style Insights
    
    /// Get or generate style insights
    func getStyleInsights(wardrobeId: UUID) async throws -> StyleInsights
    
    /// Refresh style insights (recalculate)
    func refreshStyleInsights(wardrobeId: UUID) async throws -> StyleInsights
    
    /// Get color palette analysis
    func getColorPalette(wardrobeId: UUID) async throws -> [ColorFrequency]
    
    /// Get brand breakdown
    func getBrandBreakdown(wardrobeId: UUID) async throws -> [BrandFrequency]
    
    /// Get category breakdown
    func getCategoryBreakdown(wardrobeId: UUID) async throws -> [CategoryFrequency]
    
    /// Get wardrobe suggestions
    func getSuggestions(wardrobeId: UUID) async throws -> [WardrobeSuggestion]
    
    /// Get listing suggestions
    func getListingSuggestions(wardrobeId: UUID) async throws -> [Garment]
    
    // MARK: - Outfit Suggestions
    
    /// Get AI-generated outfit suggestions
    func getOutfitSuggestions(wardrobeId: UUID, occasion: String?, weather: String?) async throws -> [OutfitSuggestion]
    
    /// Save a custom outfit
    func saveOutfit(wardrobeId: UUID, outfit: OutfitSuggestion) async throws -> OutfitSuggestion
    
    /// Delete a saved outfit
    func deleteOutfit(wardrobeId: UUID, outfitId: UUID) async throws
    
    /// Get saved outfits
    func getSavedOutfits(wardrobeId: UUID) async throws -> [OutfitSuggestion]
    
    // MARK: - Public Wardrobes
    
    /// Get public wardrobes
    func getPublicWardrobes(page: Int, limit: Int) async throws -> PaginatedResult<Wardrobe>
    
    /// Get featured/public wardrobe by ID
    func getPublicWardrobe(id: UUID) async throws -> Wardrobe
    
    /// Search public wardrobes
    func searchPublicWardrobes(query: String, page: Int, limit: Int) async throws -> PaginatedResult<Wardrobe>
    
    /// Record a view of a public wardrobe
    func recordView(wardrobeId: UUID, viewerId: UUID?) async throws
    
    /// Record a save of a public wardrobe
    func recordSave(wardrobeId: UUID, userId: UUID) async throws
    
    /// Remove a save
    func removeSave(wardrobeId: UUID, userId: UUID) async throws
    
    // MARK: - Statistics
    
    /// Get wardrobe statistics
    func getStatistics(wardrobeId: UUID) async throws -> WardrobeStatistics
    
    /// Get sustainability impact
    func getSustainabilityImpact(wardrobeId: UUID) async throws -> SustainabilityImpact
    
    /// Get value analysis
    func getValueAnalysis(wardrobeId: UUID) async throws -> ValueAnalysis
    
    /// Recalculate all statistics
    func recalculateStatistics(wardrobeId: UUID) async throws -> WardrobeStatistics
}

// MARK: - Statistics Types

public struct WardrobeStatistics: Codable, Hashable, Sendable {
    public var totalItems: Int
    public var listedItems: Int
    public var totalValue: Decimal
    public var originalValue: Decimal
    public var savingsValue: Decimal
    public var averageItemValue: Decimal
    public var mostValuableItemId: UUID?
    public var oldestItemDate: Date?
    public var newestItemDate: Date?
    public var itemsByCategory: [Category: Int]
    public var itemsByCondition: [Condition: Int]
    public var exchangeHistoryCount: Int
    public var totalViews: Int
    public var totalSaves: Int
    
    public init(
        totalItems: Int = 0,
        listedItems: Int = 0,
        totalValue: Decimal = 0,
        originalValue: Decimal = 0,
        savingsValue: Decimal = 0,
        averageItemValue: Decimal = 0,
        mostValuableItemId: UUID? = nil,
        oldestItemDate: Date? = nil,
        newestItemDate: Date? = nil,
        itemsByCategory: [Category: Int] = [:],
        itemsByCondition: [Condition: Int] = [:],
        exchangeHistoryCount: Int = 0,
        totalViews: Int = 0,
        totalSaves: Int = 0
    ) {
        self.totalItems = totalItems
        self.listedItems = listedItems
        self.totalValue = totalValue
        self.originalValue = originalValue
        self.savingsValue = savingsValue
        self.averageItemValue = averageItemValue
        self.mostValuableItemId = mostValuableItemId
        self.oldestItemDate = oldestItemDate
        self.newestItemDate = newestItemDate
        self.itemsByCategory = itemsByCategory
        self.itemsByCondition = itemsByCondition
        self.exchangeHistoryCount = exchangeHistoryCount
        self.totalViews = totalViews
        self.totalSaves = totalSaves
    }
}

public struct SustainabilityImpact: Codable, Hashable, Sendable {
    public var carbonSavedKg: Double
    public var waterSavedLiters: Double
    public var itemsKeptFromLandfill: Int
    public var packagingSaved: Int // number of new packages avoided
    public var treesEquivalent: Double // trees worth of carbon offset
    public var milesNotDriven: Double // equivalent miles not driven
    
    public init(
        carbonSavedKg: Double = 0,
        waterSavedLiters: Double = 0,
        itemsKeptFromLandfill: Int = 0,
        packagingSaved: Int = 0,
        treesEquivalent: Double = 0,
        milesNotDriven: Double = 0
    ) {
        self.carbonSavedKg = carbonSavedKg
        self.waterSavedLiters = waterSavedLiters
        self.itemsKeptFromLandfill = itemsKeptFromLandfill
        self.packagingSaved = packagingSaved
        self.treesEquivalent = treesEquivalent
        self.milesNotDriven = milesNotDriven
    }
}

public struct ValueAnalysis: Codable, Hashable, Sendable {
    public var currentEstimatedValue: Decimal
    public var originalPurchaseValue: Decimal
    public var totalSavings: Decimal
    public var savingsPercentage: Double
    public var potentialResaleValue: Decimal
    public var valueRetentionRate: Double
    public var appreciationItems: [UUID] // items worth more now
    public var depreciationItems: [UUID] // items worth less
    
    public init(
        currentEstimatedValue: Decimal = 0,
        originalPurchaseValue: Decimal = 0,
        totalSavings: Decimal = 0,
        savingsPercentage: Double = 0,
        potentialResaleValue: Decimal = 0,
        valueRetentionRate: Double = 0,
        appreciationItems: [UUID] = [],
        depreciationItems: [UUID] = []
    ) {
        self.currentEstimatedValue = currentEstimatedValue
        self.originalPurchaseValue = originalPurchaseValue
        self.totalSavings = totalSavings
        self.savingsPercentage = savingsPercentage
        self.potentialResaleValue = potentialResaleValue
        self.valueRetentionRate = valueRetentionRate
        self.appreciationItems = appreciationItems
        self.depreciationItems = depreciationItems
    }
}