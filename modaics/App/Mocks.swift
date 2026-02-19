import Foundation
import UIKit

// MARK: - Mock Services

class MockAuthService: AuthServiceProtocol {
    var currentUser: User? = User(
        id: "mock-user-1",
        email: "test@example.com",
        displayName: "Test User",
        avatarUrl: nil,
        bio: "Fashion enthusiast",
        garmentCount: 12,
        storyCount: 5,
        followerCount: 23
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
    
    func getGarment(id: String) async throws -> Garment {
        return MockData.garments.first { $0.id.uuidString == id } ?? MockData.garments[0]
    }
    
    func createGarment(_ garment: Garment) async throws -> Garment {
        return garment
    }
    
    func updateGarment(_ garment: Garment) async throws -> Garment {
        return garment
    }
    
    func deleteGarment(id: String) async throws {}
}

class MockStoryRepository: StoryRepositoryProtocol {
    func getStories(for garmentId: String) async throws -> [Story] {
        return MockData.stories.filter { $0.garmentId.uuidString == garmentId }
    }
    
    func createStory(_ story: Story) async throws -> Story {
        return story
    }
    
    func deleteStory(id: String) async throws {}
}

class MockUserRepository: UserRepositoryProtocol {
    func getCurrentUser() async throws -> User {
        return MockData.currentUser
    }
    
    func updateUser(_ user: User) async throws -> User {
        return user
    }
    
    func getUser(id: String) async throws -> User {
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
    
    func getCollections() async throws -> [ModaicsCollection] {
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
    func execute(id: String) async throws {}
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
        id: "user-1",
        email: "alex@example.com",
        displayName: "Alex Rivera",
        avatarUrl: nil,
        bio: "Curating my intentional wardrobe",
        garmentCount: 24,
        storyCount: 8,
        followerCount: 156
    )
    
    static let garments: [Garment] = [
        Garment(
            title: "Vintage Denim Jacket",
            description: "A beautifully worn-in denim jacket with authentic patina.",
            story: Story(
                narrative: "Found at a thrift store in Brooklyn",
                provenance: "Levi's"
            ),
            condition: .vintage,
            category: .outerwear,
            size: Size(label: "M", system: .us),
            ownerId: UUID(uuidString: "user-1") ?? UUID(),
            brand: Brand(name: "Levi's")
        ),
        Garment(
            title: "Silk Blouse",
            description: "Elegant silk blouse in cream",
            story: Story(
                narrative: "Wedding outfit",
                provenance: "Everlane"
            ),
            condition: .excellent,
            category: .tops,
            size: Size(label: "S", system: .us),
            ownerId: UUID(uuidString: "user-1") ?? UUID(),
            brand: Brand(name: "Everlane")
        ),
        Garment(
            title: "Wool Coat",
            description: "Classic camel wool coat",
            story: Story(
                narrative: "Investment piece for winter",
                provenance: "COS"
            ),
            condition: .excellent,
            category: .outerwear,
            size: Size(label: "M", system: .us),
            ownerId: UUID(uuidString: "user-1") ?? UUID(),
            brand: Brand(name: "COS")
        ),
        Garment(
            title: "Linen Trousers",
            description: "Relaxed linen trousers",
            story: Story(
                narrative: "Summer essential",
                provenance: "Uniqlo"
            ),
            condition: .veryGood,
            category: .bottoms,
            size: Size(label: "30", system: .us),
            ownerId: UUID(uuidString: "user-1") ?? UUID(),
            brand: Brand(name: "Uniqlo")
        ),
        Garment(
            title: "Cashmere Sweater",
            description: "Soft cashmere knit",
            story: Story(
                narrative: "Cozy winter favorite",
                provenance: "Naadam"
            ),
            condition: .excellent,
            category: .tops,
            size: Size(label: "M", system: .us),
            ownerId: UUID(uuidString: "user-1") ?? UUID(),
            brand: Brand(name: "Naadam")
        ),
        Garment(
            title: "Leather Ankle Boots",
            description: "Classic black leather boots",
            story: Story(
                narrative: "Walking through cities",
                provenance: "Everlane"
            ),
            condition: .veryGood,
            category: .shoes,
            size: Size(label: "38", system: .us),
            ownerId: UUID(uuidString: "user-1") ?? UUID(),
            brand: Brand(name: "Everlane")
        )
    ]
    
    static let stories: [Story] = [
        Story(
            narrative: "I found this vintage jacket in a tiny shop in Tokyo's Shimokitazawa district.",
            provenance: "Flamingo, Shimokitazawa, Tokyo",
            whySelling: "Moving to a warmer climate",
            careNotes: "Treat with leather conditioner every 6 months"
        ),
        Story(
            narrative: "Investment piece for my first big job",
            provenance: "COS flagship store",
            whySelling: "Ready for a new chapter"
        ),
        Story(
            narrative: "These boots have walked through three countries",
            provenance: "Everlane online",
            whySelling: "Time for someone new to make memories"
        )
    ]
    
    static let collections: [ModaicsCollection] = [
        ModaicsCollection(
            title: "Summer Essentials",
            description: "Lightweight pieces for warm days",
            imageUrl: "",
            garmentCount: 12
        ),
        ModaicsCollection(
            title: "Vintage Finds",
            description: "Pre-loved treasures with stories",
            imageUrl: "",
            garmentCount: 8
        ),
        ModaicsCollection(
            title: "Work Wardrobe",
            description: "Professional and polished",
            imageUrl: "",
            garmentCount: 15
        )
    ]
}

// MARK: - Supporting Types for Mocks

struct ModaicsCollection: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var imageUrl: String
    var garmentCount: Int
    
    init(id: String = UUID().uuidString, title: String, description: String, imageUrl: String, garmentCount: Int = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.garmentCount = garmentCount
    }
}

// Extend Story to include garmentId for mock filtering
extension Story {
    var garmentId: UUID {
        // For mocks, return a predictable UUID
        UUID()
    }
}
