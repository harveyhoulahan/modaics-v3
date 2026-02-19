import Foundation
#if canImport(FirebaseAuth)
import FirebaseAuth
#endif
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Environment
/// App environment configuration
public enum Environment: String, Sendable {
    case development = "development"
    case staging = "staging"
    case production = "production"
    
    /// Current environment - change this for builds
    public static let current: Environment = .development
    
    /// Base URL for API calls
    public var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "http://localhost:8000")!
        case .staging:
            return URL(string: "https://api-staging.modaics.com")!
        case .production:
            return URL(string: "https://api.modaics.com")!
        }
    }
    
    /// API version to use
    public var apiVersion: String {
        "v2.0" // v3.5 uses v2.0 API
    }
    
    /// Whether to use verbose logging
    public var enableVerboseLogging: Bool {
        switch self {
        case .development: return true
        case .staging: return true
        case .production: return false
        }
    }
}

// MARK: - Firebase Auth Service

#if canImport(FirebaseAuth)
class FirebaseAuthService: AuthServiceProtocol {
    var currentUser: User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName ?? "User",
            avatarUrl: firebaseUser.photoURL?.absoluteString,
            bio: nil,
            garmentCount: 0,
            storyCount: 0,
            followerCount: 0
        )
    }
    
    func signIn(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
        NotificationCenter.default.post(name: .authStateChanged, object: nil)
    }
    
    func signUp(email: String, password: String) async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
        NotificationCenter.default.post(name: .authStateChanged, object: nil)
    }
    
    func signInWithApple() async throws {
        // Implementation for Apple Sign In
        // Would use ASAuthorizationController
        throw AuthError.notImplemented
    }
    
    func signInWithGoogle() async throws {
        // Implementation for Google Sign In
        // Would use GoogleSignIn SDK
        throw AuthError.notImplemented
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        NotificationCenter.default.post(name: .authStateChanged, object: nil)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
#endif

enum AuthError: Error {
    case notImplemented
    case signInFailed
    case invalidCredentials
    case userNotFound
}

// MARK: - Firebase Auth Token Provider

#if canImport(FirebaseAuth)
class FirebaseAuthTokenProvider: AuthTokenProvider {
    func getToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        return try await user.getIDToken()
    }
    
    func refreshToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        return try await user.getIDToken(forcingRefresh: true)
    }
    
    func clearToken() {
        // Token is managed by Firebase
    }
}
#endif

// MARK: - Legacy API Client (v1)
/// Maintained for backward compatibility during migration
class APIClient: APIClientProtocol {
    private let baseURL = "https://api.modaics.com/v1"
    private let authService: AuthServiceProtocol
    private var cache: [String: Data] = [:]
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func get<T: Decodable>(_ path: String) async throws -> T {
        let request = try makeRequest(path: path, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        var request = try makeRequest(path: path, method: "POST")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func put<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        var request = try makeRequest(path: path, method: "PUT")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func delete(_ path: String) async throws {
        let request = try makeRequest(path: path, method: "DELETE")
        _ = try await URLSession.shared.data(for: request)
    }
    
    func upload(_ path: String, data: Data, filename: String) async throws -> String {
        // Multipart upload implementation
        return "https://cdn.modaics.com/\(filename)"
    }
    
    func clearCache() {
        cache.removeAll()
    }
    
    private func makeRequest(path: String, method: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if available
        if let user = authService.currentUser {
            // In real implementation, would get Firebase ID token
            request.setValue("Bearer \(user.id)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}

// MARK: - Unified API Client V2 (v3.5)
/// New unified API client using v2.0 endpoints
@MainActor
class APIClientV2Service: APIClientV2Protocol {
    private let client: APIClientV2
    
    init(configuration: APIConfiguration, tokenProvider: AuthTokenProvider? = nil, logger: LoggerProtocol? = nil) {
        self.client = APIClientV2(
            configuration: configuration,
            tokenProvider: tokenProvider,
            logger: logger
        )
    }
    
    func get<T: Decodable>(_ path: String) async throws -> T {
        try await client.get(path)
    }
    
    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        try await client.post(path, body: body)
    }
    
    func put<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        try await client.put(path, body: body)
    }
    
    func delete(_ path: String) async throws {
        try await client.delete(path)
    }
    
    func uploadImageForSearch(imageData: Data, endpoint: String, topK: Int, sourceFilter: [String]) async throws -> VisualSearchResponse {
        try await client.uploadImageForSearch(
            imageData: imageData,
            endpoint: endpoint,
            topK: topK,
            sourceFilter: sourceFilter
        )
    }
    
    func uploadImageForEmbedding(imageData: Data, endpoint: String) async throws -> EmbeddingResponse {
        try await client.uploadImageForEmbedding(
            imageData: imageData,
            endpoint: endpoint
        )
    }
    
    /// Create a garment with images
    func createGarment(garment: Garment, images: [Data]) async throws -> Garment {
        try await client.createGarment(garment: garment, images: images)
    }
    
    /// Perform AI analysis on photos
    func analyzeGarmentPhotos(photos: [Data], generateStory: Bool, suggestPrice: Bool) async throws -> AIAnalysisResponse {
        try await client.analyzeGarmentPhotos(
            photos: photos,
            generateStory: generateStory,
            suggestPrice: suggestPrice
        )
    }
    
    /// Visual search
    func searchByImage(imageData: Data, topK: Int, sourceFilter: [GarmentSource]?) async throws -> VisualSearchResponse {
        try await client.searchByImage(
            imageData: imageData,
            topK: topK,
            sourceFilter: sourceFilter
        )
    }
}

// MARK: - Image Service

class ImageService: ImageServiceProtocol {
    private var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    func uploadImage(_ image: UIImage, path: String) async throws -> String {
        // Compress and upload image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ImageError.compressionFailed
        }
        
        // Upload to storage (Firebase Storage or similar)
        return "https://cdn.modaics.com/\(path)"
    }
    
    func downloadImage(url: String) async throws -> UIImage {
        // Check cache first
        if let cached = getCachedImage(for: url) {
            return cached
        }
        
        guard let imageURL = URL(string: url) else {
            throw ImageError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: imageURL)
        guard let image = UIImage(data: data) else {
            throw ImageError.invalidData
        }
        
        cacheImage(image, for: url)
        return image
    }
    
    func cacheImage(_ image: UIImage, for key: String) {
        imageCache.setObject(image, forKey: key as NSString)
    }
    
    func getCachedImage(for key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
}

enum ImageError: Error {
    case compressionFailed
    case invalidURL
    case invalidData
    case uploadFailed
}

// MARK: - Offline Storage

class CoreDataOfflineStorage: OfflineStorageProtocol {
    func configure() {
        // Core Data stack setup
    }
    
    func saveGarment(_ garment: Garment) async throws {
        // Save to Core Data
    }
    
    func getGarments() async throws -> [Garment] {
        // Fetch from Core Data
        return []
    }
    
    func getGarment(id: String) async throws -> Garment? {
        return nil
    }
    
    func deleteGarment(id: String) async throws {
        // Delete from Core Data
    }
    
    func saveStory(_ story: Story) async throws {
        // Save to Core Data
    }
    
    func getStories(for garmentId: String) async throws -> [Story] {
        return []
    }
    
    func syncPendingChanges() async throws {
        // Sync with backend
    }
}

// MARK: - Logger

class ConsoleLogger: LoggerProtocol {
    private let environment: Environment
    
    init(environment: Environment = Environment.current) {
        self.environment = environment
    }
    
    func log(_ message: String, level: LogLevel) {
        guard environment.enableVerboseLogging || level != .debug else { return }
        
        let prefix: String
        switch level {
        case .debug: prefix = "🔍"
        case .info: prefix = "ℹ️"
        case .warning: prefix = "⚠️"
        case .error: prefix = "❌"
        }
        print("\(prefix) [Modaics] \(message)")
    }
}

// MARK: - Services Container

/// Central container for all app services
/// v3.5: Uses unified API client with v2.0 endpoints
@MainActor
class Services {
    static let shared = Services()
    
    // MARK: - Environment
    
    let environment: Environment = Environment.current
    
    // MARK: - Configuration
    
    lazy var apiConfiguration: APIConfiguration = {
        APIConfiguration(
            baseURL: environment.baseURL,
            apiVersion: environment.apiVersion,
            timeout: 30.0,
            retryCount: 3
        )
    }()
    
    // MARK: - Services
    
    private(set) lazy var authService: AuthServiceProtocol = {
        FirebaseAuthService()
    }()
    
    private(set) lazy var authTokenProvider: AuthTokenProvider = {
        FirebaseAuthTokenProvider()
    }()
    
    /// Legacy v1 API client (for backward compatibility)
    private(set) lazy var apiClient: APIClientProtocol = {
        APIClient(authService: authService)
    }()
    
    /// v3.5: Unified v2.0 API client
    private(set) lazy var apiClientV2: APIClientV2Protocol = {
        APIClientV2Service(
            configuration: apiConfiguration,
            tokenProvider: authTokenProvider,
            logger: logger
        )
    }()
    
    private(set) lazy var imageService: ImageServiceProtocol = {
        ImageService()
    }()
    
    private(set) lazy var offlineStorage: OfflineStorageProtocol = {
        CoreDataOfflineStorage()
    }()
    
    private(set) lazy var logger: LoggerProtocol = {
        ConsoleLogger(environment: environment)
    }()
    
    // MARK: - v3.5: Style Matching Service
    
    private(set) lazy var styleMatchingService: StyleMatchingServiceProtocol = {
        StyleMatchingService(
            apiClient: apiClientV2,
            logger: logger
        )
    }()
    
    // MARK: - Repositories
    
    private(set) lazy var garmentRepository: GarmentRepositoryProtocol = {
        GarmentRepository(
            apiClient: apiClientV2,
            offlineStorage: offlineStorage,
            logger: logger
        )
    }()
    
    private(set) lazy var storyRepository: StoryRepositoryProtocol = {
        StoryRepository(
            apiClient: apiClientV2,
            offlineStorage: offlineStorage,
            logger: logger
        )
    }()
    
    private(set) lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(
            apiClient: apiClientV2,
            logger: logger
        )
    }()
    
    private(set) lazy var discoveryRepository: DiscoveryRepositoryProtocol = {
        DiscoveryRepository(
            apiClient: apiClientV2,
            logger: logger
        )
    }()
    
    // MARK: - Configuration
    
    func configure() {
        // Configure offline storage
        offlineStorage.configure()
        
        logger.log("Services configured for environment: \(environment.rawValue)", level: .info)
        logger.log("API Base URL: \(environment.baseURL.absoluteString)", level: .info)
        logger.log("API Version: \(environment.apiVersion)", level: .info)
    }
    
    // MARK: - Health Check
    
    func performHealthCheck() async -> Bool {
        do {
            // Try to fetch discovery feed as health check
            let _: DiscoveryFeed = try await apiClientV2.get("/discovery")
            logger.log("Health check passed", level: .info)
            return true
        } catch {
            logger.log("Health check failed: \(error.localizedDescription)", level: .error)
            return false
        }
    }
}

// MARK: - Protocol Definitions

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signInWithApple() async throws
    func signInWithGoogle() async throws
    func signOut() throws
    func resetPassword(email: String) async throws
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
    func getGarment(id: String) async throws -> Garment?
    func deleteGarment(id: String) async throws
    func saveStory(_ story: Story) async throws
    func getStories(for garmentId: String) async throws -> [Story]
    func syncPendingChanges() async throws
}

protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel)
}

enum LogLevel {
    case debug, info, warning, error
}

// MARK: - Repository Protocols

protocol GarmentRepositoryProtocol {
    func get(by id: UUID) async throws -> Garment
    func get(ids: [UUID]) async throws -> [Garment]
    func create(_ garment: Garment) async throws -> Garment
    func update(_ garment: Garment) async throws -> Garment
    func delete(id: UUID) async throws
    func exists(id: UUID) async throws -> Bool
    func getByOwner(userId: UUID) async throws -> [Garment]
    func getByOwner(userId: UUID, page: Int, limit: Int) async throws -> PaginatedResult<Garment>
    func getByOwner(userId: UUID, isListed: Bool) async throws -> [Garment]
    func listGarment(id: UUID, exchangeType: ExchangeType, price: Decimal?) async throws -> Garment
    func delistGarment(id: UUID) async throws -> Garment
    func updatePrice(id: UUID, newPrice: Decimal?) async throws -> Garment
    func createBatch(_ garments: [Garment]) async throws -> [Garment]
    func updateBatch(_ garments: [Garment]) async throws -> [Garment]
    func deleteBatch(ids: [UUID]) async throws
    func search(query: String) async throws -> [Garment]
    func search(query: String, ownerId: UUID) async throws -> [Garment]
    func filter(_ criteria: GarmentFilterCriteria) async throws -> [Garment]
    func filter(_ criteria: GarmentFilterCriteria, page: Int, limit: Int) async throws -> PaginatedResult<Garment>
    func countByOwner(userId: UUID) async throws -> Int
    func countListedByOwner(userId: UUID) async throws -> Int
    func totalValueByOwner(userId: UUID) async throws -> Decimal
}

protocol StoryRepositoryProtocol {
    func getStories(for garmentId: String) async throws -> [Story]
    func createStory(_ story: Story) async throws -> Story
    func deleteStory(id: String) async throws
}

protocol UserRepositoryProtocol {
    func getCurrentUser() async throws -> User
    func updateUser(_ user: User) async throws -> User
    func getUser(id: String) async throws -> User
}

protocol DiscoveryRepositoryProtocol {
    func getTrendingStories() async throws -> [Story]
    func getRecentGarments() async throws -> [Garment]
    func getCollections() async throws -> [Collection]
    func search(query: String) async throws -> SearchResults
}

// MARK: - Story Repository Implementation

class StoryRepository: StoryRepositoryProtocol {
    private let apiClient: APIClientV2Protocol
    private let offlineStorage: OfflineStorageProtocol
    private let logger: LoggerProtocol
    
    init(
        apiClient: APIClientV2Protocol,
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

// MARK: - User Repository Implementation

class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClientV2Protocol
    private let logger: LoggerProtocol
    
    init(
        apiClient: APIClientV2Protocol,
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

// MARK: - Discovery Repository Implementation

class DiscoveryRepository: DiscoveryRepositoryProtocol {
    private let apiClient: APIClientV2Protocol
    private let logger: LoggerProtocol
    
    init(
        apiClient: APIClientV2Protocol,
        logger: LoggerProtocol
    ) {
        self.apiClient = apiClient
        self.logger = logger
    }
    
    func getTrendingStories() async throws -> [Story] {
        let stories: [Story] = try await apiClient.get("/discovery/trending/stories")
        return stories
    }
    
    func getRecentGarments() async throws -> [Garment] {
        let garments: [Garment] = try await apiClient.get("/discovery/recent/garments")
        return garments
    }
    
    func getCollections() async throws -> [Collection] {
        let collections: [Collection] = try await apiClient.get("/discovery/collections")
        return collections
    }
    
    func search(query: String) async throws -> SearchResults {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let results: SearchResults = try await apiClient.get("/discovery/search?q=\(encodedQuery)")
        return results
    }
}

// MARK: - API Errors

enum APIError: Error {
    case invalidURL
    case unauthorized
    case notFound
    case serverError
    case decodingError
}

// MARK: - Notification Names

extension Notification.Name {
    static let authStateChanged = Notification.Name("authStateChanged")
}

// MARK: - Legacy Model Types (for backward compatibility)

struct User: Identifiable, Codable, Sendable {
    let id: String
    var email: String
    var displayName: String
    var avatarUrl: String?
    var bio: String?
    var garmentCount: Int
    var storyCount: Int
    var followerCount: Int
}

struct Collection: Identifiable, Codable, Sendable {
    let id: String
    var title: String
    var description: String
    var imageUrl: String
    var garmentCount: Int
}

struct SearchResults: Codable, Sendable {
    var garments: [Garment]
    var stories: [Story]
    var users: [User]
}

struct DiscoveryFeed: Codable, Sendable {
    var trendingStories: [Story]
    var recentGarments: [Garment]
    var collections: [Collection]
}
