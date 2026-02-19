import Foundation

// MARK: - StyleMatchingServiceProtocol
/// Service for matching garments with users based on style preferences,
/// visual embeddings, and compatibility analysis
/// v3.5: Updated for 768-dim embeddings and visual search
public protocol StyleMatchingServiceProtocol: Sendable {
    
    // MARK: - Legacy Compatibility (Text-based)
    
    /// Calculate style compatibility score between a user and a garment
    func calculateCompatibility(userId: UUID, garmentId: UUID) async throws -> CompatibilityScore
    
    /// Get reasons why a garment matches a user's style
    func getMatchReasons(userId: UUID, garmentId: UUID) async throws -> [String]
    
    /// Find potential matches for a user's wardrobe gaps
    func findMatchesForWardrobeGaps(userId: UUID, limit: Int) async throws -> [GarmentMatch]
    
    /// Analyze a user's style profile based on their wardrobe
    func analyzeStyleProfile(userId: UUID) async throws -> StyleProfile
    
    /// Suggest style improvements for a wardrobe
    func suggestStyleImprovements(wardrobeId: UUID) async throws -> [StyleSuggestion]
    
    /// Check if two garments would work well together
    func checkGarmentCompatibility(garmentId1: UUID, garmentId2: UUID) async throws -> OutfitCompatibility
    
    /// Generate outfit combinations from a wardrobe
    func generateOutfitCombinations(wardrobeId: UUID, occasion: String?) async throws -> [OutfitCombination]
    
    /// Get pricing guidance based on market data
    func getPricingGuidance(for garment: Garment) async throws -> PricingGuidance
    
    // MARK: - Visual Search (v3.5)
    
    /// Search for visually similar garments using an image
    /// Uses /search_by_image endpoint with 768-dim embeddings
    func searchByImage(
        imageData: Data,
        topK: Int,
        sourceFilter: [GarmentSource]
    ) async throws -> VisualSearchResponse
    
    /// Search for visually similar garments using an image URL
    func searchByImageUrl(
        imageUrl: URL,
        topK: Int,
        sourceFilter: [GarmentSource]
    ) async throws -> VisualSearchResponse
    
    /// Search for visually similar garments using a pre-computed embedding
    func searchByEmbedding(
        embedding: [Float],
        topK: Int,
        sourceFilter: [GarmentSource]
    ) async throws -> VisualSearchResponse
    
    /// Find similar garments to a given garment ID
    func findSimilarGarments(
        garmentId: UUID,
        topK: Int,
        sourceFilter: [GarmentSource]
    ) async throws -> VisualSearchResponse
    
    // MARK: - Embedding Operations (v3.5)
    
    /// Generate a 768-dim embedding for an image
    func generateEmbedding(for imageData: Data) async throws -> [Float]
    
    /// Calculate cosine similarity between two embeddings
    func calculateSimilarity(embedding1: [Float], embedding2: [Float]) -> Float
    
    /// Find nearest neighbors in embedding space
    func findNearestNeighbors(
        queryEmbedding: [Float],
        candidateEmbeddings: [[Float]],
        topK: Int
    ) -> [(index: Int, similarity: Float)]
}

// MARK: - Supporting Types

public struct CompatibilityScore: Codable, Hashable, Sendable {
    public let overall: Double // 0-100
    public let styleMatch: Double // 0-100
    public let sizeMatch: Double // 0-100
    public let colorMatch: Double // 0-100
    public let brandPreference: Double // 0-100
    public let sustainabilityAlignment: Double // 0-100
    
    public init(
        overall: Double,
        styleMatch: Double = 0,
        sizeMatch: Double = 0,
        colorMatch: Double = 0,
        brandPreference: Double = 0,
        sustainabilityAlignment: Double = 0
    ) {
        self.overall = overall
        self.styleMatch = styleMatch
        self.sizeMatch = sizeMatch
        self.colorMatch = colorMatch
        self.brandPreference = brandPreference
        self.sustainabilityAlignment = sustainabilityAlignment
    }
}

public struct GarmentMatch: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let garmentId: UUID
    public let score: CompatibilityScore
    public let reasons: [String]
    public let gapCategory: String?
    
    public init(
        id: UUID = UUID(),
        garmentId: UUID,
        score: CompatibilityScore,
        reasons: [String] = [],
        gapCategory: String? = nil
    ) {
        self.id = id
        self.garmentId = garmentId
        self.score = score
        self.reasons = reasons
        self.gapCategory = gapCategory
    }
}

public struct StyleProfile: Codable, Hashable, Sendable {
    public let dominantAesthetic: Aesthetic?
    public let secondaryAesthetics: [Aesthetic]
    public let preferredColors: [String]
    public let preferredBrands: [String]
    public let preferredCategories: [Category]
    public let sizeConsistency: Double // 0-100
    public let sustainabilityPriority: Double // 0-100
    public let vintageAffinity: Double // 0-100
    public let luxuryAffinity: Double // 0-100
    public let keyStyleWords: [String]
    
    public init(
        dominantAesthetic: Aesthetic? = nil,
        secondaryAesthetics: [Aesthetic] = [],
        preferredColors: [String] = [],
        preferredBrands: [String] = [],
        preferredCategories: [Category] = [],
        sizeConsistency: Double = 0,
        sustainabilityPriority: Double = 0,
        vintageAffinity: Double = 0,
        luxuryAffinity: Double = 0,
        keyStyleWords: [String] = []
    ) {
        self.dominantAesthetic = dominantAesthetic
        self.secondaryAesthetics = secondaryAesthetics
        self.preferredColors = preferredColors
        self.preferredBrands = preferredBrands
        self.preferredCategories = preferredCategories
        self.sizeConsistency = sizeConsistency
        self.sustainabilityPriority = sustainabilityPriority
        self.vintageAffinity = vintageAffinity
        self.luxuryAffinity = luxuryAffinity
        self.keyStyleWords = keyStyleWords
    }
}

public struct StyleSuggestion: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let type: StyleSuggestionType
    public let title: String
    public let description: String
    public let priority: SuggestionPriority
    public let expectedImpact: String
    
    public init(
        id: UUID = UUID(),
        type: StyleSuggestionType,
        title: String,
        description: String,
        priority: SuggestionPriority = .medium,
        expectedImpact: String = ""
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.priority = priority
        self.expectedImpact = expectedImpact
    }
}

public enum StyleSuggestionType: String, Codable, Hashable, Sendable {
    case addColor = "add_color"
    case addCategory = "add_category"
    case improveCohesion = "improve_cohesion"
    case increaseVersatility = "increase_versatility"
    case reduceDuplicates = "reduce_duplicates"
    case upgradeQuality = "upgrade_quality"
    case addBasics = "add_basics"
    case addStatementPieces = "add_statement_pieces"
}

public enum SuggestionPriority: String, Codable, Hashable, Sendable {
    case high = "high"
    case medium = "medium"
    case low = "low"
}

public struct OutfitCompatibility: Codable, Hashable, Sendable {
    public let score: Double // 0-100
    public let colorHarmony: Double // 0-100
    public let textureMix: Double // 0-100
    public let silhouetteBalance: Double // 0-100
    public let styleCohesion: Double // 0-100
    public let suggestions: [String]
    
    public init(
        score: Double,
        colorHarmony: Double = 0,
        textureMix: Double = 0,
        silhouetteBalance: Double = 0,
        styleCohesion: Double = 0,
        suggestions: [String] = []
    ) {
        self.score = score
        self.colorHarmony = colorHarmony
        self.textureMix = textureMix
        self.silhouetteBalance = silhouetteBalance
        self.styleCohesion = styleCohesion
        self.suggestions = suggestions
    }
}

public struct OutfitCombination: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let garmentIds: [UUID]
    public let name: String
    public let occasion: String
    public let compatibility: OutfitCompatibility
    public let season: Season?
    
    public init(
        id: UUID = UUID(),
        garmentIds: [UUID],
        name: String,
        occasion: String,
        compatibility: OutfitCompatibility,
        season: Season? = nil
    ) {
        self.id = id
        self.garmentIds = garmentIds
        self.name = name
        self.occasion = occasion
        self.compatibility = compatibility
        self.season = season
    }
}

public enum Season: String, Codable, Hashable, Sendable {
    case spring = "spring"
    case summer = "summer"
    case fall = "fall"
    case winter = "winter"
    case allSeason = "all_season"
}

public enum Aesthetic: String, Codable, Hashable, Sendable {
    case vintage = "vintage"
    case minimalist = "minimalist"
    case bohemian = "bohemian"
    case streetwear = "streetwear"
    case preppy = "preppy"
    case punk = "punk"
    case grunge = "grunge"
    case y2k = "y2k"
    case cottagecore = "cottagecore"
    case darkAcademia = "dark_academia"
    case lightAcademia = "light_academia"
    case sustainable = "sustainable"
    case luxury = "luxury"
    case athleisure = "athleisure"
    case avantGarde = "avant_garde"
}

// MARK: - Pricing Guidance Types

public struct PricingGuidance: Sendable {
    public let suggestedPrice: Decimal
    public let priceRange: (min: Decimal, max: Decimal)
    public let marketDemand: MarketDemand
    public let comparableSales: [ComparableSale]
    public let pricingFactors: [PricingFactor]
    public let recommendedListingPrice: Decimal
    public let estimatedDaysToSell: Int
    public let confidence: Double // 0-1
    
    public init(
        suggestedPrice: Decimal,
        priceRange: (min: Decimal, max: Decimal),
        marketDemand: MarketDemand,
        comparableSales: [ComparableSale],
        pricingFactors: [PricingFactor],
        recommendedListingPrice: Decimal,
        estimatedDaysToSell: Int,
        confidence: Double
    ) {
        self.suggestedPrice = suggestedPrice
        self.priceRange = priceRange
        self.marketDemand = marketDemand
        self.comparableSales = comparableSales
        self.pricingFactors = pricingFactors
        self.recommendedListingPrice = recommendedListingPrice
        self.estimatedDaysToSell = estimatedDaysToSell
        self.confidence = confidence
    }
}

public enum MarketDemand: String, Codable, Hashable, Sendable {
    case veryHigh = "very_high"
    case high = "high"
    case medium = "medium"
    case low = "low"
    case veryLow = "very_low"
}

public struct ComparableSale: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let price: Decimal
    public let date: Date
    public let condition: Condition
    
    public init(id: UUID = UUID(), price: Decimal, date: Date, condition: Condition) {
        self.id = id
        self.price = price
        self.date = date
        self.condition = condition
    }
}

public struct PricingFactor: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let impact: String
    
    public init(id: UUID = UUID(), name: String, impact: String) {
        self.id = id
        self.name = name
        self.impact = impact
    }
}

// MARK: - Implementation

/// Real implementation using the unified API client
public final class StyleMatchingService: StyleMatchingServiceProtocol {
    private let apiClient: APIClientV2Protocol
    private let logger: LoggerProtocol
    
    public init(apiClient: APIClientV2Protocol, logger: LoggerProtocol) {
        self.apiClient = apiClient
        self.logger = logger
    }
    
    // MARK: - Legacy Compatibility
    
    public func calculateCompatibility(userId: UUID, garmentId: UUID) async throws -> CompatibilityScore {
        let response: CompatibilityScoreResponse = try await apiClient.get(
            "/garments/\(garmentId.uuidString)/compatibility?userId=\(userId.uuidString)"
        )
        return response.score
    }
    
    public func getMatchReasons(userId: UUID, garmentId: UUID) async throws -> [String] {
        let response: MatchReasonsResponse = try await apiClient.get(
            "/garments/\(garmentId.uuidString)/match-reasons?userId=\(userId.uuidString)"
        )
        return response.reasons
    }
    
    public func findMatchesForWardrobeGaps(userId: UUID, limit: Int) async throws -> [GarmentMatch] {
        let response: MatchesResponse = try await apiClient.get(
            "/users/\(userId.uuidString)/wardrobe-gaps?limit=\(limit)"
        )
        return response.matches
    }
    
    public func analyzeStyleProfile(userId: UUID) async throws -> StyleProfile {
        let response: StyleProfileResponse = try await apiClient.get(
            "/users/\(userId.uuidString)/style-profile"
        )
        return response.profile
    }
    
    public func suggestStyleImprovements(wardrobeId: UUID) async throws -> [StyleSuggestion] {
        let response: SuggestionsResponse = try await apiClient.get(
            "/wardrobes/\(wardrobeId.uuidString)/style-suggestions"
        )
        return response.suggestions
    }
    
    public func checkGarmentCompatibility(garmentId1: UUID, garmentId2: UUID) async throws -> OutfitCompatibility {
        let request = GarmentCompatibilityRequest(garmentId1: garmentId1, garmentId2: garmentId2)
        let response: OutfitCompatibilityResponse = try await apiClient.post(
            "/garments/check-compatibility",
            body: request
        )
        return response.compatibility
    }
    
    public func generateOutfitCombinations(wardrobeId: UUID, occasion: String?) async throws -> [OutfitCombination] {
        var path = "/wardrobes/\(wardrobeId.uuidString)/outfit-combinations"
        if let occasion = occasion {
            path += "?occasion=\(occasion.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        let response: OutfitCombinationsResponse = try await apiClient.get(path)
        return response.combinations
    }
    
    public func getPricingGuidance(for garment: Garment) async throws -> PricingGuidance {
        let response: PricingGuidanceResponse = try await apiClient.post(
            "/garments/pricing-guidance",
            body: garment
        )
        return response.guidance
    }
    
    // MARK: - Visual Search (v3.5)
    
    public func searchByImage(
        imageData: Data,
        topK: Int,
        sourceFilter: [GarmentSource]
    ) async throws -> VisualSearchResponse {
        // Convert source filter to string array for API
        let sourceStrings = sourceFilter.map { $0.rawValue }
        
        return try await apiClient.uploadImageForSearch(
            imageData: imageData,
            endpoint: "/search_by_image",
            topK: topK,
            sourceFilter: sourceStrings
        )
    }
    
    public func searchByImageUrl(
        imageUrl: URL,
        topK: Int,
        sourceFilter: [GarmentSource]
    ) async throws -> VisualSearchResponse {
        let request = VisualSearchByUrlRequest(
            imageUrl: imageUrl.absoluteString,
            topK: topK,
            sourceFilter: sourceFilter.map { $0.rawValue }
        )
        return try await apiClient.post("/search_by_image", body: request)
    }
    
    public func searchByEmbedding(
        embedding: [Float],
        topK: Int,
        sourceFilter: [GarmentSource]
    ) async throws -> VisualSearchResponse {
        // Validate embedding dimensions
        guard embedding.count == 768 else {
            throw StyleMatchingError.invalidEmbeddingDimensions(expected: 768, actual: embedding.count)
        }
        
        let request = VisualSearchByEmbeddingRequest(
            embedding: embedding,
            topK: topK,
            sourceFilter: sourceFilter.map { $0.rawValue }
        )
        return try await apiClient.post("/search_by_image", body: request)
    }
    
    public func findSimilarGarments(
        garmentId: UUID,
        topK: Int,
        sourceFilter: [GarmentSource]
    ) async throws -> VisualSearchResponse {
        let sourceQuery = sourceFilter.map { "source=\($0.rawValue)" }.joined(separator: "&")
        let path = "/garments/\(garmentId.uuidString)/similar?top_k=\(topK)" + (sourceQuery.isEmpty ? "" : "&\(sourceQuery)")
        return try await apiClient.get(path)
    }
    
    // MARK: - Embedding Operations (v3.5)
    
    public func generateEmbedding(for imageData: Data) async throws -> [Float] {
        let response: EmbeddingResponse = try await apiClient.uploadImageForEmbedding(
            imageData: imageData,
            endpoint: "/embeddings/generate"
        )
        return response.embedding
    }
    
    public func calculateSimilarity(embedding1: [Float], embedding2: [Float]) -> Float {
        guard embedding1.count == embedding2.count else {
            return 0
        }
        
        // Cosine similarity: dot product / (magnitude1 * magnitude2)
        var dotProduct: Float = 0
        var magnitude1: Float = 0
        var magnitude2: Float = 0
        
        for i in 0..<embedding1.count {
            dotProduct += embedding1[i] * embedding2[i]
            magnitude1 += embedding1[i] * embedding1[i]
            magnitude2 += embedding2[i] * embedding2[i]
        }
        
        let denominator = sqrt(magnitude1) * sqrt(magnitude2)
        guard denominator > 0 else { return 0 }
        
        return dotProduct / denominator
    }
    
    public func findNearestNeighbors(
        queryEmbedding: [Float],
        candidateEmbeddings: [[Float]],
        topK: Int
    ) -> [(index: Int, similarity: Float)] {
        // Calculate similarity for all candidates
        var similarities: [(index: Int, similarity: Float)] = []
        
        for (index, candidate) in candidateEmbeddings.enumerated() {
            let similarity = calculateSimilarity(embedding1: queryEmbedding, embedding2: candidate)
            similarities.append((index, similarity))
        }
        
        // Sort by similarity descending
        similarities.sort { $0.similarity > $1.similarity }
        
        // Return top K
        return Array(similarities.prefix(topK))
    }
}

// MARK: - API Response Types

private struct CompatibilityScoreResponse: Decodable {
    let score: CompatibilityScore
}

private struct MatchReasonsResponse: Decodable {
    let reasons: [String]
}

private struct MatchesResponse: Decodable {
    let matches: [GarmentMatch]
}

private struct StyleProfileResponse: Decodable {
    let profile: StyleProfile
}

private struct SuggestionsResponse: Decodable {
    let suggestions: [StyleSuggestion]
}

private struct GarmentCompatibilityRequest: Encodable {
    let garmentId1: UUID
    let garmentId2: UUID
}

private struct OutfitCompatibilityResponse: Decodable {
    let compatibility: OutfitCompatibility
}

private struct OutfitCombinationsResponse: Decodable {
    let combinations: [OutfitCombination]
}

private struct PricingGuidanceResponse: Decodable {
    let guidance: PricingGuidance
}

private struct VisualSearchByUrlRequest: Encodable {
    let imageUrl: String
    let topK: Int
    let sourceFilter: [String]
}

private struct VisualSearchByEmbeddingRequest: Encodable {
    let embedding: [Float]
    let topK: Int
    let sourceFilter: [String]
}

private struct EmbeddingResponse: Decodable {
    let embedding: [Float]
}

// MARK: - Errors

public enum StyleMatchingError: Error {
    case invalidEmbeddingDimensions(expected: Int, actual: Int)
    case visualSearchFailed
    case embeddingGenerationFailed
    case sourceNotSupported(GarmentSource)
}

// MARK: - Logger Protocol Placeholder

public protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel)
}

public enum LogLevel {
    case debug, info, warning, error
}

// MARK: - API Client V2 Protocol

/// Protocol for the unified API client
public protocol APIClientV2Protocol: Sendable {
    func get<T: Decodable>(_ path: String) async throws -> T
    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T
    func put<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T
    func delete(_ path: String) async throws
    func uploadImageForSearch(imageData: Data, endpoint: String, topK: Int, sourceFilter: [String]) async throws -> VisualSearchResponse
    func uploadImageForEmbedding(imageData: Data, endpoint: String) async throws -> EmbeddingResponse
}
