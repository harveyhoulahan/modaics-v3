import Foundation

// MARK: - Garment Repository
class GarmentRepository: GarmentRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let offlineStorage: OfflineStorageProtocol
    private let logger: LoggerProtocol
    
    init(
        apiClient: APIClientProtocol,
        offlineStorage: OfflineStorageProtocol,
        logger: LoggerProtocol
    ) {
        self.apiClient = apiClient
        self.offlineStorage = offlineStorage
        self.logger = logger
    }
    
    func get(by id: UUID) async throws -> Garment {
        do {
            let garment: Garment = try await apiClient.get("/garments/\(id.uuidString)")
            try? await offlineStorage.saveGarment(garment)
            return garment
        } catch {
            if let offline = try? await offlineStorage.getGarment(id: id) {
                return offline
            }
            throw error
        }
    }
    
    func get(ids: [UUID]) async throws -> [Garment] {
        // In real implementation, would batch fetch
        var garments: [Garment] = []
        for id in ids {
            if let garment = try? await get(by: id) {
                garments.append(garment)
            }
        }
        return garments
    }
    
    func create(_ garment: Garment) async throws -> Garment {
        let created: Garment = try await apiClient.post("/garments", body: garment)
        try? await offlineStorage.saveGarment(created)
        return created
    }
    
    func update(_ garment: Garment) async throws -> Garment {
        let updated: Garment = try await apiClient.put("/garments/\(garment.id.uuidString)", body: garment)
        try? await offlineStorage.saveGarment(updated)
        return updated
    }
    
    func delete(id: UUID) async throws {
        try await apiClient.delete("/garments/\(id.uuidString)")
        try? await offlineStorage.deleteGarment(id: id)
    }
    
    func exists(id: UUID) async throws -> Bool {
        do {
            _ = try await get(by: id)
            return true
        } catch {
            return false
        }
    }
    
    func getByOwner(userId: UUID) async throws -> [Garment] {
        do {
            let garments: [Garment] = try await apiClient.get("/users/\(userId.uuidString)/garments")
            // Cache locally
            for garment in garments {
                try? await offlineStorage.saveGarment(garment)
            }
            return garments
        } catch {
            // Fallback to offline storage
            logger.log("Falling back to offline storage for garments", level: .warning)
            return try await offlineStorage.getGarments()
        }
    }
    
    func getByOwner(userId: UUID, page: Int, limit: Int) async throws -> PaginatedResult<Garment> {
        let garments = try await getByOwner(userId: userId)
        let start = (page - 1) * limit
        let end = min(start + limit, garments.count)
        let pageItems = Array(garments[start..<end])
        return PaginatedResult(items: pageItems, totalCount: garments.count, page: page, limit: limit)
    }
    
    func getByOwner(userId: UUID, isListed: Bool) async throws -> [Garment] {
        let garments = try await getByOwner(userId: userId)
        return garments.filter { $0.isListed == isListed }
    }
    
    func listGarment(id: UUID, exchangeType: ExchangeType, price: Decimal?) async throws -> Garment {
        var garment = try await get(by: id)
        garment.isListed = true
        garment.exchangeType = exchangeType
        garment.listingPrice = price
        return try await update(garment)
    }
    
    func delistGarment(id: UUID) async throws -> Garment {
        var garment = try await get(by: id)
        garment.isListed = false
        return try await update(garment)
    }
    
    func updatePrice(id: UUID, newPrice: Decimal?) async throws -> Garment {
        var garment = try await get(by: id)
        garment.listingPrice = newPrice
        return try await update(garment)
    }
    
    func createBatch(_ garments: [Garment]) async throws -> [Garment] {
        var created: [Garment] = []
        for garment in garments {
            let newGarment = try await create(garment)
            created.append(newGarment)
        }
        return created
    }
    
    func updateBatch(_ garments: [Garment]) async throws -> [Garment] {
        var updated: [Garment] = []
        for garment in garments {
            let newGarment = try await update(garment)
            updated.append(newGarment)
        }
        return updated
    }
    
    func deleteBatch(ids: [UUID]) async throws {
        for id in ids {
            try await delete(id: id)
        }
    }
    
    func search(query: String) async throws -> [Garment] {
        let garments: [Garment] = try await apiClient.get("/garments/search?q=\(query)")
        return garments
    }
    
    func search(query: String, ownerId: UUID) async throws -> [Garment] {
        let garments = try await search(query: query)
        return garments.filter { $0.ownerId == ownerId }
    }
    
    func filter(_ criteria: GarmentFilterCriteria) async throws -> [Garment] {
        // In real implementation, would send criteria to API
        var garments = try await getByOwner(userId: criteria.ownerId ?? UUID())
        
        if let isListed = criteria.isListed {
            garments = garments.filter { $0.isListed == isListed }
        }
        if let categories = criteria.categories {
            garments = garments.filter { categories.contains($0.category) }
        }
        if let brands = criteria.brands {
            garments = garments.filter { garment in
                brands.contains(garment.brand?.name ?? "")
            }
        }
        if let minPrice = criteria.minPrice {
            garments = garments.filter { ($0.listingPrice ?? 0) >= minPrice }
        }
        if let maxPrice = criteria.maxPrice {
            garments = garments.filter { ($0.listingPrice ?? 0) <= maxPrice }
        }
        
        return garments
    }
    
    func filter(_ criteria: GarmentFilterCriteria, page: Int, limit: Int) async throws -> PaginatedResult<Garment> {
        let garments = try await filter(criteria)
        let start = (page - 1) * limit
        let end = min(start + limit, garments.count)
        let pageItems = start < garments.count ? Array(garments[start..<end]) : []
        return PaginatedResult(items: pageItems, totalCount: garments.count, page: page, limit: limit)
    }
    
    func countByOwner(userId: UUID) async throws -> Int {
        let garments = try await getByOwner(userId: userId)
        return garments.count
    }
    
    func countListedByOwner(userId: UUID) async throws -> Int {
        let garments = try await getByOwner(userId: userId, isListed: true)
        return garments.count
    }
    
    func totalValueByOwner(userId: UUID) async throws -> Decimal {
        let garments = try await getByOwner(userId: userId)
        return garments.reduce(Decimal(0)) { $0 + ($0.originalPrice ?? 0) }
    }
}

// MARK: - Story Repository
class StoryRepository: StoryRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let offlineStorage: OfflineStorageProtocol
    private let logger: LoggerProtocol
    
    init(
        apiClient: APIClientProtocol,
        offlineStorage: OfflineStorageProtocol,
        logger: LoggerProtocol
    ) {
        self.apiClient = apiClient
        self.offlineStorage = offlineStorage
        self.logger = logger
    }
    
    func getStories(for garmentId: UUID) async throws -> [Story] {
        do {
            let stories: [Story] = try await apiClient.get("/garments/\(garmentId.uuidString)/stories")
            for story in stories {
                try? await offlineStorage.saveStory(story)
            }
            return stories
        } catch {
            return try await offlineStorage.getStories(for: garmentId)
        }
    }
    
    func createStory(_ story: Story) async throws -> Story {
        let created: Story = try await apiClient.post("/stories", body: story)
        try? await offlineStorage.saveStory(created)
        return created
    }
    
    func deleteStory(id: UUID) async throws {
        try await apiClient.delete("/stories/\(id.uuidString)")
    }
}

// MARK: - User Repository
class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let logger: LoggerProtocol
    
    init(
        apiClient: APIClientProtocol,
        logger: LoggerProtocol
    ) {
        self.apiClient = apiClient
        self.logger = logger
    }
    
    func getCurrentUser() async throws -> User {
        let user: User = try await apiClient.get("/me")
        return user
    }
    
    func updateUser(_ user: User) async throws -> User {
        let updated: User = try await apiClient.put("/me", body: user)
        return updated
    }
    
    func getUser(id: UUID) async throws -> User {
        let user: User = try await apiClient.get("/users/\(id.uuidString)")
        return user
    }
}

// MARK: - Discovery Repository
class DiscoveryRepository: DiscoveryRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let logger: LoggerProtocol
    
    init(
        apiClient: APIClientProtocol,
        logger: LoggerProtocol
    ) {
        self.apiClient = apiClient
        self.logger = logger
    }
    
    func getTrendingStories() async throws -> [Story] {
        let stories: [Story] = try await apiClient.get("/discover/trending")
        return stories
    }
    
    func getRecentGarments() async throws -> [Garment] {
        let garments: [Garment] = try await apiClient.get("/discover/recent")
        return garments
    }
    
    func getCollections() async throws -> [WardrobeCollection] {
        let collections: [WardrobeCollection] = try await apiClient.get("/discover/collections")
        return collections
    }
    
    func search(query: String) async throws -> MockSearchResults {
        let results: MockSearchResults = try await apiClient.get("/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        return results
    }
}
