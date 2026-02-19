import Foundation
import UIKit

// MARK: - Use Case Protocols
// These are simplified protocols for the App layer use cases

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
    func execute(id: String) async throws
}

protocol GetStoriesUseCaseProtocol {
    func execute(for garmentId: String) async throws -> [Story]
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

// MARK: - Use Case Implementations

// MARK: - Garment Use Cases
class GetGarmentsUseCase: GetGarmentsUseCaseProtocol {
    private let repository: GarmentRepositoryProtocol
    
    init(repository: GarmentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Garment] {
        return try await repository.getGarments()
    }
}

class CreateGarmentUseCase: CreateGarmentUseCaseProtocol {
    private let repository: GarmentRepositoryProtocol
    
    init(repository: GarmentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ garment: Garment) async throws -> Garment {
        return try await repository.createGarment(garment)
    }
}

class UpdateGarmentUseCase: UpdateGarmentUseCaseProtocol {
    private let repository: GarmentRepositoryProtocol
    
    init(repository: GarmentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ garment: Garment) async throws -> Garment {
        return try await repository.updateGarment(garment)
    }
}

class DeleteGarmentUseCase: DeleteGarmentUseCaseProtocol {
    private let repository: GarmentRepositoryProtocol
    
    init(repository: GarmentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: String) async throws {
        try await repository.deleteGarment(id: id)
    }
}

// MARK: - Story Use Cases
class GetStoriesUseCase: GetStoriesUseCaseProtocol {
    private let repository: StoryRepositoryProtocol
    
    init(repository: StoryRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(for garmentId: String) async throws -> [Story] {
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
