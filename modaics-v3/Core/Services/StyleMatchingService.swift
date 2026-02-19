import Foundation

// MARK: - StyleMatchingServiceProtocol
/// Service for matching garments with users based on style preferences
/// and compatibility analysis
public protocol StyleMatchingServiceProtocol: Sendable {
    
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

// MARK: - Mock Implementation

public final class MockStyleMatchingService: StyleMatchingServiceProtocol {
    
    public init() {}
    
    public func calculateCompatibility(userId: UUID, garmentId: UUID) async throws -> CompatibilityScore {
        return CompatibilityScore(
            overall: 87.5,
            styleMatch: 92.0,
            sizeMatch: 100.0,
            colorMatch: 85.0,
            brandPreference: 78.0,
            sustainabilityAlignment: 95.0
        )
    }
    
    public func getMatchReasons(userId: UUID, garmentId: UUID) async throws -> [String] {
        return [
            "Matches your vintage aesthetic",
            "Perfect for your preferred color palette",
            "Similar to brands you love",
            "Highly sustainable choice",
            "Your size is available"
        ]
    }
    
    public func findMatchesForWardrobeGaps(userId: UUID, limit: Int) async throws -> [GarmentMatch] {
        return [
            GarmentMatch(
                garmentId: UUID(),
                score: CompatibilityScore(overall: 94.0, styleMatch: 96.0),
                reasons: ["Fills your outerwear gap", "Perfect color match"],
                gapCategory: "Outerwear"
            ),
            GarmentMatch(
                garmentId: UUID(),
                score: CompatibilityScore(overall: 88.0, styleMatch: 90.0),
                reasons: ["Complements your existing pieces"],
                gapCategory: "Accessories"
            )
        ]
    }
    
    public func analyzeStyleProfile(userId: UUID) async throws -> StyleProfile {
        return StyleProfile(
            dominantAesthetic: .vintage,
            secondaryAesthetics: [.minimalist, .sustainable],
            preferredColors: ["Black", "Cream", "Navy", "Rust"],
            preferredBrands: ["Vince", "Reformation", "COS"],
            preferredCategories: [.tops, .dresses, .outerwear],
            sizeConsistency: 95.0,
            sustainabilityPriority: 88.0,
            vintageAffinity: 82.0,
            luxuryAffinity: 65.0,
            keyStyleWords: ["Timeless", "Quality", "Sustainable", "Minimal"]
        )
    }
    
    public func suggestStyleImprovements(wardrobeId: UUID) async throws -> [StyleSuggestion] {
        return [
            StyleSuggestion(
                type: .addBasics,
                title: "Add neutral basics",
                description: "Your wardrobe would benefit from more versatile neutral pieces",
                priority: .high,
                expectedImpact: "Increase outfit combinations by 40%"
            ),
            StyleSuggestion(
                type: .addColor,
                title: "Introduce warm tones",
                description: "Consider adding rust, terracotta, or olive pieces",
                priority: .medium,
                expectedImpact: "Enhance seasonal versatility"
            ),
            StyleSuggestion(
                type: .improveCohesion,
                title: "Unify your style",
                description: "Some pieces feel disconnected from your core aesthetic",
                priority: .low,
                expectedImpact: "Create a more cohesive look"
            )
        ]
    }
    
    public func checkGarmentCompatibility(garmentId1: UUID, garmentId2: UUID) async throws -> OutfitCompatibility {
        return OutfitCompatibility(
            score: 85.0,
            colorHarmony: 90.0,
            textureMix: 75.0,
            silhouetteBalance: 88.0,
            styleCohesion: 92.0,
            suggestions: ["Would pair beautifully with boots"]
        )
    }
    
    public func generateOutfitCombinations(wardrobeId: UUID, occasion: String?) async throws -> [OutfitCombination] {
        return [
            OutfitCombination(
                garmentIds: [UUID(), UUID(), UUID()],
                name: "Casual Chic",
                occasion: occasion ?? "Everyday",
                compatibility: OutfitCompatibility(score: 92.0),
                season: .fall
            ),
            OutfitCombination(
                garmentIds: [UUID(), UUID(), UUID()],
                name: "Weekend Comfort",
                occasion: "Casual",
                compatibility: OutfitCompatibility(score: 88.0),
                season: .spring
            )
        ]
    }
    
    public func getPricingGuidance(for garment: Garment) async throws -> PricingGuidance {
        return PricingGuidance(
            suggestedPrice: 175.00,
            priceRange: (min: 150.00, max: 225.00),
            marketDemand: .high,
            comparableSales: [
                ComparableSale(price: 180.00, date: Date().addingTimeInterval(-7*24*60*60), condition: .excellent),
                ComparableSale(price: 165.00, date: Date().addingTimeInterval(-14*24*60*60), condition: .veryGood),
                ComparableSale(price: 200.00, date: Date().addingTimeInterval(-5*24*60*60), condition: .newWithoutTags)
            ],
            pricingFactors: [
                PricingFactor(name: "Brand reputation", impact: "+15%"),
                PricingFactor(name: "Condition", impact: "+10%"),
                PricingFactor(name: "Market saturation", impact: "-5%")
            ],
            recommendedListingPrice: 185.00,
            estimatedDaysToSell: 7,
            confidence: 0.85
        )
    }
}

// Pricing guidance types

public struct PricingGuidance: Sendable {
    public let suggestedPrice: Decimal
    public let priceRange: (min: Decimal, max: Decimal)
    public let marketDemand: MarketDemand
    public let comparableSales: [ComparableSale]
    public let pricingFactors: [PricingFactor]
    public let recommendedListingPrice: Decimal
    public let estimatedDaysToSell: Int
    public let confidence: Double // 0-1
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