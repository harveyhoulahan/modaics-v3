import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - API Configuration
/// Configuration for API client
public struct APIConfiguration: Sendable {
    public let baseURL: URL
    public let apiVersion: String
    public let timeout: TimeInterval
    public let retryCount: Int
    
    public init(
        baseURL: URL,
        apiVersion: String = "v2.0",
        timeout: TimeInterval = 30.0,
        retryCount: Int = 3
    ) {
        self.baseURL = baseURL
        self.apiVersion = apiVersion
        self.timeout = timeout
        self.retryCount = retryCount
    }
    
    /// Default configuration for local development
    public static let local = APIConfiguration(
        baseURL: URL(string: "http://localhost:8000")!
    )
    
    /// Default configuration for staging
    public static let staging = APIConfiguration(
        baseURL: URL(string: "https://api-staging.modaics.com")!
    )
    
    /// Default configuration for production
    public static let production = APIConfiguration(
        baseURL: URL(string: "https://api.modaics.com")!
    )
}

// MARK: - Auth Token Provider
/// Protocol for providing authentication tokens
public protocol AuthTokenProvider: Sendable {
    func getToken() async throws -> String
    func refreshToken() async throws -> String
    func clearToken()
}

// MARK: - APIClientV2
/// Unified API client for Modaics v3.5
/// Handles all API communication with the unified backend
@MainActor
public final class APIClientV2: APIClientV2Protocol {
    
    // MARK: - Properties
    
    private let configuration: APIConfiguration
    private let tokenProvider: AuthTokenProvider?
    private let logger: LoggerProtocol?
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let urlSession: URLSession
    
    // MARK: - Initialization
    
    public init(
        configuration: APIConfiguration = .local,
        tokenProvider: AuthTokenProvider? = nil,
        logger: LoggerProtocol? = nil
    ) {
        self.configuration = configuration
        self.tokenProvider = tokenProvider
        self.logger = logger
        
        // Configure decoder for ISO8601 dates
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
        
        // Configure encoder
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder = encoder
        
        // Configure URL session
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = configuration.timeout
        config.timeoutIntervalForResource = configuration.timeout * 2
        self.urlSession = URLSession(configuration: config)
    }
    
    // MARK: - Base URL Construction
    
    private func makeURL(path: String) -> URL {
        var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: true)!
        components.path = "/\(configuration.apiVersion)\(path)"
        return components.url!
    }
    
    // MARK: - Request Building
    
    private func makeRequest(
        path: String,
        method: HTTPMethod,
        body: Data? = nil,
        contentType: ContentType = .json
    ) async throws -> URLRequest {
        let url = makeURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Set headers
        request.setValue(contentType.headerValue, forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add auth token if available
        if let tokenProvider = tokenProvider {
            let token = try await tokenProvider.getToken()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    // MARK: - HTTP Methods
    
    public func get<T: Decodable>(_ path: String) async throws -> T {
        let request = try await makeRequest(path: path, method: .get)
        return try await performRequest(request)
    }
    
    public func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        let bodyData = try encoder.encode(body)
        let request = try await makeRequest(path: path, method: .post, body: bodyData)
        return try await performRequest(request)
    }
    
    public func put<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        let bodyData = try encoder.encode(body)
        let request = try await makeRequest(path: path, method: .put, body: bodyData)
        return try await performRequest(request)
    }
    
    public func delete(_ path: String) async throws {
        let request = try await makeRequest(path: path, method: .delete)
        _ = try await performRequest(request) as EmptyResponse
    }
    
    // MARK: - Special Endpoints
    
    /// POST /garments - Create a new garment with image upload
    public func createGarment(
        garment: Garment,
        images: [Data]
    ) async throws -> Garment {
        return try await uploadMultipart(
            path: "/garments",
            garment: garment,
            images: images
        )
    }
    
    /// POST /search_by_image - Visual search with image upload
    public func searchByImage(
        imageData: Data,
        topK: Int = 20,
        sourceFilter: [GarmentSource]? = nil
    ) async throws -> VisualSearchResponse {
        return try await uploadImageForSearch(
            imageData: imageData,
            endpoint: "/search_by_image",
            topK: topK,
            sourceFilter: sourceFilter?.map { $0.rawValue } ?? []
        )
    }
    
    /// POST /analyze - AI analysis for garment photos
    public func analyzeGarmentPhotos(
        photos: [Data],
        generateStory: Bool = true,
        suggestPrice: Bool = true
    ) async throws -> AIAnalysisResponse {
        return try await uploadMultipartAnalysis(
            path: "/analyze",
            photos: photos,
            generateStory: generateStory,
            suggestPrice: suggestPrice
        )
    }
    
    /// POST /payment_intent - Create payment intent
    public func createPaymentIntent(
        amount: Decimal,
        currency: Currency,
        garmentId: UUID
    ) async throws -> PaymentIntent {
        let request = PaymentIntentRequest(
            amount: amount,
            currency: currency.rawValue,
            garmentId: garmentId.uuidString
        )
        return try await post("/payment_intent", body: request)
    }
    
    // MARK: - Multipart Upload
    
    private func uploadMultipart(
        path: String,
        garment: Garment,
        images: [Data]
    ) async throws -> Garment {
        let url = makeURL(path: path)
        var request = try await makeRequest(path: path, method: .post, body: nil, contentType: .multipart)
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add garment JSON
        let garmentData = try encoder.encode(garment)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"garment\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        body.append(garmentData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add images
        for (index, imageData) in images.enumerated() {
            let filename = "image_\(index).jpg"
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        return try await performRequest(request)
    }
    
    private func uploadMultipartAnalysis(
        path: String,
        photos: [Data],
        generateStory: Bool,
        suggestPrice: Bool
    ) async throws -> AIAnalysisResponse {
        let url = makeURL(path: path)
        var request = try await makeRequest(path: path, method: .post, body: nil, contentType: .multipart)
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add options
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"generate_story\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(generateStory)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"suggest_price\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(suggestPrice)\r\n".data(using: .utf8)!)
        
        // Add photos
        for (index, photoData) in photos.enumerated() {
            let filename = "photo_\(index).jpg"
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"photos\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(photoData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        return try await performRequest(request)
    }
    
    // MARK: - Image Upload for Visual Search
    
    public func uploadImageForSearch(
        imageData: Data,
        endpoint: String,
        topK: Int,
        sourceFilter: [String]
    ) async throws -> VisualSearchResponse {
        let url = makeURL(path: endpoint)
        var request = try await makeRequest(path: endpoint, method: .post, body: nil, contentType: .multipart)
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add top_k parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"top_k\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(topK)\r\n".data(using: .utf8)!)
        
        // Add source filter if provided
        for source in sourceFilter {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"source\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(source)\r\n".data(using: .utf8)!)
        }
        
        // Add image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"search.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        return try await performRequest(request)
    }
    
    public func uploadImageForEmbedding(
        imageData: Data,
        endpoint: String
    ) async throws -> EmbeddingResponse {
        let url = makeURL(path: endpoint)
        var request = try await makeRequest(path: endpoint, method: .post, body: nil, contentType: .multipart)
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        return try await performRequest(request)
    }
    
    // MARK: - Request Execution
    
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<configuration.retryCount {
            do {
                let (data, response) = try await urlSession.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                logger?.log("HTTP \(httpResponse.statusCode) - \(request.url?.path ?? "unknown")", level: .debug)
                
                switch httpResponse.statusCode {
                case 200...299:
                    // Handle empty response
                    if T.self == EmptyResponse.self {
                        return EmptyResponse() as! T
                    }
                    return try decoder.decode(T.self, from: data)
                    
                case 401:
                    // Try to refresh token and retry
                    if attempt < configuration.retryCount - 1 {
                        _ = try await tokenProvider?.refreshToken()
                        continue
                    }
                    throw APIError.unauthorized
                    
                case 403:
                    throw APIError.forbidden
                    
                case 404:
                    throw APIError.notFound
                    
                case 400...499:
                    let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
                    throw APIError.clientError(errorResponse?.message ?? "Client error", httpResponse.statusCode)
                    
                case 500...599:
                    throw APIError.serverError
                    
                default:
                    throw APIError.unknown
                }
                
            } catch let error as APIError {
                throw error
            } catch {
                lastError = error
                if attempt < configuration.retryCount - 1 {
                    // Exponential backoff
                    let delay = pow(2.0, Double(attempt))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? APIError.unknown
    }
}

// MARK: - Supporting Types

private enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

private enum ContentType {
    case json
    case multipart
    
    var headerValue: String {
        switch self {
        case .json: return "application/json"
        case .multipart: return "multipart/form-data"
        }
    }
}

private struct EmptyResponse: Decodable {
    init() {}
}

private struct ErrorResponse: Decodable {
    let message: String
    let code: String?
}

struct PaymentIntentRequest: Encodable {
    let amount: Decimal
    let currency: String
    let garmentId: String
}

// MARK: - API Errors

public enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case clientError(String, Int)
    case serverError
    case decodingError
    case encodingError
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized - please sign in again"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .clientError(let message, _):
            return message
        case .serverError:
            return "Server error - please try again later"
        case .decodingError:
            return "Failed to decode response"
        case .encodingError:
            return "Failed to encode request"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Response Types

public struct AIAnalysisResponse: Decodable, Sendable {
    public let suggestedTitle: String?
    public let generatedDescription: String?
    public let generatedStory: String?
    public let detectedCategory: String?
    public let detectedColors: [String]
    public let detectedBrand: String?
    public let detectedCondition: String?
    public let suggestedPrice: PriceSuggestion?
    public let styleTags: [String]
    public let confidence: Double
}

public struct PriceSuggestion: Decodable, Sendable {
    public let min: Decimal
    public let max: Decimal
    public let recommended: Decimal
    public let currency: String
    public let reasoning: String
}

public struct PaymentIntent: Decodable, Sendable {
    public let clientSecret: String
    public let amount: Decimal
    public let currency: String
    public let status: String
}

// MARK: - Logger Protocol (re-export)

public protocol LoggerProtocol: Sendable {
    func log(_ message: String, level: LogLevel)
}

public enum LogLevel {
    case debug, info, warning, error
}

// MARK: - API Client V2 Protocol (re-export for StyleMatchingService)

public protocol APIClientV2Protocol: Sendable {
    func get<T: Decodable>(_ path: String) async throws -> T
    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T
    func put<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T
    func delete(_ path: String) async throws
    func uploadImageForSearch(imageData: Data, endpoint: String, topK: Int, sourceFilter: [String]) async throws -> VisualSearchResponse
    func uploadImageForEmbedding(imageData: Data, endpoint: String) async throws -> EmbeddingResponse
}

extension APIClientV2: APIClientV2Protocol {}
