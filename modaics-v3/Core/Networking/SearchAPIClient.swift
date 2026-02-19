import Foundation
import UIKit

// MARK: - SearchAPIClient
/// Client for AI-powered search and garment analysis
public actor SearchAPIClient {
    
    // MARK: - Shared Instance
    public static let shared = SearchAPIClient()
    
    // MARK: - Properties
    private let baseURL: URL
    private let session: URLSession
    
    // MARK: - Initialization
    public init(baseURL: URL? = nil) {
        self.baseURL = baseURL ?? URL(string: "https://api.modaics.com/v1")!
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 120
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Search
    
    /// Perform a search with the given parameters
    public func search(parameters: SearchParameters) async throws -> SearchResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 800_000_000)
        
        // Return mock data
        var items = FashionItem.sampleItems
        
        // Apply category filter if specified
        if let category = parameters.category {
            items = items.filter { $0.category == category }
        }
        
        // Apply condition filter if specified
        if let condition = parameters.condition {
            items = items.filter { $0.condition == condition }
        }
        
        // Apply price filters
        if let minPrice = parameters.minPrice {
            items = items.filter { $0.price >= minPrice }
        }
        if let maxPrice = parameters.maxPrice {
            items = items.filter { $0.price <= maxPrice }
        }
        
        // Apply sustainability filter
        if parameters.sustainabilityOnly {
            items = items.filter { $0.sustainabilityScore >= 60 }
        }
        
        // Apply vintage filter
        if parameters.vintageOnly {
            items = items.filter { $0.isVintage }
        }
        
        // Apply search query
        if let query = parameters.query, !query.isEmpty {
            let lowerQuery = query.lowercased()
            items = items.filter {
                $0.name.lowercased().contains(lowerQuery) ||
                $0.brand.lowercased().contains(lowerQuery) ||
                $0.description.lowercased().contains(lowerQuery)
            }
        }
        
        // Apply sorting
        switch parameters.sortBy {
        case .recent:
            items.sort { $0.createdAt > $1.createdAt }
        case .alphabetical:
            items.sort { $0.name < $1.name }
        case .brand:
            items.sort { $0.brand < $1.brand }
        case .condition:
            let conditionOrder: [Condition] = [.new, .likeNew, .excellent, .good, .fair]
            items.sort { item1, item2 in
                guard let index1 = conditionOrder.firstIndex(of: item1.condition),
                      let index2 = conditionOrder.firstIndex(of: item2.condition) else {
                    return false
                }
                return index1 < index2
            }
        }
        
        // Paginate
        let startIndex = (parameters.page - 1) * parameters.limit
        let endIndex = min(startIndex + parameters.limit, items.count)
        let paginatedItems = Array(items[startIndex..<min(endIndex, items.count)])
        
        return SearchResponse(
            items: paginatedItems,
            totalCount: items.count,
            hasMore: endIndex < items.count
        )
    }
    
    /// Perform visual search with an image
    public func visualSearch(image: UIImage, parameters: SearchParameters) async throws -> SearchResponse {
        // Simulate network delay for image processing
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Return all items as "visually similar" for mock
        return try await search(parameters: parameters)
    }
    
    /// Get search suggestions for a query
    public func getSearchSuggestions(query: String) async throws -> [SearchSuggestion] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let allSuggestions = [
            SearchSuggestion(text: "Vintage Denim", type: .style),
            SearchSuggestion(text: "Cashmere Sweater", type: .category),
            SearchSuggestion(text: "Chanel", type: .brand),
            SearchSuggestion(text: "Leather Jacket", type: .category),
            SearchSuggestion(text: "Nike Air Force", type: .brand),
            SearchSuggestion(text: "Wool Coat", type: .category),
            SearchSuggestion(text: "Sustainable Fashion", type: .style)
        ]
        
        let lowerQuery = query.lowercased()
        return allSuggestions.filter { $0.text.lowercased().contains(lowerQuery) }
    }
    
    /// Get trending searches
    public func getTrendingSearches() async throws -> [SearchSuggestion] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return [
            SearchSuggestion(text: "Vintage Denim", type: .trending),
            SearchSuggestion(text: "Sustainable Brands", type: .trending),
            SearchSuggestion(text: "Cashmere", type: .trending),
            SearchSuggestion(text: "Leather Bags", type: .trending),
            SearchSuggestion(text: "Winter Coats", type: .trending),
            SearchSuggestion(text: "Designer Shoes", type: .trending)
        ]
    }
    
    // MARK: - AI Analysis
    
    /// Analyze an image to extract garment information
    public func analyzeImage(_ image: UIImage) async throws -> AIGarmentAnalysis {
        // Simulate network delay for AI processing
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Return mock AI analysis
        return AIGarmentAnalysis(
            title: "Vintage Wool Coat",
            category: .outerwear,
            condition: .excellent,
            materials: [
                AIMaterial(name: "Wool", percentage: 80, isSustainable: true),
                AIMaterial(name: "Cashmere", percentage: 20, isSustainable: true)
            ],
            colors: ["Camel", "Brown"],
            estimatedPrice: Decimal(245),
            sustainabilityScore: 78,
            confidence: 0.92,
            suggestions: [
                "Consider mentioning the vintage origin",
                "Highlight the wool-cashmere blend",
                "Note the timeless design"
            ]
        )
    }
    
    /// Analyze multiple images for better accuracy
    public func analyzeImages(_ images: [UIImage]) async throws -> AIGarmentAnalysis {
        guard let firstImage = images.first else {
            throw SearchAPIError.noImagesProvided
        }
        
        // In real implementation, would send all images
        // For now, just analyze the first one
        var analysis = try await analyzeImage(firstImage)
        analysis.imageCount = images.count
        return analysis
    }
    
    /// Search for similar items
    public func searchSimilar(image: UIImage) async throws -> [SimilarItem] {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        return [
            SimilarItem(
                id: UUID(),
                title: "Similar Wool Coat",
                brand: "Max Mara",
                price: Decimal(320),
                condition: .veryGood,
                imageURL: nil
            ),
            SimilarItem(
                id: UUID(),
                title: "Camel Coat Vintage",
                brand: "Burberry",
                price: Decimal(450),
                condition: .excellent,
                imageURL: nil
            )
        ]
    }
    
    /// Get sustainability analysis
    public func analyzeSustainability(
        materials: [AIMaterial],
        brand: String?,
        isRecycled: Bool
    ) async throws -> SustainabilityAnalysis {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        var score = 50
        
        // Material points
        for material in materials {
            if material.isSustainable {
                score += 10
            }
        }
        
        // Recycled bonus
        if isRecycled {
            score += 15
        }
        
        // Cap at 100
        score = min(100, score)
        
        return SustainabilityAnalysis(
            score: score,
            carbonSavingsKg: Double.random(in: 5...25),
            waterSavingsLiters: Double.random(in: 500...2000),
            rating: score >= 80 ? .excellent : score >= 60 ? .good : score >= 40 ? .average : .needsImprovement,
            suggestions: generateSustainabilitySuggestions(materials: materials, isRecycled: isRecycled)
        )
    }
    
    private func generateSustainabilitySuggestions(
        materials: [AIMaterial],
        isRecycled: Bool
    ) -> [String] {
        var suggestions: [String] = []
        
        let sustainableCount = materials.filter(\.isSustainable).count
        if sustainableCount == 0 {
            suggestions.append("Consider highlighting the garment's durability and care instructions")
        }
        
        if !isRecycled {
            suggestions.append("Mention if the item was purchased second-hand")
        }
        
        suggestions.append("Include care instructions to extend garment life")
        
        return suggestions
    }
}

// MARK: - AI Analysis Types

public struct AIGarmentAnalysis: Codable, Equatable {
    public var title: String
    public var category: Category
    public var condition: Condition
    public var materials: [AIMaterial]
    public var colors: [String]
    public var estimatedPrice: Decimal
    public var sustainabilityScore: Int
    public var confidence: Double
    public var suggestions: [String]
    public var imageCount: Int?
    
    public init(
        title: String,
        category: Category,
        condition: Condition,
        materials: [AIMaterial],
        colors: [String],
        estimatedPrice: Decimal,
        sustainabilityScore: Int,
        confidence: Double,
        suggestions: [String],
        imageCount: Int? = nil
    ) {
        self.title = title
        self.category = category
        self.condition = condition
        self.materials = materials
        self.colors = colors
        self.estimatedPrice = estimatedPrice
        self.sustainabilityScore = sustainabilityScore
        self.confidence = confidence
        self.suggestions = suggestions
        self.imageCount = imageCount
    }
}

public struct AIMaterial: Codable, Identifiable {
    public let id: UUID
    public var name: String
    public var percentage: Int
    public var isSustainable: Bool
    
    public init(id: UUID = UUID(), name: String, percentage: Int, isSustainable: Bool) {
        self.id = id
        self.name = name
        self.percentage = percentage
        self.isSustainable = isSustainable
    }
}

public struct SimilarItem: Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let brand: String?
    public let price: Decimal
    public let condition: Condition
    public let imageURL: URL?
}

public struct SustainabilityAnalysis: Codable {
    public let score: Int
    public let carbonSavingsKg: Double
    public let waterSavingsLiters: Double
    public let rating: SustainabilityRating
    public let suggestions: [String]
}

public enum SustainabilityRating: String, Codable {
    case excellent = "EXCELLENT"
    case good = "GOOD"
    case average = "AVERAGE"
    case needsImprovement = "NEEDS_IMPROVEMENT"
    
    public var color: String {
        switch self {
        case .excellent: return "3DDC84"
        case .good: return "4A9A5A"
        case .average: return "D9BD6B"
        case .needsImprovement: return "F59E0B"
        }
    }
}

// MARK: - Search Parameters
public struct SearchParameters {
    public let query: String?
    public let category: Category?
    public let condition: Condition?
    public let size: Size?
    public let minPrice: Double?
    public let maxPrice: Double?
    public let sustainabilityOnly: Bool
    public let vintageOnly: Bool
    public let sortBy: SortOption
    public let page: Int
    public let limit: Int
    
    public init(
        query: String? = nil,
        category: Category? = nil,
        condition: Condition? = nil,
        size: Size? = nil,
        minPrice: Double? = nil,
        maxPrice: Double? = nil,
        sustainabilityOnly: Bool = false,
        vintageOnly: Bool = false,
        sortBy: SortOption = .recent,
        page: Int = 1,
        limit: Int = 20
    ) {
        self.query = query
        self.category = category
        self.condition = condition
        self.size = size
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.sustainabilityOnly = sustainabilityOnly
        self.vintageOnly = vintageOnly
        self.sortBy = sortBy
        self.page = page
        self.limit = limit
    }
}

// MARK: - Search Suggestion
public struct SearchSuggestion: Identifiable {
    public let id = UUID()
    public let text: String
    public let type: SuggestionType
    
    public init(text: String, type: SuggestionType) {
        self.text = text
        self.type = type
    }
    
    public enum SuggestionType {
        case brand
        case category
        case style
        case recent
        case trending
    }
}

// MARK: - Search Response
public struct SearchResponse {
    public let items: [FashionItem]
    public let totalCount: Int
    public let hasMore: Bool
    
    public init(items: [FashionItem], totalCount: Int, hasMore: Bool) {
        self.items = items
        self.totalCount = totalCount
        self.hasMore = hasMore
    }
}

// MARK: - Errors
public enum SearchAPIError: Error, LocalizedError {
    case noImagesProvided
    case invalidImageData
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int, String)
    case analysisFailed
    
    public var errorDescription: String? {
        switch self {
        case .noImagesProvided:
            return "No images were provided for analysis"
        case .invalidImageData:
            return "Could not process image data"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError:
            return "Failed to parse server response"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .analysisFailed:
            return "AI analysis failed. Please try again."
        }
    }
}
