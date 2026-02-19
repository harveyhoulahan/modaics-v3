import Foundation
import UIKit

// MARK: - Mock Services

class MockAuthService: AuthServiceProtocol {
    var currentUser: User? = User(
        id: UUID(),
        displayName: "Test User",
        username: "testuser",
        bio: "Fashion enthusiast",
        email: "test@example.com"
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
    func getGarments() async throws -> [Garment] {
        return MockData.garments
    }
    
    func getGarment(id: UUID) async throws -> Garment {
        return MockData.garments.first { $0.id == id } ?? MockData.garments[0]
    }
    
    func createGarment(_ garment: Garment) async throws -> Garment {
        return garment
    }
    
    func updateGarment(_ garment: Garment) async throws -> Garment {
        return garment
    }
    
    func deleteGarment(id: UUID) async throws {}
}

class MockStoryRepository: StoryRepositoryProtocol {
    func getStories(for garmentId: UUID) async throws -> [Story] {
        return MockData.stories.filter { $0.id == garmentId }
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
    
    func search(query: String) async throws -> SearchResults {
        return SearchResults(
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

// MARK: - Mock Data

enum MockData {
    static let currentUser = User(
        id: UUID(),
        displayName: "Alex Rivera",
        username: "alexrivera",
        bio: "Curating my intentional wardrobe",
        email: "alex@example.com"
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