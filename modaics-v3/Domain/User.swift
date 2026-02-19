import Foundation

// MARK: - ModaicsUser
/// The Intentional Dresser - Modaics user profile
/// Represents someone who cares about the stories behind their clothes
public struct ModaicsUser: Identifiable, Codable, Hashable {
    public let id: UUID
    
    public var displayName: String
    public var username: String
    public var bio: String
    public var avatarURL: URL?
    public var coverImageURL: URL?
    
    public var styleDescriptors: [String]
    public var aesthetic: ModaicsAesthetic?
    public var sizePreferences: [ModaicsSizePreference]
    public var favoriteColors: [String]
    public var favoriteBrands: [ModaicsBrand]
    public var wishlistItems: [ModaicsWishlistItem]
    public var openToTrade: Bool
    public var preferredExchangeTypes: [ModaicsExchangeType]
    
    public var wardrobeCount: Int
    public var exchangeCount: Int
    public var rating: Double
    public var ratingCount: Int
    public var followerCount: Int
    public var followingCount: Int
    public var totalCarbonSavingsKg: Double
    public var totalWaterSavingsLiters: Double
    public var itemsCirculated: Int
    
    public var location: ModaicsLocation?
    public var shippingPreference: ModaicsShippingPreference
    
    public var email: String
    public var isEmailVerified: Bool
    public var tier: ModaicsUserTier
    public var joinedAt: Date
    public var lastActiveAt: Date
    public var status: ModaicsUserStatus
    
    public var notificationPreferences: ModaicsNotificationPreferences
    public var privacySettings: ModaicsPrivacySettings
    public var contentPreferences: ModaicsContentPreferences
    
    public init(
        id: UUID = UUID(),
        displayName: String,
        username: String,
        bio: String = "",
        avatarURL: URL? = nil,
        coverImageURL: URL? = nil,
        styleDescriptors: [String] = [],
        aesthetic: ModaicsAesthetic? = nil,
        sizePreferences: [ModaicsSizePreference] = [],
        favoriteColors: [String] = [],
        favoriteBrands: [ModaicsBrand] = [],
        wishlistItems: [ModaicsWishlistItem] = [],
        openToTrade: Bool = true,
        preferredExchangeTypes: [ModaicsExchangeType] = [.sellOrTrade],
        wardrobeCount: Int = 0,
        exchangeCount: Int = 0,
        rating: Double = 0,
        ratingCount: Int = 0,
        followerCount: Int = 0,
        followingCount: Int = 0,
        totalCarbonSavingsKg: Double = 0,
        totalWaterSavingsLiters: Double = 0,
        itemsCirculated: Int = 0,
        location: ModaicsLocation? = nil,
        shippingPreference: ModaicsShippingPreference = .domestic,
        email: String,
        isEmailVerified: Bool = false,
        tier: ModaicsUserTier = .free,
        joinedAt: Date = Date(),
        lastActiveAt: Date = Date(),
        status: ModaicsUserStatus = .active,
        notificationPreferences: ModaicsNotificationPreferences = ModaicsNotificationPreferences(),
        privacySettings: ModaicsPrivacySettings = ModaicsPrivacySettings(),
        contentPreferences: ModaicsContentPreferences = ModaicsContentPreferences()
    ) {
        self.id = id
        self.displayName = displayName
        self.username = username
        self.bio = bio
        self.avatarURL = avatarURL
        self.coverImageURL = coverImageURL
        self.styleDescriptors = styleDescriptors
        self.aesthetic = aesthetic
        self.sizePreferences = sizePreferences
        self.favoriteColors = favoriteColors
        self.favoriteBrands = favoriteBrands
        self.wishlistItems = wishlistItems
        self.openToTrade = openToTrade
        self.preferredExchangeTypes = preferredExchangeTypes
        self.wardrobeCount = wardrobeCount
        self.exchangeCount = exchangeCount
        self.rating = rating
        self.ratingCount = ratingCount
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.totalCarbonSavingsKg = totalCarbonSavingsKg
        self.totalWaterSavingsLiters = totalWaterSavingsLiters
        self.itemsCirculated = itemsCirculated
        self.location = location
        self.shippingPreference = shippingPreference
        self.email = email
        self.isEmailVerified = isEmailVerified
        self.tier = tier
        self.joinedAt = joinedAt
        self.lastActiveAt = lastActiveAt
        self.status = status
        self.notificationPreferences = notificationPreferences
        self.privacySettings = privacySettings
        self.contentPreferences = contentPreferences
    }
}

// MARK: - Supporting Types

public enum ModaicsAesthetic: String, Codable, CaseIterable, Hashable {
    case minimalist = "minimalist"
    case maximalist = "maximalist"
    case classic = "classic"
    case bohemian = "bohemian"
    case streetwear = "streetwear"
    case avantGarde = "avant_garde"
    case vintage = "vintage"
    case preppy = "preppy"
    case romantic = "romantic"
    case edgy = "edgy"
    case sustainable = "sustainable"
    case luxury = "luxury"
    case casual = "casual"
    case workwear = "workwear"
}

public struct ModaicsSizePreference: Codable, Hashable, Identifiable {
    public let id: UUID
    public var category: ModaicsCategory
    public var size: String
    public var system: ModaicsSizeSystem
    
    public init(id: UUID = UUID(), category: ModaicsCategory, size: String, system: ModaicsSizeSystem) {
        self.id = id
        self.category = category
        self.size = size
        self.system = system
    }
}

public struct ModaicsWishlistItem: Codable, Hashable, Identifiable {
    public let id: UUID
    public var description: String
    public var category: ModaicsCategory?
    public var brand: String?
    public var priority: ModaicsWishlistPriority
    
    public init(id: UUID = UUID(), description: String, category: ModaicsCategory? = nil, brand: String? = nil, priority: ModaicsWishlistPriority = .medium) {
        self.id = id
        self.description = description
        self.category = category
        self.brand = brand
        self.priority = priority
    }
}

public enum ModaicsWishlistPriority: String, Codable, CaseIterable, Hashable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case dreamItem = "dream_item"
}

public enum ModaicsShippingPreference: String, Codable, CaseIterable, Hashable {
    case localOnly = "local_only"
    case domestic = "domestic"
    case international = "international"
}

public enum ModaicsUserTier: String, Codable, CaseIterable, Hashable {
    case free = "free"
    case premium = "premium"
    case atelier = "atelier"
}

public enum ModaicsUserStatus: String, Codable, CaseIterable, Hashable {
    case active = "active"
    case suspended = "suspended"
    case pendingVerification = "pending_verification"
    case deactivated = "deactivated"
}

public struct ModaicsNotificationPreferences: Codable, Hashable {
    public var newMatches: Bool
    public var messages: Bool
    public var priceDrops: Bool
    public var newArrivals: Bool
    public var newsletter: Bool
    public var exchangeUpdates: Bool
    public var pushEnabled: Bool
    public var emailEnabled: Bool
    
    public init(
        newMatches: Bool = true,
        messages: Bool = true,
        priceDrops: Bool = true,
        newArrivals: Bool = false,
        newsletter: Bool = false,
        exchangeUpdates: Bool = true,
        pushEnabled: Bool = true,
        emailEnabled: Bool = true
    ) {
        self.newMatches = newMatches
        self.messages = messages
        self.priceDrops = priceDrops
        self.newArrivals = newArrivals
        self.newsletter = newsletter
        self.exchangeUpdates = exchangeUpdates
        self.pushEnabled = pushEnabled
        self.emailEnabled = emailEnabled
    }
}

public struct ModaicsPrivacySettings: Codable, Hashable {
    public var profilePublic: Bool
    public var wardrobeVisible: Bool
    public var showLocation: Bool
    public var allowMessaging: Bool
    public var showActivityStatus: Bool
    
    public init(
        profilePublic: Bool = true,
        wardrobeVisible: Bool = true,
        showLocation: Bool = false,
        allowMessaging: Bool = true,
        showActivityStatus: Bool = true
    ) {
        self.profilePublic = profilePublic
        self.wardrobeVisible = wardrobeVisible
        self.showLocation = showLocation
        self.allowMessaging = allowMessaging
        self.showActivityStatus = showActivityStatus
    }
}

public struct ModaicsContentPreferences: Codable, Hashable {
    public var preferredCategories: [ModaicsCategory]
    public var priceRange: ModaicsPriceRange?
    public var preferredConditions: [ModaicsCondition]
    public var sustainableOnly: Bool
    public var localOnly: Bool
    
    public init(
        preferredCategories: [ModaicsCategory] = [],
        priceRange: ModaicsPriceRange? = nil,
        preferredConditions: [ModaicsCondition] = [],
        sustainableOnly: Bool = false,
        localOnly: Bool = false
    ) {
        self.preferredCategories = preferredCategories
        self.priceRange = priceRange
        self.preferredConditions = preferredConditions
        self.sustainableOnly = sustainableOnly
        self.localOnly = localOnly
    }
}

public struct ModaicsPriceRange: Codable, Hashable {
    public var min: Decimal
    public var max: Decimal
    public var currency: String
    
    public init(min: Decimal, max: Decimal, currency: String = "USD") {
        self.min = min
        self.max = max
        self.currency = currency
    }
}
