import Foundation

// MARK: - ModaicsGarment
/// A single piece of clothing in the Modaics ecosystem
/// Every garment has a story, condition, and lifecycle
public struct ModaicsGarment: Identifiable, Codable, Hashable {
    public let id: UUID
    
    public var title: String
    public var description: String
    public var storyId: UUID
    public var condition: ModaicsCondition
    public var originalPrice: Decimal?
    public var listingPrice: Decimal?
    
    public var category: ModaicsCategory
    public var subcategory: String?
    public var styleTags: [String]
    public var colors: [ModaicsGarmentColor]
    public var materials: [ModaicsMaterial]
    public var brand: ModaicsBrand?
    public var size: ModaicsSize
    public var era: ModaicsEra?
    
    public var coverImageURL: URL?
    public var imageURLs: [URL]
    
    public var ownerId: UUID
    public var previousOwnerIds: [UUID]
    public var isListed: Bool
    public var exchangeType: ModaicsExchangeType?
    
    public var createdAt: Date
    public var updatedAt: Date
    public var viewCount: Int
    public var favoriteCount: Int
    public var location: ModaicsLocation?
    
    public var carbonSavingsKg: Double?
    public var waterSavingsLiters: Double?
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        storyId: UUID,
        condition: ModaicsCondition,
        originalPrice: Decimal? = nil,
        listingPrice: Decimal? = nil,
        category: ModaicsCategory,
        subcategory: String? = nil,
        styleTags: [String] = [],
        colors: [ModaicsGarmentColor] = [],
        materials: [ModaicsMaterial] = [],
        brand: ModaicsBrand? = nil,
        size: ModaicsSize,
        era: ModaicsEra? = nil,
        coverImageURL: URL? = nil,
        imageURLs: [URL] = [],
        ownerId: UUID,
        previousOwnerIds: [UUID] = [],
        isListed: Bool = false,
        exchangeType: ModaicsExchangeType? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        viewCount: Int = 0,
        favoriteCount: Int = 0,
        location: ModaicsLocation? = nil,
        carbonSavingsKg: Double? = nil,
        waterSavingsLiters: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.storyId = storyId
        self.condition = condition
        self.originalPrice = originalPrice
        self.listingPrice = listingPrice
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
    }
}

// MARK: - Supporting Types

public enum ModaicsCondition: String, Codable, CaseIterable, Hashable {
    case newWithTags = "new_with_tags"
    case newWithoutTags = "new_without_tags"
    case excellent = "excellent"
    case veryGood = "very_good"
    case good = "good"
    case fair = "fair"
    case vintage = "vintage"
    case needsRepair = "needs_repair"
}

public enum ModaicsExchangeType: String, Codable, CaseIterable, Hashable {
    case sell = "sell"
    case trade = "trade"
    case sellOrTrade = "sell_or_trade"
}

public enum ModaicsCategory: String, Codable, CaseIterable, Hashable {
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

public struct ModaicsGarmentColor: Codable, Hashable, Identifiable {
    public let id: UUID
    public var name: String
    public var hex: String?
    
    public init(id: UUID = UUID(), name: String, hex: String? = nil) {
        self.id = id
        self.name = name
        self.hex = hex
    }
}

public struct ModaicsMaterial: Codable, Hashable, Identifiable {
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

public struct ModaicsBrand: Codable, Hashable, Identifiable {
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

public struct ModaicsSize: Codable, Hashable, Identifiable {
    public let id: UUID
    public var label: String
    public var system: ModaicsSizeSystem
    public var measurements: [ModaicsMeasurement]
    
    public init(id: UUID = UUID(), label: String, system: ModaicsSizeSystem, measurements: [ModaicsMeasurement] = []) {
        self.id = id
        self.label = label
        self.system = system
        self.measurements = measurements
    }
}

public enum ModaicsSizeSystem: String, Codable, CaseIterable, Hashable {
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

public struct ModaicsMeasurement: Codable, Hashable, Identifiable {
    public let id: UUID
    public var type: ModaicsMeasurementType
    public var value: Double
    public var unit: ModaicsUnit
    
    public init(id: UUID = UUID(), type: ModaicsMeasurementType, value: Double, unit: ModaicsUnit = .inches) {
        self.id = id
        self.type = type
        self.value = value
        self.unit = unit
    }
}

public enum ModaicsMeasurementType: String, Codable, CaseIterable, Hashable {
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
    case other = "other"
}

public enum ModaicsUnit: String, Codable, Hashable {
    case inches = "inches"
    case centimeters = "centimeters"
}

public enum ModaicsEra: String, Codable, CaseIterable, Hashable {
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

public struct ModaicsLocation: Codable, Hashable, Identifiable {
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

public enum ModaicsCertification: String, Codable, CaseIterable, Hashable {
    case organic = "organic"
    case fairTrade = "fair_trade"
    case recycled = "recycled"
    case vegan = "vegan"
    case carbonNeutral = "carbon_neutral"
    case bCorp = "b_corp"
    case gots = "gots"
    case oekoTex = "oeko_tex"
}
