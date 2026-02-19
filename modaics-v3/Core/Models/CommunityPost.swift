import Foundation

// MARK: - PostType
/// Types of community posts
public enum PostType: String, CaseIterable, Codable, Identifiable {
    case ootd = "OOTD"
    case thriftFind = "Thrift Find"
    case stylingTip = "Styling Tip"
    case ecoTip = "Eco Tip"
    case challenge = "Challenge"
    case general = "General"
    
    public var id: String { rawValue }
    
    public var displayName: String { rawValue }
    
    public var icon: String {
        switch self {
        case .ootd: return "person.fill"
        case .thriftFind: return "bag.fill"
        case .stylingTip: return "wand.and.stars"
        case .ecoTip: return "leaf.fill"
        case .challenge: return "flag.fill"
        case .general: return "text.bubble.fill"
        }
    }
    
    public var color: String {
        switch self {
        case .ootd: return "D9BD6B"  // luxeGold
        case .thriftFind: return "3D5C1F"  // moss
        case .stylingTip: return "7A9A5A"  // sage
        case .ecoTip: return "3DDC84"  // eco green
        case .challenge: return "F59E0B"  // warning/amber
        case .general: return "B8C9B0"  // sageMuted
        }
    }
}

// MARK: - PostComment
/// Comment on a community post
public struct PostComment: Identifiable, Codable, Hashable {
    public let id: String
    public let userId: String
    public let username: String
    public let avatar: String?
    public let text: String
    public let createdAt: Date
    
    public init(id: String, userId: String, username: String, avatar: String?, text: String, createdAt: Date) {
        self.id = id
        self.userId = userId
        self.username = username
        self.avatar = avatar
        self.text = text
        self.createdAt = createdAt
    }
}

// MARK: - LinkedItem
/// Optional linked item (garment, event, etc.)
public struct LinkedItem: Identifiable, Codable, Hashable {
    public let id: String
    public let type: LinkedItemType
    public let title: String
    public let imageURL: String?
    public let url: String?
    
    public enum LinkedItemType: String, Codable {
        case garment = "GARMENT"
        case event = "EVENT"
        case brand = "BRAND"
        case article = "ARTICLE"
    }
    
    public init(id: String, type: LinkedItemType, title: String, imageURL: String?, url: String?) {
        self.id = id
        self.type = type
        self.title = title
        self.imageURL = imageURL
        self.url = url
    }
}

// MARK: - CommunityPost
/// Model representing a community post in the social feed
public struct CommunityPost: Identifiable, Codable, Hashable {
    public let id: String
    public let userId: String
    public let username: String
    public let avatar: String?
    public let postType: PostType
    public let caption: String
    public let imageURLs: [String]
    public let tags: [String]
    public let location: String?
    public let linkedItem: LinkedItem?
    public var likes: Int
    public var comments: [PostComment]
    public var isLiked: Bool
    public var isBookmarked: Bool
    public let createdAt: Date
    
    public var formattedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    public var likeCountText: String {
        if likes >= 1000 {
            return String(format: "%.1fk", Double(likes) / 1000)
        }
        return "\(likes)"
    }
    
    public var commentCount: Int {
        comments.count
    }
    
    public var commentCountText: String {
        if commentCount >= 1000 {
            return String(format: "%.1fk", Double(commentCount) / 1000)
        }
        return "\(commentCount)"
    }
    
    public init(
        id: String,
        userId: String,
        username: String,
        avatar: String?,
        postType: PostType,
        caption: String,
        imageURLs: [String],
        tags: [String] = [],
        location: String? = nil,
        linkedItem: LinkedItem? = nil,
        likes: Int = 0,
        comments: [PostComment] = [],
        isLiked: Bool = false,
        isBookmarked: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.avatar = avatar
        self.postType = postType
        self.caption = caption
        self.imageURLs = imageURLs
        self.tags = tags
        self.location = location
        self.linkedItem = linkedItem
        self.likes = likes
        self.comments = comments
        self.isLiked = isLiked
        self.isBookmarked = isBookmarked
        self.createdAt = createdAt
    }
    
    // MARK: - Mock Data
    public static let mockPosts: [CommunityPost] = [
        // OOTD Posts
        CommunityPost(
            id: "post-001",
            userId: "user-001",
            username: "sustainable_sarah",
            avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100",
            postType: .ootd,
            caption: "Head-to-toe thrifted outfit for today's coffee run! Found this vintage blazer at the Fitzroy market last weekend. The quality is incredible and it's so unique!",
            imageURLs: [
                "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600",
                "https://images.unsplash.com/photo-1581044777550-4cfa60707c03?w=600"
            ],
            tags: ["thrifted", "vintage", "ootd", "melbourne"],
            location: "Fitzroy, Melbourne",
            likes: 247,
            comments: [
                PostComment(id: "c1", userId: "u2", username: "eco_emma", avatar: nil, text: "Love the blazer! What a find! 🌿", createdAt: Date().addingTimeInterval(-3600)),
                PostComment(id: "c2", userId: "u3", username: "vintage_vibes", avatar: nil, text: "That color is perfect on you", createdAt: Date().addingTimeInterval(-7200))
            ],
            isLiked: false,
            isBookmarked: true,
            createdAt: Date().addingTimeInterval(-3600 * 2)
        ),
        
        // Thrift Find
        CommunityPost(
            id: "post-002",
            userId: "user-002",
            username: "thrift_king_marcus",
            avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100",
            postType: .thriftFind,
            caption: "SCORE! Found this 90s windbreaker at the Northcote Salvos for $12. It's in perfect condition and the colorway is 🔥 Who says sustainable fashion can't be street?",
            imageURLs: [
                "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600",
                "https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=600"
            ],
            tags: ["thriftfind", "90s", "streetwear", "bargain"],
            location: "Northcote, Melbourne",
            likes: 892,
            comments: [
                PostComment(id: "c3", userId: "u4", username: "street_style_jen", avatar: nil, text: "That color is INSANE! Great find! 🔥", createdAt: Date().addingTimeInterval(-1800))
            ],
            isLiked: true,
            isBookmarked: false,
            createdAt: Date().addingTimeInterval(-3600 * 4)
        ),
        
        // Styling Tip
        CommunityPost(
            id: "post-003",
            userId: "user-003",
            username: "style_guru_lisa",
            avatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100",
            postType: .stylingTip,
            caption: "3 ways to style a white button-down sustainably:\n\n1. Tucked into vintage Levi's with gold hoops\n2. Over a slip dress as a light jacket\n3. Tied at waist with wide-leg linen pants\n\nOne piece, endless outfits! This is why investing in quality basics matters 💚",
            imageURLs: [
                "https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600",
                "https://images.unsplash.com/photo-1485968579580-b6d095142e6e?w=600",
                "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600"
            ],
            tags: ["stylingtips", "sustainablefashion", "capsulewardrobe", "minimalism"],
            likes: 1564,
            comments: [],
            isLiked: true,
            isBookmarked: true,
            createdAt: Date().addingTimeInterval(-3600 * 6)
        ),
        
        // Eco Tip
        CommunityPost(
            id: "post-004",
            userId: "user-004",
            username: "green_living_alex",
            avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100",
            postType: .ecoTip,
            caption: "Did you know? Washing clothes in cold water can reduce your carbon footprint by up to 90% per load! Plus it preserves your clothes longer.\n\n🌡️ Use cold water\n🧺 Air dry when possible\n♻️ Wash full loads\n\nSmall changes, big impact!",
            imageURLs: [
                "https://images.unsplash.com/photo-1582735689369-4fe89db7114c?w=600"
            ],
            tags: ["ecotips", "sustainability", "consciousliving", "carbonfootprint"],
            likes: 2341,
            comments: [
                PostComment(id: "c4", userId: "u5", username: "eco_warrior", avatar: nil, text: "Been doing this for years! Also recommend wool dryer balls 🧶", createdAt: Date().addingTimeInterval(-900))
            ],
            isLiked: false,
            isBookmarked: false,
            createdAt: Date().addingTimeInterval(-3600 * 8)
        ),
        
        // Challenge Post
        CommunityPost(
            id: "post-005",
            userId: "user-005",
            username: "challenge_master_tom",
            avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100",
            postType: .challenge,
            caption: "Day 15 of the #30DayThriftChallenge! Today I styled an entire outfit from my local op shop for under $50. The challenge is reminding me how creative sustainable fashion can be!\n\nJoin us - tag your finds! 🏆",
            imageURLs: [
                "https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=600",
                "https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=600"
            ],
            tags: ["30daythriftchallenge", "thriftchallenge", "community"],
            likes: 567,
            comments: [],
            isLiked: true,
            isBookmarked: false,
            createdAt: Date().addingTimeInterval(-3600 * 12)
        ),
        
        // General Post
        CommunityPost(
            id: "post-006",
            userId: "user-006",
            username: "melbourne_thrifter",
            avatar: nil,
            postType: .general,
            caption: "Just wanted to say how much I love this community! Everyone here is so supportive and creative. Seeing all your sustainable fashion journeys inspires me every day 💚🌿\n\nLet's keep building a better fashion future together!",
            imageURLs: [],
            tags: ["community", "gratitude", "sustainablefashion"],
            likes: 1892,
            comments: [
                PostComment(id: "c5", userId: "u1", username: "sustainable_sarah", avatar: nil, text: "Right back at you! Love this community ❤️", createdAt: Date().addingTimeInterval(-3600 * 2))
            ],
            isLiked: false,
            isBookmarked: false,
            createdAt: Date().addingTimeInterval(-3600 * 18)
        ),
        
        // Another OOTD
        CommunityPost(
            id: "post-007",
            userId: "user-007",
            username: "minimalist_maya",
            avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100",
            postType: .ootd,
            caption: "Monday meetings in my capsule wardrobe staples. This linen blazer has been in rotation for 3 years now and only gets better with age. Quality over quantity always! ✨",
            imageURLs: [
                "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600"
            ],
            tags: ["ootd", "capsulewardrobe", "minimalist", "linen"],
            location: "CBD, Melbourne",
            linkedItem: LinkedItem(id: "item-001", type: .garment, title: "Linen Blazer - Brand Name", imageURL: nil, url: nil),
            likes: 423,
            comments: [],
            isLiked: false,
            isBookmarked: true,
            createdAt: Date().addingTimeInterval(-3600 * 20)
        ),
        
        // Thrift Find - Rare
        CommunityPost(
            id: "post-008",
            userId: "user-008",
            username: "vintage_hunter_jess",
            avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100",
            postType: .thriftFind,
            caption: "I still can't believe I found these 70s Levi's in my size! The patina on the denim is gorgeous and they fit like a glove. Thrifting truly is treasure hunting 🏴‍☠️💎",
            imageURLs: [
                "https://images.unsplash.com/photo-1542272454315-4c01d7abdf4a?w=600",
                "https://images.unsplash.com/photo-1582418702059-97ebafb35d09?w=600",
                "https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=600"
            ],
            tags: ["vintage", "70s", "levis", "denim", "thriftfind"],
            location: "Brunswick, Melbourne",
            likes: 1205,
            comments: [
                PostComment(id: "c6", userId: "u2", username: "eco_emma", avatar: nil, text: "OMG the fit is PERFECT! Jealous! 😍", createdAt: Date().addingTimeInterval(-3600 * 3)),
                PostComment(id: "c7", userId: "u9", username: "denim_lover", avatar: nil, text: "That patina is chefs kiss 👌", createdAt: Date().addingTimeInterval(-3600 * 4))
            ],
            isLiked: true,
            isBookmarked: true,
            createdAt: Date().addingTimeInterval(-3600 * 22)
        ),
        
        // Eco Tip - Mending
        CommunityPost(
            id: "post-009",
            userId: "user-009",
            username: "mending_marie",
            avatar: nil,
            postType: .ecoTip,
            caption: "Visible mending is not just practical - it's art! 🪡\n\nInstead of tossing clothes with small tears or holes, try sashiko or simple embroidery to extend their life. Each repair tells a story and makes your piece unique.\n\nWho else loves visible mending?",
            imageURLs: [
                "https://images.unsplash.com/photo-1605218427306-022ba6c63395?w=600",
                "https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600"
            ],
            tags: ["mending", "visiblemending", "slowfashion", "repair"],
            likes: 789,
            comments: [],
            isLiked: false,
            isBookmarked: true,
            createdAt: Date().addingTimeInterval(-3600 * 24)
        ),
        
        // Styling Tip - Layering
        CommunityPost(
            id: "post-010",
            userId: "user-010",
            username: "layer_queen_rita",
            avatar: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=100",
            postType: .stylingTip,
            caption: "Melbourne weather got you confused? Master the art of layers!\n\n🧥 Start with a breathable base\n🧶 Add a knit or cardigan\n🧣 Top with a versatile jacket\n\nEach piece should work on its own, giving you 3+ outfits in one! Perfect for unpredictable days ☀️🌧️",
            imageURLs: [
                "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=600",
                "https://images.unsplash.com/photo-1487222477894-8943e31ef7b2?w=600"
            ],
            tags: ["melbourneweather", "layering", "stylingtips", "versatile"],
            location: "Melbourne",
            likes: 634,
            comments: [
                PostComment(id: "c8", userId: "u11", username: "weather_watcher", avatar: nil, text: "So true! Melbourne in a day has all 4 seasons 😂", createdAt: Date().addingTimeInterval(-3600 * 5))
            ],
            isLiked: false,
            isBookmarked: false,
            createdAt: Date().addingTimeInterval(-3600 * 28)
        )
    ]
}
