import Foundation
import FirebaseAuth
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
    
    func garmentDetailViewModel(garmentId: UUID) -> GarmentDetailViewModel {
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

// MARK: - Protocol Definitions

// Services
protocol AuthServiceProtocol {
    var currentUser: User? { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signInWithApple() async throws
    func signInWithGoogle() async throws
    func signOut() throws
    func resetPassword(email: String) async throws
}

// MARK: - APIError Definition
enum APIError: Error {
    case invalidURL
    case unauthorized
    case notFound
    case serverError
    case decodingError
}

protocol APIClientProtocol {
    func get<T: Decodable>(_ path: String) async throws -> T
    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T
    func put<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T
    func delete(_ path: String) async throws
    func upload(_ path: String, data: Data, filename: String) async throws -> String
    func clearCache()
}

protocol ImageServiceProtocol {
    func uploadImage(_ image: UIImage, path: String) async throws -> String
    func downloadImage(url: String) async throws -> UIImage
    func cacheImage(_ image: UIImage, for key: String)
    func getCachedImage(for key: String) -> UIImage?
}

protocol OfflineStorageProtocol {
    func configure()
    func saveGarment(_ garment: Garment) async throws
    func getGarments() async throws -> [Garment]
    func getGarment(id: UUID) async throws -> Garment?
    func deleteGarment(id: UUID) async throws
    func saveStory(_ story: Story) async throws
    func getStories(for garmentId: UUID) async throws -> [Story]
    func syncPendingChanges() async throws
}

protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel)
}

enum LogLevel {
    case debug, info, warning, error
}

// Repositories
protocol GarmentRepositoryProtocol {
    func getGarments() async throws -> [Garment]
    func getGarment(id: UUID) async throws -> Garment
    func createGarment(_ garment: Garment) async throws -> Garment
    func updateGarment(_ garment: Garment) async throws -> Garment
    func deleteGarment(id: UUID) async throws
}

protocol StoryRepositoryProtocol {
    func getStories(for garmentId: UUID) async throws -> [Story]
    func createStory(_ story: Story) async throws -> Story
    func deleteStory(id: UUID) async throws
}

protocol UserRepositoryProtocol {
    func getCurrentUser() async throws -> User
    func updateUser(_ user: User) async throws -> User
    func getUser(id: UUID) async throws -> User
}

protocol DiscoveryRepositoryProtocol {
    func getTrendingStories() async throws -> [Story]
    func getRecentGarments() async throws -> [Garment]
    func getCollections() async throws -> [WardrobeCollection]
    func search(query: String) async throws -> SearchResults
}

// Use Cases
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

// MARK: - DiscoveryFeed Model (for API responses)
struct DiscoveryFeed: Codable {
    var trendingStories: [Story]
    var recentGarments: [Garment]
    var collections: [WardrobeCollection]
    
    enum CodingKeys: String, CodingKey {
        case trendingStories
        case recentGarments
        case collections
    }
}

// MARK: - SearchResults Model (for API responses)
struct SearchResults: Codable {
    var garments: [Garment]
    var stories: [Story]
    var users: [User]
}

// MARK: - Notification Names
extension Notification.Name {
    static let authStateChanged = Notification.Name("authStateChanged")
}