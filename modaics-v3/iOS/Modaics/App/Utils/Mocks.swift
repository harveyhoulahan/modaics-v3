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
        return MockData.garments.first { $0.id == id } ?? MockData.garments[0]
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
        return MockData.stories.filter { $0.garmentId == garmentId }
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
    
    func getCollections() async throws -> [Collection] {
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
            id: "garment-1",
            name: "Vintage Denim Jacket",
            category: "Outerwear",
            color: "Indigo",
            brand: "Levi's",
            size: "M",
            images: [],
            storyIds: ["story-1"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Garment(
            id: "garment-2",
            name: "Silk Blouse",
            category: "Tops",
            color: "Cream",
            brand: "Everlane",
            size: "S",
            images: [],
            storyIds: [],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Garment(
            id: "garment-3",
            name: "Wool Coat",
            category: "Outerwear",
            color: "Camel",
            brand: "COS",
            size: "M",
            images: [],
            storyIds: ["story-2"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Garment(
            id: "garment-4",
            name: "Linen Trousers",
            category: "Bottoms",
            color: "Beige",
            brand: "Uniqlo",
            size: "30",
            images: [],
            storyIds: [],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Garment(
            id: "garment-5",
            name: "Cashmere Sweater",
            category: "Knitwear",
            color: "Heather Grey",
            brand: "Naadam",
            size: "M",
            images: [],
            storyIds: [],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Garment(
            id: "garment-6",
            name: "Leather Ankle Boots",
            category: "Shoes",
            color: "Black",
            brand: "Everlane",
            size: "38",
            images: [],
            storyIds: ["story-3"],
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    static let stories: [Story] = [
        Story(
            id: "story-1",
            garmentId: "garment-1",
            authorId: "user-1",
            title: "The Thrift Store Treasure",
            content: "Found this vintage Levi's jacket at a small thrift store in Brooklyn. It was hidden behind a rack of oversized 80s blazers, but something about the worn-in denim caught my eye. The previous owner had patched the elbows with beautiful Japanese sashiko stitching—someone clearly loved this piece. I like to imagine where it traveled, what concerts it attended, the stories it could tell. Now it's my go-to layer for cool autumn evenings.",
            images: [],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Story(
            id: "story-2",
            garmentId: "garment-3",
            authorId: "user-1",
            title: "Investment Piece",
            content: "I saved for six months to buy this coat. It was my first major fashion purchase after landing my dream job. Every time I put it on, I'm reminded of that milestone and how far I've come. Quality over quantity—this coat will last me decades.",
            images: [],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Story(
            id: "story-3",
            garmentId: "garment-6",
            authorId: "user-1",
            title: "Walking Through Life",
            content: "These boots have walked through three countries, countless city streets, and one unforgettable rainy proposal in Paris. The leather has molded to my feet perfectly—they're like old friends at this point.",
            images: [],
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    static let collections: [Collection] = [
        Collection(
            id: "collection-1",
            title: "Summer Essentials",
            description: "Lightweight pieces for warm days",
            imageUrl: "",
            garmentCount: 12
        ),
        Collection(
            id: "collection-2",
            title: "Vintage Finds",
            description: "Pre-loved treasures with stories",
            imageUrl: "",
            garmentCount: 8
        ),
        Collection(
            id: "collection-3",
            title: "Work Wardrobe",
            description: "Professional and polished",
            imageUrl: "",
            garmentCount: 15
        )
    ]
}