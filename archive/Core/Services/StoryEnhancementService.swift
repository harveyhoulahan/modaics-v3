import Foundation

// MARK: - StoryEnhancementServiceProtocol
/// Service for enhancing garment stories using AI
/// Helps users tell more compelling narratives about their clothing
public protocol StoryEnhancementServiceProtocol: Sendable {
    
    /// Enhance a narrative with AI suggestions
    func enhanceNarrative(_ narrative: String, context: Garment) async throws -> String
    
    /// Analyze a story and provide insights
    func analyzeStory(_ story: Story) async throws -> StoryAnalysis
    
    /// Suggest improvements for a story
    func suggestImprovements(for story: Story) async throws -> [String]
    
    /// Generate a story from photos
    func analyzePhotos(_ photoURLs: [URL]) async throws -> PhotoAnalysis
    
    /// Translate a story to another language
    func translateStory(_ story: Story, to language: String) async throws -> StoryTranslation
    
    /// Generate title suggestions from a story
    func suggestTitles(from story: Story) async throws -> [String]
    
    /// Detect mood/tone of a story
    func detectMood(from narrative: String) async throws -> Mood?
    
    /// Extract keywords from a story
    func extractKeywords(from story: Story) async throws -> [String]
    
    /// Validate a story for quality
    func validateStory(_ story: Story) async throws -> StoryValidation
    
    /// Generate care instructions based on materials and story
    func generateCareNotes(garment: Garment) async throws -> String
    
    /// Complete a partial story with AI
    func completeStory(partial: String, context: Garment) async throws -> String
}

// MARK: - Supporting Types

public struct StoryAnalysis: Sendable {
    public let emotionalTone: String
    public let qualityScore: Double // 0-100
    public let completenessScore: Double // 0-100
    public let engagementPrediction: Double // 0-100
    public let keyHighlights: [String]
    public let detectedMood: Mood?
    public let styleKeywords: [String]
    public let narrativeArc: NarrativeArc
    public let suggestedTags: [String]
    public let readabilityScore: Double // Flesch reading ease
    
    public init(
        emotionalTone: String,
        qualityScore: Double,
        completenessScore: Double,
        engagementPrediction: Double,
        keyHighlights: [String] = [],
        detectedMood: Mood? = nil,
        styleKeywords: [String] = [],
        narrativeArc: NarrativeArc = .descriptive,
        suggestedTags: [String] = [],
        readabilityScore: Double = 0
    ) {
        self.emotionalTone = emotionalTone
        self.qualityScore = qualityScore
        self.completenessScore = completenessScore
        self.engagementPrediction = engagementPrediction
        self.keyHighlights = keyHighlights
        self.detectedMood = detectedMood
        self.styleKeywords = styleKeywords
        self.narrativeArc = narrativeArc
        self.suggestedTags = suggestedTags
        self.readabilityScore = readabilityScore
    }
}

public enum NarrativeArc: String, Codable, Hashable, Sendable {
    case origin = "origin"
    case journey = "journey"
    case transformation = "transformation"
    case relationship = "relationship"
    case discovery = "discovery"
    case legacy = "legacy"
    case descriptive = "descriptive"
    case hybrid = "hybrid"
}

public struct PhotoAnalysis: Sendable {
    public let suggestedNarrative: String?
    public let detectedProvenance: String?
    public let detectedMemories: [String]
    public let detectedEra: Era?
    public let detectedCondition: Condition?
    public let suggestedTitle: String?
    public let styleKeywords: [String]
    public let colorPalette: [String]
    public let detectedMaterials: [String]
    public let confidence: Double
    
    public init(
        suggestedNarrative: String? = nil,
        detectedProvenance: String? = nil,
        detectedMemories: [String] = [],
        detectedEra: Era? = nil,
        detectedCondition: Condition? = nil,
        suggestedTitle: String? = nil,
        styleKeywords: [String] = [],
        colorPalette: [String] = [],
        detectedMaterials: [String] = [],
        confidence: Double = 0
    ) {
        self.suggestedNarrative = suggestedNarrative
        self.detectedProvenance = detectedProvenance
        self.detectedMemories = detectedMemories
        self.detectedEra = detectedEra
        self.detectedCondition = detectedCondition
        self.suggestedTitle = suggestedTitle
        self.styleKeywords = styleKeywords
        self.colorPalette = colorPalette
        self.detectedMaterials = detectedMaterials
        self.confidence = confidence
    }
}

public struct StoryTranslation: Sendable {
    public let originalLanguage: String
    public let targetLanguage: String
    public let translatedNarrative: String
    public let translatedProvenance: String?
    public let translatedMemories: [String]
    public let qualityScore: Double
    
    public init(
        originalLanguage: String,
        targetLanguage: String,
        translatedNarrative: String,
        translatedProvenance: String? = nil,
        translatedMemories: [String] = [],
        qualityScore: Double = 0
    ) {
        self.originalLanguage = originalLanguage
        self.targetLanguage = targetLanguage
        self.translatedNarrative = translatedNarrative
        self.translatedProvenance = translatedProvenance
        self.translatedMemories = translatedMemories
        self.qualityScore = qualityScore
    }
}

public struct StoryValidation: Sendable {
    public let isValid: Bool
    public let score: Double
    public let issues: [ValidationIssue]
    public let suggestions: [String]
    
    public init(
        isValid: Bool,
        score: Double,
        issues: [ValidationIssue] = [],
        suggestions: [String] = []
    ) {
        self.isValid = isValid
        self.score = score
        self.issues = issues
        self.suggestions = suggestions
    }
}

public struct ValidationIssue: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let type: IssueType
    public let message: String
    public let severity: Severity
    
    public init(
        id: UUID = UUID(),
        type: IssueType,
        message: String,
        severity: Severity
    ) {
        self.id = id
        self.type = type
        self.message = message
        self.severity = severity
    }
}

public enum IssueType: String, Codable, Hashable, Sendable {
    case tooShort = "too_short"
    case tooLong = "too_long"
    case missingProvenance = "missing_provenance"
    case missingMemories = "missing_memories"
    case grammarErrors = "grammar_errors"
    case inappropriateContent = "inappropriate_content"
    case unclearDescription = "unclear_description"
    case spam = "spam"
}

public enum Severity: String, Codable, Hashable, Sendable {
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
}

// MARK: - Mock Implementation

public final class MockStoryEnhancementService: StoryEnhancementServiceProtocol {
    
    public init() {}
    
    public func enhanceNarrative(_ narrative: String, context: Garment) async throws -> String {
        // Simulate AI enhancement by adding descriptive flourishes
        let enhancements = [
            "This beautiful piece",
            "crafted with exceptional attention to detail",
            "tells a story of timeless elegance",
            "Each wear brings new meaning",
            "The quality speaks for itself"
        ]
        
        return "\(narrative)\n\n\(enhancements.randomElement() ?? "")"
    }
    
    public func analyzeStory(_ story: Story) async throws -> StoryAnalysis {
        return StoryAnalysis(
            emotionalTone: "Warm and nostalgic",
            qualityScore: 85.0,
            completenessScore: 78.0,
            engagementPrediction: 82.0,
            keyHighlights: [
                "Personal connection to Tokyo",
                "Musician history adds intrigue",
                "Emotional attachment evident"
            ],
            detectedMood: .nostalgic,
            styleKeywords: ["Vintage", "Leather", "Classic", "Edgy"],
            narrativeArc: .origin,
            suggestedTags: ["vintage", "tokyo", "jazz", "travel"],
            readabilityScore: 72.0
        )
    }
    
    public func suggestImprovements(for story: Story) async throws -> [String] {
        var suggestions: [String] = []
        
        if story.narrative.count < 100 {
            suggestions.append("Consider adding more details about how the piece makes you feel")
        }
        
        if story.memories.isEmpty {
            suggestions.append("Adding a specific memory would make this story more engaging")
        }
        
        if story.whySelling == nil {
            suggestions.append("Explaining why you're parting with this item helps buyers connect")
        }
        
        if story.provenance.isEmpty {
            suggestions.append("Share where this piece came from - it adds authenticity")
        }
        
        if suggestions.isEmpty {
            suggestions = [
                "Your story is well-crafted! Consider adding more sensory details",
                "Perhaps mention any special care the item has received"
            ]
        }
        
        return suggestions
    }
    
    public func analyzePhotos(_ photoURLs: [URL]) async throws -> PhotoAnalysis {
        return PhotoAnalysis(
            suggestedNarrative: "A beautifully worn leather jacket with rich patina that tells of countless adventures.",
            detectedProvenance: "Appears to be vintage American-made",
            detectedMemories: [
                "Shows signs of being well-loved and traveled",
                "Hardware suggests it was worn regularly"
            ],
            detectedEra: .nineties,
            detectedCondition: .vintage,
            suggestedTitle: "Vintage Leather Biker Jacket",
            styleKeywords: ["Vintage", "Biker", "Leather", "Classic"],
            colorPalette: ["Black", "Brown", "Bronze"],
            detectedMaterials: ["Leather", "Metal hardware"],
            confidence: 0.87
        )
    }
    
    public func translateStory(_ story: Story, to language: String) async throws -> StoryTranslation {
        let translations: [String: String] = [
            "es": "Encontré esta chaqueta de cuero vintage en una pequeña tienda en Shimokitazawa, Tokio...",
            "fr": "J'ai trouvé ce blouson en cuir vintage dans une petite boutique à Shimokitazawa, Tokyo...",
            "de": "Ich habe diese Vintage-Lederjacke in einem kleinen Laden in Tokios Shimokitazawa-Viertel gefunden...",
            "ja": "東京の下北沢の小さな店でこのヴィンテージレザージャケットを見つけました..."
        ]
        
        let translated = translations[language] ?? story.narrative
        
        return StoryTranslation(
            originalLanguage: "en",
            targetLanguage: language,
            translatedNarrative: translated,
            translatedProvenance: story.provenance,
            qualityScore: 0.92
        )
    }
    
    public func suggestTitles(from story: Story) async throws -> [String] {
        return [
            "Vintage Leather with Jazz History",
            "Tokyo Find: Musician's Leather Jacket",
            "Well-Loved Leather from Shimokitazawa",
            "A Jacket with Soul: Tokyo Jazz Scene",
            "Vintage Biker Jacket with Stories"
        ]
    }
    
    public func detectMood(from narrative: String) async throws -> Mood? {
        let moodKeywords: [(Mood, [String])] = [
            (.nostalgic, ["remember", "memories", "past", "nostalgia", "fond"]),
            (.joyful, ["happy", "joy", "love", "amazing", "wonderful"]),
            (.confident, ["powerful", "strong", "confident", "bold"]),
            (.romantic, ["romance", "date", "evening", "elegant"]),
            (.adventurous, ["adventure", "travel", "explore", "journey"])
        ]
        
        let lowercased = narrative.lowercased()
        for (mood, keywords) in moodKeywords {
            if keywords.contains(where: { lowercased.contains($0) }) {
                return mood
            }
        }
        return nil
    }
    
    public func extractKeywords(from story: Story) async throws -> [String] {
        return [
            "vintage",
            "leather",
            "tokyo",
            "jazz",
            "musician",
            "travel",
            "shimokitazawa",
            "japan",
            "authentic",
            "patina"
        ]
    }
    
    public func validateStory(_ story: Story) async throws -> StoryValidation {
        var issues: [ValidationIssue] = []
        
        if story.narrative.count < 50 {
            issues.append(ValidationIssue(
                type: .tooShort,
                message: "Story is quite short. Consider adding more details.",
                severity: .warning
            ))
        }
        
        if story.narrative.count > 2000 {
            issues.append(ValidationIssue(
                type: .tooLong,
                message: "Story is quite long. Consider making it more concise.",
                severity: .info
            ))
        }
        
        if story.provenance.isEmpty {
            issues.append(ValidationIssue(
                type: .missingProvenance,
                message: "Consider adding where the item came from.",
                severity: .info
            ))
        }
        
        let isValid = !issues.contains { $0.severity == .error || $0.severity == .critical }
        let score = max(0, 100 - Double(issues.count * 10))
        
        return StoryValidation(
            isValid: isValid,
            score: score,
            issues: issues,
            suggestions: [
                "Add sensory details (how it feels, smells)",
                "Include why this piece is special to you"
            ]
        )
    }
    
    public func generateCareNotes(garment: Garment) async throws -> String {
        var notes: [String] = []
        
        for material in garment.materials {
            switch material.name.lowercased() {
            case "leather":
                notes.append("Condition leather every 6 months with quality leather conditioner")
                notes.append("Store on padded hanger away from direct sunlight")
                notes.append("Avoid water exposure; use leather protector spray")
            case "silk":
                notes.append("Dry clean only recommended")
                notes.append("Store in breathable garment bag")
                notes.append("Avoid direct sunlight to prevent fading")
            case "wool":
                notes.append("Hand wash cold or dry clean")
                notes.append("Lay flat to dry")
                notes.append("Use cedar blocks to prevent moths")
            case "cotton":
                notes.append("Machine wash cold, gentle cycle")
                notes.append("Tumble dry low or hang dry")
            default:
                notes.append("Follow care label instructions")
            }
        }
        
        return notes.joined(separator: "\n")
    }
    
    public func completeStory(partial: String, context: Garment) async throws -> String {
        let completions = [
            "\(partial)... and every time I wear it, I feel connected to those magical moments.",
            "\(partial)... It has become more than just clothing - it's a piece of my history.",
            "\(partial)... I hope it brings you as much joy as it brought me.",
            "\(partial)... The memories woven into this fabric are irreplaceable."
        ]
        
        return completions.randomElement() ?? partial
    }
}