import Foundation
import UIKit

// MARK: - Use Case Implementations

// MARK: - Garment Use Cases
class GetGarmentsUseCase: GetGarmentsUseCaseProtocol {
    private let repository: GarmentRepositoryProtocol
    
    init(repository: GarmentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Garment] {
        return try await repository.getByOwner(userId: UUID())
    }
}

class CreateGarmentUseCase: CreateGarmentUseCaseProtocol {
    private let repository: GarmentRepositoryProtocol
    
    init(repository: GarmentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ garment: Garment) async throws -> Garment {
        return try await repository.create(garment)
    }
}

class UpdateGarmentUseCase: UpdateGarmentUseCaseProtocol {
    private let repository: GarmentRepositoryProtocol
    
    init(repository: GarmentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ garment: Garment) async throws -> Garment {
        return try await repository.update(garment)
    }
}

class DeleteGarmentUseCase: DeleteGarmentUseCaseProtocol {
    private let repository: GarmentRepositoryProtocol
    
    init(repository: GarmentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}

// MARK: - Story Use Cases
class GetStoriesUseCase: GetStoriesUseCaseProtocol {
    private let repository: StoryRepositoryProtocol
    
    init(repository: StoryRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(for garmentId: UUID) async throws -> [Story] {
        return try await repository.getStories(for: garmentId)
    }
}

class CreateStoryUseCase: CreateStoryUseCaseProtocol {
    private let repository: StoryRepositoryProtocol
    
    init(repository: StoryRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ story: Story) async throws -> Story {
        return try await repository.createStory(story)
    }
}

// MARK: - Discovery Use Cases
class GetDiscoveryFeedUseCase: GetDiscoveryFeedUseCaseProtocol {
    private let repository: DiscoveryRepositoryProtocol
    
    init(repository: DiscoveryRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> DiscoveryFeed {
        async let trending = repository.getTrendingStories()
        async let recent = repository.getRecentGarments()
        async let collections = repository.getCollections()
        
        return DiscoveryFeed(
            trendingStories: try await trending,
            recentGarments: try await recent,
            collections: try await collections
        )
    }
}

// MARK: - User Use Cases
class GetUserProfileUseCase: GetUserProfileUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> User {
        return try await repository.getCurrentUser()
    }
}

// MARK: - Image Use Cases
class UploadImageUseCase: UploadImageUseCaseProtocol {
    private let imageService: ImageServiceProtocol
    
    init(imageService: ImageServiceProtocol) {
        self.imageService = imageService
    }
    
    func execute(_ image: UIImage, path: String) async throws -> String {
        return try await imageService.uploadImage(image, path: path)
    }
}

// MARK: - Protocol Definitions (to be imported from ServiceLocator or defined here)

protocol GetGarmentsUseCaseProtocol {
    func execute() async throws -> [Garment]
}

protocol CreateGarmentUseCaseProtocol {
    func execute(_ garment: Garment) async throws -> Garment
}

protocol UpdateGarmentUseCaseProtocol {
    func execute(_ garment: Garment) async throws -> Garment
}

protocol DeleteGarmentUseCaseProtocol {
    func execute(id: UUID) async throws
}

protocol GetStoriesUseCaseProtocol {
    func execute(for garmentId: UUID) async throws -> [Story]
}

protocol CreateStoryUseCaseProtocol {
    func execute(_ story: Story) async throws -> Story
}

protocol GetDiscoveryFeedUseCaseProtocol {
    func execute() async throws -> DiscoveryFeed
}

protocol GetUserProfileUseCaseProtocol {
    func execute() async throws -> User
}

protocol UploadImageUseCaseProtocol {
    func execute(_ image: UIImage, path: String) async throws -> String
}

// MARK: - DiscoveryFeed Model
struct DiscoveryFeed: Codable {
    var trendingStories: [Story]
    var recentGarments: [Garment]
    var collections: [WardrobeCollection]
}

// MARK: - SearchResults Model  
struct SearchResults: Codable {
    var garments: [Garment]
    var stories: [Story]
    var users: [User]
}
