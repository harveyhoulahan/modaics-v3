import Foundation

// MARK: - Story
/// The heart of Modaics - every garment has a story worth telling
/// Stories capture the emotional and historical value of clothing
public struct Story: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    
    /// The narrative description - why this piece matters
    public var narrative: String
    
    /// Where it came from - brand origin, vintage find, gift, etc.
    public var provenance: String
    
    /// Key moments and memories associated with this garment
    public var memories: [Memory]
    
    /// Why the owner is parting with it (if applicable)
    public var whySelling: String?
    
    /// Care instructions and special notes
    public var careNotes: String?
    
    /// Previous owners' stories (for vintage/resale items)
    public var previousStories: [Story]
    
    /// When the story was created
    public var createdAt: Date
    
    /// Last time the story was updated
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        narrative: String,
        provenance: String,
        memories: [Memory] = [],
        whySelling: String? = nil,
        careNotes: String? = nil,
        previousStories: [Story] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.narrative = narrative
        self.provenance = provenance
        self.memories = memories
        self.whySelling = whySelling
        self.careNotes = careNotes
        self.previousStories = previousStories
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Memory
/// A specific memory tied to a garment
public struct Memory: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    
    /// The memory description
    public var description: String
    
    /// When the memory occurred
    public var date: Date?
    
    /// Location where the memory was made
    public var location: String?
    
    /// Associated image URLs
    public var imageURLs: [URL]
    
    /// Mood/feeling associated with this memory
    public var mood: Mood?
    
    public init(
        id: UUID = UUID(),
        description: String,
        date: Date? = nil,
        location: String? = nil,
        imageURLs: [URL] = [],
        mood: Mood? = nil
    ) {
        self.id = id
        self.description = description
        self.date = date
        self.location = location
        self.imageURLs = imageURLs
        self.mood = mood
    }
}

// MARK: - Mood
/// Emotional tone for memories and stories
public enum Mood: String, Codable, CaseIterable, Hashable, Sendable {
    case joyful = "Joyful"
    case nostalgic = "Nostalgic"
    case confident = "Confident"
    case romantic = "Romantic"
    case adventurous = "Adventurous"
    case peaceful = "Peaceful"
    case empowered = "Empowered"
    case melancholic = "Melancholic"
    case celebratory = "Celebratory"
    case bittersweet = "Bittersweet"
}

// MARK: - Sample Data
public extension Story {
    static let sample = Story(
        id: UUID(),
        narrative: "I found this vintage leather jacket in a tiny shop in Tokyo's Shimokitazawa district. The owner told me it had been worn by a local jazz musician for over 20 years.",
        provenance: "Flamingo, Shimokitazawa, Tokyo",
        memories: [
            Memory(
                description: "Wore it to my first gallery opening in Berlin",
                date: Date(),
                location: "Berlin, Germany",
                mood: .confident
            ),
            Memory(
                description: "Danced until 4am in this at a warehouse party",
                date: Date(),
                mood: .joyful
            )
        ],
        whySelling: "Moving to a warmer climate and it deserves more wear than I'll give it",
        careNotes: "Treat with leather conditioner every 6 months. Store on padded hanger.",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let sampleMinimal = Story(
        narrative: "A classic piece with timeless appeal",
        provenance: "Purchased new from retailer"
    )
}
