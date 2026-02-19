import Foundation

// MARK: - ModaicsStory
/// The heart of Modaics - every garment has a story worth telling
/// Stories capture the emotional and historical value of clothing
public struct ModaicsStory: Identifiable, Codable, Hashable {
    public let id: UUID
    
    public var narrative: String
    public var provenance: String
    public var memories: [ModaicsMemory]
    public var whySelling: String?
    public var careNotes: String?
    public var previousStoryIds: [UUID]
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        narrative: String,
        provenance: String,
        memories: [ModaicsMemory] = [],
        whySelling: String? = nil,
        careNotes: String? = nil,
        previousStoryIds: [UUID] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.narrative = narrative
        self.provenance = provenance
        self.memories = memories
        self.whySelling = whySelling
        self.careNotes = careNotes
        self.previousStoryIds = previousStoryIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Memory

public struct ModaicsMemory: Identifiable, Codable, Hashable {
    public let id: UUID
    
    public var description: String
    public var date: Date?
    public var location: String?
    public var imageURLs: [URL]
    public var mood: ModaicsMood?
    
    public init(
        id: UUID = UUID(),
        description: String,
        date: Date? = nil,
        location: String? = nil,
        imageURLs: [URL] = [],
        mood: ModaicsMood? = nil
    ) {
        self.id = id
        self.description = description
        self.date = date
        self.location = location
        self.imageURLs = imageURLs
        self.mood = mood
    }
}

public enum ModaicsMood: String, Codable, CaseIterable, Hashable {
    case joyful = "joyful"
    case nostalgic = "nostalgic"
    case confident = "confident"
    case romantic = "romantic"
    case adventurous = "adventurous"
    case peaceful = "peaceful"
    case empowered = "empowered"
    case melancholic = "melancholic"
    case celebratory = "celebratory"
    case bittersweet = "bittersweet"
}
