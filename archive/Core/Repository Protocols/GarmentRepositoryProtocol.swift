import Foundation

// MARK: - GarmentRepositoryProtocol
/// Repository protocol for garment data operations
/// Handles CRUD operations and specialized queries for garments
public protocol GarmentRepositoryProtocol: Sendable {
    
    // MARK: - CRUD Operations
    
    /// Get a garment by its ID
    func get(by id: UUID) async throws -> Garment
    
    /// Get multiple garments by their IDs
    func get(ids: [UUID]) async throws -> [Garment]
    
    /// Create a new garment
    func create(_ garment: Garment) async throws -> Garment
    
    /// Update an existing garment
    func update(_ garment: Garment) async throws -> Garment
    
    /// Delete a garment by ID
    func delete(id: UUID) async throws
    
    /// Check if a garment exists
    func exists(id: UUID) async throws -> Bool
    
    // MARK: - User-Specific Operations
    
    /// Get all garments owned by a user
    func getByOwner(userId: UUID) async throws -> [Garment]
    
    /// Get paginated garments for an owner
    func getByOwner(userId: UUID, page: Int, limit: Int) async throws -> PaginatedResult<Garment>
    
    /// Get garments owned by a user, filtered by listing status
    func getByOwner(userId: UUID, isListed: Bool) async throws -> [Garment]
    
    // MARK: - Listing Operations
    
    /// List a garment for exchange (sets isListed = true)
    func listGarment(id: UUID, exchangeType: ExchangeType, price: Decimal?) async throws -> Garment
    
    /// Delist a garment (sets isListed = false)
    func delistGarment(id: UUID) async throws -> Garment
    
    /// Update listing price
    func updatePrice(id: UUID, newPrice: Decimal?) async throws -> Garment
    
    // MARK: - Batch Operations
    
    /// Create multiple garments at once
    func createBatch(_ garments: [Garment]) async throws -> [Garment]
    
    /// Update multiple garments at once
    func updateBatch(_ garments: [Garment]) async throws -> [Garment]
    
    /// Delete multiple garments at once
    func deleteBatch(ids: [UUID]) async throws
    
    // MARK: - Search & Filter
    
    /// Search garments with a query string
    func search(query: String) async throws -> [Garment]
    
    /// Search within a user's garments
    func search(query: String, ownerId: UUID) async throws -> [Garment]
    
    /// Filter garments by criteria
    func filter(_ criteria: GarmentFilterCriteria) async throws -> [Garment]
    
    /// Get paginated filtered results
    func filter(_ criteria: GarmentFilterCriteria, page: Int, limit: Int) async throws -> PaginatedResult<Garment>
    
    // MARK: - Statistics
    
    /// Get count of garments for a user
    func countByOwner(userId: UUID) async throws -> Int
    
    /// Get count of listed garments for a user
    func countListedByOwner(userId: UUID) async throws -> Int
    
    /// Get total estimated value of a user's wardrobe
    func totalValueByOwner(userId: UUID) async throws -> Decimal
}

// MARK: - Filter Criteria

/// Criteria for filtering garments
public struct GarmentFilterCriteria: Hashable, Sendable {
    public var ownerId: UUID?
    public var isListed: Bool?
    public var exchangeType: ExchangeType?
    public var categories: [Category]?
    public var brands: [String]?
    public var colors: [String]?
    public var sizes: [String]?
    public var sizeSystem: SizeSystem?
    public var conditions: [Condition]?
    public var minPrice: Decimal?
    public var maxPrice: Decimal?
    public var styles: [String]?
    public var materials: [String]?
    public var eras: [Era]?
    public var location: Location?
    public var radiusKm: Double?
    public var sustainableOnly: Bool?
    public var luxuryOnly: Bool?
    public var vintageOnly: Bool?
    public var sortBy: GarmentSortOption
    public var sortOrder: SortOrder
    
    public init(
        ownerId: UUID? = nil,
        isListed: Bool? = nil,
        exchangeType: ExchangeType? = nil,
        categories: [Category]? = nil,
        brands: [String]? = nil,
        colors: [String]? = nil,
        sizes: [String]? = nil,
        sizeSystem: SizeSystem? = nil,
        conditions: [Condition]? = nil,
        minPrice: Decimal? = nil,
        maxPrice: Decimal? = nil,
        styles: [String]? = nil,
        materials: [String]? = nil,
        eras: [Era]? = nil,
        location: Location? = nil,
        radiusKm: Double? = nil,
        sustainableOnly: Bool? = nil,
        luxuryOnly: Bool? = nil,
        vintageOnly: Bool? = nil,
        sortBy: GarmentSortOption = .dateAdded,
        sortOrder: SortOrder = .descending
    ) {
        self.ownerId = ownerId
        self.isListed = isListed
        self.exchangeType = exchangeType
        self.categories = categories
        self.brands = brands
        self.colors = colors
        self.sizes = sizes
        self.sizeSystem = sizeSystem
        self.conditions = conditions
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.styles = styles
        self.materials = materials
        self.eras = eras
        self.location = location
        self.radiusKm = radiusKm
        self.sustainableOnly = sustainableOnly
        self.luxuryOnly = luxuryOnly
        self.vintageOnly = vintageOnly
        self.sortBy = sortBy
        self.sortOrder = sortOrder
    }
}

public enum GarmentSortOption: String, Hashable, Sendable {
    case dateAdded = "date_added"
    case price = "price"
    case priceAsc = "price_asc"
    case popularity = "popularity"
    case relevance = "relevance"
    case distance = "distance"
    case condition = "condition"
    case brand = "brand"
}

public enum SortOrder: String, Hashable, Sendable {
    case ascending = "asc"
    case descending = "desc"
}

// MARK: - Paginated Result

public struct PaginatedResult<T: Sendable>: Sendable {
    public let items: [T]
    public let totalCount: Int
    public let page: Int
    public let limit: Int
    public let hasMore: Bool
    
    public init(items: [T], totalCount: Int, page: Int, limit: Int) {
        self.items = items
        self.totalCount = totalCount
        self.page = page
        self.limit = limit
        self.hasMore = (page * limit) < totalCount
    }
}