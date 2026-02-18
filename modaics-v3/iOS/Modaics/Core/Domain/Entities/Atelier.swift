import Foundation

// MARK: - Atelier
/// Premium tier features for serious fashion enthusiasts and professionals
/// The Atelier provides advanced tools for wardrobe curation and style management
public struct Atelier: Identifiable, Codable, Hashable {
    public let id: UUID
    
    // MARK: - Subscription
    
    /// User who owns this Atelier subscription
    public var userId: UUID
    
    /// Current subscription tier within Atelier
    public var tier: AtelierTier
    
    /// When the subscription started
    public var subscribedAt: Date
    
    /// When the current billing period ends
    public var currentPeriodEnd: Date
    
    /// Whether auto-renew is enabled
    public var autoRenew: Bool
    
    /// Payment status
    public var paymentStatus: PaymentStatus
    
    // MARK: - Features Enabled
    
    /// Priority listing placement
    public var hasPriorityListing: Bool
    
    /// Advanced analytics access
    public var hasAdvancedAnalytics: Bool
    
    /// Personal stylist consultations
    public var hasPersonalStylist: Bool
    
    /// Zero platform fees on sales
    public var hasZeroFees: Bool
    
    /// Exclusive early access to drops
    public var hasEarlyAccess: Bool
    
    /// Bulk listing tools
    public var hasBulkTools: Bool
    
    /// Custom storefront/page
    public var hasCustomStorefront: Bool
    
    /// API access for integrations
    public var hasAPIAccess: Bool
    
    // MARK: - Usage Tracking
    
    /// Number of priority listings used this period
    public var priorityListingsUsed: Int
    
    /// Priority listing quota
    public var priorityListingsQuota: Int
    
    /// Stylist consultations used
    public var stylistSessionsUsed: Int
    
    /// Stylist consultation quota
    public var stylistSessionsQuota: Int
    
    /// API calls made this period
    public var apiCallsUsed: Int
    
    /// API call quota
    public var apiCallsQuota: Int
    
    /// Amount saved on platform fees
    public var feesSaved: Decimal
    
    /// Revenue from priority listing boost
    public var priorityRevenueBoost: Decimal
    
    // MARK: - Analytics
    
    /// Detailed performance metrics
    public var performanceMetrics: PerformanceMetrics
    
    /// Historical growth data
    public var growthHistory: [MonthlyMetrics]
    
    /// Audience insights
    public var audienceInsights: AudienceInsights?
    
    /// Competitive benchmarking
    public var marketPosition: MarketPosition?
    
    // MARK: - Stylist Features
    
    /// Assigned stylist (if applicable)
    public var assignedStylistId: UUID?
    
    /// Stylist session history
    public var stylistSessions: [StylistSession]
    
    /// Personalized recommendations
    public var stylistRecommendations: [StylistRecommendation]
    
    /// Wardrobe audit reports
    public var wardrobeAudits: [WardrobeAudit]
    
    // MARK: - Customization
    
    /// Custom storefront configuration
    public var storefrontConfig: StorefrontConfig?
    
    /// Custom branding elements
    public var branding: AtelierBranding?
    
    /// Vanity URL handle
    public var vanityUrl: String?
    
    // MARK: - Metadata
    
    /// Last billing date
    public var lastBillingDate: Date
    
    /// Next billing amount
    public var nextBillingAmount: Decimal
    
    /// Currency
    public var currency: String
    
    /// Whether trial was used
    public var trialUsed: Bool
    
    /// Referral code
    public var referralCode: String
    
    /// Referred users count
    public var referredUsersCount: Int
    
    /// Credits earned from referrals
    public var referralCredits: Decimal
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        tier: AtelierTier = .essentials,
        subscribedAt: Date = Date(),
        currentPeriodEnd: Date = Date().addingTimeInterval(30 * 24 * 60 * 60),
        autoRenew: Bool = true,
        paymentStatus: PaymentStatus = .active,
        hasPriorityListing: Bool = false,
        hasAdvancedAnalytics: Bool = false,
        hasPersonalStylist: Bool = false,
        hasZeroFees: Bool = false,
        hasEarlyAccess: Bool = false,
        hasBulkTools: Bool = false,
        hasCustomStorefront: Bool = false,
        hasAPIAccess: Bool = false,
        priorityListingsUsed: Int = 0,
        priorityListingsQuota: Int = 0,
        stylistSessionsUsed: Int = 0,
        stylistSessionsQuota: Int = 0,
        apiCallsUsed: Int = 0,
        apiCallsQuota: Int = 0,
        feesSaved: Decimal = 0,
        priorityRevenueBoost: Decimal = 0,
        performanceMetrics: PerformanceMetrics = PerformanceMetrics(),
        growthHistory: [MonthlyMetrics] = [],
        audienceInsights: AudienceInsights? = nil,
        marketPosition: MarketPosition? = nil,
        assignedStylistId: UUID? = nil,
        stylistSessions: [StylistSession] = [],
        stylistRecommendations: [StylistRecommendation] = [],
        wardrobeAudits: [WardrobeAudit] = [],
        storefrontConfig: StorefrontConfig? = nil,
        branding: AtelierBranding? = nil,
        vanityUrl: String? = nil,
        lastBillingDate: Date = Date(),
        nextBillingAmount: Decimal = 0,
        currency: String = "USD",
        trialUsed: Bool = false,
        referralCode: String = "",
        referredUsersCount: Int = 0,
        referralCredits: Decimal = 0
    ) {
        self.id = id
        self.userId = userId
        self.tier = tier
        self.subscribedAt = subscribedAt
        self.currentPeriodEnd = currentPeriodEnd
        self.autoRenew = autoRenew
        self.paymentStatus = paymentStatus
        self.hasPriorityListing = hasPriorityListing
        self.hasAdvancedAnalytics = hasAdvancedAnalytics
        self.hasPersonalStylist = hasPersonalStylist
        self.hasZeroFees = hasZeroFees
        self.hasEarlyAccess = hasEarlyAccess
        self.hasBulkTools = hasBulkTools
        self.hasCustomStorefront = hasCustomStorefront
        self.hasAPIAccess = hasAPIAccess
        self.priorityListingsUsed = priorityListingsUsed
        self.priorityListingsQuota = priorityListingsQuota
        self.stylistSessionsUsed = stylistSessionsUsed
        self.stylistSessionsQuota = stylistSessionsQuota
        self.apiCallsUsed = apiCallsUsed
        self.apiCallsQuota = apiCallsQuota
        self.feesSaved = feesSaved
        self.priorityRevenueBoost = priorityRevenueBoost
        self.performanceMetrics = performanceMetrics
        self.growthHistory = growthHistory
        self.audienceInsights = audienceInsights
        self.marketPosition = marketPosition
        self.assignedStylistId = assignedStylistId
        self.stylistSessions = stylistSessions
        self.stylistRecommendations = stylistRecommendations
        self.wardrobeAudits = wardrobeAudits
        self.storefrontConfig = storefrontConfig
        self.branding = branding
        self.vanityUrl = vanityUrl
        self.lastBillingDate = lastBillingDate
        self.nextBillingAmount = nextBillingAmount
        self.currency = currency
        self.trialUsed = trialUsed
        self.referralCode = referralCode
        self.referredUsersCount = referredUsersCount
        self.referralCredits = referralCredits
    }
}

// MARK: - Supporting Types

public enum AtelierTier: String, Codable, CaseIterable, Hashable {
    case essentials = "essentials"      // $9.99/month
    case professional = "professional"  // $24.99/month
    case atelier = "atelier"           // $49.99/month
    
    public var displayName: String {
        switch self {
        case .essentials: return "Essentials"
        case .professional: return "Professional"
        case .atelier: return "The Atelier"
        }
    }
    
    public var monthlyPrice: Decimal {
        switch self {
        case .essentials: return 9.99
        case .professional: return 24.99
        case .atelier: return 49.99
        }
    }
}

public enum PaymentStatus: String, Codable, CaseIterable, Hashable {
    case active = "active"
    case pastDue = "past_due"
    case cancelled = "cancelled"
    case paused = "paused"
    case trialing = "trialing"
}

public struct PerformanceMetrics: Codable, Hashable {
    public var totalSales: Decimal
    public var totalSalesCount: Int
    public var averageSalePrice: Decimal
    public var listingConversionRate: Double
    public var averageTimeToSell: TimeInterval // in days
    public var totalViews: Int
    public var totalFavorites: Int
    public var followersGained: Int
    public var profileViews: Int
    
    public init(
        totalSales: Decimal = 0,
        totalSalesCount: Int = 0,
        averageSalePrice: Decimal = 0,
        listingConversionRate: Double = 0,
        averageTimeToSell: TimeInterval = 0,
        totalViews: Int = 0,
        totalFavorites: Int = 0,
        followersGained: Int = 0,
        profileViews: Int = 0
    ) {
        self.totalSales = totalSales
        self.totalSalesCount = totalSalesCount
        self.averageSalePrice = averageSalePrice
        self.listingConversionRate = listingConversionRate
        self.averageTimeToSell = averageTimeToSell
        self.totalViews = totalViews
        self.totalFavorites = totalFavorites
        self.followersGained = followersGained
        self.profileViews = profileViews
    }
}

public struct MonthlyMetrics: Identifiable, Codable, Hashable {
    public let id: UUID
    public var month: Date
    public var sales: Decimal
    public var salesCount: Int
    public var newListings: Int
    public var views: Int
    public var favorites: Int
    public var followersGained: Int
    
    public init(
        id: UUID = UUID(),
        month: Date,
        sales: Decimal = 0,
        salesCount: Int = 0,
        newListings: Int = 0,
        views: Int = 0,
        favorites: Int = 0,
        followersGained: Int = 0
    ) {
        self.id = id
        self.month = month
        self.sales = sales
        self.salesCount = salesCount
        self.newListings = newListings
        self.views = views
        self.favorites = favorites
        self.followersGained = followersGained
    }
}

public struct AudienceInsights: Codable, Hashable {
    public var topLocations: [LocationCount]
    public var ageDistribution: [AgeRange: Double]
    public var genderDistribution: [Gender: Double]
    public var stylePreferences: [StylePreference]
    public var activeHours: [Int: Double] // hour of day -> activity percentage
    public var topReferrers: [String]
    
    public init(
        topLocations: [LocationCount] = [],
        ageDistribution: [AgeRange: Double] = [:],
        genderDistribution: [Gender: Double] = [:],
        stylePreferences: [StylePreference] = [],
        activeHours: [Int: Double] = [:],
        topReferrers: [String] = []
    ) {
        self.topLocations = topLocations
        self.ageDistribution = ageDistribution
        self.genderDistribution = genderDistribution
        self.stylePreferences = stylePreferences
        self.activeHours = activeHours
        self.topReferrers = topReferrers
    }
}

public struct LocationCount: Codable, Hashable, Identifiable {
    public let id: UUID
    public var city: String
    public var country: String
    public var count: Int
    public var percentage: Double
    
    public init(id: UUID = UUID(), city: String, country: String, count: Int, percentage: Double) {
        self.id = id
        self.city = city
        self.country = country
        self.count = count
        self.percentage = percentage
    }
}

public enum AgeRange: String, Codable, CaseIterable, Hashable {
    case under18 = "under_18"
    case range18_24 = "18_24"
    case range25_34 = "25_34"
    case range35_44 = "35_44"
    case range45_54 = "45_54"
    case range55_64 = "55_64"
    case over65 = "over_65"
}

public enum Gender: String, Codable, CaseIterable, Hashable {
    case female = "female"
    case male = "male"
    case nonBinary = "non_binary"
    case preferNotToSay = "prefer_not_to_say"
}

public struct StylePreference: Codable, Hashable, Identifiable {
    public let id: UUID
    public var aesthetic: Aesthetic
    public var percentage: Double
    
    public init(id: UUID = UUID(), aesthetic: Aesthetic, percentage: Double) {
        self.id = id
        self.aesthetic = aesthetic
        self.percentage = percentage
    }
}

public struct MarketPosition: Codable, Hashable {
    public var pricePercentile: Double // 0-100, where do they price vs market
    public var qualityScore: Double // 0-100
    public var engagementRate: Double // 0-100
    public var velocityScore: Double // 0-100 (how fast items sell)
    public var percentileRank: Int // 1-100, overall percentile
    
    public init(
        pricePercentile: Double = 0,
        qualityScore: Double = 0,
        engagementRate: Double = 0,
        velocityScore: Double = 0,
        percentileRank: Int = 0
    ) {
        self.pricePercentile = pricePercentile
        self.qualityScore = qualityScore
        self.engagementRate = engagementRate
        self.velocityScore = velocityScore
        self.percentileRank = percentileRank
    }
}

public struct StylistSession: Identifiable, Codable, Hashable {
    public let id: UUID
    public var stylistId: UUID
    public var scheduledAt: Date
    public var duration: Int // minutes
    public var type: SessionType
    public var status: SessionStatus
    public var notes: String?
    public var recommendations: [String]
    public var completedAt: Date?
    
    public init(
        id: UUID = UUID(),
        stylistId: UUID,
        scheduledAt: Date,
        duration: Int = 60,
        type: SessionType = .virtualConsultation,
        status: SessionStatus = .scheduled,
        notes: String? = nil,
        recommendations: [String] = [],
        completedAt: Date? = nil
    ) {
        self.id = id
        self.stylistId = stylistId
        self.scheduledAt = scheduledAt
        self.duration = duration
        self.type = type
        self.status = status
        self.notes = notes
        self.recommendations = recommendations
        self.completedAt = completedAt
    }
}

public enum SessionType: String, Codable, CaseIterable, Hashable {
    case virtualConsultation = "virtual_consultation"
    case wardrobeAudit = "wardrobe_audit"
    case listingOptimization = "listing_optimization"
    case styleProfile = "style_profile"
    case specialOccasion = "special_occasion"
}

public enum SessionStatus: String, Codable, CaseIterable, Hashable {
    case scheduled = "scheduled"
    case confirmed = "confirmed"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    case noShow = "no_show"
}

public struct StylistRecommendation: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var description: String
    public var category: RecommendationCategory
    public var priority: SuggestionPriority
    public var createdAt: Date
    public var implemented: Bool
    public var implementedAt: Date?
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: RecommendationCategory,
        priority: SuggestionPriority = .medium,
        createdAt: Date = Date(),
        implemented: Bool = false,
        implementedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.priority = priority
        self.createdAt = createdAt
        self.implemented = implemented
        self.implementedAt = implementedAt
    }
}

public enum RecommendationCategory: String, Codable, CaseIterable, Hashable {
    case pricing = "pricing"
    case photography = "photography"
    case description = "description"
    case discovery = "discovery"
    case inventory = "inventory"
    case branding = "branding"
    case general = "general"
}

public struct WardrobeAudit: Identifiable, Codable, Hashable {
    public let id: UUID
    public var conductedAt: Date
    public var stylistId: UUID
    public var totalItemsReviewed: Int
    public var itemsToList: [UUID]
    public var itemsToRepair: [UUID]
    public var itemsToDonate: [UUID]
    public var keyFindings: [String]
    public var actionPlan: [String]
    public var estimatedValueUnlock: Decimal
    
    public init(
        id: UUID = UUID(),
        conductedAt: Date = Date(),
        stylistId: UUID,
        totalItemsReviewed: Int,
        itemsToList: [UUID] = [],
        itemsToRepair: [UUID] = [],
        itemsToDonate: [UUID] = [],
        keyFindings: [String] = [],
        actionPlan: [String] = [],
        estimatedValueUnlock: Decimal = 0
    ) {
        self.id = id
        self.conductedAt = conductedAt
        self.stylistId = stylistId
        self.totalItemsReviewed = totalItemsReviewed
        self.itemsToList = itemsToList
        self.itemsToRepair = itemsToRepair
        self.itemsToDonate = itemsToDonate
        self.keyFindings = keyFindings
        self.actionPlan = actionPlan
        self.estimatedValueUnlock = estimatedValueUnlock
    }
}

public struct StorefrontConfig: Codable, Hashable {
    public var title: String
    public var description: String
    public var bannerImageURL: URL?
    public var profileLayout: ProfileLayout
    public var accentColor: String
    public var font: String
    public var showStats: Bool
    public var showReviews: Bool
    
    public init(
        title: String = "",
        description: String = "",
        bannerImageURL: URL? = nil,
        profileLayout: ProfileLayout = .grid,
        accentColor: String = "#6B7280",
        font: String = "system",
        showStats: Bool = true,
        showReviews: Bool = true
    ) {
        self.title = title
        self.description = description
        self.bannerImageURL = bannerImageURL
        self.profileLayout = profileLayout
        self.accentColor = accentColor
        self.font = font
        self.showStats = showStats
        self.showReviews = showReviews
    }
}

public enum ProfileLayout: String, Codable, CaseIterable, Hashable {
    case grid = "grid"
    case list = "list"
    case magazine = "magazine"
    case minimal = "minimal"
}

public struct AtelierBranding: Codable, Hashable {
    public var logoURL: URL?
    public var customHeader: String?
    public var socialLinks: [SocialLink]
    public var contactEmail: String?
    public var businessName: String?
    
    public init(
        logoURL: URL? = nil,
        customHeader: String? = nil,
        socialLinks: [SocialLink] = [],
        contactEmail: String? = nil,
        businessName: String? = nil
    ) {
        self.logoURL = logoURL
        self.customHeader = customHeader
        self.socialLinks = socialLinks
        self.contactEmail = contactEmail
        self.businessName = businessName
    }
}

public struct SocialLink: Codable, Hashable, Identifiable {
    public let id: UUID
    public var platform: String
    public var url: URL
    public var handle: String?
    
    public init(id: UUID = UUID(), platform: String, url: URL, handle: String? = nil) {
        self.id = id
        self.platform = platform
        self.url = url
        self.handle = handle
    }
}

// MARK: - Sample Data

public extension Atelier {
    static let sampleEssentials = Atelier(
        userId: UUID(),
        tier: .essentials,
        hasPriorityListing: true,
        hasEarlyAccess: true,
        priorityListingsQuota: 5,
        performanceMetrics: PerformanceMetrics(
            totalSales: 1850.00,
            totalSalesCount: 12,
            averageSalePrice: 154.17,
            listingConversionRate: 0.18,
            totalViews: 2450,
            totalFavorites: 189
        ),
        feesSaved: 92.50,
        referralCode: "ELARA20"
    )
    
    static let sampleProfessional = Atelier(
        userId: UUID(),
        tier: .professional,
        hasPriorityListing: true,
        hasAdvancedAnalytics: true,
        hasZeroFees: true,
        hasEarlyAccess: true,
        hasBulkTools: true,
        priorityListingsQuota: 15,
        stylistSessionsQuota: 2,
        performanceMetrics: PerformanceMetrics(
            totalSales: 8750.00,
            totalSalesCount: 47,
            averageSalePrice: 186.17,
            listingConversionRate: 0.24,
            totalViews: 12500,
            totalFavorites: 892,
            followersGained: 234
        ),
        feesSaved: 437.50,
        audienceInsights: AudienceInsights(
            topLocations: [
                LocationCount(city: "New York", country: "USA", count: 450, percentage: 28),
                LocationCount(city: "Los Angeles", country: "USA", count: 320, percentage: 20),
                LocationCount(city: "London", country: "UK", count: 180, percentage: 11)
            ],
            ageDistribution: [.range25_34: 0.45, .range35_44: 0.30, .range18_24: 0.15],
            stylePreferences: [
                StylePreference(aesthetic: .vintage, percentage: 0.35),
                StylePreference(aesthetic: .minimalist, percentage: 0.28),
                StylePreference(aesthetic: .sustainable, percentage: 0.22)
            ]
        ),
        referralCode: "PROSTYLE50"
    )
    
    static let sampleAtelier = Atelier(
        userId: UUID(),
        tier: .atelier,
        hasPriorityListing: true,
        hasAdvancedAnalytics: true,
        hasPersonalStylist: true,
        hasZeroFees: true,
        hasEarlyAccess: true,
        hasBulkTools: true,
        hasCustomStorefront: true,
        hasAPIAccess: true,
        priorityListingsQuota: 50,
        stylistSessionsQuota: 5,
        apiCallsQuota: 10000,
        performanceMetrics: PerformanceMetrics(
            totalSales: 28750.00,
            totalSalesCount: 128,
            averageSalePrice: 224.61,
            listingConversionRate: 0.32,
            averageTimeToSell: 5.2,
            totalViews: 45000,
            totalFavorites: 3200,
            followersGained: 1200,
            profileViews: 8500
        ),
        feesSaved: 1437.50,
        priorityRevenueBoost: 3200.00,
        marketPosition: MarketPosition(
            pricePercentile: 75,
            qualityScore: 92,
            engagementRate: 8.5,
            velocityScore: 88,
            percentileRank: 94
        ),
        storefrontConfig: StorefrontConfig(
            title: "Elara Curated",
            description: "Thoughtfully selected vintage and contemporary pieces with stories to tell",
            profileLayout: .magazine,
            accentColor: "#8B5CF6"
        ),
        branding: AtelierBranding(
            socialLinks: [
                SocialLink(platform: "instagram", url: URL(string: "https://instagram.com/elaracurated")!, handle: "@elaracurated"),
                SocialLink(platform: "pinterest", url: URL(string: "https://pinterest.com/elaracurated")!, handle: "@elaracurated")
            ],
            contactEmail: "hello@elaracurated.com",
            businessName: "Elara Curated LLC"
        ),
        vanityUrl: "elaracurated",
        referralCode: "ATELIER100"
    )
}