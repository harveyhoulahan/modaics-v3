import SwiftUI
import Combine
import PhotosUI

// MARK: - Story View Model
// Connects to TellGarmentStoryUseCase

@MainActor
public class StoryViewModel: ObservableObject {
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
    
    // MARK: - Computed Properties
    
    public var progressPercentage: Double {
        Double(currentStep.rawValue) / Double(StoryStep.allCases.count)
    }
    
    public var canPublish: Bool {
        !capturedPhotos.isEmpty &&
        !garmentTitle.isEmpty &&
        selectedCategory != nil &&
        !sizeLabel.isEmpty &&
        !storyNarrative.isEmpty &&
        (exchangeType != .sell || !listingPrice.isEmpty)
    }
    
    public var suggestedPrice: String? {
        // In real implementation, would call PricingGuidanceService
        guard let original = originalPrice, !original.isEmpty else { return nil }
        // Suggest 40-60% of original based on condition
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
        formatter.currencyCode = "USD"
        if let value = Double(listingPrice) {
            return formatter.string(from: NSNumber(value: value))
        }
        return nil
    }
    
    // MARK: - Private Properties
    
    private let tellStoryUseCase: TellGarmentStoryUseCaseProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(tellStoryUseCase: TellGarmentStoryUseCaseProtocol? = nil) {
        self.tellStoryUseCase = tellStoryUseCase
        setupBindings()
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
    
    // MARK: - AI Enhancement
    
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
    }
    
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

extension StoryViewModel {
    static func preview() -> StoryViewModel {
        let vm = StoryViewModel()
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
    
    static func previewAtStep(_ step: StoryStep) -> StoryViewModel {
        let vm = preview()
        vm.currentStep = step
        return vm
    }
}