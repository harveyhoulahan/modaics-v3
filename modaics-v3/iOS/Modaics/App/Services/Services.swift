import Foundation
import FirebaseAuth
import UIKit

// MARK: - Firebase Auth Service
class FirebaseAuthService: AuthServiceProtocol {
    var currentUser: User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return User(
            id: UUID(uuidString: firebaseUser.uid) ?? UUID(),
            displayName: firebaseUser.displayName ?? "User",
            username: firebaseUser.email?.components(separatedBy: "@").first ?? "user",
            bio: "",
            email: firebaseUser.email ?? "",
            avatarURL: firebaseUser.photoURL
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

enum AuthError: Error {
    case notImplemented
    case signInFailed
    case invalidCredentials
    case userNotFound
}

// MARK: - API Client
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

// MARK: - APIError Definition
enum APIError: Error {
    case invalidURL
    case unauthorized
    case notFound
    case serverError
    case decodingError
}

// MARK: - APIClient Protocol
protocol APIClientProtocol {
    func get<T: Decodable>(_ path: String) async throws -> T
    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T
    func put<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T
    func delete(_ path: String) async throws
    func upload(_ path: String, data: Data, filename: String) async throws -> String
    func clearCache()
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

// MARK: - ImageService Protocol
protocol ImageServiceProtocol {
    func uploadImage(_ image: UIImage, path: String) async throws -> String
    func downloadImage(url: String) async throws -> UIImage
    func cacheImage(_ image: UIImage, for key: String)
    func getCachedImage(for key: String) -> UIImage?
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
    
    func getGarment(id: UUID) async throws -> Garment? {
        return nil
    }
    
    func deleteGarment(id: UUID) async throws {
        // Delete from Core Data
    }
    
    func saveStory(_ story: Story) async throws {
        // Save to Core Data
    }
    
    func getStories(for garmentId: UUID) async throws -> [Story] {
        return []
    }
    
    func syncPendingChanges() async throws {
        // Sync with backend
    }
}

// MARK: - OfflineStorage Protocol
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

// MARK: - Logger
class ConsoleLogger: LoggerProtocol {
    func log(_ message: String, level: LogLevel) {
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

// MARK: - Logger Protocol
protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel)
}

enum LogLevel {
    case debug, info, warning, error
}

// MARK: - AuthService Protocol
protocol AuthServiceProtocol {
    var currentUser: User? { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signInWithApple() async throws
    func signInWithGoogle() async throws
    func signOut() throws
    func resetPassword(email: String) async throws
}

// MARK: - Notification Names
extension Notification.Name {
    static let authStateChanged = Notification.Name("authStateChanged")
}
