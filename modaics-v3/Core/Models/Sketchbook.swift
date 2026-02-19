import Foundation

// MARK: - Sketchbook Models

public struct Sketchbook: Identifiable, Codable {
    public let id: Int
    public let brandId: String
    public var title: String?
    public var description: String?
    public var accessPolicy: SketchbookAccessPolicy
    public var membershipRule: SketchbookMembershipRule
    public var minSpendAmount: Double?
    public var minSpendWindowMonths: Int?
    public var postsCount: Int
    public var memberCount: Int
    public let createdAt: Date?
    
    public init(id: Int, brandId: String, title: String? = nil, description: String? = nil, accessPolicy: SketchbookAccessPolicy = .public_access, membershipRule: SketchbookMembershipRule = .autoApprove, minSpendAmount: Double? = nil, minSpendWindowMonths: Int? = nil, postsCount: Int = 0, memberCount: Int = 0, createdAt: Date? = nil) {
        self.id = id
        self.brandId = brandId
        self.title = title
        self.description = description
        self.accessPolicy = accessPolicy
        self.membershipRule = membershipRule
        self.minSpendAmount = minSpendAmount
        self.minSpendWindowMonths = minSpendWindowMonths
        self.postsCount = postsCount
        self.memberCount = memberCount
        self.createdAt = createdAt
    }
}

public struct SketchbookPost: Identifiable, Codable {
    public let id: Int
    public let sketchbookId: Int
    public let authorUserId: String
    public var postType: SketchbookPostType
    public var title: String
    public var body: String?
    public var media: [MediaAttachment]?
    public var tags: [String]?
    public var visibility: SketchbookVisibility
    public var pollQuestion: String?
    public var pollOptions: [PollOption]?
    public var pollClosesAt: Date?
    public var eventId: Int?
    public var eventHighlight: String?
    public var reactionCount: Int
    public var commentCount: Int
    public let createdAt: Date?
    public var updatedAt: Date?
    public var brandId: String?
    public var authorDisplayName: String?
    public var authorUsername: String?
    
    public init(id: Int, sketchbookId: Int, authorUserId: String, postType: SketchbookPostType = .standard, title: String, body: String? = nil, media: [MediaAttachment]? = nil, tags: [String]? = nil, visibility: SketchbookVisibility = .public, pollQuestion: String? = nil, pollOptions: [PollOption]? = nil, pollClosesAt: Date? = nil, eventId: Int? = nil, eventHighlight: String? = nil, reactionCount: Int = 0, commentCount: Int = 0, createdAt: Date? = nil, updatedAt: Date? = nil, brandId: String? = nil, authorDisplayName: String? = nil, authorUsername: String? = nil) {
        self.id = id
        self.sketchbookId = sketchbookId
        self.authorUserId = authorUserId
        self.postType = postType
        self.title = title
        self.body = body
        self.media = media
        self.tags = tags
        self.visibility = visibility
        self.pollQuestion = pollQuestion
        self.pollOptions = pollOptions
        self.pollClosesAt = pollClosesAt
        self.eventId = eventId
        self.eventHighlight = eventHighlight
        self.reactionCount = reactionCount
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.brandId = brandId
        self.authorDisplayName = authorDisplayName
        self.authorUsername = authorUsername
    }
}

public struct MediaAttachment: Codable {
    public let url: String
    public let type: MediaType
    
    public init(url: String, type: MediaType = .image) {
        self.url = url
        self.type = type
    }
}

public enum MediaType: String, Codable {
    case image, video
}

public struct PollOption: Codable, Identifiable {
    public let id: String
    public let text: String
    public var voteCount: Int
    
    public init(id: String = UUID().uuidString, text: String, voteCount: Int = 0) {
        self.id = id
        self.text = text
        self.voteCount = voteCount
    }
}

public struct SketchbookMembership: Identifiable, Codable {
    public let id: Int
    public let sketchbookId: Int
    public let userId: String
    public var status: MembershipStatus
    public var joinSource: SketchbookJoinSource
    public var joinedAt: Date?
    public var expiresAt: Date?
    
    public init(id: Int, sketchbookId: Int, userId: String, status: MembershipStatus = .pending, joinSource: SketchbookJoinSource = .free, joinedAt: Date? = nil, expiresAt: Date? = nil) {
        self.id = id
        self.sketchbookId = sketchbookId
        self.userId = userId
        self.status = status
        self.joinSource = joinSource
        self.joinedAt = joinedAt
        self.expiresAt = expiresAt
    }
}

// MARK: - Enums

public enum SketchbookAccessPolicy: String, Codable, CaseIterable {
    case public_access = "PUBLIC"
    case members_only = "MEMBERS_ONLY"
    case private_access = "PRIVATE"
    
    public var displayName: String {
        switch self {
        case .public_access: return "Public"
        case .members_only: return "Members Only"
        case .private_access: return "Private"
        }
    }
}

public enum SketchbookMembershipRule: String, Codable, CaseIterable {
    case autoApprove = "AUTO_APPROVE"
    case requestApproval = "REQUEST_APPROVAL"
    case spendThreshold = "SPEND_THRESHOLD"
    case inviteOnly = "INVITE_ONLY"
    
    public var displayName: String {
        switch self {
        case .autoApprove: return "Free Join"
        case .requestApproval: return "Request Access"
        case .spendThreshold: return "Minimum Spend"
        case .inviteOnly: return "Invite Only"
        }
    }
}

public enum SketchbookPostType: String, Codable, CaseIterable {
    case standard = "STANDARD"
    case update = "UPDATE"
    case poll = "POLL"
    case event = "EVENT"
    case announcement = "ANNOUNCEMENT"
    case drop = "DROP"
    
    public var displayName: String {
        switch self {
        case .standard: return "Post"
        case .update: return "Update"
        case .poll: return "Poll"
        case .event: return "Event"
        case .announcement: return "Announcement"
        case .drop: return "Drop"
        }
    }
    
    public var icon: String {
        switch self {
        case .standard: return "doc.text"
        case .update: return "arrow.clockwise"
        case .poll: return "chart.bar"
        case .event: return "calendar"
        case .announcement: return "megaphone"
        case .drop: return "bag"
        }
    }
    
    public var color: String {
        switch self {
        case .standard: return "#D9BD6B"
        case .update: return "#4ADE80"
        case .poll: return "#60A5FA"
        case .event: return "#F472B6"
        case .announcement: return "#FBBF24"
        case .drop: return "#A78BFA"
        }
    }
}

public enum SketchbookVisibility: String, Codable, CaseIterable {
    case `public` = "PUBLIC"
    case membersOnly = "MEMBERS_ONLY"
    case privateVisibility = "PRIVATE"
    
    public var displayName: String {
        switch self {
        case .public: return "Public"
        case .membersOnly: return "Members Only"
        case .privateVisibility: return "Private"
        }
    }
}

public enum MembershipStatus: String, Codable {
    case active = "ACTIVE"
    case pending = "PENDING"
    case expired = "EXPIRED"
    case rejected = "REJECTED"
    
    public var displayName: String {
        switch self {
        case .active: return "Active"
        case .pending: return "Pending"
        case .expired: return "Expired"
        case .rejected: return "Rejected"
        }
    }
}

public enum SketchbookJoinSource: String, Codable {
    case free = "FREE"
    case invited = "INVITED"
    case spend = "SPEND"
    case requested = "REQUESTED"
}

// MARK: - Mock Data

extension Sketchbook {
    public static let mockSketchbooks: [Sketchbook] = [
        Sketchbook(
            id: 1,
            brandId: "brand-001",
            title: "GANNI Sketchbook",
            description: "Behind-the-scenes, early access to drops, and exclusive member events.",
            accessPolicy: .members_only,
            membershipRule: .autoApprove,
            postsCount: 24,
            memberCount: 156,
            createdAt: Date()
        ),
        Sketchbook(
            id: 2,
            brandId: "brand-002",
            title: "Kuwaii Studio",
            description: "Sustainable fashion insights, pattern-making workshops, and member-only sales.",
            accessPolicy: .members_only,
            membershipRule: .requestApproval,
            minSpendAmount: 200,
            minSpendWindowMonths: 12,
            postsCount: 18,
            memberCount: 89,
            createdAt: Date()
        ),
        Sketchbook(
            id: 3,
            brandId: "brand-003",
            title: "The Social Studio",
            description: "Community stories, sewing tips, and upcycling inspiration.",
            accessPolicy: .public_access,
            membershipRule: .autoApprove,
            postsCount: 45,
            memberCount: 342,
            createdAt: Date()
        )
    ]
}

extension SketchbookPost {
    public static let mockPosts: [SketchbookPost] = [
        // GANNI Posts
        SketchbookPost(
            id: 1,
            sketchbookId: 1,
            authorUserId: "brand-001",
            postType: .drop,
            title: "Spring Collection Drop",
            body: "Our new sustainable denim line drops this Friday! Members get 24-hour early access.",
            visibility: .membersOnly,
            eventId: 1,
            reactionCount: 89,
            commentCount: 23,
            createdAt: Date(),
            brandId: "brand-001",
            authorDisplayName: "GANNI",
            authorUsername: "ganni"
        ),
        SketchbookPost(
            id: 2,
            sketchbookId: 1,
            authorUserId: "brand-001",
            postType: .poll,
            title: "Which color should we bring back?",
            body: "We're considering reviving a classic. Vote for your favorite!",
            visibility: .public,
            pollQuestion: "Which colorway should return?",
            pollOptions: [
                PollOption(text: "Vintage Blue", voteCount: 156),
                PollOption(text: "Forest Green", voteCount: 89),
                PollOption(text: "Rust Orange", voteCount: 67)
            ],
            pollClosesAt: Date().addingTimeInterval(86400 * 7),
            reactionCount: 234,
            commentCount: 45,
            createdAt: Date(),
            brandId: "brand-001",
            authorDisplayName: "GANNI",
            authorUsername: "ganni"
        ),
        SketchbookPost(
            id: 3,
            sketchbookId: 1,
            authorUserId: "brand-001",
            postType: .announcement,
            title: "New Store Opening",
            body: "We're opening a new flagship store in Fitzroy! Join us for the launch party.",
            visibility: .public,
            eventId: 2,
            reactionCount: 178,
            commentCount: 34,
            createdAt: Date(),
            brandId: "brand-001",
            authorDisplayName: "GANNI",
            authorUsername: "ganni"
        ),
        // Kuwaii Posts
        SketchbookPost(
            id: 4,
            sketchbookId: 2,
            authorUserId: "brand-002",
            postType: .update,
            title: "Behind the Seams",
            body: "A look at our pattern-making process. Each piece takes 12+ hours to perfect.",
            visibility: .membersOnly,
            reactionCount: 67,
            commentCount: 12,
            createdAt: Date(),
            brandId: "brand-002",
            authorDisplayName: "Kuwaii Studio",
            authorUsername: "kuwaii"
        ),
        SketchbookPost(
            id: 5,
            sketchbookId: 2,
            authorUserId: "brand-002",
            postType: .event,
            title: "Pattern Making Workshop",
            body: "Learn to draft your own patterns. Intermediate level, machines provided.",
            visibility: .membersOnly,
            eventId: 3,
            reactionCount: 45,
            commentCount: 8,
            createdAt: Date(),
            brandId: "brand-002",
            authorDisplayName: "Kuwaii Studio",
            authorUsername: "kuwaii"
        ),
        // Social Studio Posts
        SketchbookPost(
            id: 6,
            sketchbookId: 3,
            authorUserId: "brand-003",
            postType: .standard,
            title: "Sewing Tips: Invisible Hem",
            body: "A step-by-step guide to achieving the perfect invisible hem on any garment.",
            visibility: .public,
            reactionCount: 234,
            commentCount: 56,
            createdAt: Date(),
            brandId: "brand-003",
            authorDisplayName: "The Social Studio",
            authorUsername: "socialstudio"
        ),
        SketchbookPost(
            id: 7,
            sketchbookId: 3,
            authorUserId: "brand-003",
            postType: .poll,
            title: "Workshop Interest Check",
            body: "What workshop would you like to see next?",
            visibility: .public,
            pollQuestion: "Next workshop topic?",
            pollOptions: [
                PollOption(text: "Visible Mending", voteCount: 89),
                PollOption(text: "Natural Dyeing", voteCount: 134),
                PollOption(text: "Zero Waste Pattern", voteCount: 67)
            ],
            pollClosesAt: Date().addingTimeInterval(86400 * 3),
            reactionCount: 123,
            commentCount: 34,
            createdAt: Date(),
            brandId: "brand-003",
            authorDisplayName: "The Social Studio",
            authorUsername: "socialstudio"
        ),
        SketchbookPost(
            id: 8,
            sketchbookId: 3,
            authorUserId: "brand-003",
            postType: .announcement,
            title: "Community Spotlight",
            body: "This month we're featuring local makers who've transformed their wardrobes through upcycling.",
            visibility: .public,
            reactionCount: 189,
            commentCount: 45,
            createdAt: Date(),
            brandId: "brand-003",
            authorDisplayName: "The Social Studio",
            authorUsername: "socialstudio"
        )
    ]
}