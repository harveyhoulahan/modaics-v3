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
    
    func getGarments() async throws -> [Garment] {
        do {
            let garments: [Garment] = try await apiClient.get("/garments")
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
    
    func getGarment(id: String) async throws -> Garment {
        do {
            let garment: Garment = try await apiClient.get("/garments/\(id)")
            try? await offlineStorage.saveGarment(garment)
            return garment
        } catch {
            if let offline = try? await offlineStorage.getGarment(id: id) {
                return offline
            }
            throw error
        }
    }
    
    func createGarment(_ garment: Garment) async throws -> Garment {
        let created: Garment = try await apiClient.post("/garments", body: garment)
        try? await offlineStorage.saveGarment(created)
        return created
    }
    
    func updateGarment(_ garment: Garment) async throws -> Garment {
        let updated: Garment = try await apiClient.put("/garments/\(garment.id)", body: garment)
        try? await offlineStorage.saveGarment(updated)
        return updated
    }
    
    func deleteGarment(id: String) async throws {
        try await apiClient.delete("/garments/\(id)")
        try? await offlineStorage.deleteGarment(id: id)
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
    
    func getStories(for garmentId: String) async throws -> [Story] {
        do {
            let stories: [Story] = try await apiClient.get("/garments/\(garmentId)/stories")
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
    
    func deleteStory(id: String) async throws {
        try await apiClient.delete("/stories/\(id)")
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
    
    func getUser(id: String) async throws -> User {
        let user: User = try await apiClient.get("/users/\(id)")
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
    
    func getCollections() async throws -> [Collection] {
        let collections: [Collection] = try await apiClient.get("/discover/collections")
        return collections
    }
    
    func search(query: String) async throws -> SearchResults {
        let results: SearchResults = try await apiClient.get("/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        return results
    }
}