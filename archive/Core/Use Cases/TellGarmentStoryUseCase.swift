import Foundation

// MARK: - TellGarmentStoryUseCase
/// Use case for creating, enriching, and sharing garment stories
/// Makes the narrative a first-class citizen of the garment
public protocol TellGarmentStoryUseCaseProtocol: Sendable {
    func execute(input: TellStoryInput) async throws -> TellStoryOutput
}

// MARK: - Input/Output Types

public struct TellStoryInput: Sendable {
    public let action: StoryAction
    public let garmentId: UUID
    public let userId: UUID
    
    public init(action: StoryAction, garmentId: UUID, userId: UUID) {
        self.action = action
        self.garmentId = garmentId
        self.userId = userId
    }
}

public enum StoryAction: Sendable {
    case create(CreateStoryInput)
    case update(Story)
    case addMemory(Memory)
    case enhanceWithAI
    case generateFromPhotos([URL])
    case addWhySelling(reason: String)
    case addCareNotes(notes: String)
    case enhanceNarrative
    case translate(to: String)
    case getSuggestions
}

public struct CreateStoryInput: Sendable {
    public var narrative: String
    public var provenance: String
    public var memories: [Memory]
    public var whySelling: String?
    public var careNotes: String?
    
    public init(
        narrative: String,
        provenance: String = "",
        memories: [Memory] = [],
        whySelling: String? = nil,
        careNotes: String? = nil
    ) {
        self.narrative = narrative
        self.provenance = provenance
        self.memories = memories
        self.whySelling = whySelling
        self.careNotes = careNotes
    }
}

public struct TellStoryOutput: Sendable {
    public let story: Story
    public let enhancementSuggestions: [String]?
    public let generatedContent: GeneratedContent?
    public let aiInsights: AIStoryInsights?
    
    public init(
        story: Story,
        enhancementSuggestions: [String]? = nil,
        generatedContent: GeneratedContent? = nil,
        aiInsights: AIStoryInsights? = nil
    ) {
        self.story = story
        self.enhancementSuggestions = enhancementSuggestions
        self.generatedContent = generatedContent
        self.aiInsights = aiInsights
    }
}

public struct GeneratedContent: Sendable {
    public let enhancedNarrative: String?
    public let suggestedTitle: String?
    public let keyHighlights: [String]
    public let moodAnalysis: Mood?
    public let styleKeywords: [String]
    
    public init(
        enhancedNarrative: String? = nil,
        suggestedTitle: String? = nil,
        keyHighlights: [String] = [],
        moodAnalysis: Mood? = nil,
        styleKeywords: [String] = []
    ) {
        self.enhancedNarrative = enhancedNarrative
        self.suggestedTitle = suggestedTitle
        self.keyHighlights = keyHighlights
        self.moodAnalysis = moodAnalysis
        self.styleKeywords = styleKeywords
    }
}

public struct AIStoryInsights: Sendable {
    public let emotionalTone: String
    public let narrativeQuality: Double // 0-100
    public let completeness: Double // 0-100
    public let engagementPrediction: Double // 0-100
    public let suggestedImprovements: [String]
    
    public init(
        emotionalTone: String,
        narrativeQuality: Double,
        completeness: Double,
        engagementPrediction: Double,
        suggestedImprovements: [String]
    ) {
        self.emotionalTone = emotionalTone
        self.narrativeQuality = narrativeQuality
        self.completeness = completeness
        self.engagementPrediction = engagementPrediction
        self.suggestedImprovements = suggestedImprovements
    }
}

// MARK: - Implementation

public final class TellGarmentStoryUseCase: TellGarmentStoryUseCaseProtocol {
    private let garmentRepository: GarmentRepositoryProtocol
    private let storyEnhancementService: StoryEnhancementServiceProtocol
    
    public init(
        garmentRepository: GarmentRepositoryProtocol,
        storyEnhancementService: StoryEnhancementServiceProtocol
    ) {
        self.garmentRepository = garmentRepository
        self.storyEnhancementService = storyEnhancementService
    }
    
    public func execute(input: TellStoryInput) async throws -> TellStoryOutput {
        // Verify user owns the garment
        let garment = try await garmentRepository.get(by: input.garmentId)
        guard garment.ownerId == input.userId else {
            throw StoryError.unauthorized
        }
        
        switch input.action {
        case .create(let createInput):
            return try await createStory(garment: garment, input: createInput)
            
        case .update(let story):
            return try await updateStory(garment: garment, story: story)
            
        case .addMemory(let memory):
            return try await addMemory(garment: garment, memory: memory)
            
        case .enhanceWithAI:
            return try await enhanceWithAI(garment: garment)
            
        case .generateFromPhotos(let photoURLs):
            return try await generateFromPhotos(garment: garment, photos: photoURLs)
            
        case .addWhySelling(let reason):
            return try await addWhySelling(garment: garment, reason: reason)
            
        case .addCareNotes(let notes):
            return try await addCareNotes(garment: garment, notes: notes)
            
        case .enhanceNarrative:
            return try await enhanceNarrative(garment: garment)
            
        case .translate(let language):
            return try await translateStory(garment: garment, to: language)
            
        case .getSuggestions:
            return try await getSuggestions(garment: garment)
        }
    }
    
    // MARK: - Private Methods
    
    private func createStory(garment: Garment, input: CreateStoryInput) async throws -> TellStoryOutput {
        let story = Story(
            narrative: input.narrative,
            provenance: input.provenance,
            memories: input.memories,
            whySelling: input.whySelling,
            careNotes: input.careNotes
        )
        
        var updatedGarment = garment
        updatedGarment.story = story
        _ = try await garmentRepository.update(updatedGarment)
        
        return TellStoryOutput(story: story)
    }
    
    private func updateStory(garment: Garment, story: Story) async throws -> TellStoryOutput {
        var updatedGarment = garment
        updatedGarment.story = story
        _ = try await garmentRepository.update(updatedGarment)
        
        return TellStoryOutput(story: story)
    }
    
    private func addMemory(garment: Garment, memory: Memory) async throws -> TellStoryOutput {
        var updatedStory = garment.story
        updatedStory.memories.append(memory)
        updatedStory.updatedAt = Date()
        
        var updatedGarment = garment
        updatedGarment.story = updatedStory
        _ = try await garmentRepository.update(updatedGarment)
        
        return TellStoryOutput(story: updatedStory)
    }
    
    private func enhanceWithAI(garment: Garment) async throws -> TellStoryOutput {
        let currentStory = garment.story
        
        // Use story enhancement service
        let enhancedNarrative = try await storyEnhancementService.enhanceNarrative(
            currentStory.narrative,
            context: garment
        )
        
        let suggestions = try await storyEnhancementService.suggestImprovements(for: currentStory)
        let insights = try await storyEnhancementService.analyzeStory(currentStory)
        
        let generatedContent = GeneratedContent(
            enhancedNarrative: enhancedNarrative,
            keyHighlights: insights.keyHighlights,
            moodAnalysis: insights.detectedMood,
            styleKeywords: insights.styleKeywords
        )
        
        let aiInsights = AIStoryInsights(
            emotionalTone: insights.emotionalTone,
            narrativeQuality: insights.qualityScore,
            completeness: insights.completenessScore,
            engagementPrediction: insights.engagementPrediction,
            suggestedImprovements: suggestions
        )
        
        return TellStoryOutput(
            story: currentStory,
            enhancementSuggestions: suggestions,
            generatedContent: generatedContent,
            aiInsights: aiInsights
        )
    }
    
    private func generateFromPhotos(garment: Garment, photos: [URL]) async throws -> TellStoryOutput {
        // Use AI to analyze photos and generate story elements
        let analysis = try await storyEnhancementService.analyzePhotos(photos)
        
        var story = garment.story
        
        // Merge AI-generated content with existing story
        if story.narrative.isEmpty && analysis.suggestedNarrative != nil {
            story.narrative = analysis.suggestedNarrative!
        }
        
        if story.provenance.isEmpty && analysis.detectedProvenance != nil {
            story.provenance = analysis.detectedProvenance!
        }
        
        // Add detected memories
        for memoryDescription in analysis.detectedMemories {
            let memory = Memory(description: memoryDescription)
            story.memories.append(memory)
        }
        
        story.updatedAt = Date()
        
        var updatedGarment = garment
        updatedGarment.story = story
        _ = try await garmentRepository.update(updatedGarment)
        
        return TellStoryOutput(
            story: story,
            generatedContent: GeneratedContent(
                suggestedTitle: analysis.suggestedTitle,
                styleKeywords: analysis.styleKeywords
            )
        )
    }
    
    private func addWhySelling(garment: Garment, reason: String) async throws -> TellStoryOutput {
        var updatedStory = garment.story
        updatedStory.whySelling = reason
        updatedStory.updatedAt = Date()
        
        var updatedGarment = garment
        updatedGarment.story = updatedStory
        _ = try await garmentRepository.update(updatedGarment)
        
        return TellStoryOutput(story: updatedStory)
    }
    
    private func addCareNotes(garment: Garment, notes: String) async throws -> TellStoryOutput {
        var updatedStory = garment.story
        updatedStory.careNotes = notes
        updatedStory.updatedAt = Date()
        
        var updatedGarment = garment
        updatedGarment.story = updatedStory
        _ = try await garmentRepository.update(updatedGarment)
        
        return TellStoryOutput(story: updatedStory)
    }
    
    private func enhanceNarrative(garment: Garment) async throws -> TellStoryOutput {
        let currentNarrative = garment.story.narrative
        let enhanced = try await storyEnhancementService.enhanceNarrative(
            currentNarrative,
            context: garment
        )
        
        var updatedStory = garment.story
        updatedStory.narrative = enhanced
        updatedStory.updatedAt = Date()
        
        var updatedGarment = garment
        updatedGarment.story = updatedStory
        _ = try await garmentRepository.update(updatedGarment)
        
        return TellStoryOutput(
            story: updatedStory,
            generatedContent: GeneratedContent(enhancedNarrative: enhanced)
        )
    }
    
    private func translateStory(garment: Garment, to language: String) async throws -> TellStoryOutput {
        let translation = try await storyEnhancementService.translateStory(
            garment.story,
            to: language
        )
        
        return TellStoryOutput(
            story: garment.story, // Original story
            generatedContent: GeneratedContent(enhancedNarrative: translation.translatedNarrative)
        )
    }
    
    private func getSuggestions(garment: Garment) async throws -> TellStoryOutput {
        let suggestions = try await storyEnhancementService.suggestImprovements(for: garment.story)
        let insights = try await storyEnhancementService.analyzeStory(garment.story)
        
        return TellStoryOutput(
            story: garment.story,
            enhancementSuggestions: suggestions,
            aiInsights: AIStoryInsights(
                emotionalTone: insights.emotionalTone,
                narrativeQuality: insights.qualityScore,
                completeness: insights.completenessScore,
                engagementPrediction: insights.engagementPrediction,
                suggestedImprovements: suggestions
            )
        )
    }
}

public enum StoryError: Error {
    case unauthorized
    case garmentNotFound
    case invalidStoryData
    case enhancementFailed
    case translationNotAvailable
    case aiServiceUnavailable
}