import SwiftUI

struct CommunityPost: Identifiable {
    let id: UUID
    let user: User
    let content: String
    let images: [String]
    let likes: Int
    let comments: Int
    let timestamp: Date
    let isLiked: Bool
    let isSketchbook: Bool
}

struct User: Identifiable {
    let id: UUID
    let name: String
    let avatar: String
    let isBrand: Bool
}

struct CommunityEvent: Identifiable {
    let id: UUID
    let title: String
    let image: String
    let date: Date
    let location: String
    let attendeeCount: Int
    let isRSVPd: Bool
    let eventType: EventType
}

enum EventType: String {
    case swapMeet = "Swap Meet"
    case market = "Market"
    case workshop = "Workshop"
    case meetup = "Meetup"
}

enum CommunityTab {
    case feed
    case events
    case sketchbook
}

// MARK: - Mock Data
extension CommunityViewModel {
    static let mockUsers = [
        User(id: UUID(), name: "VintageFinds", avatar: "person.circle.fill", isBrand: false),
        User(id: UUID(), name: "MODAICS", avatar: "storefront.fill", isBrand: true),
        User(id: UUID(), name: "DenimArchive", avatar: "person.crop.circle.fill", isBrand: false),
        User(id: UUID(), name: "SelvedgeCo", avatar: "building.columns.fill", isBrand: true),
        User(id: UUID(), name: "ThreadStories", avatar: "person.circle", isBrand: false)
    ]
    
    static let mockPosts = [
        CommunityPost(
            id: UUID(),
            user: mockUsers[0],
            content: "Just found this incredible 1960s Type II jacket at the flea market. The fades on this are unreal!",
            images: ["jacket1", "jacket2"],
            likes: 247,
            comments: 42,
            timestamp: Date().addingTimeInterval(-3600),
            isLiked: false,
            isSketchbook: false
        ),
        CommunityPost(
            id: UUID(),
            user: mockUsers[1],
            content: "New collection dropping next week. Raw indigo meets industrial hardware. Stay tuned.",
            images: ["collection1", "detail1", "hardware1"],
            likes: 892,
            comments: 156,
            timestamp: Date().addingTimeInterval(-7200),
            isLiked: true,
            isSketchbook: true
        ),
        CommunityPost(
            id: UUID(),
            user: mockUsers[2],
            content: "6 months of wear on these 21oz. The honeycombs are starting to show.",
            images: ["denim1"],
            likes: 134,
            comments: 23,
            timestamp: Date().addingTimeInterval(-14400),
            isLiked: false,
            isSketchbook: false
        ),
        CommunityPost(
            id: UUID(),
            user: mockUsers[3],
            content: "Behind the scenes at the mill. The shuttle looms never stop.",
            images: ["mill1", "loom1", "thread1"],
            likes: 567,
            comments: 89,
            timestamp: Date().addingTimeInterval(-28800),
            isLiked: false,
            isSketchbook: true
        ),
        CommunityPost(
            id: UUID(),
            user: mockUsers[4],
            content: "Anyone heading to the Tokyo denim swap next month? Looking to connect with fellow collectors.",
            images: [],
            likes: 78,
            comments: 34,
            timestamp: Date().addingTimeInterval(-43200),
            isLiked: false,
            isSketchbook: false
        )
    ]
    
    static let mockEvents = [
        CommunityEvent(
            id: UUID(),
            title: "Brooklyn Denim Swap Meet",
            image: "event1",
            date: Date().addingTimeInterval(86400 * 7),
            location: "Williamsburg, NY",
            attendeeCount: 234,
            isRSVPd: false,
            eventType: .swapMeet
        ),
        CommunityEvent(
            id: UUID(),
            title: "Raw Denim Market",
            image: "event2",
            date: Date().addingTimeInterval(86400 * 14),
            location: "Shibuya, Tokyo",
            attendeeCount: 567,
            isRSVPd: true,
            eventType: .market
        ),
        CommunityEvent(
            id: UUID(),
            title: "Repair Workshop: Sashiko Basics",
            image: "event3",
            date: Date().addingTimeInterval(86400 * 3),
            location: "Online",
            attendeeCount: 89,
            isRSVPd: false,
            eventType: .workshop
        ),
        CommunityEvent(
            id: UUID(),
            title: "Vintage Hunting Meetup",
            image: "event4",
            date: Date().addingTimeInterval(86400 * 21),
            location: "East London",
            attendeeCount: 45,
            isRSVPd: false,
            eventType: .meetup
        )
    ]
}
