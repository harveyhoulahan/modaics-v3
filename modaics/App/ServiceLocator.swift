import Foundation
#if canImport(FirebaseAuth)
import FirebaseAuth
#endif
import UIKit

// MARK: - Service Locator
/// Central dependency injection container for the Modaics app
/// Uses protocol definitions from Core/
class ServiceLocator {
    static let shared = ServiceLocator()
    
    // MARK: - Services
    private(set) lazy var authService: AuthServiceProtocol = {
        #if canImport(FirebaseAuth)
        FirebaseAuthService()
        #else
        MockAuthService()
        #endif
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
    
    // MARK: - Use Cases
    private(set) lazy var getGarmentsUseCase: GetGarmentsUseCaseProtocol = {
        GetGarmentsUseCase(repository: garmentRepository)
    }()
    
    private(set) lazy var createGarmentUseCase: CreateGarmentUseCaseProtocol = {
        CreateGarmentUseCase(repository: garmentRepository)
    }()
    
    private(set) lazy var updateGarmentUseCase: UpdateGarmentUseCaseProtocol = {
        UpdateGarmentUseCase(repository: garmentRepository)
    }()
    
    private(set) lazy var deleteGarmentUseCase: DeleteGarmentUseCaseProtocol = {
        DeleteGarmentUseCase(repository: garmentRepository)
    }()
    
    private(set) lazy var getStoriesUseCase: GetStoriesUseCaseProtocol = {
        GetStoriesUseCase(repository: storyRepository)
    }()
    
    private(set) lazy var createStoryUseCase: CreateStoryUseCaseProtocol = {
        CreateStoryUseCase(repository: storyRepository)
    }()
    
    private(set) lazy var getDiscoveryFeedUseCase: GetDiscoveryFeedUseCaseProtocol = {
        GetDiscoveryFeedUseCase(repository: discoveryRepository)
    }()
    
    private(set) lazy var getUserProfileUseCase: GetUserProfileUseCaseProtocol = {
        GetUserProfileUseCase(repository: userRepository)
    }()
    
    private(set) lazy var uploadImageUseCase: UploadImageUseCaseProtocol = {
        UploadImageUseCase(imageService: imageService)
    }()
    
    // MARK: - Configuration
    func configure() {
        // Register for notifications
        setupNotifications()
        
        // Configure offline storage
        offlineStorage.configure()
        
        logger.log("ServiceLocator configured", level: .info)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAuthStateChange),
            name: .authStateChanged,
            object: nil
        )
    }
    
    @objc private func handleAuthStateChange() {
        // Clear caches when auth state changes
        apiClient.clearCache()
    }
    
    // MARK: - ViewModel Factories
    func discoveryViewModel() -> DiscoveryViewModel {
        DiscoveryViewModel(
            getDiscoveryFeedUseCase: getDiscoveryFeedUseCase,
            logger: logger
        )
    }
    
    func wardrobeViewModel() -> WardrobeViewModel {
        WardrobeViewModel(
            getGarmentsUseCase: getGarmentsUseCase,
            createGarmentUseCase: createGarmentUseCase,
            deleteGarmentUseCase: deleteGarmentUseCase,
            logger: logger
        )
    }
    
    func profileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            getUserProfileUseCase: getUserProfileUseCase,
            authService: authService,
            logger: logger
        )
    }
    
    func garmentDetailViewModel(garmentId: String) -> GarmentDetailViewModel {
        GarmentDetailViewModel(
            garmentId: garmentId,
            garmentRepository: garmentRepository,
            getStoriesUseCase: getStoriesUseCase,
            logger: logger
        )
    }
    
    func storyComposerViewModel() -> StoryComposerViewModel {
        StoryComposerViewModel(
            createStoryUseCase: createStoryUseCase,
            uploadImageUseCase: uploadImageUseCase,
            garmentRepository: garmentRepository,
            logger: logger
        )
    }
    
    func settingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            authService: authService,
            logger: logger
        )
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
    
    // MARK: - Mock ViewModels
    func mockDiscoveryViewModel() -> DiscoveryViewModel {
        DiscoveryViewModel(
            getDiscoveryFeedUseCase: MockGetDiscoveryFeedUseCase(),
            logger: mockLogger
        )
    }
    
    func mockWardrobeViewModel() -> WardrobeViewModel {
        WardrobeViewModel(
            getGarmentsUseCase: MockGetGarmentsUseCase(),
            createGarmentUseCase: MockCreateGarmentUseCase(),
            deleteGarmentUseCase: MockDeleteGarmentUseCase(),
            logger: mockLogger
        )
    }
    
    func mockProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            getUserProfileUseCase: MockGetUserProfileUseCase(),
            authService: mockAuthService,
            logger: mockLogger
        )
    }
}
