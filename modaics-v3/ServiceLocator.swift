import Foundation
import Combine
import UIKit

// MARK: - Service Locator
/// Central dependency injection container for the Modaics app
class ServiceLocator {
    static let shared = ServiceLocator()
    
    // MARK: - Services
    private(set) lazy var authService: AuthServiceProtocol = {
        FirebaseAuthService()
    }()
    
    private(set) lazy var apiClient: APIClientProtocol = {
        APIClient(authService: authService)
    }()
    
    private(set) lazy var imageService: ImageServiceProtocol = {
        ImageService()
    }()
    
    private(set) lazy var offlineStorage: OfflineStorageProtocol = {
        CoreDataOfflineStorage()
    }()
    
    private(set) lazy var logger: LoggerProtocol = {
        ConsoleLogger()
    }()
    
    // MARK: - Repositories
    private(set) lazy var garmentRepository: GarmentRepositoryProtocol = {
        GarmentRepository(
            apiClient: apiClient,
            offlineStorage: offlineStorage,
            logger: logger
        )
    }()
    
    private(set) lazy var storyRepository: StoryRepositoryProtocol = {
        StoryRepository(
            apiClient: apiClient,
            offlineStorage: offlineStorage,
            logger: logger
        )
    }()
    
    private(set) lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(
            apiClient: apiClient,
            logger: logger
        )
    }()
    
    private(set) lazy var discoveryRepository: DiscoveryRepositoryProtocol = {
        DiscoveryRepository(
            apiClient: apiClient,
            logger: logger
        )
    }()
    
    // MARK: - Configuration
    func configure() {
        // Configure offline storage
        offlineStorage.configure()
        logger.log("ServiceLocator configured", level: .info)
    }
}

// MARK: - Mock Service Locator (for Previews/Testing)
class MockServiceLocator {
    static let shared = MockServiceLocator()
    
    // Mock Services
    lazy var mockAuthService: AuthServiceProtocol = {
        MockAuthService()
    }()
    
    lazy var mockGarmentRepository: GarmentRepositoryProtocol = {
        MockGarmentRepository()
    }()
    
    lazy var mockStoryRepository: StoryRepositoryProtocol = {
        MockStoryRepository()
    }()
    
    lazy var mockUserRepository: UserRepositoryProtocol = {
        MockUserRepository()
    }()
    
    lazy var mockDiscoveryRepository: DiscoveryRepositoryProtocol = {
        MockDiscoveryRepository()
    }()
    
    lazy var mockLogger: LoggerProtocol = {
        MockLogger()
    }()
}