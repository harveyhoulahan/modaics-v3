import Foundation
import CoreLocation
import SwiftUI

// MARK: - CommunityEventType
/// Event types supported in the app
public enum CommunityEventType: String, CaseIterable, Codable, Identifiable {
    case market = "MARKET"
    case exhibition = "EXHIBITION"
    case talk = "TALK"
    case party = "PARTY"
    case swapMeet = "SWAP_MEET"
    case workshop = "WORKSHOP"
    case classSession = "CLASS"
    case popUp = "POP_UP"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .market: return "Market"
        case .exhibition: return "Exhibition"
        case .talk: return "Talk"
        case .party: return "Party"
        case .swapMeet: return "Swap Meet"
        case .workshop: return "Workshop"
        case .classSession: return "Class"
        case .popUp: return "Pop-up"
        }
    }
    
    public var icon: String {
        switch self {
        case .market: return "storefront"
        case .exhibition: return "photo.artframe"
        case .talk: return "bubble.left.fill"
        case .party: return "sparkles"
        case .swapMeet: return "arrow.2.squarepath"
        case .workshop: return "hammer"
        case .classSession: return "person.2"
        case .popUp: return "star.fill"
        }
    }
    
    public var swiftColor: SwiftUI.Color {
        switch self {
        case .market: return .orange
        case .exhibition: return .purple
        case .talk: return .blue
        case .party: return .pink
        case .swapMeet: return .green
        case .workshop: return .teal
        case .classSession: return .indigo
        case .popUp: return .yellow
        }
    }
}

// MARK: - CommunityEvent
/// Model representing a community event with location coordinates
public struct CommunityEvent: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let type: CommunityEventType
    public let venueName: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
    public let startDate: Date
    public let endDate: Date
    public let imageURL: String?
    public let organizerId: String
    public let organizerName: String
    public let isFree: Bool
    public let price: Double?
    public let capacity: Int?
    public let attendees: Int
    public let tags: [String]
    public let createdAt: Date
    
    /// Computed property for CLLocationCoordinate2D
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
    
    public var formattedPrice: String {
        if isFree { return "Free" }
        guard let price = price else { return "Price TBA" }
        return String(format: "$%.2f", price)
    }
    
    public var isUpcoming: Bool {
        startDate > Date()
    }
    
    public var isOngoing: Bool {
        let now = Date()
        return startDate <= now && endDate >= now
    }
    
    public var daysUntil: Int? {
        guard isUpcoming else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: startDate)
        return components.day
    }
    
    public var timeUntil: String {
        if let days = daysUntil {
            if days == 0 { return "Today" }
            if days == 1 { return "Tomorrow" }
            return "In \(days) days"
        }
        return "Ended"
    }
    
    public var maxAttendees: Int {
        capacity ?? 100
    }
    
    public var isAlmostFull: Bool {
        Double(attendees) / Double(maxAttendees) > 0.8
    }
    
    public init(
        id: String,
        title: String,
        description: String,
        type: CommunityEventType,
        venueName: String,
        address: String,
        latitude: Double,
        longitude: Double,
        startDate: Date,
        endDate: Date,
        imageURL: String? = nil,
        organizerId: String,
        organizerName: String,
        isFree: Bool = true,
        price: Double? = nil,
        capacity: Int? = nil,
        attendees: Int = 0,
        tags: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.venueName = venueName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.startDate = startDate
        self.endDate = endDate
        self.imageURL = imageURL
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.isFree = isFree
        self.price = price
        self.capacity = capacity
        self.attendees = attendees
        self.tags = tags
        self.createdAt = createdAt
    }
}

// MARK: - Mock Data
extension CommunityEvent {
    /// Mock events with Melbourne coordinates
    public static let mockEvents: [CommunityEvent] = [
        // Fitzroy Community Hall
        CommunityEvent(
            id: "evt-001",
            title: "Vintage Market Day",
            description: "Discover curated vintage fashion from local sellers. Sustainable shopping at its finest.",
            type: .market,
            venueName: "Fitzroy Community Hall",
            address: "123 Brunswick St, Fitzroy VIC 3065",
            latitude: -37.7990,
            longitude: 144.9780,
            startDate: Date().addingTimeInterval(86400 * 3),
            endDate: Date().addingTimeInterval(86400 * 3 + 28800),
            imageURL: "https://example.com/market1.jpg",
            organizerId: "org-001",
            organizerName: "Fitzroy Vintage Collective",
            isFree: false,
            price: 5.00,
            capacity: 200,
            attendees: 145,
            tags: ["vintage", "market", "sustainable"]
        ),
        
        // Prahran Town Hall
        CommunityEvent(
            id: "evt-002",
            title: "Sustainable Fashion Talk",
            description: "Join industry experts discussing the future of sustainable fashion in Australia.",
            type: .talk,
            venueName: "Prahran Town Hall",
            address: "255 Chapel St, Prahran VIC 3181",
            latitude: -37.8510,
            longitude: 144.9920,
            startDate: Date().addingTimeInterval(86400 * 7),
            endDate: Date().addingTimeInterval(86400 * 7 + 7200),
            imageURL: "https://example.com/talk1.jpg",
            organizerId: "org-002",
            organizerName: "Melbourne Fashion Forum",
            isFree: true,
            capacity: 150,
            attendees: 89,
            tags: ["talk", "sustainable", "fashion"]
        ),
        
        // Northcote Social Club
        CommunityEvent(
            id: "evt-003",
            title: "Swap Meet Social",
            description: "Bring your pre-loved clothes and swap with the community. Drinks and music included!",
            type: .swapMeet,
            venueName: "Northcote Social Club",
            address: "301 High St, Northcote VIC 3070",
            latitude: -37.7690,
            longitude: 144.9990,
            startDate: Date().addingTimeInterval(86400 * 5),
            endDate: Date().addingTimeInterval(86400 * 5 + 14400),
            imageURL: "https://example.com/swap1.jpg",
            organizerId: "org-003",
            organizerName: "Northcote Fashion Exchange",
            isFree: false,
            price: 10.00,
            capacity: 100,
            attendees: 67,
            tags: ["swap", "social", "community"]
        ),
        
        // Brunswick Made
        CommunityEvent(
            id: "evt-004",
            title: "Upcycling Workshop",
            description: "Learn to transform old garments into new favorites. Materials provided.",
            type: .workshop,
            venueName: "Brunswick Made",
            address: "456 Sydney Rd, Brunswick VIC 3056",
            latitude: -37.7650,
            longitude: 144.9600,
            startDate: Date().addingTimeInterval(86400 * 10),
            endDate: Date().addingTimeInterval(86400 * 10 + 10800),
            imageURL: "https://example.com/workshop1.jpg",
            organizerId: "org-004",
            organizerName: "Brunswick Makers Guild",
            isFree: false,
            price: 45.00,
            capacity: 20,
            attendees: 18,
            tags: ["workshop", "upcycling", "hands-on"]
        ),
        
        // Collingwood Yards
        CommunityEvent(
            id: "evt-005",
            title: "Indie Designer Pop-up",
            description: "Exclusive collection launch from 10 emerging Melbourne designers.",
            type: .popUp,
            venueName: "Collingwood Yards",
            address: "35 Johnston St, Collingwood VIC 3066",
            latitude: -37.8040,
            longitude: 144.9840,
            startDate: Date().addingTimeInterval(86400 * 2),
            endDate: Date().addingTimeInterval(86400 * 4),
            imageURL: "https://example.com/popup1.jpg",
            organizerId: "org-005",
            organizerName: "Melbourne Design Collective",
            isFree: true,
            capacity: 300,
            attendees: 0,
            tags: ["pop-up", "designer", "exclusive"]
        ),
        
        // Abbotsford Convent
        CommunityEvent(
            id: "evt-006",
            title: "Textile Art Exhibition",
            description: "Exploring sustainability through textile art. Featuring 15 local artists.",
            type: .exhibition,
            venueName: "Abbotsford Convent",
            address: "1 St Heliers St, Abbotsford VIC 3067",
            latitude: -37.8020,
            longitude: 145.0060,
            startDate: Date().addingTimeInterval(-86400),
            endDate: Date().addingTimeInterval(86400 * 14),
            imageURL: "https://example.com/exhibition1.jpg",
            organizerId: "org-006",
            organizerName: "Convent Arts",
            isFree: false,
            price: 15.00,
            capacity: 500,
            attendees: 234,
            tags: ["exhibition", "art", "textiles"]
        ),
        
        // Queen Victoria Market
        CommunityEvent(
            id: "evt-007",
            title: "Sustainable Fashion Night Market",
            description: "Evening market featuring eco-friendly brands and vintage collectors.",
            type: .market,
            venueName: "Queen Victoria Market",
            address: "Queen St, Melbourne VIC 3000",
            latitude: -37.8070,
            longitude: 144.9570,
            startDate: Date().addingTimeInterval(86400 * 4),
            endDate: Date().addingTimeInterval(86400 * 4 + 18000),
            imageURL: "https://example.com/market2.jpg",
            organizerId: "org-007",
            organizerName: "QVM Events",
            isFree: true,
            capacity: 1000,
            attendees: 0,
            tags: ["market", "night", "sustainable"]
        ),
        
        // The Social Studio
        CommunityEvent(
            id: "evt-008",
            title: "Sewing Class for Beginners",
            description: "Learn basic sewing techniques and garment repair. Machines provided.",
            type: .classSession,
            venueName: "The Social Studio",
            address: "128-136 Smith St, Collingwood VIC 3066",
            latitude: -37.8060,
            longitude: 144.9830,
            startDate: Date().addingTimeInterval(86400 * 6),
            endDate: Date().addingTimeInterval(86400 * 6 + 7200),
            imageURL: "https://example.com/class1.jpg",
            organizerId: "org-008",
            organizerName: "The Social Studio",
            isFree: false,
            price: 35.00,
            capacity: 12,
            attendees: 8,
            tags: ["class", "sewing", "beginner"]
        ),
        
        // Colour Club
        CommunityEvent(
            id: "evt-009",
            title: "End of Season Party",
            description: "Celebrate sustainable fashion with drinks, DJ, and pop-up stalls.",
            type: .party,
            venueName: "Colour Club",
            address: "229 High St, Northcote VIC 3070",
            latitude: -37.7720,
            longitude: 144.9980,
            startDate: Date().addingTimeInterval(86400 * 14),
            endDate: Date().addingTimeInterval(86400 * 14 + 21600),
            imageURL: "https://example.com/party1.jpg",
            organizerId: "org-009",
            organizerName: "Colour Club",
            isFree: false,
            price: 25.00,
            capacity: 200,
            attendees: 156,
            tags: ["party", "social", "drinks"]
        ),
        
        // CERES Environment Park
        CommunityEvent(
            id: "evt-010",
            title: "Natural Dye Workshop",
            description: "Learn to dye fabrics using native Australian plants and flowers.",
            type: .workshop,
            venueName: "CERES Environment Park",
            address: "Stewart St, Brunswick East VIC 3057",
            latitude: -37.7660,
            longitude: 144.9700,
            startDate: Date().addingTimeInterval(86400 * 8),
            endDate: Date().addingTimeInterval(86400 * 8 + 14400),
            imageURL: "https://example.com/workshop2.jpg",
            organizerId: "org-010",
            organizerName: "CERES",
            isFree: false,
            price: 55.00,
            capacity: 15,
            attendees: 12,
            tags: ["workshop", "natural-dye", "eco"]
        ),
        
        // Melbourne Museum
        CommunityEvent(
            id: "evt-011",
            title: "Fashion Through the Ages",
            description: "Historical fashion exhibition showcasing sustainability in vintage clothing.",
            type: .exhibition,
            venueName: "Melbourne Museum",
            address: "11 Nicholson St, Carlton VIC 3053",
            latitude: -37.8030,
            longitude: 144.9720,
            startDate: Date().addingTimeInterval(-86400 * 7),
            endDate: Date().addingTimeInterval(86400 * 30),
            imageURL: "https://example.com/exhibition2.jpg",
            organizerId: "org-011",
            organizerName: "Melbourne Museum",
            isFree: false,
            price: 25.00,
            capacity: 2000,
            attendees: 892,
            tags: ["exhibition", "history", "vintage"]
        ),
        
        // Thornbury Theatre
        CommunityEvent(
            id: "evt-012",
            title: "Circular Fashion Panel",
            description: "Industry leaders discuss circular economy in fashion.",
            type: .talk,
            venueName: "Thornbury Theatre",
            address: "859 High St, Thornbury VIC 3071",
            latitude: -37.7550,
            longitude: 145.0000,
            startDate: Date().addingTimeInterval(86400 * 9),
            endDate: Date().addingTimeInterval(86400 * 9 + 9000),
            imageURL: "https://example.com/talk2.jpg",
            organizerId: "org-012",
            organizerName: "Circular Melbourne",
            isFree: false,
            price: 20.00,
            capacity: 300,
            attendees: 178,
            tags: ["talk", "circular", "industry"]
        ),
        
        // Rose Street Artists' Market
        CommunityEvent(
            id: "evt-013",
            title: "Handmade Fashion Market",
            description: "Independent designers selling handmade and small-batch fashion items.",
            type: .market,
            venueName: "Rose Street Artists' Market",
            address: "60 Rose St, Fitzroy VIC 3065",
            latitude: -37.7980,
            longitude: 144.9790,
            startDate: Date().addingTimeInterval(86400),
            endDate: Date().addingTimeInterval(86400 + 25200),
            imageURL: "https://example.com/market3.jpg",
            organizerId: "org-013",
            organizerName: "Rose Street Market",
            isFree: true,
            capacity: 150,
            attendees: 0,
            tags: ["market", "handmade", "local"]
        ),
        
        // Kuwaii Studio
        CommunityEvent(
            id: "evt-014",
            title: "Pattern Making Class",
            description: "Learn to draft your own sewing patterns. Intermediate level.",
            type: .classSession,
            venueName: "Kuwaii Studio",
            address: "118 High St, Northcote VIC 3070",
            latitude: -37.7700,
            longitude: 144.9970,
            startDate: Date().addingTimeInterval(86400 * 12),
            endDate: Date().addingTimeInterval(86400 * 12 + 10800),
            imageURL: "https://example.com/class2.jpg",
            organizerId: "org-014",
            organizerName: "Kuwaii",
            isFree: false,
            price: 85.00,
            capacity: 8,
            attendees: 6,
            tags: ["class", "pattern-making", "intermediate"]
        ),
        
        // School of Life Melbourne
        CommunityEvent(
            id: "evt-015",
            title: "Style & Identity Workshop",
            description: "Explore personal style and build a conscious wardrobe.",
            type: .workshop,
            venueName: "School of Life Melbourne",
            address: "669 Bourke St, Melbourne VIC 3000",
            latitude: -37.8170,
            longitude: 144.9550,
            startDate: Date().addingTimeInterval(86400 * 11),
            endDate: Date().addingTimeInterval(86400 * 11 + 7200),
            imageURL: "https://example.com/workshop3.jpg",
            organizerId: "org-015",
            organizerName: "The School of Life",
            isFree: false,
            price: 65.00,
            capacity: 25,
            attendees: 19,
            tags: ["workshop", "style", "personal-development"]
        ),
        
        // Flinders Lane Gallery
        CommunityEvent(
            id: "evt-016",
            title: "Wearable Art Exhibition",
            description: "Contemporary artists explore fashion as artistic expression.",
            type: .exhibition,
            venueName: "Flinders Lane Gallery",
            address: "137 Flinders Ln, Melbourne VIC 3000",
            latitude: -37.8150,
            longitude: 144.9700,
            startDate: Date().addingTimeInterval(86400 * 3),
            endDate: Date().addingTimeInterval(86400 * 17),
            imageURL: "https://example.com/exhibition3.jpg",
            organizerId: "org-016",
            organizerName: "Flinders Lane Gallery",
            isFree: true,
            capacity: 100,
            attendees: 0,
            tags: ["exhibition", "wearable-art", "contemporary"]
        )
    ]
}
