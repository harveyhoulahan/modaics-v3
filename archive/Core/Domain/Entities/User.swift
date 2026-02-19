import Foundation

// MARK: - User
/// The Intentional Dresser - Modaics user profile
/// Represents someone who cares about the stories behind their clothes
public struct User: Identifiable, Codable, Hashable {
    public let id: UUID
    
    // MARK: - Profile
    
    /// Display name/handle
    public var displayName: String
    
    /// Username (@handle)
    public var username: String
    
    /// Bio/description
    public var bio: String
    
    /// Profile avatar URL
    public var avatarURL: URL?
    
    /// Cover/header image URL
    public var coverImageURL: URL?
    
    // MARK: - Style Profile
    
    /// Self-described style descriptors
    public var styleDescriptors: [String]
    
    /// Preferred aesthetic (minimalist, maximalist, etc.)
    public var aesthetic: Aesthetic?
    
    /// Size preferences across systems
    public var sizePreferences: [SizePreference]
    
    /// Preferred colors
    public var favoriteColors: [String]
    
    /// Brands they love
    public var favoriteBrands: [Brand]
    
    /// What they're looking for
    public var wishlistItems: [WishlistItem]
    
    /// What they're willing to trade
    public var openToTrade: Bool
    
    /// Preferred exchange types
    public var preferredExchangeTypes: [ExchangeType]
    
    // MARK: - Statistics
    
    /// Number of garments in their wardrobe
    public var wardrobeCount: Int
    
    /// Number of successful exchanges completed
    public var exchangeCount: Int
    
    /// Average rating from other users (1-5)
    public var rating: Double
    
    /// Number of ratings received
    public var ratingCount: Int
    
    /// Follower count
    public var followerCount: Int
    
    /// Following count
    public var followingCount: Int
    
    /// Total carbon savings achieved through exchanges
    public var totalCarbonSavingsKg: Double
    
    /// Total water savings in liters
    public var totalWaterSavingsLiters: Double
    
    /// Items kept in circulation (vs landfill)
    public var itemsCirculated: Int
    
    // MARK: - Location & Availability
    
    /// Primary location for local discovery
    public var location: Location?
    
    /// Shipping preferences (domestic, international, local only)
    public var shippingPreference: ShippingPreference
    
    // MARK: - Account
    
    /// Email address
    public var email: String
    
    /// Email verified status
    public var isEmailVerified: Bool
    
    /// Account tier
    public var tier: UserTier
    
    /// Atelier subscription (premium features)
    public var atelierSubscription: AtelierSubscription?
    
    /// When they joined
    public var joinedAt: Date
    
    /// Last active timestamp
    public var lastActiveAt: Date
    
    /// Account status
    public var status: UserStatus
    
    // MARK: - Preferences
    
    /// Notification preferences
    public var notificationPreferences: NotificationPreferences
    
    /// Privacy settings
    public var privacySettings: PrivacySettings
    
    /// Content preferences (what they want to see)
    public var contentPreferences: ContentPreferences
    
    public init(
        id: UUID = UUID(),
        displayName: String,
        username: String,
        bio: String = "",
        avatarURL: URL? = nil,
        coverImageURL: URL? = nil,
        styleDescriptors: [String] = [],
        aesthetic: Aesthetic? = nil,
        sizePreferences: [SizePreference] = [],
        favoriteColors: [String] = [],
        favoriteBrands: [Brand] = [],
        wishlistItems: [WishlistItem] = [],
        openToTrade: Bool = true,
        preferredExchangeTypes: [ExchangeType] = [.sellOrTrade],
        wardrobeCount: Int = 0,
        exchangeCount: Int = 0,
        rating: Double = 0,
        ratingCount: Int = 0,
        followerCount: Int = 0,
        followingCount: Int = 0,
        totalCarbonSavingsKg: Double = 0,
        totalWaterSavingsLiters: Double = 0,
        itemsCirculated: Int = 0,
        location: Location? = nil,
        shippingPreference: ShippingPreference = .domestic,
        email: String,
        isEmailVerified: Bool = false,
        tier: UserTier = .free,
        atelierSubscription: AtelierSubscription? = nil,
        joinedAt: Date = Date(),
        lastActiveAt: Date = Date(),
        status: UserStatus = .active,
        notificationPreferences: NotificationPreferences = NotificationPreferences(),
        privacySettings: PrivacySettings = PrivacySettings(),
        contentPreferences: ContentPreferences = ContentPreferences()
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
        self.atelierSubscription = atelierSubscription
        self.joinedAt = joinedAt
        self.lastActiveAt = lastActiveAt
        self.status = status
        self.notificationPreferences = notificationPreferences
        self.privacySettings = privacySettings
        self.contentPreferences = contentPreferences
    }
}

// MARK: - Supporting Types

public enum Aesthetic: String, Codable, CaseIterable, Hashable {
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

public struct SizePreference: Codable, Hashable, Identifiable {
    public let id: UUID
    public var category: Category
    public var size: String
    public var system: SizeSystem
    
    public init(id: UUID = UUID(), category: Category, size: String, system: SizeSystem) {
        self.id = id
        self.category = category
        self.size = size
        self.system = system
    }
}

public struct WishlistItem: Codable, Hashable, Identifiable {
    public let id: UUID
    public var description: String
    public var category: Category?
    public var brand: String?
    public var priority: WishlistPriority
    
    public init(id: UUID = UUID(), description: String, category: Category? = nil, brand: String? = nil, priority: WishlistPriority = .medium) {
        self.id = id
        self.description = description
        self.category = category
        self.brand = brand
        self.priority = priority
    }
}

public enum WishlistPriority: String, Codable, CaseIterable, Hashable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case dreamItem = "dream_item"
}

public enum ShippingPreference: String, Codable, CaseIterable, Hashable {
    case localOnly = "local_only"
    case domestic = "domestic"
    case international = "international"
}

public enum UserTier: String, Codable, CaseIterable, Hashable {
    case free = "free"
    case premium = "premium"
    case atelier = "atelier"
}

public struct AtelierSubscription: Codable, Hashable, Identifiable {
    public let id: UUID
    public var startedAt: Date
    public var expiresAt: Date?
    public var autoRenew: Bool
    public var features: [AtelierFeature]
    
    public init(id: UUID = UUID(), startedAt: Date = Date(), expiresAt: Date? = nil, autoRenew: Bool = true, features: [AtelierFeature] = []) {
        self.id = id
        self.startedAt = startedAt
        self.expiresAt = expiresAt
        self.autoRenew = autoRenew
        self.features = features
    }
}

public enum AtelierFeature: String, Codable, CaseIterable, Hashable {
    case priorityListing = "priority_listing"
    case enhancedAnalytics = "enhanced_analytics"
    case personalStylist = "personal_stylist"
    case exclusiveAccess = "exclusive_access"
    case zeroFees = "zero_fees"
    case earlyAccess = "early_access"
}

public enum UserStatus: String, Codable, CaseIterable, Hashable {
    case active = "active"
    case suspended = "suspended"
    case pendingVerification = "pending_verification"
    case deactivated = "deactivated"
}

public struct NotificationPreferences: Codable, Hashable {
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

public struct PrivacySettings: Codable, Hashable {
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

public struct ContentPreferences: Codable, Hashable {
    public var preferredCategories: [Category]
    public var priceRange: PriceRange?
    public var preferredConditions: [Condition]
    public var sustainableOnly: Bool
    public var localOnly: Bool
    
    public init(
        preferredCategories: [Category] = [],
        priceRange: PriceRange? = nil,
        preferredConditions: [Condition] = [],
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

public struct PriceRange: Codable, Hashable {
    public var min: Decimal
    public var max: Decimal
    public var currency: String
    
    public init(min: Decimal, max: Decimal, currency: String = "USD") {
        self.min = min
        self.max = max
        self.currency = currency
    }
}

// MARK: - Sample Data

public extension User {
    static let sample = User(
        displayName: "Elara Vance",
        username: "elaravance",
        bio: "Curator of stories, lover of vintage finds. Building a wardrobe with intention and soul. ✨",
        styleDescriptors: ["Vintage-modern fusion", "Sustainable", "Minimalist-maximalist"],
        aesthetic: .vintage,
        sizePreferences: [
            SizePreference(category: .tops, size: "M", system: .us),
            SizePreference(category: .bottoms, size: "28", system: .us),
            SizePreference(category: .dresses, size: "6", system: .us)
        ],
        favoriteColors: ["Emerald", "Rust", "Cream", "Black"],
        favoriteBrands: [
            Brand(name: "Vince", isLuxury: true),
            Brand(name: "Reformation", isSustainable: true)
        ],
        wishlistItems: [
            WishlistItem(description: "Vintage silk blouse in cream", category: .tops, priority: .high),
            WishlistItem(description: "Oversized wool coat", category: .outerwear, priority: .medium)
        ],
        wardrobeCount: 47,
        exchangeCount: 23,
        rating: 4.9,
        ratingCount: 18,
        totalCarbonSavingsKg: 1250.5,
        itemsCirculated: 31,
        location: Location(city: "Brooklyn", country: "USA"),
        email: "elara@example.com",
        tier: .premium
    )
    
    static let sampleNew = User(
        displayName: "Jordan Chen",
        username: "jordanchen",
        bio: "Just getting started with intentional dressing. Looking to build a capsule wardrobe!",
        email: "jordan@example.com"
    )
}