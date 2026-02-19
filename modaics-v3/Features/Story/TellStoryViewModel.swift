import SwiftUI
import PhotosUI
import Combine

// MARK: - Tell Story View Model
/// Manages form state and validation for the Tell Story flow
@MainActor
public class TellStoryViewModel: ObservableObject {
    
    // MARK: - Navigation State
    
    @Published public var currentStep: TellStoryStep = .photos
    @Published public var showPhotoPicker = false
    @Published public var showError = false
    @Published public var errorMessage = ""
    @Published public var isSubmitting = false
    
    // MARK: - Step 1: Photos
    
    @Published public var selectedPhotoItems: [PhotosPickerItem] = []
    @Published public var selectedImages: [UIImage] = []
    
    // MARK: - Step 2: Basics
    
    @Published public var garmentTitle: String = ""
    @Published public var selectedCategory: ModaicsCategory?
    @Published public var selectedCondition: ModaicsCondition = .good
    @Published public var selectedSizeSystem: ModaicsSizeSystem = .us
    @Published public var sizeLabel: String = ""
    
    // MARK: - Step 3: Story
    
    @Published public var provenance: String = ""
    @Published public var memories: String = ""
    @Published public var whySelling: String = ""
    
    // MARK: - Step 4: Exchange
    
    @Published public var exchangeType: ModaicsExchangeType = .sell
    @Published public var price: String = ""
    
    // MARK: - Computed Properties
    
    /// Progress percentage for the progress bar
    public var progressPercentage: Double {
        Double(currentStep.rawValue) / Double(TellStoryStep.allCases.count)
    }
    
    /// Whether the user can proceed to the next step
    public var canProceed: Bool {
        switch currentStep {
        case .photos:
            return !selectedImages.isEmpty
        case .basics:
            return !garmentTitle.isEmpty &&
                   selectedCategory != nil &&
                   !sizeLabel.isEmpty
        case .story:
            return !provenance.isEmpty || !memories.isEmpty
        case .exchange:
            return true
        }
    }
    
    /// Whether the form is complete and ready to submit
    public var canSubmit: Bool {
        // Must have completed all steps
        guard !selectedImages.isEmpty,
              !garmentTitle.isEmpty,
              selectedCategory != nil,
              !sizeLabel.isEmpty,
              !provenance.isEmpty else {
            return false
        }
        
        // If selling, must have a price
        if (exchangeType == .sell || exchangeType == .sellOrTrade) && price.isEmpty {
            return false
        }
        
        return true
    }
    
    /// Suggested price based on condition
    public var suggestedPrice: String? {
        // In a real implementation, this would call a pricing service
        // For now, return nil as we don't have original price input
        nil
    }
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init() {
        setupBindings()
    }
    
    // MARK: - Navigation
    
    /// Move to the next step if validation passes
    public func nextStep() {
        guard validateCurrentStep() else { return }
        
        guard let next = TellStoryStep(rawValue: currentStep.rawValue + 1) else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = next
        }
    }
    
    /// Go back to the previous step
    public func previousStep() {
        guard let previous = TellStoryStep(rawValue: currentStep.rawValue - 1) else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = previous
        }
    }
    
    /// Jump to a specific step (only if already visited)
    public func goToStep(_ step: TellStoryStep) {
        guard step.rawValue <= currentStep.rawValue else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = step
        }
    }
    
    // MARK: - Photo Management
    
    /// Remove an image at the specified index
    public func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
        
        // Also remove from photo items if available
        if index < selectedPhotoItems.count {
            selectedPhotoItems.remove(at: index)
        }
    }
    
    // MARK: - Validation
    
    /// Validates the current step and shows error if invalid
    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case .photos:
            if selectedImages.isEmpty {
                showError(message: "Please add at least one photo of your garment")
                return false
            }
            return true
            
        case .basics:
            if garmentTitle.isEmpty {
                showError(message: "Please enter a title for your garment")
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
            if provenance.isEmpty && memories.isEmpty {
                showError(message: "Please share at least some of the garment's story")
                return false
            }
            return true
            
        case .exchange:
            if (exchangeType == .sell || exchangeType == .sellOrTrade) && price.isEmpty {
                showError(message: "Please enter a price")
                return false
            }
            return true
        }
    }
    
    // MARK: - Submission
    
    /// Submit the completed form and create the garment
    public func submit() async {
        guard canSubmit else {
            showError(message: "Please complete all required fields")
            return
        }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            // Create the story
            let story = createStory()
            
            // Create the garment
            let garment = createGarment(storyId: story.id)
            
            // In a real implementation, upload images and save to backend
            // For now, simulate network delay
            try await Task.sleep(nanoseconds: 1_500_000_000)
            
            // Success - would typically dismiss or navigate
            print("Successfully created garment: \(garment.id)")
            print("With story: \(story.id)")
            
        } catch {
            showError(message: "Failed to publish: \(error.localizedDescription)")
        }
    }
    
    /// Creates a ModaicsStory from form data
    private func createStory() -> ModaicsStory {
        ModaicsStory(
            narrative: memories,
            provenance: provenance,
            memories: [],
            whySelling: whySelling.isEmpty ? nil : whySelling,
            careNotes: nil,
            previousStoryIds: []
        )
    }
    
    /// Creates a ModaicsGarment from form data
    private func createGarment(storyId: UUID) -> ModaicsGarment {
        let listingPrice: Decimal? = {
            guard !price.isEmpty,
                  let doubleValue = Double(price) else { return nil }
            return Decimal(doubleValue)
        }()
        
        let size = ModaicsSize(
            label: sizeLabel,
            system: selectedSizeSystem
        )
        
        return ModaicsGarment(
            title: garmentTitle,
            description: "", // Could add description field
            storyId: storyId,
            condition: selectedCondition,
            listingPrice: listingPrice,
            category: selectedCategory ?? .other,
            subcategory: nil,
            styleTags: [],
            colors: [],
            materials: [],
            brand: nil,
            size: size,
            era: nil,
            imageURLs: [], // Would be populated after upload
            ownerId: UUID(), // Would be current user
            exchangeType: exchangeType
        )
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Load images when photo items are selected
        $selectedPhotoItems
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
                    if !self.selectedImages.contains(where: { $0.pngData() == image.pngData() }) {
                        self.selectedImages.append(image)
                    }
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Display Name Extensions

extension ModaicsCategory {
    public var displayName: String {
        switch self {
        case .tops: return "Tops"
        case .bottoms: return "Bottoms"
        case .dresses: return "Dresses"
        case .outerwear: return "Outerwear"
        case .activewear: return "Activewear"
        case .loungewear: return "Loungewear"
        case .formal: return "Formal"
        case .accessories: return "Accessories"
        case .shoes: return "Shoes"
        case .jewelry: return "Jewelry"
        case .bags: return "Bags"
        case .vintage: return "Vintage"
        case .other: return "Other"
        }
    }
}

extension ModaicsCondition {
    public var displayName: String {
        switch self {
        case .newWithTags: return "New with Tags"
        case .newWithoutTags: return "New without Tags"
        case .excellent: return "Excellent"
        case .veryGood: return "Very Good"
        case .good: return "Good"
        case .fair: return "Fair"
        case .vintage: return "Vintage"
        case .needsRepair: return "Needs Repair"
        }
    }
}

extension ModaicsSizeSystem {
    public var displayName: String {
        switch self {
        case .us: return "US"
        case .uk: return "UK"
        case .eu: return "EU"
        case .it: return "IT"
        case .fr: return "FR"
        case .jp: return "JP"
        case .universal: return "Universal"
        case .numeric: return "Numeric"
        case .oneSize: return "One Size"
        }
    }
}

extension ModaicsExchangeType {
    public var displayName: String {
        switch self {
        case .sell: return "Sell"
        case .trade: return "Trade"
        case .sellOrTrade: return "Sell or Trade"
        }
    }
}
