import Foundation

// MARK: - BuildWardrobeUseCase
/// Use case for wardrobe building and curation
/// Handles adding garments, organization, analytics, and AI-powered insights
public protocol BuildWardrobeUseCaseProtocol: Sendable {
    func execute(input: BuildWardrobeInput) async throws -> BuildWardrobeOutput
}

// MARK: - Input/Output Types

public struct BuildWardrobeInput: Sendable {
    public let action: BuildWardrobeAction
    public let userId: UUID
    
    public init(action: BuildWardrobeAction, userId: UUID) {
        self.action = action
        self.userId = userId
    }
}

public enum BuildWardrobeAction: Sendable {
    case createWardrobe(CreateWardrobeInput)
    case addGarment(AddGarmentInput)
    case addGarments([AddGarmentInput])
    case removeGarment(garmentId: UUID)
    case createCollection(CreateCollectionInput)
    case addToCollection(collectionId: UUID, garmentId: UUID)
    case createTag(name: String, color: String)
    case tagGarment(garmentId: UUID, tagId: UUID)
    case analyzeWardrobe
    case getInsights
    case getSuggestions
    case getOutfitSuggestions(occasion: String?, weather: String?)
    case findGaps
    case calculateSustainabilityImpact
    case calculateValueAnalysis
    case refreshStyleAnalysis
    case exportWardrobe(format: ExportFormat)
    case duplicateGarment(garmentId: UUID)
    case listGarment(garmentId: UUID, exchangeType: ExchangeType, price: Decimal?)
    case delistGarment(garmentId: UUID)
}

public struct CreateWardrobeInput: Sendable {
    public var name: String
    public var description: String
    public var isPublic: Bool
    
    public init(name: String, description: String = "", isPublic: Bool = false) {
        self.name = name
        self.description = description
        self.isPublic = isPublic
    }
}

public struct AddGarmentInput: Sendable {
    public var title: String
    public var description: String
    public var story: Story
    public var condition: Condition
    public var originalPrice: Decimal?
    public var category: Category
    public var subcategory: String?
    public var styleTags: [String]
    public var colors: [GarmentColor]
    public var materials: [Material]
    public var brand: Brand?
    public var size: Size
    public var era: Era?
    public var coverImageURL: URL?
    public var imageURLs: [URL]
    public var isListed: Bool
    public var exchangeType: ExchangeType?
    public var listingPrice: Decimal?
    public var location: Location?
    public var certifications: [Certification]
    
    public init(
        title: String,
        description: String,
        story: Story,
        condition: Condition,
        originalPrice: Decimal? = nil,
        category: Category,
        subcategory: String? = nil,
        styleTags: [String] = [],
        colors: [GarmentColor] = [],
        materials: [Material] = [],
        brand: Brand? = nil,
        size: Size,
        era: Era? = nil,
        coverImageURL: URL? = nil,
        imageURLs: [URL] = [],
        isListed: Bool = false,
        exchangeType: ExchangeType? = nil,
        listingPrice: Decimal? = nil,
        location: Location? = nil,
        certifications: [Certification] = []
    ) {
        self.title = title
        self.description = description
        self.story = story
        self.condition = condition
        self.originalPrice = originalPrice
        self.category = category
        self.subcategory = subcategory
        self.styleTags = styleTags
        self.colors = colors
        self.materials = materials
        self.brand = brand
        self.size = size
        self.era = era
        self.coverImageURL = coverImageURL
        self.imageURLs = imageURLs
        self.isListed = isListed
        self.exchangeType = exchangeType
        self.listingPrice = listingPrice
        self.location = location
        self.certifications = certifications
    }
}

public struct CreateCollectionInput: Sendable {
    public var name: String
    public var description: String
    public var garmentIds: [UUID]
    public var isSmartCollection: Bool
    public var smartCriteria: SmartCriteria?
    
    public init(
        name: String,
        description: String = "",
        garmentIds: [UUID] = [],
        isSmartCollection: Bool = false,
        smartCriteria: SmartCriteria? = nil
    ) {
        self.name = name
        self.description = description
        self.garmentIds = garmentIds
        self.isSmartCollection = isSmartCollection
        self.smartCriteria = smartCriteria
    }
}

public enum ExportFormat: String, Sendable {
    case pdf
    case csv
    case json
}

public struct BuildWardrobeOutput: Sendable {
    public let wardrobe: Wardrobe?
    public let garment: Garment?
    public let collection: WardrobeCollection?
    public let tag: WardrobeTag?
    public let statistics: WardrobeStatistics?
    public let insights: WardrobeInsights?
    public let sustainabilityImpact: SustainabilityImpact?
    public let valueAnalysis: ValueAnalysis?
    public let outfitSuggestions: [OutfitSuggestion]?
    public let suggestions: [WardrobeSuggestion]?
    public let exportData: Data?
    public let message: String?
    
    public init(
        wardrobe: Wardrobe? = nil,
        garment: Garment? = nil,
        collection: WardrobeCollection? = nil,
        tag: WardrobeTag? = nil,
        statistics: WardrobeStatistics? = nil,
        insights: WardrobeInsights? = nil,
        sustainabilityImpact: SustainabilityImpact? = nil,
        valueAnalysis: ValueAnalysis? = nil,
        outfitSuggestions: [OutfitSuggestion]? = nil,
        suggestions: [WardrobeSuggestion]? = nil,
        exportData: Data? = nil,
        message: String? = nil
    ) {
        self.wardrobe = wardrobe
        self.garment = garment
        self.collection = collection
        self.tag = tag
        self.statistics = statistics
        self.insights = insights
        self.sustainabilityImpact = sustainabilityImpact
        self.valueAnalysis = valueAnalysis
        self.outfitSuggestions = outfitSuggestions
        self.suggestions = suggestions
        self.exportData = exportData
        self.message = message
    }
}

public struct WardrobeInsights: Sendable {
    public let styleInsights: StyleInsights
    public let colorPalette: [ColorFrequency]
    public let brandBreakdown: [BrandFrequency]
    public let categoryBreakdown: [CategoryFrequency]
    public let seasonalReadiness: [Season: Double]
    public let wardrobeHealth: WardrobeHealth
    public let aiRecommendations: [AIRecommendation]
    
    public init(
        styleInsights: StyleInsights,
        colorPalette: [ColorFrequency],
        brandBreakdown: [BrandFrequency],
        categoryBreakdown: [CategoryFrequency],
        seasonalReadiness: [Season: Double],
        wardrobeHealth: WardrobeHealth,
        aiRecommendations: [AIRecommendation] = []
    ) {
        self.styleInsights = styleInsights
        self.colorPalette = colorPalette
        self.brandBreakdown = brandBreakdown
        self.categoryBreakdown = categoryBreakdown
        self.seasonalReadiness = seasonalReadiness
        self.wardrobeHealth = wardrobeHealth
        self.aiRecommendations = aiRecommendations
    }
}

public struct WardrobeHealth: Sendable {
    public let cohesionScore: Double // 0-100
    public let versatilityScore: Double // 0-100
    public let sustainabilityScore: Double // 0-100
    public let valueRetentionScore: Double // 0-100
    public let overallScore: Double // 0-100
    public let strengths: [String]
    public let areasForImprovement: [String]
    
    public init(
        cohesionScore: Double,
        versatilityScore: Double,
        sustainabilityScore: Double,
        valueRetentionScore: Double,
        overallScore: Double,
        strengths: [String] = [],
        areasForImprovement: [String] = []
    ) {
        self.cohesionScore = cohesionScore
        self.versatilityScore = versatilityScore
        self.sustainabilityScore = sustainabilityScore
        self.valueRetentionScore = valueRetentionScore
        self.overallScore = overallScore
        self.strengths = strengths
        self.areasForImprovement = areasForImprovement
    }
}

public struct AIRecommendation: Sendable {
    public let category: String
    public let title: String
    public let description: String
    public let priority: RecommendationPriority
    public let potentialImpact: String
    
    public init(
        category: String,
        title: String,
        description: String,
        priority: RecommendationPriority = .medium,
        potentialImpact: String = ""
    ) {
        self.category = category
        self.title = title
        self.description = description
        self.priority = priority
        self.potentialImpact = potentialImpact
    }
}

public enum RecommendationPriority: String, Sendable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

// MARK: - Implementation

public final class BuildWardrobeUseCase: BuildWardrobeUseCaseProtocol {
    private let wardrobeRepository: WardrobeRepositoryProtocol
    private let garmentRepository: GarmentRepositoryProtocol
    private let styleMatchingService: StyleMatchingServiceProtocol
    
    public init(
        wardrobeRepository: WardrobeRepositoryProtocol,
        garmentRepository: GarmentRepositoryProtocol,
        styleMatchingService: StyleMatchingServiceProtocol
    ) {
        self.wardrobeRepository = wardrobeRepository
        self.garmentRepository = garmentRepository
        self.styleMatchingService = styleMatchingService
    }
    
    public func execute(input: BuildWardrobeInput) async throws -> BuildWardrobeOutput {
        switch input.action {
        case .createWardrobe(let createInput):
            return try await createWardrobe(input: createInput, userId: input.userId)
            
        case .addGarment(let garmentInput):
            return try await addGarment(input: garmentInput, userId: input.userId)
            
        case .addGarments(let garmentInputs):
            return try await addGarments(inputs: garmentInputs, userId: input.userId)
            
        case .removeGarment(let garmentId):
            return try await removeGarment(garmentId: garmentId, userId: input.userId)
            
        case .createCollection(let collectionInput):
            return try await createCollection(input: collectionInput, userId: input.userId)
            
        case .addToCollection(let collectionId, let garmentId):
            return try await addToCollection(collectionId: collectionId, garmentId: garmentId, userId: input.userId)
            
        case .createTag(let name, let color):
            return try await createTag(name: name, color: color, userId: input.userId)
            
        case .tagGarment(let garmentId, let tagId):
            return try await tagGarment(garmentId: garmentId, tagId: tagId, userId: input.userId)
            
        case .analyzeWardrobe:
            return try await analyzeWardrobe(userId: input.userId)
            
        case .getInsights:
            return try await getInsights(userId: input.userId)
            
        case .getSuggestions:
            return try await getSuggestions(userId: input.userId)
            
        case .getOutfitSuggestions(let occasion, let weather):
            return try await getOutfitSuggestions(occasion: occasion, weather: weather, userId: input.userId)
            
        case .findGaps:
            return try await findGaps(userId: input.userId)
            
        case .calculateSustainabilityImpact:
            return try await calculateSustainabilityImpact(userId: input.userId)
            
        case .calculateValueAnalysis:
            return try await calculateValueAnalysis(userId: input.userId)
            
        case .refreshStyleAnalysis:
            return try await refreshStyleAnalysis(userId: input.userId)
            
        case .exportWardrobe(let format):
            return try await exportWardrobe(format: format, userId: input.userId)
            
        case .duplicateGarment(let garmentId):
            return try await duplicateGarment(garmentId: garmentId, userId: input.userId)
            
        case .listGarment(let garmentId, let exchangeType, let price):
            return try await listGarment(garmentId: garmentId, exchangeType: exchangeType, price: price, userId: input.userId)
            
        case .delistGarment(let garmentId):
            return try await delistGarment(garmentId: garmentId, userId: input.userId)
        }
    }
    
    // MARK: - Private Methods
    
    private func createWardrobe(input: CreateWardrobeInput, userId: UUID) async throws -> BuildWardrobeOutput {
        let wardrobe = Wardrobe(
            ownerId: userId,
            name: input.name,
            description: input.description,
            isPublic: input.isPublic
        )
        
        let created = try await wardrobeRepository.create(wardrobe)
        
        return BuildWardrobeOutput(
            wardrobe: created,
            message: "Wardrobe '\(input.name)' created successfully"
        )
    }
    
    private func addGarment(input: AddGarmentInput, userId: UUID) async throws -> BuildWardrobeOutput {
        // Get or create wardrobe
        let wardrobe: Wardrobe
        if try await wardrobeRepository.existsForUser(userId: userId) {
            wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        } else {
            wardrobe = try await wardrobeRepository.create(Wardrobe(
                ownerId: userId,
                name: "My Wardrobe"
            ))
        }
        
        // Create garment
        let garment = Garment(
            title: input.title,
            description: input.description,
            story: input.story,
            condition: input.condition,
            originalPrice: input.originalPrice,
            suggestedPrice: nil,
            listingPrice: input.listingPrice,
            category: input.category,
            subcategory: input.subcategory,
            styleTags: input.styleTags,
            colors: input.colors,
            materials: input.materials,
            brand: input.brand,
            size: input.size,
            era: input.era,
            coverImageURL: input.coverImageURL,
            imageURLs: input.imageURLs,
            ownerId: userId,
            isListed: input.isListed,
            exchangeType: input.exchangeType,
            location: input.location,
            certifications: input.certifications
        )
        
        let createdGarment = try await garmentRepository.create(garment)
        
        // Add to wardrobe
        _ = try await wardrobeRepository.addGarment(wardrobeId: wardrobe.id, garmentId: createdGarment.id)
        
        // Get pricing guidance if listing price not set
        if input.listingPrice == nil {
            _ = try? await styleMatchingService.getPricingGuidance(for: createdGarment)
        }
        
        return BuildWardrobeOutput(
            garment: createdGarment,
            message: "'\(input.title)' added to your wardrobe"
        )
    }
    
    private func addGarments(inputs: [AddGarmentInput], userId: UUID) async throws -> BuildWardrobeOutput {
        var addedCount = 0
        
        for input in inputs {
            _ = try await addGarment(input: input, userId: userId)
            addedCount += 1
        }
        
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        
        return BuildWardrobeOutput(
            wardrobe: wardrobe,
            message: "\(addedCount) items added to your wardrobe"
        )
    }
    
    private func removeGarment(garmentId: UUID, userId: UUID) async throws -> BuildWardrobeOutput {
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        _ = try await wardrobeRepository.removeGarment(wardrobeId: wardrobe.id, garmentId: garmentId)
        try await garmentRepository.delete(id: garmentId)
        
        return BuildWardrobeOutput(
            wardrobe: wardrobe,
            message: "Item removed from your wardrobe"
        )
    }
    
    private func createCollection(input: CreateCollectionInput, userId: UUID) async throws -> BuildWardrobeOutput {
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        
        let collection = WardrobeCollection(
            name: input.name,
            description: input.description,
            garmentIds: input.garmentIds,
            isSmartCollection: input.isSmartCollection,
            smartCriteria: input.smartCriteria
        )
        
        let created = try await wardrobeRepository.createCollection(wardrobeId: wardrobe.id, collection: collection)
        
        return BuildWardrobeOutput(
            collection: created,
            message: "Collection '\(input.name)' created"
        )
    }
    
    private func addToCollection(collectionId: UUID, garmentId: UUID, userId: UUID) async throws -> BuildWardrobeOutput {
        try await wardrobeRepository.addToCollection(collectionId: collectionId, garmentId: garmentId)
        
        return BuildWardrobeOutput(
            message: "Item added to collection"
        )
    }
    
    private func createTag(name: String, color: String, userId: UUID) async throws -> BuildWardrobeOutput {
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        let tag = WardrobeTag(name: name, color: color)
        
        let created = try await wardrobeRepository.createTag(wardrobeId: wardrobe.id, tag: tag)
        
        return BuildWardrobeOutput(
            tag: created,
            message: "Tag '\(name)' created"
        )
    }
    
    private func tagGarment(garmentId: UUID, tagId: UUID, userId: UUID) async throws -> BuildWardrobeOutput {
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        try await wardrobeRepository.tagGarment(wardrobeId: wardrobe.id, garmentId: garmentId, tagId: tagId)
        
        return BuildWardrobeOutput(
            message: "Item tagged"
        )
    }
    
    private func analyzeWardrobe(userId: UUID) async throws -> BuildWardrobeOutput {
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        
        let styleInsights = try await wardrobeRepository.getStyleInsights(wardrobeId: wardrobe.id)
        let colorPalette = try await wardrobeRepository.getColorPalette(wardrobeId: wardrobe.id)
        let brandBreakdown = try await wardrobeRepository.getBrandBreakdown(wardrobeId: wardrobe.id)
        let categoryBreakdown = try await wardrobeRepository.getCategoryBreakdown(wardrobeId: wardrobe.id)
        let statistics = try await wardrobeRepository.getStatistics(wardrobeId: wardrobe.id)
        
        let health = WardrobeHealth(
            cohesionScore: styleInsights.cohesionScore,
            versatilityScore: styleInsights.versatilityScore,
            sustainabilityScore: styleInsights.sustainabilityScore,
            valueRetentionScore: 75.0, // Placeholder
            overallScore: (styleInsights.cohesionScore + styleInsights.versatilityScore + styleInsights.sustainabilityScore) / 3,
            strengths: ["Great color cohesion", "High sustainability score"],
            areasForImprovement: ["Consider adding more versatile basics"]
        )
        
        let insights = WardrobeInsights(
            styleInsights: styleInsights,
            colorPalette: colorPalette,
            brandBreakdown: brandBreakdown,
            categoryBreakdown: categoryBreakdown,
            seasonalReadiness: styleInsights.seasonalReadiness,
            wardrobeHealth: health
        )
        
        return BuildWardrobeOutput(
            wardrobe: wardrobe,
            statistics: statistics,
            insights: insights,
            message: "Wardrobe analysis complete"
        )
    }
    
    private func getInsights(userId: UUID) async throws -> BuildWardrobeOutput {
        return try await analyzeWardrobe(userId: userId)
    }
    
    private func getSuggestions(userId: UUID) async throws -> BuildWardrobeOutput {
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        let suggestions = try await wardrobeRepository.getSuggestions(wardrobeId: wardrobe.id)
        
        return BuildWardrobeOutput(
            wardrobe: wardrobe,
            suggestions: suggestions,
            message: "Found \(suggestions.count) suggestions for your wardrobe"
        )
    }
    
    private func getOutfitSuggestions(occasion: String?, weather: String?, userId: UUID) async throws -> BuildWardrobeOutput {
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        let outfits = try await wardrobeRepository.getOutfitSuggestions(
            wardrobeId: wardrobe.id,
            occasion: occasion,
            weather: weather
        )
        
        return BuildWardrobeOutput(
            wardrobe: wardrobe,
            outfitSuggestions: outfits,
            message: "Generated \(outfits.count) outfit suggestions"
        )
    }
    
    private func findGaps(userId: UUID) async throws -> BuildWardrobeOutput {
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        let suggestions = try await wardrobeRepository.getSuggestions(wardrobeId: wardrobe.id)
        
        return BuildWardrobeOutput(
            wardrobe: wardrobe,
            suggestions: suggestions,
            message: "Found \(suggestions.count) gaps in your wardrobe"
        )
    }
    
    private func calculateSustainabilityImpact(userId: UUID) async throws -> BuildWardrobeOutput {
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        let impact = try await wardrobeRepository.getSustainabilityImpact(wardrobeId: wardrobe.id)
        
        return BuildWardrobeOutput(
            wardrobe: wardrobe,
            sustainabilityImpact: impact,
            message: "You've saved \(String(format: "%.1f", impact.carbonSavedKg))kg of CO2!"
        )
    }
    
    private func calculateValueAnalysis(userId: UUID) async throws -> BuildWardrobeOutput {
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        let analysis = try await wardrobeRepository.getValueAnalysis(wardrobeId: wardrobe.id)
        
        return BuildWardrobeOutput(
            wardrobe: wardrobe,
            valueAnalysis: analysis,
            message: "Wardrobe value: $\(analysis.currentEstimatedValue)"
        )
    }
    
    private func refreshStyleAnalysis(userId: UUID) async throws -> BuildWardrobeOutput {
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        _ = try await wardrobeRepository.refreshStyleInsights(wardrobeId: wardrobe.id)
        
        return BuildWardrobeOutput(
            wardrobe: wardrobe,
            message: "Style analysis refreshed"
        )
    }
    
    private func exportWardrobe(format: ExportFormat, userId: UUID) async throws -> BuildWardrobeOutput {
        // Placeholder for export functionality
        return BuildWardrobeOutput(
            exportData: Data(),
            message: "Wardrobe exported as \(format.rawValue.uppercased())"
        )
    }
    
    private func duplicateGarment(garmentId: UUID, userId: UUID) async throws -> BuildWardrobeOutput {
        let original = try await garmentRepository.get(by: garmentId)
        
        var duplicate = original
        duplicate.id = UUID()
        duplicate.title = "\(original.title) (Copy)"
        duplicate.ownerId = userId
        duplicate.createdAt = Date()
        duplicate.updatedAt = Date()
        duplicate.isListed = false
        duplicate.exchangeType = nil
        duplicate.listingPrice = nil
        
        let created = try await garmentRepository.create(duplicate)
        let wardrobe = try await wardrobeRepository.getByOwner(userId: userId)
        _ = try await wardrobeRepository.addGarment(wardrobeId: wardrobe.id, garmentId: created.id)
        
        return BuildWardrobeOutput(
            garment: created,
            message: "Garment duplicated"
        )
    }
    
    private func listGarment(garmentId: UUID, exchangeType: ExchangeType, price: Decimal?, userId: UUID) async throws -> BuildWardrobeOutput {
        let garment = try await garmentRepository.listGarment(
            id: garmentId,
            exchangeType: exchangeType,
            price: price
        )
        
        return BuildWardrobeOutput(
            garment: garment,
            message: "'\(garment.title)' is now listed for \(exchangeType.rawValue)"
        )
    }
    
    private func delistGarment(garmentId: UUID, userId: UUID) async throws -> BuildWardrobeOutput {
        let garment = try await garmentRepository.delistGarment(id: garmentId)
        
        return BuildWardrobeOutput(
            garment: garment,
            message: "'\(garment.title)' has been delisted"
        )
    }
}

public enum BuildWardrobeError: Error {
    case wardrobeNotFound
    case garmentNotFound
    case unauthorized
    case invalidInput
    case collectionNotFound
    case tagNotFound
    case duplicateName
    case exportFailed
    case analysisFailed
}