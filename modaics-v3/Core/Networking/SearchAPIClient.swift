import Foundation
import UIKit

// MARK: - SearchAPIClient
/// Client for AI-powered search and garment analysis
public actor SearchAPIClient {
    
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

public struct AIGarmentAnalysis: Codable {
    public var title: String
    public var category: ModaicsCategory
    public var condition: ModaicsCondition
    public var materials: [AIMaterial]
    public var colors: [String]
    public var estimatedPrice: Decimal
    public var sustainabilityScore: Int
    public var confidence: Double
    public var suggestions: [String]
    public var imageCount: Int?
    
    public init(
        title: String,
        category: ModaicsCategory,
        condition: ModaicsCondition,
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
    public let condition: ModaicsCondition
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
