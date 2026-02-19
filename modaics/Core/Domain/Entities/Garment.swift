import Foundation

// MARK: - Garment Source
/// Source of the garment - either from Modaics platform or external (Depop)
public enum GarmentSource: String, Codable, Hashable, Sendable, CaseIterable {
    case modaics = "modaics"
    case depop = "depop"
    
    public var displayName: String {
        switch self {
        case .modaics: return "Modaics"
        case .depop: return "Depop"
        }
    }
}

// MARK: - Currency
/// Currency for pricing
public enum Currency: String, Codable, Hashable, Sendable, CaseIterable {
    case usd = "USD"
    case gbp = "GBP"
    case eur = "EUR"
    
    public var symbol: String {
        switch self {
        case .usd: return "$"
        case .gbp: return "£"
        case .eur: return "€"
        }
    }
    
    public var displayName: String {
        switch self {
        case .usd: return "US Dollar"
        case .gbp: return "British Pound"
        case .eur: return "Euro"
        }
    }
}

// MARK: - Garment
/// A single piece of clothing in the Modaics ecosystem
/// Every garment has a story, condition, and lifecycle
/// v3.5: Updated for 768-dim embeddings and external source support
public struct Garment: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    
    // MARK: - External Source Fields (v3.5)
    
    /// External ID from source platform (e.g., Depop listing ID)
    public var externalId: String?
    
    /// Source platform (Modaics or Depop)
    public var source: GarmentSource
    
    /// Original URL on the source platform
    public var originalUrl: URL?
    
    // MARK: - 768-Dim Embedding (v3.5)
    
    /// 768-dimensional CLIP embedding for visual search
    /// Using CLIP ViT-L/14 for v3.5
    public var embedding: [Float]?
    
    /// Check if embedding is valid (has exactly 768 dimensions)
    public var hasValidEmbedding: Bool {
        guard let embedding = embedding else { return false }
        return embedding.count == 768
    }
    
    // MARK: - Core Properties
    
    /// Display name/title of the garment
    public var title: String
    
    /// Detailed description (v3.5: Renamed from 'body' for consistency)
    public var description: String
    
    /// The story behind this piece - the emotional core
    public var story: Story
    
    /// Current condition of the garment
    public var condition: Condition
    
    /// Original retail price
    public var originalPrice: Decimal?
    
    /// Suggested resale price (calculated or user-set)
    public var suggestedPrice: Decimal?
    
    /// Current listing price if for sale
    public var listingPrice: Decimal?
    
    /// Currency for all prices (v3.5: Added for multi-currency support)
    public var currency: Currency
    
    // MARK: - Categorization
    
    /// Primary category (Dress, Jacket, Shoes, etc.)
    public var category: Category
    
    /// Subcategory for finer classification
    public var subcategory: String?
    
    /// Style tags for discovery
    public var styleTags: [String]
    
    /// Colors present in the garment
    public var colors: [Color]
    
    /// Materials and fabric composition
    public var materials: [Material]
    
    /// Brand or maker
    public var brand: Brand?
    
    /// Size information
    public var size: Size
    
    /// Era/vintage period if applicable
    public var era: Era?
    
    // MARK: - Media
    
    /// Primary cover image
    public var coverImageURL: URL?
    
    /// Gallery of additional images
    public var imageURLs: [URL]
    
    /// Video showcase URL
    public var videoURL: URL?
    
    // MARK: - Ownership
    
    /// Current owner ID
    public var ownerId: UUID
    
    /// Previous owner IDs (for provenance tracking)
    public var previousOwnerIds: [UUID]
    
    /// Is this garment currently listed for exchange?
    public var isListed: Bool
    
    /// Exchange type if listed (sell, trade, both)
    public var exchangeType: ExchangeType?
    
    // MARK: - Metadata
    
    /// When the garment was added to the platform
    public var createdAt: Date
    
    /// Last update timestamp
    public var updatedAt: Date
    
    /// View count for popularity tracking
    public var viewCount: Int
    
    /// Favorite/save count
    public var favoriteCount: Int
    
    /// Geographic location for local discovery
    public var location: Location?
    
    // MARK: - Sustainability
    
    /// Estimated carbon footprint vs buying new
    public var carbonSavingsKg: Double?
    
    /// Water savings in liters
    public var waterSavingsLiters: Double?
    
    /// Certification badges (organic, fair trade, etc.)
    public var certifications: [Certification]
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        externalId: String? = nil,
        source: GarmentSource = .modaics,
        originalUrl: URL? = nil,
        embedding: [Float]? = nil,
        title: String,
        description: String,
        story: Story,
        condition: Condition,
        originalPrice: Decimal? = nil,
        suggestedPrice: Decimal? = nil,
        listingPrice: Decimal? = nil,
        currency: Currency = .gbp,
        category: Category,
        subcategory: String? = nil,
        styleTags: [String] = [],
        colors: [Color] = [],
        materials: [Material] = [],
        brand: Brand? = nil,
        size: Size,
        era: Era? = nil,
        coverImageURL: URL? = nil,
        imageURLs: [URL] = [],
        videoURL: URL? = nil,
        ownerId: UUID,
        previousOwnerIds: [UUID] = [],
        isListed: Bool = false,
        exchangeType: ExchangeType? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        viewCount: Int = 0,
        favoriteCount: Int = 0,
        location: Location? = nil,
        carbonSavingsKg: Double? = nil,
        waterSavingsLiters: Double? = nil,
        certifications: [Certification] = []
    ) {
        self.id = id
        self.externalId = externalId
        self.source = source
        self.originalUrl = originalUrl
        self.embedding = embedding
        self.title = title
        self.description = description
        self.story = story
        self.condition = condition
        self.originalPrice = originalPrice
        self.suggestedPrice = suggestedPrice
        self.listingPrice = listingPrice
        self.currency = currency
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
        self.videoURL = videoURL
        self.ownerId = ownerId
        self.previousOwnerIds = previousOwnerIds
        self.isListed = isListed
        self.exchangeType = exchangeType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.viewCount = viewCount
        self.favoriteCount = favoriteCount
        self.location = location
        self.carbonSavingsKg = carbonSavingsKg
        self.waterSavingsLiters = waterSavingsLiters
        self.certifications = certifications
    }
}

// MARK: - Supporting Types

public enum Condition: String, Codable, CaseIterable, Hashable, Sendable {
    case newWithTags = "new_with_tags"
    case newWithoutTags = "new_without_tags"
    case excellent = "excellent"
    case veryGood = "very_good"
    case good = "good"
    case fair = "fair"
    case vintage = "vintage"
    case needsRepair = "needs_repair"
}

public enum ExchangeType: String, Codable, CaseIterable, Hashable, Sendable {
    case sell = "sell"
    case trade = "trade"
    case sellOrTrade = "sell_or_trade"
}

public enum Category: String, Codable, CaseIterable, Hashable, Sendable {
    case tops = "tops"
    case bottoms = "bottoms"
    case dresses = "dresses"
    case outerwear = "outerwear"
    case activewear = "activewear"
    case loungewear = "loungewear"
    case formal = "formal"
    case accessories = "accessories"
    case shoes = "shoes"
    case jewelry = "jewelry"
    case bags = "bags"
    case vintage = "vintage"
    case other = "other"
}

public struct Color: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var hex: String?
    
    public init(id: UUID = UUID(), name: String, hex: String? = nil) {
        self.id = id
        self.name = name
        self.hex = hex
    }
}

public struct Material: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var percentage: Int?
    public var isSustainable: Bool
    
    public init(id: UUID = UUID(), name: String, percentage: Int? = nil, isSustainable: Bool = false) {
        self.id = id
        self.name = name
        self.percentage = percentage
        self.isSustainable = isSustainable
    }
}

public struct Brand: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var isLuxury: Bool
    public var isSustainable: Bool
    public var countryOfOrigin: String?
    
    public init(id: UUID = UUID(), name: String, isLuxury: Bool = false, isSustainable: Bool = false, countryOfOrigin: String? = nil) {
        self.id = id
        self.name = name
        self.isLuxury = isLuxury
        self.isSustainable = isSustainable
        self.countryOfOrigin = countryOfOrigin
    }
}

public struct Size: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var label: String
    public var system: SizeSystem
    public var measurements: [Measurement]
    
    public init(id: UUID = UUID(), label: String, system: SizeSystem, measurements: [Measurement] = []) {
        self.id = id
        self.label = label
        self.system = system
        self.measurements = measurements
    }
}

public enum SizeSystem: String, Codable, CaseIterable, Hashable, Sendable {
    case us = "us"
    case uk = "uk"
    case eu = "eu"
    case it = "it"
    case fr = "fr"
    case jp = "jp"
    case universal = "universal"
    case numeric = "numeric"
    case oneSize = "one_size"
}

public struct Measurement: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var type: MeasurementType
    public var value: Double
    public var unit: Unit
    
    public init(id: UUID = UUID(), type: MeasurementType, value: Double, unit: Unit = .inches) {
        self.id = id
        self.type = type
        self.value = value
        self.unit = unit
    }
}

public enum MeasurementType: String, Codable, CaseIterable, Hashable, Sendable {
    case bust = "bust"
    case waist = "waist"
    case hips = "hips"
    case length = "length"
    case sleeve = "sleeve"
    case shoulder = "shoulder"
    case inseam = "inseam"
    case rise = "rise"
    case footLength = "foot_length"
    case width = "width"
    case height = "height"
    case depth = "depth"
    case chest = "chest"
    case other = "other"
}

public enum Unit: String, Codable, Hashable, Sendable {
    case inches = "inches"
    case centimeters = "centimeters"
}

public enum Era: String, Codable, CaseIterable, Hashable, Sendable {
    case y2k = "2000s"
    case nineties = "1990s"
    case eighties = "1980s"
    case seventies = "1970s"
    case sixties = "1960s"
    case fifties = "1950s"
    case forties = "1940s"
    case thirties = "1930s"
    case twenties = "1920s"
    case antique = "antique"
    case contemporary = "contemporary"
}

public struct Location: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var city: String
    public var country: String
    public var latitude: Double?
    public var longitude: Double?
    
    public init(id: UUID = UUID(), city: String, country: String, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = id
        self.city = city
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
}

public enum Certification: String, Codable, CaseIterable, Hashable, Sendable {
    case organic = "organic"
    case fairTrade = "fair_trade"
    case recycled = "recycled"
    case vegan = "vegan"
    case carbonNeutral = "carbon_neutral"
    case bCorp = "b_corp"
    case gots = "gots"
    case oekoTex = "oeko_tex"
}

// MARK: - Visual Search Types

/// Result from visual search query
public struct VisualSearchResult: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let garment: Garment
    public let similarityScore: Float
    public let matchReasons: [String]
    
    public init(
        id: UUID = UUID(),
        garment: Garment,
        similarityScore: Float,
        matchReasons: [String] = []
    ) {
        self.id = id
        self.garment = garment
        self.similarityScore = similarityScore
        self.matchReasons = matchReasons
    }
}

/// Visual search request payload
public struct VisualSearchRequest: Codable, Sendable {
    public let imageData: Data?
    public let imageUrl: URL?
    public let embedding: [Float]?
    public let topK: Int
    public let sourceFilter: [GarmentSource]?
    
    public init(
        imageData: Data? = nil,
        imageUrl: URL? = nil,
        embedding: [Float]? = nil,
        topK: Int = 20,
        sourceFilter: [GarmentSource]? = nil
    ) {
        self.imageData = imageData
        self.imageUrl = imageUrl
        self.embedding = embedding
        self.topK = topK
        self.sourceFilter = sourceFilter
    }
}

/// Visual search response
public struct VisualSearchResponse: Codable, Sendable {
    public let results: [VisualSearchResult]
    public let generatedEmbedding: [Float]?
    public let processingTimeMs: Int
}

// MARK: - Sample Data

public extension Garment {
    static let sample = Garment(
        title: "Vintage Leather Biker Jacket",
        description: "A beautifully worn-in leather jacket with authentic patina. Butter-soft leather with original hardware.",
        story: .sample,
        condition: .vintage,
        originalPrice: 450.00,
        suggestedPrice: 280.00,
        listingPrice: 295.00,
        currency: .gbp,
        category: .outerwear,
        subcategory: "Leather Jacket",
        styleTags: ["vintage", "biker", "edgy", "classic", "timeless"],
        colors: [Color(name: "Black", hex: "#1a1a1a")],
        materials: [Material(name: "Leather", percentage: 100)],
        brand: Brand(name: "Schott NYC", isLuxury: false),
        size: Size(label: "M", system: .us, measurements: [
            Measurement(type: .chest, value: 42),
            Measurement(type: .length, value: 26)
        ]),
        era: .nineties,
        ownerId: UUID(),
        isListed: true,
        exchangeType: .sell,
        carbonSavingsKg: 45.2,
        waterSavingsLiters: 1800
    )
    
    static let sampleDress = Garment(
        title: "Silk Midi Dress - Emerald",
        description: "Elegant silk midi dress with bias cut and delicate spaghetti straps. Perfect for special occasions.",
        story: Story(
            narrative: "Wore this to my sister's wedding in Tuscany. The way the silk caught the golden hour light made me feel like I was in a Renaissance painting.",
            provenance: "Vince, purchased new",
            whySelling: "Celebrated too many milestones in it - ready for someone else to make new memories"
        ),
        condition: .excellent,
        originalPrice: 395.00,
        suggestedPrice: 185.00,
        currency: .gbp,
        category: .dresses,
        styleTags: ["elegant", "minimal", "special-occasion"],
        colors: [Color(name: "Emerald", hex: "#50C878")],
        materials: [Material(name: "Silk", percentage: 100, isSustainable: true)],
        brand: Brand(name: "Vince", isLuxury: true),
        size: Size(label: "S", system: .us),
        ownerId: UUID(),
        isListed: true,
        exchangeType: .sellOrTrade
    )
    
    /// Sample Depop-sourced garment
    static let sampleFromDepop = Garment(
        externalId: "depop_12345678",
        source: .depop,
        originalUrl: URL(string: "https://www.depop.com/products/sample-item"),
        title: "Vintage Denim Jacket",
        description: "Authentic vintage denim jacket from the 90s",
        story: Story(
            narrative: "Sourced from Depop - a classic vintage find",
            provenance: "Depop listing"
        ),
        condition: .vintage,
        listingPrice: 65.00,
        currency: .gbp,
        category: .outerwear,
        styleTags: ["vintage", "denim", "90s"],
        colors: [Color(name: "Blue")],
        materials: [Material(name: "Denim", percentage: 100)],
        size: Size(label: "M", system: .us),
        ownerId: UUID(),
        isListed: true,
        exchangeType: .sell
    )
}
