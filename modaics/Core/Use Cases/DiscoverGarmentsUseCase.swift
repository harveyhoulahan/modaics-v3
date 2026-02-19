import Foundation

// MARK: - DiscoverGarmentsUseCase
/// Use case for discovering garments in the Modaics ecosystem
/// Handles personalized feeds, search, and recommendation discovery
/// v3.5: Updated for visual search and multi-source support
public protocol DiscoverGarmentsUseCaseProtocol: Sendable {
    func execute(input: DiscoverGarmentsInput) async throws -> DiscoverGarmentsOutput
}

// MARK: - Input/Output Types

public struct DiscoverGarmentsInput: Sendable {
    public let userId: UUID?
    public let discoveryType: DiscoveryType
    public let page: Int
    public let limit: Int
    public let filters: DiscoveryFilters?
    public let sourceFilter: [GarmentSource] // v3.5: Source filtering
    
    public init(
        userId: UUID? = nil,
        discoveryType: DiscoveryType,
        page: Int = 1,
        limit: Int = 20,
        filters: DiscoveryFilters? = nil,
        sourceFilter: [GarmentSource] = [.modaics, .depop] // v3.5: Default to all sources
    ) {
        self.userId = userId
        self.discoveryType = discoveryType
        self.page = page
        self.limit = limit
        self.filters = filters
        self.sourceFilter = sourceFilter
    }
}

public enum DiscoveryType: Hashable, Sendable {
    case personalizedFeed
    case newArrivals
    case trending
    case category(Category)
    case aesthetic(Aesthetic)
    case similarTo(garmentId: UUID)
    case complementaryTo(garmentId: UUID)
    case styleMatches
    case search(query: String)
    case visualSearch(embedding: [Float]) // v3.5: Visual search
    case local(radiusKm: Double)
    case curatedCollection(collectionId: UUID)
    case byUser(userId: UUID)
    case following
}

public struct DiscoveryFilters: Sendable {
    public var categories: [Category]?
    public var sizes: [String]?
    public var sizeSystem: SizeSystem?
    public var priceRange: PriceRange?
    public var conditions: [Condition]?
    public var colors: [String]?
    public var brands: [String]?
    public var materials: [String]?
    public var sustainableOnly: Bool
    public var vintageOnly: Bool
    public var luxuryOnly: Bool
    public var exchangeType: ExchangeType?
    public var sortBy: GarmentSortOption
    public var sortOrder: SortOrder
    public var sources: [GarmentSource] // v3.5: Source filter
    
    public init(
        categories: [Category]? = nil,
        sizes: [String]? = nil,
        sizeSystem: SizeSystem? = nil,
        priceRange: PriceRange? = nil,
        conditions: [Condition]? = nil,
        colors: [String]? = nil,
        brands: [String]? = nil,
        materials: [String]? = nil,
        sustainableOnly: Bool = false,
        vintageOnly: Bool = false,
        luxuryOnly: Bool = false,
        exchangeType: ExchangeType? = nil,
        sortBy: GarmentSortOption = .relevance,
        sortOrder: SortOrder = .descending,
        sources: [GarmentSource] = [.modaics, .depop] // v3.5
    ) {
        self.categories = categories
        self.sizes = sizes
        self.sizeSystem = sizeSystem
        self.priceRange = priceRange
        self.conditions = conditions
        self.colors = colors
        self.brands = brands
        self.materials = materials
        self.sustainableOnly = sustainableOnly
        self.vintageOnly = vintageOnly
        self.luxuryOnly = luxuryOnly
        self.exchangeType = exchangeType
        self.sortBy = sortBy
        self.sortOrder = sortOrder
        self.sources = sources
    }
}

public struct PriceRange: Sendable {
    public let min: Decimal
    public let max: Decimal
    
    public init(min: Decimal, max: Decimal) {
        self.min = min
        self.max = max
    }
}

public struct DiscoverGarmentsOutput: Sendable {
    public let garments: [Garment]
    public let totalCount: Int
    public let page: Int
    public let hasMore: Bool
    public let discoveryType: DiscoveryType
    public let recommendationReasons: [UUID: [String]] // garmentId -> reasons
    public let visualSearchResults: [VisualSearchResult]? // v3.5: Visual search results
    
    public init(
        garments: [Garment],
        totalCount: Int,
        page: Int,
        hasMore: Bool,
        discoveryType: DiscoveryType,
        recommendationReasons: [UUID: [String]] = [:],
        visualSearchResults: [VisualSearchResult]? = nil // v3.5
    ) {
        self.garments = garments
        self.totalCount = totalCount
        self.page = page
        self.hasMore = hasMore
        self.discoveryType = discoveryType
        self.recommendationReasons = recommendationReasons
        self.visualSearchResults = visualSearchResults
    }
}

// MARK: - Implementation

public final class DiscoverGarmentsUseCase: DiscoverGarmentsUseCaseProtocol {
    private let discoveryRepository: DiscoveryRepositoryProtocol
    private let styleMatchingService: StyleMatchingServiceProtocol
    
    public init(
        discoveryRepository: DiscoveryRepositoryProtocol,
        styleMatchingService: StyleMatchingServiceProtocol
    ) {
        self.discoveryRepository = discoveryRepository
        self.styleMatchingService = styleMatchingService
    }
    
    public func execute(input: DiscoverGarmentsInput) async throws -> DiscoverGarmentsOutput {
        // Handle visual search separately
        if case .visualSearch(let embedding) = input.discoveryType {
            return try await performVisualSearch(embedding: embedding, input: input)
        }
        
        let result: PaginatedResult<Garment>
        var reasons: [UUID: [String]] = [:]
        
        switch input.discoveryType {
        case .personalizedFeed:
            guard let userId = input.userId else {
                throw DiscoveryError.userIdRequired
            }
            result = try await discoveryRepository.getPersonalizedFeed(
                for: userId,
                page: input.page,
                limit: input.limit
            )
            
        case .newArrivals:
            let garments = try await discoveryRepository.getNewArrivals(for: input.userId)
            result = PaginatedResult(
                items: garments,
                totalCount: garments.count,
                page: input.page,
                limit: input.limit
            )
            
        case .trending:
            let garments = try await discoveryRepository.getTrending(limit: input.limit)
            result = PaginatedResult(
                items: garments,
                totalCount: garments.count,
                page: input.page,
                limit: input.limit
            )
            
        case .category(let category):
            result = try await discoveryRepository.browseBy(
                category: category,
                page: input.page,
                limit: input.limit
            )
            
        case .aesthetic(let aesthetic):
            result = try await discoveryRepository.browseBy(
                aesthetic: aesthetic,
                page: input.page,
                limit: input.limit
            )
            
        case .similarTo(let garmentId):
            let garments = try await discoveryRepository.findSimilar(to: garmentId, limit: input.limit)
            result = PaginatedResult(
                items: garments,
                totalCount: garments.count,
                page: input.page,
                limit: input.limit
            )
            
        case .complementaryTo(let garmentId):
            let garments = try await discoveryRepository.findComplementary(to: garmentId, limit: input.limit)
            result = PaginatedResult(
                items: garments,
                totalCount: garments.count,
                page: input.page,
                limit: input.limit
            )
            
        case .styleMatches:
            guard let userId = input.userId else {
                throw DiscoveryError.userIdRequired
            }
            let garments = try await discoveryRepository.findStyleMatches(for: userId, limit: input.limit)
            // Get match reasons from style matching service
            for garment in garments {
                let matchReasons = try await styleMatchingService.getMatchReasons(
                    userId: userId,
                    garmentId: garment.id
                )
                reasons[garment.id] = matchReasons
            }
            result = PaginatedResult(
                items: garments,
                totalCount: garments.count,
                page: input.page,
                limit: input.limit
            )
            
        case .search(let query):
            let garments = try await discoveryRepository.search(query: query, filters: input.filters)
            result = PaginatedResult(
                items: garments,
                totalCount: garments.count,
                page: input.page,
                limit: input.limit
            )
            
        case .visualSearch:
            // Handled above
            throw DiscoveryError.invalidDiscoveryType
            
        case .local(let radiusKm):
            guard let userId = input.userId else {
                throw DiscoveryError.userIdRequired
            }
            // In real implementation, would get user location first
            throw DiscoveryError.notImplemented
            
        case .curatedCollection(let collectionId):
            result = try await discoveryRepository.getCollectionItems(
                collectionId: collectionId,
                page: input.page,
                limit: input.limit
            )
            
        case .byUser(let userId):
            // Would need to get user's listed garments
            throw DiscoveryError.notImplemented
            
        case .following:
            guard let userId = input.userId else {
                throw DiscoveryError.userIdRequired
            }
            throw DiscoveryError.notImplemented
        }
        
        return DiscoverGarmentsOutput(
            garments: result.items,
            totalCount: result.totalCount,
            page: result.page,
            hasMore: result.hasMore,
            discoveryType: input.discoveryType,
            recommendationReasons: reasons
        )
    }
    
    // MARK: - Private Methods
    
    private func performVisualSearch(
        embedding: [Float],
        input: DiscoverGarmentsInput
    ) async throws -> DiscoverGarmentsOutput {
        let response = try await styleMatchingService.searchByEmbedding(
            embedding: embedding,
            topK: input.limit,
            sourceFilter: input.sourceFilter
        )
        
        let garments = response.results.map { $0.garment }
        
        return DiscoverGarmentsOutput(
            garments: garments,
            totalCount: garments.count,
            page: 1,
            hasMore: false,
            discoveryType: input.discoveryType,
            visualSearchResults: response.results
        )
    }
}

public enum DiscoveryError: Error {
    case userIdRequired
    case notImplemented
    case invalidDiscoveryType
    case networkError
    case invalidFilters
}
