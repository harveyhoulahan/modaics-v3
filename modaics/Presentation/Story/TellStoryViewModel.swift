import SwiftUI
import Combine
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Story Step

public enum StoryStep: Int, CaseIterable, Identifiable {
    case photos = 0
    case basics = 1
    case story = 2
    case exchange = 3
    
    public var id: Int { rawValue }
    
    public var title: String {
        switch self {
        case .photos: return "Photos"
        case .basics: return "Basics"
        case .story: return "Story"
        case .exchange: return "Exchange"
        }
    }
    
    public var icon: String {
        switch self {
        case .photos: return "camera.fill"
        case .basics: return "tag.fill"
        case .story: return "book.fill"
        case .exchange: return "arrow.2.circlepath"
        }
    }
}

// MARK: - AI Analysis State

public enum AIAnalysisState: Equatable {
    case idle
    case analyzing
    case completed
    case failed(String)
    
    public var isAnalyzing: Bool {
        if case .analyzing = self { return true }
        return false
    }
}

// MARK: - Tell Story View Model

@MainActor
public class TellStoryViewModel: ObservableObject {
    
    // MARK: - Published Properties - Navigation
    
    @Published public var currentStep: StoryStep = .photos
    @Published public var showPhotoPicker = false
    @Published public var isPublishing = false
    @Published public var showError = false
    @Published public var errorMessage = ""
    @Published public var isEnhancing = false
    
    // MARK: - Published Properties - Step 1: Photos
    
    @Published public var selectedPhotos: [PhotosPickerItem] = []
    @Published public var capturedPhotos: [UIImage] = []
    
    // MARK: - Published Properties - Step 2: Basics
    
    @Published public var garmentTitle: String = ""
    @Published public var selectedCategory: Category?
    @Published public var selectedCondition: Condition = .good
    @Published public var selectedSizeSystem: SizeSystem = .us
    @Published public var sizeLabel: String = ""
    @Published public var selectedColors: [Color] = []
    @Published public var brand: String = ""
    @Published public var currency: Currency = .gbp // v3.5: Multi-currency support
    
    // MARK: - Published Properties - Step 3: Story
    
    @Published public var storyNarrative: String = ""
    @Published public var storyProvenance: String = ""
    @Published public var whySelling: String = ""
    @Published public var careNotes: String = ""
    
    // MARK: - Published Properties - Step 4: Exchange
    
    @Published public var exchangeType: ExchangeType = .sell
    @Published public var listingPrice: String = ""
    @Published public var originalPrice: String?
    @Published public var tradePreferences: String = ""
    
    // MARK: - v3.5: AI Analysis Properties
    
    @Published public var aiAnalysisState: AIAnalysisState = .idle
    @Published public var aiSuggestedTitle: String?
    @Published public var aiGeneratedDescription: String?
    @Published public var aiGeneratedStory: String?
    @Published public var aiDetectedCategory: Category?
    @Published public var aiDetectedColors: [Color] = []
    @Published public var aiDetectedBrand: String?
    @Published public var aiDetectedCondition: Condition?
    @Published public var aiSuggestedPrice: PriceSuggestion?
    @Published public var aiStyleTags: [String] = []
    @Published public var showAIConfirmations: Bool = false
    
    // MARK: - Computed Properties
    
    public var progressPercentage: Double {
        Double(currentStep.rawValue) / Double(StoryStep.allCases.count - 1)
    }
    
    public var canPublish: Bool {
        !capturedPhotos.isEmpty &&
        !garmentTitle.isEmpty &&
        selectedCategory != nil &&
        !sizeLabel.isEmpty &&
        !storyNarrative.isEmpty &&
        (exchangeType != .sell || !listingPrice.isEmpty)
    }
    
    public var canPerformAIAnalysis: Bool {
        !capturedPhotos.isEmpty
    }
    
    public var suggestedPrice: String? {
        // Prefer AI suggestion if available
        if let aiPrice = aiSuggestedPrice {
            return String(describing: aiPrice.recommended)
        }
        
        // Fall back to condition-based calculation
        guard let original = originalPrice, !original.isEmpty else { return nil }
        let multiplier: Double
        switch selectedCondition {
        case .newWithTags: multiplier = 0.75
        case .newWithoutTags: multiplier = 0.65
        case .excellent: multiplier = 0.55
        case .veryGood: multiplier = 0.45
        case .good: multiplier = 0.35
        case .fair: multiplier = 0.25
        case .vintage: multiplier = 0.50
        case .needsRepair: multiplier = 0.15
        }
        
        if let originalValue = Double(original) {
            let suggested = Int(originalValue * multiplier)
            return String(suggested)
        }
        return nil
    }
    
    public var formattedPrice: String? {
        guard !listingPrice.isEmpty else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        if let value = Double(listingPrice) {
            return formatter.string(from: NSNumber(value: value))
        }
        return nil
    }
    
    // MARK: - Private Properties
    
    private let tellStoryUseCase: TellGarmentStoryUseCaseProtocol?
    private let apiClient: APIClientV2Protocol? // v3.5: For AI analysis
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(
        tellStoryUseCase: TellGarmentStoryUseCaseProtocol? = nil,
        apiClient: APIClientV2Protocol? = nil // v3.5
    ) {
        self.tellStoryUseCase = tellStoryUseCase
        self.apiClient = apiClient
        setupBindings()
    }
    
    private func setupBindings() {
        // Watch for photo picker selections
        $selectedPhotos
            .dropFirst()
            .sink { [weak self] items in
                Task {
                    await self?.loadSelectedPhotos(items)
                }
            }
            .store(in: &cancellables)
        
        // Auto-suggest price when AI analysis provides one
        $aiSuggestedPrice
            .sink { [weak self] suggestion in
                guard let self = self, let suggestion = suggestion else { return }
                let recommended = String(describing: suggestion.recommended)
                if self.listingPrice.isEmpty {
                    self.listingPrice = recommended
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Navigation Methods
    
    public func nextStep() {
        guard let next = StoryStep(rawValue: currentStep.rawValue + 1) else { return }
        
        // Validate current step
        if validateCurrentStep() {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = next
            }
        }
    }
    
    public func previousStep() {
        guard let previous = StoryStep(rawValue: currentStep.rawValue - 1) else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = previous
        }
    }
    
    public func goToStep(_ step: StoryStep) {
        // Only allow going to completed steps or current step
        if step.rawValue <= currentStep.rawValue {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = step
            }
        }
    }
    
    // MARK: - Photo Methods
    
    public func addPhoto(_ image: UIImage) {
        capturedPhotos.append(image)
    }
    
    public func removePhoto(at index: Int) {
        guard index < capturedPhotos.count else { return }
        capturedPhotos.remove(at: index)
    }
    
    // MARK: - v3.5: AI Analysis
    
    /// Perform AI analysis on garment photos using the /analyze endpoint
    public func analyzePhotosWithAI() async {
        guard !capturedPhotos.isEmpty else {
            showError(message: "Please add at least one photo first")
            return
        }
        
        guard let apiClient = apiClient else {
            // Mock analysis for development
            await performMockAIAnalysis()
            return
        }
        
        aiAnalysisState = .analyzing
        
        do {
            // Convert photos to data
            let photoDataArray = capturedPhotos.compactMap { $0.jpegData(compressionQuality: 0.9) }
            
            // Call the analyze endpoint
            let analysis = try await apiClient.analyzeGarmentPhotos(
                photos: photoDataArray,
                generateStory: true,
                suggestPrice: true
            )
            
            // Apply AI suggestions
            await applyAIAnalysis(analysis)
            
            aiAnalysisState = .completed
            showAIConfirmations = true
            
        } catch {
            aiAnalysisState = .failed(error.localizedDescription)
            showError(message: "AI analysis failed: \(error.localizedDescription)")
        }
    }
    
    /// Apply AI analysis results to the form
    private func applyAIAnalysis(_ analysis: AIAnalysisResponse) async {
        // Apply detected category
        if let categoryString = analysis.detectedCategory,
           let category = Category(rawValue: categoryString) {
            aiDetectedCategory = category
            if selectedCategory == nil {
                selectedCategory = category
            }
        }
        
        // Apply suggested title
        if let title = analysis.suggestedTitle {
            aiSuggestedTitle = title
            if garmentTitle.isEmpty {
                garmentTitle = title
            }
        }
        
        // Apply generated description/story
        if let story = analysis.generatedStory {
            aiGeneratedStory = story
            if storyNarrative.isEmpty {
                storyNarrative = story
            }
        }
        
        // Apply detected colors
        if !analysis.detectedColors.isEmpty {
            let colors = analysis.detectedColors.map { Color(name: $0) }
            aiDetectedColors = colors
            if selectedColors.isEmpty {
                selectedColors = colors
            }
        }
        
        // Apply detected brand
        if let brandName = analysis.detectedBrand {
            aiDetectedBrand = brandName
            if brand.isEmpty {
                brand = brandName
            }
        }
        
        // Apply detected condition
        if let conditionString = analysis.detectedCondition,
           let condition = Condition(rawValue: conditionString) {
            aiDetectedCondition = condition
            selectedCondition = condition
        }
        
        // Apply price suggestion
        if let priceSuggestion = analysis.suggestedPrice {
            aiSuggestedPrice = priceSuggestion
        }
        
        // Apply style tags
        if !analysis.styleTags.isEmpty {
            aiStyleTags = analysis.styleTags
        }
    }
    
    /// Accept all AI suggestions
    public func acceptAllAISuggestions() {
        if let title = aiSuggestedTitle {
            garmentTitle = title
        }
        if let category = aiDetectedCategory {
            selectedCategory = category
        }
        if let story = aiGeneratedStory {
            storyNarrative = story
        }
        if !aiDetectedColors.isEmpty {
            selectedColors = aiDetectedColors
        }
        if let brandName = aiDetectedBrand {
            brand = brandName
        }
        if let condition = aiDetectedCondition {
            selectedCondition = condition
        }
        if let price = aiSuggestedPrice {
            listingPrice = String(describing: price.recommended)
        }
        showAIConfirmations = false
    }
    
    /// Reject AI suggestions and continue manually
    public func rejectAISuggestions() {
        showAIConfirmations = false
    }
    
    /// Mock AI analysis for development/preview
    private func performMockAIAnalysis() async {
        aiAnalysisState = .analyzing
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Generate mock analysis
        aiSuggestedTitle = "Vintage Leather Jacket"
        aiGeneratedStory = "This classic leather jacket features a rich patina that tells stories of adventures past. The buttery-soft leather has been well-loved, developing unique creases and character that only come with time."
        aiDetectedCategory = .outerwear
        aiDetectedColors = [Color(name: "Black", hex: "#1a1a1a")]
        aiDetectedBrand = "Schott NYC"
        aiDetectedCondition = .vintage
        aiStyleTags = ["vintage", "biker", "classic", "leather", "edgy"]
        
        aiSuggestedPrice = PriceSuggestion(
            min: 180.00,
            max: 280.00,
            recommended: 240.00,
            currency: "GBP",
            reasoning: "Based on similar vintage leather jackets in excellent condition"
        )
        
        await MainActor.run {
            // Apply to form if empty
            if garmentTitle.isEmpty { garmentTitle = aiSuggestedTitle! }
            if selectedCategory == nil { selectedCategory = aiDetectedCategory }
            if storyNarrative.isEmpty { storyNarrative = aiGeneratedStory! }
            if selectedColors.isEmpty { selectedColors = aiDetectedColors }
            if brand.isEmpty { brand = aiDetectedBrand! }
            selectedCondition = aiDetectedCondition ?? .good
            if listingPrice.isEmpty, let price = aiSuggestedPrice {
                listingPrice = String(describing: price.recommended)
            }
            
            aiAnalysisState = .completed
            showAIConfirmations = true
        }
    }
    
    // MARK: - AI Enhancement (Legacy)
    
    public func enhanceWithAI() async {
        guard !storyNarrative.isEmpty else { return }
        
        isEnhancing = true
        defer { isEnhancing = false }
        
        if let useCase = tellStoryUseCase {
            // Real implementation with use case
            let garmentId = UUID() // Would use actual garment ID
            let userId = UUID() // Would use actual user ID
            
            let input = TellStoryInput(
                action: .enhanceWithAI,
                garmentId: garmentId,
                userId: userId
            )
            
            do {
                let output = try await useCase.execute(input: input)
                if let enhanced = output.generatedContent?.enhancedNarrative {
                    await MainActor.run {
                        storyNarrative = enhanced
                    }
                }
            } catch {
                showError(message: "Failed to enhance story: \(error.localizedDescription)")
            }
        } else {
            // Preview/development: simulate enhancement
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            // Simple mock enhancement
            let enhanced = storyNarrative + "\n\n[Enhanced with richer detail and emotional resonance.]"
            storyNarrative = enhanced
        }
    }
    
    // MARK: - Publishing
    
    public func publish() async {
        guard canPublish else {
            showError(message: "Please complete all required fields")
            return
        }
        
        isPublishing = true
        defer { isPublishing = false }
        
        if let useCase = tellStoryUseCase {
            await publishWithUseCase(useCase)
        } else {
            // Preview/development mode
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            print("Published garment: \(garmentTitle)")
        }
    }
    
    private func publishWithUseCase(_ useCase: TellGarmentStoryUseCaseProtocol) async {
        let garmentId = UUID()
        let userId = UUID() // Current user
        
        // Create story input
        let createInput = CreateStoryInput(
            narrative: storyNarrative,
            provenance: storyProvenance,
            memories: [], // Could be populated from photo memories
            whySelling: whySelling.isEmpty ? nil : whySelling,
            careNotes: careNotes.isEmpty ? nil : careNotes
        )
        
        let input = TellStoryInput(
            action: .create(createInput),
            garmentId: garmentId,
            userId: userId
        )
        
        do {
            let output = try await useCase.execute(input: input)
            print("Successfully created story: \(output.story.id)")
        } catch {
            showError(message: "Failed to publish: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Validation
    
    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case .photos:
            if capturedPhotos.isEmpty {
                showError(message: "Please add at least one photo")
                return false
            }
            return true
            
        case .basics:
            if garmentTitle.isEmpty {
                showError(message: "Please enter a title")
                return false
            }
            if selectedCategory == nil {
                showError(message: "Please select a category")
                return false
            }
            if sizeLabel.isEmpty {
                showError(message: "Please enter a size")
                return false
            }
            return true
            
        case .story:
            if storyNarrative.isEmpty {
                showError(message: "Please share the story behind this piece")
                return false
            }
            return true
            
        case .exchange:
            if exchangeType == .sell && listingPrice.isEmpty {
                showError(message: "Please enter a price")
                return false
            }
            return true
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    capturedPhotos.append(image)
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Preview Helpers

extension TellStoryViewModel {
    public static func preview() -> TellStoryViewModel {
        let vm = TellStoryViewModel()
        vm.garmentTitle = "Vintage Leather Jacket"
        vm.selectedCategory = .outerwear
        vm.selectedCondition = .vintage
        vm.sizeLabel = "M"
        vm.storyNarrative = "Found this in a tiny shop in Tokyo..."
        vm.storyProvenance = "Shimokitazawa, Tokyo"
        vm.exchangeType = .sell
        vm.listingPrice = "295"
        return vm
    }
    
    public static func previewAtStep(_ step: StoryStep) -> TellStoryViewModel {
        let vm = preview()
        vm.currentStep = step
        return vm
    }
    
    public static func previewWithAIAnalysis() -> TellStoryViewModel {
        let vm = preview()
        vm.aiAnalysisState = .completed
        vm.aiSuggestedTitle = "Vintage Leather Biker Jacket"
        vm.aiGeneratedStory = "This authentic vintage leather jacket carries decades of character in every crease. The rich patina tells stories of open roads and adventures."
        vm.aiDetectedCategory = .outerwear
        vm.aiDetectedColors = [Color(name: "Black", hex: "#1a1a1a")]
        vm.aiDetectedBrand = "Schott NYC"
        vm.aiDetectedCondition = .vintage
        vm.aiSuggestedPrice = PriceSuggestion(
            min: 180.00,
            max: 280.00,
            recommended: 240.00,
            currency: "GBP",
            reasoning: "Based on similar vintage leather jackets"
        )
        vm.showAIConfirmations = true
        return vm
    }
}

// MARK: - Supporting Types

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
    case enhanceWithAI
    case generateFromPhotos([URL])
}

public struct Memory: Identifiable, Sendable {
    public let id: UUID
    public var description: String
    public var date: Date?
    public var location: String?
    
    public init(id: UUID = UUID(), description: String, date: Date? = nil, location: String? = nil) {
        self.id = id
        self.description = description
        self.date = date
        self.location = location
    }
}

public protocol TellGarmentStoryUseCaseProtocol: Sendable {
    func execute(input: TellStoryInput) async throws -> TellStoryOutput
}

public struct TellStoryOutput: Sendable {
    public let story: Story
    public let generatedContent: GeneratedContent?
    
    public init(story: Story, generatedContent: GeneratedContent? = nil) {
        self.story = story
        self.generatedContent = generatedContent
    }
}

public struct GeneratedContent: Sendable {
    public let enhancedNarrative: String?
    public let suggestedTitle: String?
    public let keyHighlights: [String]
    
    public init(
        enhancedNarrative: String? = nil,
        suggestedTitle: String? = nil,
        keyHighlights: [String] = []
    ) {
        self.enhancedNarrative = enhancedNarrative
        self.suggestedTitle = suggestedTitle
        self.keyHighlights = keyHighlights
    }
}
