import Foundation

// MARK: - DiscoveryRepositoryProtocol
/// Repository protocol for discovery and recommendation features
/// Handles personalized feeds, trending items, and matching algorithms
public protocol DiscoveryRepositoryProtocol: Sendable {
    
    // MARK: - Personalized Feeds
    
    /// Get personalized feed for a user
    func getPersonalizedFeed(for userId: UUID) async throws -> [Garment]
    
    /// Get paginated personalized feed
    func getPersonalizedFeed(for userId: UUID, page: Int, limit: Int) async throws -> PaginatedResult<Garment>
    
    /// Get "New Arrivals" feed
    func getNewArrivals(for userId: UUID?) async throws -> [Garment]
    
    /// Get trending items
    func getTrending(limit: Int) async throws -> [Garment]
    
    // MARK: - Style-Based Discovery
    
    /// Find items matching a user's style profile
    func findStyleMatches(for userId: UUID, limit: Int) async throws -> [Garment]
    
    /// Get items similar to a given garment
    func findSimilar(to garmentId: UUID, limit: Int) async throws -> [Garment]
    
    /// Get complementary items (completes the look)
    func findComplementary(to garmentId: UUID, limit: Int) async throws -> [Garment]
    
    // MARK: - User Discovery
    
    /// Find users with similar style
    func findSimilarUsers(to userId: UUID, limit: Int) async throws -> [User]
    
    /// Get suggested users to follow
    func getSuggestedUsers(for userId: UUID, limit: Int) async throws -> [User]
    
    /// Get popular/featured wardrobes
    func getFeaturedWardrobes(limit: Int) async throws -> [Wardrobe]
    
    // MARK: - Category & Collection Browsing
    
    /// Browse by category
    func browseBy(category: Category, page: Int, limit: Int) async throws -> PaginatedResult<Garment>
    
    /// Browse by aesthetic/style
    func browseBy(aesthetic: Aesthetic, page: Int, limit: Int) async throws -> PaginatedResult<Garment>
    
    /// Browse by brand
    func browseBy(brand: String, page: Int, limit: Int) async throws -> PaginatedResult<Garment>
    
    /// Get curated collections
    func getCuratedCollections() async throws -> [CuratedCollection]
    
    /// Get items in a curated collection
    func getCollectionItems(collectionId: UUID, page: Int, limit: Int) async throws -> PaginatedResult<Garment>
    
    // MARK: - Location-Based
    
    /// Get items near a location
    func getLocalItems(near location: Location, radiusKm: Double, limit: Int) async throws -> [Garment]
    
    /// Get local sellers
    func getLocalSellers(near location: Location, radiusKm: Double, limit: Int) async throws -> [User]
    
    // MARK: - Search
    
    /// Full-text search across all garments
    func search(query: String, filters: GarmentFilterCriteria?) async throws -> [Garment]
    
    /// Search with autocomplete suggestions
    func searchSuggestions(query: String, limit: Int) async throws -> [SearchSuggestion]
    
    /// Recent searches for a user
    func getRecentSearches(for userId: UUID, limit: Int) async throws -> [String]
    
    /// Clear recent searches
    func clearRecentSearches(for userId: UUID) async throws
    
    // MARK: - Matches & Interactions
    
    /// Record a user viewing a garment (for recommendations)
    func recordView(userId: UUID, garmentId: UUID) async throws
    
    /// Record a user favoriting a garment
    func recordFavorite(userId: UUID, garmentId: UUID) async throws
    
    /// Remove a favorite
    func removeFavorite(userId: UUID, garmentId: UUID) async throws
    
    /// Check if user has favorited a garment
    func isFavorited(userId: UUID, garmentId: UUID) async throws -> Bool
    
    /// Get user's favorites
    func getUserFavorites(userId: UUID, page: Int, limit: Int) async throws -> PaginatedResult<Garment>
    
    /// Get users who favorited a garment
    func getGarmentFavoritedBy(garmentId: UUID, limit: Int) async throws -> [User]
    
    // MARK: - Trade Matching
    
    /// Find potential trade matches for a user's items
    func findTradeMatches(for userId: UUID) async throws -> [TradeMatch]
    
    /// Get potential trade partners for a specific item
    func findTradePartners(for garmentId: UUID) async throws -> [TradePartner]
    
    // MARK: - Analytics
    
    /// Get popular searches
    func getPopularSearches(limit: Int) async throws -> [String]
    
    /// Get trending categories
    func getTrendingCategories(limit: Int) async throws -> [CategoryTrend]
    
    /// Get trending brands
    func getTrendingBrands(limit: Int) async throws -> [BrandTrend]
}

// MARK: - Supporting Types

public struct CuratedCollection: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var title: String
    public var description: String
    public var coverImageURL: URL?
    public var curatorId: UUID?
    public var itemCount: Int
    public var featured: Bool
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        coverImageURL: URL? = nil,
        curatorId: UUID? = nil,
        itemCount: Int = 0,
        featured: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.coverImageURL = coverImageURL
        self.curatorId = curatorId
        self.itemCount = itemCount
        self.featured = featured
        self.createdAt = createdAt
    }
}

public struct SearchSuggestion: Codable, Hashable, Sendable {
    public var text: String
    public var type: SuggestionType
    public var metadata: [String: String]?
    
    public init(text: String, type: SuggestionType, metadata: [String: String]? = nil) {
        self.text = text
        self.type = type
        self.metadata = metadata
    }
}

public enum SuggestionType: String, Codable, Hashable, Sendable {
    case garment = "garment"
    case brand = "brand"
    case category = "category"
    case user = "user"
    case style = "style"
    case color = "color"
    case recent = "recent"
    case trending = "trending"
}

public struct TradeMatch: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var userGarmentId: UUID
    public var matchGarmentId: UUID
    public var matchOwnerId: UUID
    public var matchScore: Double // 0-100
    public var matchReasons: [MatchReason]
    public var potentialExchangeType: ExchangeType
    
    public init(
        id: UUID = UUID(),
        userGarmentId: UUID,
        matchGarmentId: UUID,
        matchOwnerId: UUID,
        matchScore: Double,
        matchReasons: [MatchReason] = [],
        potentialExchangeType: ExchangeType = .trade
    ) {
        self.id = id
        self.userGarmentId = userGarmentId
        self.matchGarmentId = matchGarmentId
        self.matchOwnerId = matchOwnerId
        self.matchScore = matchScore
        self.matchReasons = matchReasons
        self.potentialExchangeType = potentialExchangeType
    }
}

public struct MatchReason: Codable, Hashable, Sendable {
    public var type: MatchReasonType
    public var description: String
    
    public init(type: MatchReasonType, description: String) {
        self.type = type
        self.description = description
    }
}

public enum MatchReasonType: String, Codable, Hashable, Sendable {
    case styleCompatibility = "style_compatibility"
    case sizeMatch = "size_match"
    case brandPreference = "brand_preference"
    categoryMatch = "category_match"
    case colorHarmony = "color_harmony"
    case mutualInterest = "mutual_interest"
    case locationProximity = "location_proximity"
    case wishlistItem = "wishlist_item"
}

public struct TradePartner: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var user: User
    public var interestedInGarmentId: UUID
    public var offeredGarmentIds: [UUID]
    public var compatibilityScore: Double
    public var locationDistance: Double? // in km
    
    public init(
        id: UUID = UUID(),
        user: User,
        interestedInGarmentId: UUID,
        offeredGarmentIds: [UUID] = [],
        compatibilityScore: Double = 0,
        locationDistance: Double? = nil
    ) {
        self.id = id
        self.user = user
        self.interestedInGarmentId = interestedInGarmentId
        self.offeredGarmentIds = offeredGarmentIds
        self.compatibilityScore = compatibilityScore
        self.locationDistance = locationDistance
    }
}

public struct CategoryTrend: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var category: Category
    public var growthRate: Double // percentage change
    public var itemCount: Int
    
    public init(id: UUID = UUID(), category: Category, growthRate: Double, itemCount: Int) {
        self.id = id
        self.category = category
        self.growthRate = growthRate
        self.itemCount = itemCount
    }
}

public struct BrandTrend: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var brandName: String
    public var growthRate: Double
    public var searchCount: Int
    
    public init(id: UUID = UUID(), brandName: String, growthRate: Double, searchCount: Int) {
        self.id = id
        self.brandName = brandName
        self.growthRate = growthRate
        self.searchCount = searchCount
    }
}