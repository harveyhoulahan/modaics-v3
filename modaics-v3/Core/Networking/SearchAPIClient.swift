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
    
    // MARK: - Mock Data (non-isolated for actor access)
    private let mockItems: [FashionItem] = [
        FashionItem(
            id: "1",
            brand: "Levi's",
            name: "Vintage 501 Jeans",
            description: "Classic vintage Levi's 501 jeans",
            price: 85.0,
            originalPrice: 120.0,
            category: .bottoms,
            condition: .good,
            size: "32",
            images: [],
            sellerId: "seller1"
        ),
        FashionItem(
            id: "2",
            brand: "Zimmermann",
            name: "Silk Blouse",
            description: "Elegant silk blouse",
            price: 180.0,
            originalPrice: 280.0,
            category: .tops,
            condition: .excellent,
            size: "S",
            images: [],
            sellerId: "seller2"
        ),
        FashionItem(
            id: "3",
            brand: "Vintage Coach",
            name: "Leather Bag",
            description: "Authentic vintage leather bag",
            price: 220.0,
            originalPrice: 350.0,
            category: .bags,
            condition: .good,
            size: "OS",
            images: [],
            sellerId: "seller3"
        ),
        FashionItem(
            id: "4",
            brand: "Zara",
            name: "Linen Trousers",
            description: "Perfect summer linen trousers",
            price: 45.0,
            originalPrice: 89.0,
            category: .bottoms,
            condition: .veryGood,
            size: "M",
            images: [],
            sellerId: "seller4"
        )
    ]
    
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
        var items = mockItems
        
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
            let conditionOrder: [Condition] = [.new, .likeNew, .excellent, .veryGood, .good, .fair]
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
            estimatedPrice: 245.0,
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
                id: UUID().uuidString,
                title: "Similar Wool Coat",
                brand: "Max Mara",
                price: 320.0,
                condition: .veryGood,
                imageURL: nil
            ),
            SimilarItem(
                id: UUID().uuidString,
                title: "Camel Coat Vintage",
                brand: "Burberry",
                price: 450.0,
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
        
        let sustainableCount = materials.filter { $0.isSustainable }.count
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

public struct AIGarmentAnalysis: Codable, Sendable {
    public var title: String
    public var category: Category
    public var condition: Condition
    public var materials: [AIMaterial]
    public var colors: [String]
    public var estimatedPrice: Double
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
        estimatedPrice: Double,
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

public struct AIMaterial: Codable, Sendable {
    public let name: String
    public let percentage: Int
    public let isSustainable: Bool
}

public struct SimilarItem: Codable, Sendable {
    public let id: String
    public let title: String
    public let brand: String
    public let price: Double
    public let condition: Condition
    public let imageURL: String?
}

public struct SustainabilityAnalysis: Codable, Sendable {
    public let score: Int
    public let carbonSavingsKg: Double
    public let waterSavingsLiters: Double
    public let rating: SustainabilityRating
    public let suggestions: [String]
}

public enum SustainabilityRating: String, Codable, Sendable {
    case excellent = "Excellent"
    case good = "Good"
    case average = "Average"
    case needsImprovement = "Needs Improvement"
}

// MARK: - Search Types

public struct SearchParameters: Codable, Sendable {
    public var query: String?
    public var category: Category?
    public var condition: Condition?
    public var minPrice: Double?
    public var maxPrice: Double?
    public var sortBy: SortOption
    public var page: Int
    public var limit: Int
    public var sustainabilityOnly: Bool
    public var vintageOnly: Bool
    
    public init(
        query: String? = nil,
        category: Category? = nil,
        condition: Condition? = nil,
        minPrice: Double? = nil,
        maxPrice: Double? = nil,
        sortBy: SortOption = .recent,
        page: Int = 1,
        limit: Int = 20,
        sustainabilityOnly: Bool = false,
        vintageOnly: Bool = false
    ) {
        self.query = query
        self.category = category
        self.condition = condition
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.sortBy = sortBy
        self.page = page
        self.limit = limit
        self.sustainabilityOnly = sustainabilityOnly
        self.vintageOnly = vintageOnly
    }
}

public struct SearchResponse: Codable, Sendable {
    public let items: [FashionItem]
    public let totalCount: Int
    public let hasMore: Bool
}

public struct SearchSuggestion: Codable, Sendable {
    public let text: String
    public let type: SuggestionType
    
    public init(text: String, type: SuggestionType) {
        self.text = text
        self.type = type
    }
}

public enum SuggestionType: String, Codable, Sendable {
    case style = "Style"
    case category = "Category"
    case brand = "Brand"
    case trending = "Trending"
}

// MARK: - Errors

public enum SearchAPIError: Error, Sendable {
    case noImagesProvided
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
}