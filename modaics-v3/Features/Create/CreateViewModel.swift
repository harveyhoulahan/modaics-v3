import SwiftUI
import Combine

// MARK: - Creation Type
public enum CreationType: String, CaseIterable, Identifiable {
    case item = "ITEM"
    case event = "EVENT"
    case workshop = "WORKSHOP"
    case post = "POST"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .item: return "tshirt"
        case .event: return "calendar"
        case .workshop: return "wrench.and.screwdriver"
        case .post: return "text.bubble"
        }
    }
    
    public var description: String {
        switch self {
        case .item: return "LIST CLOTHING"
        case .event: return "HOST SWAP EVENT"
        case .workshop: return "TEACH A SKILL"
        case .post: return "SHARE STORY"
        }
    }
}

// MARK: - Listing Mode
public enum ListingMode: String, CaseIterable, Identifiable {
    case sell = "SELL"
    case rent = "RENT"
    case swap = "SWAP"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .sell: return "dollarsign.circle"
        case .rent: return "clock.arrow.circlepath"
        case .swap: return "arrow.left.arrow.right"
        }
    }
}

// MARK: - Create Form State
public struct CreateFormState {
    // Basic Info
    var title: String = ""
    var description: String = ""
    var garmentStory: String = ""
    
    // Category & Condition
    var category: Category?
    var condition: Condition?
    
    // Pricing
    var listingPrice: String = ""
    var originalPrice: String = ""
    
    // Images
    var images: [UIImage] = []
    var heroImageIndex: Int = 0
    
    // Materials & Sustainability
    var materials: [MaterialEntry] = []
    var isRecycled: Bool = false
    var certifications: [ModaicsCertification] = []
    
    // Size
    var sizeLabel: String = ""
    var sizeSystem: ModaicsSizeSystem = .us
    
    // Brand
    var brandName: String = ""
    
    // Colors
    var selectedColors: [String] = []
    
    // Listing
    var listingMode: ListingMode = .sell
    
    // Computed
    var hasRequiredFields: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        category != nil &&
        condition != nil &&
        !images.isEmpty &&
        !sizeLabel.isEmpty &&
        (listingMode == .swap || !listingPrice.isEmpty)
    }
    
    var listingPriceDecimal: Decimal? {
        Decimal(string: listingPrice)
    }
    
    var originalPriceDecimal: Decimal? {
        Decimal(string: originalPrice)
    }
}

// MARK: - Material Entry
public struct MaterialEntry: Identifiable, Equatable {
    public let id: UUID
    var name: String
    var percentage: Int
    var isSustainable: Bool
    
    public init(
        id: UUID = UUID(),
        name: String = "",
        percentage: Int = 100,
        isSustainable: Bool = false
    ) {
        self.id = id
        self.name = name
        self.percentage = percentage
        self.isSustainable = isSustainable
    }
}

// MARK: - Validation Error
public enum ValidationError: Error, LocalizedError, Hashable {
    case missingTitle
    case missingDescription
    case missingCategory
    case missingCondition
    case missingImages
    case missingSize
    case invalidPrice
    case missingMaterials
    
    public var errorDescription: String? {
        switch self {
        case .missingTitle: return "Title is required"
        case .missingDescription: return "Description is required"
        case .missingCategory: return "Please select a category"
        case .missingCondition: return "Please select condition"
        case .missingImages: return "At least one image is required"
        case .missingSize: return "Size is required"
        case .invalidPrice: return "Please enter a valid price"
        case .missingMaterials: return "Please add at least one material"
        }
    }
}

// MARK: - AI Analysis State
public enum AIAnalysisState: Equatable {
    case idle
    case analyzing(AnalysisPhase)
    case completed(AIGarmentAnalysis)
    case failed(String)
    
    public enum AnalysisPhase {
        case onDevice          // MobileCLIP + YOLO (< 150ms)
        case server            // Full FashionCLIP analysis
        case mergingResults    // Combining on-device + server
    }
    
    public static func == (lhs: AIAnalysisState, rhs: AIAnalysisState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.analyzing(let lhsPhase), .analyzing(let rhsPhase)):
            return lhsPhase == rhsPhase
        case (.completed(let lhsAnalysis), .completed(let rhsAnalysis)):
            return lhsAnalysis.title == rhsAnalysis.title &&
                   lhsAnalysis.category == rhsAnalysis.category &&
                   lhsAnalysis.confidence == rhsAnalysis.confidence
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

// MARK: - Create ViewModel
/// Single form state - NO step navigation
@MainActor
public final class CreateViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Form state (single unified form)
    @Published public var form = CreateFormState()
    
    /// Validation errors
    @Published public var validationErrors: [ValidationError] = []
    
    /// Whether form is valid
    @Published public var isFormValid: Bool = false
    
    /// Loading state
    @Published public var isSubmitting: Bool = false
    
    /// Submission result
    @Published public var submissionSuccess: Bool = false
    @Published public var submissionError: Error?
    
    /// AI Analysis state
    @Published public var aiAnalysisState: AIAnalysisState = .idle
    
    /// Sustainability score
    @Published public var sustainabilityScore: Int = 50
    
    /// Show smart create sheet
    @Published public var showSmartCreate: Bool = false
    
    // MARK: - Private Properties
    
    private let apiClient: SearchAPIClient
    private let onDeviceClassifier: OnDeviceClassifier
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(apiClient: SearchAPIClient? = nil) {
        self.apiClient = apiClient ?? SearchAPIClient.shared
        self.onDeviceClassifier = OnDeviceClassifier()
        setupValidation()
        
        // Initialize on-device ML models
        Task {
            try? await onDeviceClassifier.initialize()
        }
    }
    
    // MARK: - Setup
    
    private func setupValidation() {
        $form
            .map { $0.hasRequiredFields }
            .assign(to: &$isFormValid)
    }
    
    // MARK: - Validation
    
    @discardableResult
    public func validate() -> [ValidationError] {
        var errors: [ValidationError] = []
        
        if form.title.isEmpty {
            errors.append(.missingTitle)
        }
        
        if form.description.isEmpty {
            errors.append(.missingDescription)
        }
        
        if form.category == nil {
            errors.append(.missingCategory)
        }
        
        if form.condition == nil {
            errors.append(.missingCondition)
        }
        
        if form.images.isEmpty {
            errors.append(.missingImages)
        }
        
        if form.sizeLabel.isEmpty {
            errors.append(.missingSize)
        }
        
        if form.listingMode != .swap && form.listingPrice.isEmpty {
            errors.append(.invalidPrice)
        }
        
        validationErrors = errors
        return errors
    }
    
    // MARK: - Form Actions
    
    public func addMaterial() {
        form.materials.append(MaterialEntry())
    }
    
    public func removeMaterial(at index: Int) {
        guard index < form.materials.count else { return }
        form.materials.remove(at: index)
        calculateSustainabilityScore()
    }
    
    public func updateMaterial(id: UUID, name: String? = nil, percentage: Int? = nil, isSustainable: Bool? = nil) {
        if let index = form.materials.firstIndex(where: { $0.id == id }) {
            if let name = name { form.materials[index].name = name }
            if let percentage = percentage { form.materials[index].percentage = percentage }
            if let isSustainable = isSustainable { form.materials[index].isSustainable = isSustainable }
            calculateSustainabilityScore()
        }
    }
    
    public func addColor(_ color: String) {
        if !form.selectedColors.contains(color) {
            form.selectedColors.append(color)
        }
    }
    
    public func removeColor(_ color: String) {
        form.selectedColors.removeAll { $0 == color }
    }
    
    public func toggleCertification(_ certification: ModaicsCertification) {
        if form.certifications.contains(certification) {
            form.certifications.removeAll { $0 == certification }
        } else {
            form.certifications.append(certification)
        }
        calculateSustainabilityScore()
    }
    
    // MARK: - Sustainability Score
    
    public func calculateSustainabilityScore() {
        var score = 50 // Base score
        
        // Material points (max 30)
        let sustainableMaterials = form.materials.filter { $0.isSustainable }.count
        score += min(30, sustainableMaterials * 10)
        
        // Recycled bonus (15 points)
        if form.isRecycled {
            score += 15
        }
        
        // Certification points (max 20)
        score += min(20, form.certifications.count * 5)
        
        // Condition bonus (max 5)
        if let condition = form.condition {
            switch condition {
            case .new, .likeNew: score += 5
            case .excellent: score += 3
            case .good: score += 2
            case .fair: break
            }
        }
        
        // Cap at 100
        sustainabilityScore = min(100, score)
    }
    
    // MARK: - AI Analysis (On-Device + Server)
    
    public func analyzeWithAI() async {
        guard !form.images.isEmpty else { return }
        
        let firstImage = form.images[0]
        
        // Phase 1: On-device instant analysis (< 150ms)
        aiAnalysisState = .analyzing(.onDevice)
        
        do {
            let onDeviceResult = try await onDeviceClassifier.classifyInstant(
                image: firstImage,
                includeOCR: true
            )
            
            // Immediately show preview while server processes
            let previewAnalysis = createPreviewAnalysis(from: onDeviceResult)
            aiAnalysisState = .completed(previewAnalysis)
            await applyAIAnalysis(previewAnalysis)
            
            // Phase 2: Full server analysis in background
            aiAnalysisState = .analyzing(.server)
            
            let fullResult = try await onDeviceClassifier.classifyFull(image: firstImage)
            
            // Phase 3: Merge and update with full results
            aiAnalysisState = .analyzing(.mergingResults)
            
            if let serverResult = fullResult.serverResult {
                let finalAnalysis = createFullAnalysis(from: serverResult, onDevice: onDeviceResult)
                aiAnalysisState = .completed(finalAnalysis)
                await applyAIAnalysis(finalAnalysis)
            }
            
        } catch {
            aiAnalysisState = .failed(error.localizedDescription)
        }
    }
    
    private func createPreviewAnalysis(from onDevice: OnDeviceClassificationResult) -> AIGarmentAnalysis {
        AIGarmentAnalysis(
            title: onDevice.labelInfo?.brand != nil ? "\(onDevice.labelInfo!.brand!) Item" : "New Listing",
            category: mapCategory(onDevice.category),
            condition: .good,
            materials: onDevice.labelInfo?.material.map { 
                AIMaterial(name: $0, percentage: 100, isSustainable: false) 
            } ?? [],
            colors: [],
            estimatedPrice: 50.0,
            sustainabilityScore: 50,
            confidence: Double(onDevice.categoryConfidence),
            suggestions: onDevice.category != nil ? ["Detected as \(onDevice.category!)"] : []
        )
    }
    
    private func createFullAnalysis(from server: ServerAnalysisResult, onDevice: OnDeviceClassificationResult) -> AIGarmentAnalysis {
        AIGarmentAnalysis(
            title: "\(server.category.first?.label.capitalized ?? "Item") for Sale",
            category: mapCategory(server.category.first?.label),
            condition: mapCondition(server.conditionGrade.grade),
            materials: server.material.map { 
                AIMaterial(
                    name: $0.label, 
                    percentage: 100, 
                    isSustainable: isSustainableMaterial($0.label)
                ) 
            },
            colors: server.color.map { $0.label },
            estimatedPrice: server.estimatedPrice.max,
            sustainabilityScore: server.sustainabilityScore,
            confidence: Double(server.category.first?.confidence ?? 0.5),
            suggestions: server.suggestions
        )
    }
    
    private func mapCategory(_ label: String?) -> Category {
        let normalized = label?.lowercased() ?? ""
        switch normalized {
        case "tops", "shirt", "blouse", "t-shirt", "tshirt": return .tops
        case "bottoms", "pants", "jeans", "trousers", "shorts": return .bottoms
        case "dresses", "dress": return .dresses
        case "outerwear", "jacket", "coat", "blazer": return .outerwear
        case "shoes", "footwear", "boots", "sneakers": return .shoes
        case "accessories", "accessory": return .accessories
        case "bags", "bag", "handbag": return .bags
        case "activewear", "sportswear": return .activewear
        case "swimwear", "swimsuit", "bikini": return .swimwear
        case "formal", "evening", "gown": return .formal
        case "vintage": return .vintage
        default: return .tops
        }
    }
    
    private func mapCondition(_ grade: String) -> Condition {
        switch grade {
        case "A": return .new
        case "B": return .likeNew
        case "C": return .good
        case "D": return .fair
        case "F": return .excellent
        default: return .good
        }
    }
    
    private func isSustainableMaterial(_ name: String) -> Bool {
        let sustainable = ["organic", "recycled", "hemp", "linen", "tencel", "silk", "wool", "cashmere"]
        return sustainable.contains { name.lowercased().contains($0) }
    }
    
    public func applyAIAnalysis(_ analysis: AIGarmentAnalysis) async {
        // Only fill empty fields to preserve user edits
        if form.title.isEmpty || form.title.count < 5 {
            form.title = analysis.title
        }
        
        if form.category == nil {
            form.category = analysis.category
        }
        
        if form.condition == nil {
            form.condition = analysis.condition
        }
        
        // Convert AI materials to form materials
        if form.materials.isEmpty {
            form.materials = analysis.materials.map { aiMaterial in
                MaterialEntry(
                    name: aiMaterial.name,
                    percentage: aiMaterial.percentage,
                    isSustainable: aiMaterial.isSustainable
                )
            }
        }
        
        // Add suggested colors
        for color in analysis.colors {
            addColor(color)
        }
        
        // Set estimated price
        if form.listingPrice.isEmpty {
            form.listingPrice = String(describing: analysis.estimatedPrice)
        }
        
        // Update sustainability score
        sustainabilityScore = analysis.sustainabilityScore
        
        // Add AI suggestions to description if empty
        if form.description.isEmpty && !analysis.suggestions.isEmpty {
            form.description = analysis.suggestions.joined(separator: "\n")
        }
        
        // Recalculate score with new data
        calculateSustainabilityScore()
    }
    
    // MARK: - Submission
    
    public func submit() async throws {
        let errors = validate()
        guard errors.isEmpty else {
            throw ValidationError.missingTitle // Use first error
        }
        
        isSubmitting = true
        submissionError = nil
        
        // Simulate network request
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // In real implementation, would upload images and create listing
        // For now, just simulate success
        
        isSubmitting = false
        submissionSuccess = true
    }
    
    public func resetForm() {
        form = CreateFormState()
        validationErrors = []
        aiAnalysisState = .idle
        sustainabilityScore = 50
        submissionSuccess = false
        submissionError = nil
    }
}

// MARK: - Material Options
public enum MaterialOption: String, CaseIterable {
    case cotton = "Cotton"
    case polyester = "Polyester"
    case wool = "Wool"
    case linen = "Linen"
    case silk = "Silk"
    case denim = "Denim"
    case leather = "Leather"
    case nylon = "Nylon"
    case cashmere = "Cashmere"
    case hemp = "Hemp"
    case recycledPolyester = "Recycled Polyester"
    case organicCotton = "Organic Cotton"
    case tencel = "Tencel"
    case other = "Other"
    
    public var isSustainable: Bool {
        switch self {
        case .organicCotton, .hemp, .linen, .recycledPolyester, .tencel, .silk, .cashmere, .wool:
            return true
        case .cotton, .denim:
            return false // Natural but water-intensive
        case .polyester, .nylon, .leather, .other:
            return false
        }
    }
}

// MARK: - Color Options
public struct ColorOption: Identifiable {
    public let id = UUID()
    public let name: String
    public let hex: String
    
    public static let all: [ColorOption] = [
        ColorOption(name: "Black", hex: "000000"),
        ColorOption(name: "White", hex: "FFFFFF"),
        ColorOption(name: "Gray", hex: "808080"),
        ColorOption(name: "Navy", hex: "000080"),
        ColorOption(name: "Blue", hex: "0000FF"),
        ColorOption(name: "Brown", hex: "8B4513"),
        ColorOption(name: "Beige", hex: "F5F5DC"),
        ColorOption(name: "Cream", hex: "FFFDD0"),
        ColorOption(name: "Red", hex: "FF0000"),
        ColorOption(name: "Pink", hex: "FFC0CB"),
        ColorOption(name: "Green", hex: "008000"),
        ColorOption(name: "Olive", hex: "808000"),
        ColorOption(name: "Yellow", hex: "FFFF00"),
        ColorOption(name: "Orange", hex: "FFA500"),
        ColorOption(name: "Purple", hex: "800080"),
        ColorOption(name: "Gold", hex: "FFD700"),
        ColorOption(name: "Silver", hex: "C0C0C0"),
        ColorOption(name: "Camel", hex: "C19A6B"),
        ColorOption(name: "Terracotta", hex: "E2725B"),
        ColorOption(name: "Burgundy", hex: "800020")
    ]
}
