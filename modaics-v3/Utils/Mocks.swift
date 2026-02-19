import Foundation
import UIKit

// MARK: - Mock Services

class MockAuthService: AuthServiceProtocol {
    var currentUser: User? = User(
        id: UUID(),
        displayName: "Test User",
        username: "testuser",
        bio: "Fashion enthusiast",
        email: "test@example.com",
        avatarURL: nil,
        coverImageURL: nil,
        styleDescriptors: [],
        aesthetic: nil,
        sizePreferences: [],
        favoriteColors: [],
        favoriteBrands: [],
        wishlistItems: [],
        openToTrade: true,
        preferredExchangeTypes: [.sellOrTrade],
        wardrobeCount: 0,
        exchangeCount: 0,
        rating: 0,
        ratingCount: 0,
        followerCount: 0,
        followingCount: 0,
        totalCarbonSavingsKg: 0,
        totalWaterSavingsLiters: 0,
        itemsCirculated: 0,
        location: nil,
        shippingPreference: .domestic,
        isEmailVerified: true,
        tier: .free,
        atelierSubscription: nil,
        joinedAt: Date(),
        lastActiveAt: Date(),
        status: .active,
        notificationPreferences: NotificationPreferences(),
        privacySettings: PrivacySettings(),
        contentPreferences: ContentPreferences()
    )
    
    func signIn(email: String, password: String) async throws {}
    func signUp(email: String, password: String) async throws {}
    func signInWithApple() async throws {}
    func signInWithGoogle() async throws {}
    func signOut() throws {}
    func resetPassword(email: String) async throws {}
}

class MockLogger: LoggerProtocol {
    func log(_ message: String, level: LogLevel) {
        print("[MOCK] \(message)")
    }
}

// MARK: - Mock Repositories

class MockGarmentRepository: GarmentRepositoryProtocol {
    func get(by id: UUID) async throws -> Garment {
        return MockData.garments.first { $0.id == id } ?? MockData.garments[0]
    }
    
    func get(ids: [UUID]) async throws -> [Garment] {
        return MockData.garments.filter { ids.contains($0.id) }
    }
    
    func create(_ garment: Garment) async throws -> Garment {
        return garment
    }
    
    func update(_ garment: Garment) async throws -> Garment {
        return garment
    }
    
    func delete(id: UUID) async throws {}
    
    func exists(id: UUID) async throws -> Bool {
        return MockData.garments.contains { $0.id == id }
    }
    
    func getByOwner(userId: UUID) async throws -> [Garment] {
        return MockData.garments.filter { $0.ownerId == userId }
    }
    
    func getByOwner(userId: UUID, page: Int, limit: Int) async throws -> PaginatedResult<Garment> {
        let garments = MockData.garments.filter { $0.ownerId == userId }
        return PaginatedResult(items: garments, totalCount: garments.count, page: page, limit: limit)
    }
    
    func getByOwner(userId: UUID, isListed: Bool) async throws -> [Garment] {
        return MockData.garments.filter { $0.ownerId == userId && $0.isListed == isListed }
    }
    
    func listGarment(id: UUID, exchangeType: ExchangeType, price: Decimal?) async throws -> Garment {
        guard var garment = MockData.garments.first(where: { $0.id == id }) else {
            throw NSError(domain: "Mock", code: 404)
        }
        garment.isListed = true
        garment.exchangeType = exchangeType
        garment.listingPrice = price
        return garment
    }
    
    func delistGarment(id: UUID) async throws -> Garment {
        guard var garment = MockData.garments.first(where: { $0.id == id }) else {
            throw NSError(domain: "Mock", code: 404)
        }
        garment.isListed = false
        return garment
    }
    
    func updatePrice(id: UUID, newPrice: Decimal?) async throws -> Garment {
        guard var garment = MockData.garments.first(where: { $0.id == id }) else {
            throw NSError(domain: "Mock", code: 404)
        }
        garment.listingPrice = newPrice
        return garment
    }
    
    func createBatch(_ garments: [Garment]) async throws -> [Garment] {
        return garments
    }
    
    func updateBatch(_ garments: [Garment]) async throws -> [Garment] {
        return garments
    }
    
    func deleteBatch(ids: [UUID]) async throws {}
    
    func search(query: String) async throws -> [Garment] {
        return MockData.garments.filter { $0.title.contains(query) || $0.description.contains(query) }
    }
    
    func search(query: String, ownerId: UUID) async throws -> [Garment] {
        return MockData.garments.filter { 
            $0.ownerId == ownerId && ($0.title.contains(query) || $0.description.contains(query))
        }
    }
    
    func filter(_ criteria: GarmentFilterCriteria) async throws -> [Garment] {
        return MockData.garments
    }
    
    func filter(_ criteria: GarmentFilterCriteria, page: Int, limit: Int) async throws -> PaginatedResult<Garment> {
        return PaginatedResult(items: MockData.garments, totalCount: MockData.garments.count, page: page, limit: limit)
    }
    
    func countByOwner(userId: UUID) async throws -> Int {
        return MockData.garments.filter { $0.ownerId == userId }.count
    }
    
    func countListedByOwner(userId: UUID) async throws -> Int {
        return MockData.garments.filter { $0.ownerId == userId && $0.isListed }.count
    }
    
    func totalValueByOwner(userId: UUID) async throws -> Decimal {
        return MockData.garments
            .filter { $0.ownerId == userId }
            .reduce(Decimal(0)) { $0 + ($1.originalPrice ?? 0) }
    }
}

class MockStoryRepository: StoryRepositoryProtocol {
    func getStories(for garmentId: UUID) async throws -> [Story] {
        return MockData.stories
    }
    
    func createStory(_ story: Story) async throws -> Story {
        return story
    }
    
    func deleteStory(id: UUID) async throws {}
}

class MockUserRepository: UserRepositoryProtocol {
    func getCurrentUser() async throws -> User {
        return MockData.currentUser
    }
    
    func updateUser(_ user: User) async throws -> User {
        return user
    }
    
    func getUser(id: UUID) async throws -> User {
        return MockData.currentUser
    }
}

class MockDiscoveryRepository: DiscoveryRepositoryProtocol {
    func getTrendingStories() async throws -> [Story] {
        return MockData.stories
    }
    
    func getRecentGarments() async throws -> [Garment] {
        return MockData.garments
    }
    
    func getCollections() async throws -> [WardrobeCollection] {
        return MockData.collections
    }
    
    func search(query: String) async throws -> MockSearchResults {
        return MockSearchResults(
            garments: MockData.garments,
            stories: MockData.stories,
            users: [MockData.currentUser]
        )
    }
}

// MARK: - Mock Use Cases

class MockGetGarmentsUseCase: GetGarmentsUseCaseProtocol {
    func execute() async throws -> [Garment] {
        return MockData.garments
    }
}

class MockCreateGarmentUseCase: CreateGarmentUseCaseProtocol {
    func execute(_ garment: Garment) async throws -> Garment {
        return garment
    }
}

class MockDeleteGarmentUseCase: DeleteGarmentUseCaseProtocol {
    func execute(id: UUID) async throws {}
}

class MockGetDiscoveryFeedUseCase: GetDiscoveryFeedUseCaseProtocol {
    func execute() async throws -> DiscoveryFeed {
        return DiscoveryFeed(
            trendingStories: MockData.stories,
            recentGarments: MockData.garments,
            collections: MockData.collections
        )
    }
}

class MockGetUserProfileUseCase: GetUserProfileUseCaseProtocol {
    func execute() async throws -> User {
        return MockData.currentUser
    }
}

// MARK: - DiscoveryFeed Model (for API responses)
struct DiscoveryFeed: Codable {
    var trendingStories: [Story]
    var recentGarments: [Garment]
    var collections: [WardrobeCollection]
}

// MARK: - Mock SearchResults Model (for API responses)
struct MockSearchResults: Codable {
    var garments: [Garment]
    var stories: [Story]
    var users: [User]
}

// MARK: - Use Case Protocols (simplified versions for mocks)
protocol GetGarmentsUseCaseProtocol {
    func execute() async throws -> [Garment]
}

protocol CreateGarmentUseCaseProtocol {
    func execute(_ garment: Garment) async throws -> Garment
}

protocol DeleteGarmentUseCaseProtocol {
    func execute(id: UUID) async throws
}

protocol GetDiscoveryFeedUseCaseProtocol {
    func execute() async throws -> DiscoveryFeed
}

protocol GetUserProfileUseCaseProtocol {
    func execute() async throws -> User
}

// MARK: - Mock Data

enum MockData {
    static let currentUser = User(
        id: UUID(),
        displayName: "Alex Rivera",
        username: "alexrivera",
        bio: "Curating my intentional wardrobe",
        email: "alex@example.com",
        avatarURL: nil,
        coverImageURL: nil,
        styleDescriptors: [],
        aesthetic: nil,
        sizePreferences: [],
        favoriteColors: [],
        favoriteBrands: [],
        wishlistItems: [],
        openToTrade: true,
        preferredExchangeTypes: [.sellOrTrade],
        wardrobeCount: 5,
        exchangeCount: 0,
        rating: 5.0,
        ratingCount: 10,
        followerCount: 25,
        followingCount: 30,
        totalCarbonSavingsKg: 100,
        totalWaterSavingsLiters: 500,
        itemsCirculated: 3,
        location: nil,
        shippingPreference: .domestic,
        isEmailVerified: true,
        tier: .free,
        atelierSubscription: nil,
        joinedAt: Date(),
        lastActiveAt: Date(),
        status: .active,
        notificationPreferences: NotificationPreferences(),
        privacySettings: PrivacySettings(),
        contentPreferences: ContentPreferences()
    )
    
    static let garments: [Garment] = [
        Garment(
            id: UUID(),
            title: "Vintage Denim Jacket",
            description: "A classic vintage Levi's jacket",
            story: Story.sample,
            condition: .vintage,
            originalPrice: 150.00,
            category: .outerwear,
            size: Size(label: "M", system: .us),
            ownerId: UUID()
        ),
        Garment(
            id: UUID(),
            title: "Silk Blouse",
            description: "Elegant cream silk blouse",
            story: Story.sampleMinimal,
            condition: .excellent,
            originalPrice: 120.00,
            category: .tops,
            size: Size(label: "S", system: .us),
            ownerId: UUID()
        ),
        Garment(
            id: UUID(),
            title: "Wool Coat",
            description: "Classic camel wool coat",
            story: Story.sampleMinimal,
            condition: .excellent,
            originalPrice: 350.00,
            category: .outerwear,
            size: Size(label: "M", system: .us),
            ownerId: UUID()
        ),
        Garment(
            id: UUID(),
            title: "Linen Trousers",
            description: "Relaxed beige linen trousers",
            story: Story.sampleMinimal,
            condition: .good,
            originalPrice: 80.00,
            category: .bottoms,
            size: Size(label: "30", system: .us),
            ownerId: UUID()
        ),
        Garment(
            id: UUID(),
            title: "Cashmere Sweater",
            description: "Soft heather grey cashmere",
            story: Story.sampleMinimal,
            condition: .excellent,
            originalPrice: 200.00,
            category: .tops,
            size: Size(label: "M", system: .us),
            ownerId: UUID()
        ),
        Garment(
            id: UUID(),
            title: "Leather Ankle Boots",
            description: "Black leather ankle boots",
            story: Story.sampleMinimal,
            condition: .veryGood,
            originalPrice: 180.00,
            category: .shoes,
            size: Size(label: "38", system: .eu),
            ownerId: UUID()
        )
    ]
    
    static let stories: [Story] = [
        Story(
            narrative: "Found this vintage Levi's jacket at a small thrift store in Brooklyn. It was hidden behind a rack of oversized 80s blazers, but something about the worn-in denim caught my eye. The previous owner had patched the elbows with beautiful Japanese sashiko stitching.",
            provenance: "Brooklyn Thrift Store",
            memories: [
                Memory(description: "Wore it to my first art show", mood: .joyful)
            ],
            whySelling: "Ready for a new chapter"
        ),
        Story(
            narrative: "I saved for six months to buy this coat. It was my first major fashion purchase after landing my dream job.",
            provenance: "COS Retail Store",
            whySelling: "Moving to a warmer climate"
        ),
        Story(
            narrative: "These boots have walked through three countries, countless city streets, and one unforgettable rainy proposal in Paris.",
            provenance: "Paris boutique",
            whySelling: "Time for new adventures"
        )
    ]
    
    static let collections: [WardrobeCollection] = [
        WardrobeCollection(
            name: "Summer Essentials",
            description: "Lightweight pieces for warm days",
            garmentIds: [UUID(), UUID()],
            isSmartCollection: false,
            sortOrder: 0
        ),
        WardrobeCollection(
            name: "Vintage Finds",
            description: "Pre-loved treasures with stories",
            garmentIds: [UUID()],
            isSmartCollection: false,
            sortOrder: 1
        ),
        WardrobeCollection(
            name: "Work Wardrobe",
            description: "Professional and polished",
            garmentIds: [UUID(), UUID(), UUID()],
            isSmartCollection: false,
            sortOrder: 2
        )
    ]
}
