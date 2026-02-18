import Foundation

// MARK: - PricingGuidanceServiceProtocol
/// Service for providing intelligent pricing recommendations
/// based on market data, condition, brand, and other factors
public protocol PricingGuidanceServiceProtocol: Sendable {
    
    /// Get comprehensive pricing guidance for a garment
    func getPricingGuidance(for garment: Garment) async throws -> PricingGuidance
    
    /// Get quick price estimate
    func estimatePrice(garment: Garment) async throws -> Decimal
    
    /// Get comparable sales for a garment
    func getComparableSales(garmentId: UUID, limit: Int) async throws -> [ComparableSale]
    
    /// Get market trends for a specific category or brand
    func getMarketTrends(category: Category?, brand: String?) async throws -> MarketTrends
    
    /// Analyze pricing history for a garment
    func getPricingHistory(garmentId: UUID) async throws -> [PricePoint]
    
    /// Get optimal listing time recommendations
    func getOptimalListingTime(garment: Garment) async throws -> ListingTimeRecommendation
    
    /// Calculate potential revenue with different pricing strategies
    func calculateRevenueScenarios(garment: Garment) async throws -> [RevenueScenario]
    
    /// Get dynamic price adjustment recommendation
    func getPriceAdjustmentRecommendation(listedGarmentId: UUID) async throws -> PriceAdjustment?
    
    /// Batch pricing for multiple garments
    func batchPrice(garmentIds: [UUID]) async throws -> [UUID: PricingGuidance]
}

// MARK: - Supporting Types

public struct MarketTrends: Codable, Hashable, Sendable {
    public let category: Category?
    public let brand: String?
    public let averagePrice: Decimal
    public let medianPrice: Decimal
    public let priceRange: (min: Decimal, max: Decimal)
    public let trendDirection: TrendDirection
    public let trendPercentage: Double
    public let volumeChange: Double
    public let timePeriod: String
    
    public init(
        category: Category? = nil,
        brand: String? = nil,
        averagePrice: Decimal = 0,
        medianPrice: Decimal = 0,
        priceRange: (min: Decimal, max: Decimal) = (0, 0),
        trendDirection: TrendDirection = .stable,
        trendPercentage: Double = 0,
        volumeChange: Double = 0,
        timePeriod: String = "30d"
    ) {
        self.category = category
        self.brand = brand
        self.averagePrice = averagePrice
        self.medianPrice = medianPrice
        self.priceRange = priceRange
        self.trendDirection = trendDirection
        self.trendPercentage = trendPercentage
        self.volumeChange = volumeChange
        self.timePeriod = timePeriod
    }
}

public enum TrendDirection: String, Codable, Hashable, Sendable {
    case rising = "rising"
    case falling = "falling"
    case stable = "stable"
    case volatile = "volatile"
}

public struct PricePoint: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let price: Decimal
    public let date: Date
    public let eventType: PriceEventType
    public let notes: String?
    
    public init(
        id: UUID = UUID(),
        price: Decimal,
        date: Date,
        eventType: PriceEventType,
        notes: String? = nil
    ) {
        self.id = id
        self.price = price
        self.date = date
        self.eventType = eventType
        self.notes = notes
    }
}

public enum PriceEventType: String, Codable, Hashable, Sendable {
    case listed = "listed"
    case priceDrop = "price_drop"
    case priceIncrease = "price_increase"
    case sold = "sold"
    case delisted = "delisted"
    case autoAdjusted = "auto_adjusted"
}

public struct ListingTimeRecommendation: Codable, Hashable, Sendable {
    public let bestDay: String
    public let bestTime: String
    public let reasoning: String
    public let expectedBoost: Double // percentage increase in visibility
    public let alternativeTimes: [String]
    
    public init(
        bestDay: String,
        bestTime: String,
        reasoning: String,
        expectedBoost: Double = 0,
        alternativeTimes: [String] = []
    ) {
        self.bestDay = bestDay
        self.bestTime = bestTime
        self.reasoning = reasoning
        self.expectedBoost = expectedBoost
        self.alternativeTimes = alternativeTimes
    }
}

public struct RevenueScenario: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let listingPrice: Decimal
    public let estimatedDaysToSell: Int
    public let probabilityOfSale: Double // 0-1
    public let expectedRevenue: Decimal
    public let platformFees: Decimal
    public let netRevenue: Decimal
    public let strategy: PricingStrategy
    
    public init(
        id: UUID = UUID(),
        name: String,
        listingPrice: Decimal,
        estimatedDaysToSell: Int,
        probabilityOfSale: Double,
        expectedRevenue: Decimal,
        platformFees: Decimal,
        netRevenue: Decimal,
        strategy: PricingStrategy
    ) {
        self.id = id
        self.name = name
        self.listingPrice = listingPrice
        self.estimatedDaysToSell = estimatedDaysToSell
        self.probabilityOfSale = probabilityOfSale
        self.expectedRevenue = expectedRevenue
        self.platformFees = platformFees
        self.netRevenue = netRevenue
        self.strategy = strategy
    }
}

public enum PricingStrategy: String, Codable, Hashable, Sendable {
    case aggressive = "aggressive" // Price low, sell fast
    case balanced = "balanced" // Standard pricing
    case premium = "premium" // Price high, wait for right buyer
    case dynamic = "dynamic" // Adjust based on interest
}

public struct PriceAdjustment: Codable, Hashable, Sendable {
    public let currentPrice: Decimal
    public let recommendedPrice: Decimal
    public let reason: String
    public let urgency: PriceAdjustmentUrgency
    public let expectedImpact: String
    
    public init(
        currentPrice: Decimal,
        recommendedPrice: Decimal,
        reason: String,
        urgency: PriceAdjustmentUrgency,
        expectedImpact: String
    ) {
        self.currentPrice = currentPrice
        self.recommendedPrice = recommendedPrice
        self.reason = reason
        self.urgency = urgency
        self.expectedImpact = expectedImpact
    }
}

public enum PriceAdjustmentUrgency: String, Codable, Hashable, Sendable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
}

// MARK: - Mock Implementation

public final class MockPricingGuidanceService: PricingGuidanceServiceProtocol {
    
    public init() {}
    
    public func getPricingGuidance(for garment: Garment) async throws -> PricingGuidance {
        let basePrice = garment.originalPrice ?? 200.00
        let conditionMultiplier: Decimal
        
        switch garment.condition {
        case .newWithTags:
            conditionMultiplier = 0.85
        case .newWithoutTags:
            conditionMultiplier = 0.75
        case .excellent:
            conditionMultiplier = 0.65
        case .veryGood:
            conditionMultiplier = 0.55
        case .good:
            conditionMultiplier = 0.45
        case .fair:
            conditionMultiplier = 0.35
        case .vintage:
            conditionMultiplier = 0.70
        case .needsRepair:
            conditionMultiplier = 0.20
        }
        
        let suggestedPrice = basePrice * conditionMultiplier
        let rangeMin = suggestedPrice * 0.85
        let rangeMax = suggestedPrice * 1.15
        let recommendedPrice = suggestedPrice * 1.05
        
        return PricingGuidance(
            suggestedPrice: suggestedPrice,
            priceRange: (min: rangeMin, max: rangeMax),
            marketDemand: .high,
            comparableSales: generateMockComparables(basePrice: basePrice),
            pricingFactors: [
                PricingFactor(name: "Condition", impact: "-\(Int((1 - Double(conditionMultiplier)) * 100))%"),
                PricingFactor(name: "Brand strength", impact: "+10%"),
                PricingFactor(name: "Seasonal demand", impact: "+5%")
            ],
            recommendedListingPrice: recommendedPrice,
            estimatedDaysToSell: Int.random(in: 3...14),
            confidence: Double.random(in: 0.75...0.95)
        )
    }
    
    public func estimatePrice(garment: Garment) async throws -> Decimal {
        let guidance = try await getPricingGuidance(for: garment)
        return guidance.suggestedPrice
    }
    
    public func getComparableSales(garmentId: UUID, limit: Int) async throws -> [ComparableSale] {
        return generateMockComparables(basePrice: 200.00).prefix(limit).map { $0 }
    }
    
    public func getMarketTrends(category: Category?, brand: String?) async throws -> MarketTrends {
        return MarketTrends(
            category: category,
            brand: brand,
            averagePrice: 185.00,
            medianPrice: 165.00,
            priceRange: (min: 50.00, max: 450.00),
            trendDirection: .rising,
            trendPercentage: 8.5,
            volumeChange: 12.3,
            timePeriod: "30d"
        )
    }
    
    public func getPricingHistory(garmentId: UUID) async throws -> [PricePoint] {
        return [
            PricePoint(price: 250.00, date: Date().addingTimeInterval(-30*24*60*60), eventType: .listed),
            PricePoint(price: 225.00, date: Date().addingTimeInterval(-15*24*60*60), eventType: .priceDrop, notes: "Increased interest after price drop"),
            PricePoint(price: 225.00, date: Date().addingTimeInterval(-2*24*60*60), eventType: .sold)
        ]
    }
    
    public func getOptimalListingTime(garment: Garment) async throws -> ListingTimeRecommendation {
        return ListingTimeRecommendation(
            bestDay: "Sunday",
            bestTime: "7:00 PM",
            reasoning: "Highest buyer activity on Sunday evenings. Peak engagement for fashion items.",
            expectedBoost: 25.0,
            alternativeTimes: ["Wednesday 8:00 PM", "Friday 6:00 PM"]
        )
    }
    
    public func calculateRevenueScenarios(garment: Garment) async throws -> [RevenueScenario] {
        let guidance = try await getPricingGuidance(for: garment)
        let platformFeeRate: Decimal = 0.05 // 5%
        
        return [
            RevenueScenario(
                name: "Quick Sale",
                listingPrice: guidance.priceRange.min,
                estimatedDaysToSell: 3,
                probabilityOfSale: 0.90,
                expectedRevenue: guidance.priceRange.min,
                platformFees: guidance.priceRange.min * platformFeeRate,
                netRevenue: guidance.priceRange.min * (1 - platformFeeRate),
                strategy: .aggressive
            ),
            RevenueScenario(
                name: "Balanced",
                listingPrice: guidance.recommendedListingPrice,
                estimatedDaysToSell: 7,
                probabilityOfSale: 0.75,
                expectedRevenue: guidance.recommendedListingPrice,
                platformFees: guidance.recommendedListingPrice * platformFeeRate,
                netRevenue: guidance.recommendedListingPrice * (1 - platformFeeRate),
                strategy: .balanced
            ),
            RevenueScenario(
                name: "Maximum Value",
                listingPrice: guidance.priceRange.max,
                estimatedDaysToSell: 21,
                probabilityOfSale: 0.50,
                expectedRevenue: guidance.priceRange.max,
                platformFees: guidance.priceRange.max * platformFeeRate,
                netRevenue: guidance.priceRange.max * (1 - platformFeeRate),
                strategy: .premium
            )
        ]
    }
    
    public func getPriceAdjustmentRecommendation(listedGarmentId: UUID) async throws -> PriceAdjustment? {
        return PriceAdjustment(
            currentPrice: 250.00,
            recommendedPrice: 225.00,
            reason: "Item has been listed for 14 days with moderate interest. A 10% reduction should accelerate sale.",
            urgency: .medium,
            expectedImpact: "Increase sale probability from 45% to 75% within 7 days"
        )
    }
    
    public func batchPrice(garmentIds: [UUID]) async throws -> [UUID: PricingGuidance] {
        var results: [UUID: PricingGuidance] = [:]
        
        for id in garmentIds {
            // In mock, generate consistent pricing based on ID
            let mockGarment = Garment(
                title: "Mock Item",
                description: "",
                story: .sampleMinimal,
                condition: .excellent,
                originalPrice: Decimal.random(in: 100...500),
                category: .tops,
                size: Size(label: "M", system: .us),
                ownerId: UUID()
            )
            results[id] = try await getPricingGuidance(for: mockGarment)
        }
        
        return results
    }
    
    // MARK: - Helper
    
    private func generateMockComparables(basePrice: Decimal) -> [ComparableSale] {
        return [
            ComparableSale(price: basePrice * 0.90, date: Date().addingTimeInterval(-7*24*60*60), condition: .excellent),
            ComparableSale(price: basePrice * 0.85, date: Date().addingTimeInterval(-14*24*60*60), condition: .veryGood),
            ComparableSale(price: basePrice * 0.95, date: Date().addingTimeInterval(-3*24*60*60), condition: .excellent),
            ComparableSale(price: basePrice * 1.00, date: Date().addingTimeInterval(-5*24*60*60), condition: .newWithoutTags),
            ComparableSale(price: basePrice * 0.80, date: Date().addingTimeInterval(-21*24*60*60), condition: .good)
        ]
    }
}