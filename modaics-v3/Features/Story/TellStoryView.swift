import SwiftUI
import PhotosUI

// MARK: - Tell Story Step
/// The four steps of telling a garment's story
public enum TellStoryStep: Int, CaseIterable {
    case photos = 1
    case basics = 2
    case story = 3
    case exchange = 4
    
    public var title: String {
        switch self {
        case .photos: return "PHOTOS"
        case .basics: return "DETAILS"
        case .story: return "STORY"
        case .exchange: return "EXCHANGE"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .photos: return "Show us your garment"
        case .basics: return "Describe the piece"
        case .story: return "Share its journey"
        case .exchange: return "How it finds a home"
        }
    }
}

// MARK: - Tell Story View (Dark Green Porsche)
/// Multi-step form for creating a new garment listing
/// Dark green Porsche aesthetic with gold accents
public struct TellStoryView: View {
    @StateObject private var viewModel: TellStoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: TellStoryViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? TellStoryViewModel())
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Dark green background
                Color.modaicsBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress header
                    progressHeader
                    
                    // Step content
                    ScrollView {
                        stepContent
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                    }
                    
                    // Navigation footer
                    navigationFooter
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("CANCEL") {
                        dismiss()
                    }
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .photosPicker(
                isPresented: $viewModel.showPhotoPicker,
                selection: $viewModel.selectedPhotoItems,
                maxSelectionCount: 10,
                matching: .images
            )
            .overlay {
                if viewModel.isSubmitting {
                    loadingOverlay
                }
            }
        }
    }
    
    // MARK: - Progress Header
    
    private var progressHeader: some View {
        VStack(spacing: 12) {
            // Step indicators
            HStack(spacing: 8) {
                ForEach(TellStoryStep.allCases, id: \.self) { step in
                    StepIndicator(
                        step: step,
                        isActive: step == viewModel.currentStep,
                        isCompleted: step.rawValue < viewModel.currentStep.rawValue
                    )
                }
            }
            .padding(.horizontal, 24)
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.modaicsSurface)
                        .frame(height: 2)
                    
                    Rectangle()
                        .fill(Color.luxeGold)
                        .frame(
                            width: geo.size.width * viewModel.progressPercentage,
                            height: 2
                        )
                }
            }
            .frame(height: 2)
            
            // Step title
            VStack(spacing: 4) {
                Text(viewModel.currentStep.title)
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.sageWhite)
                    .tracking(2)
                
                Text(viewModel.currentStep.subtitle)
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 12)
        .background(Color.modaicsSurface)
    }
    
    // MARK: - Step Content
    
    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .photos:
            PhotosStepView(viewModel: viewModel)
        case .basics:
            BasicsStepView(viewModel: viewModel)
        case .story:
            StoryStepView(viewModel: viewModel)
        case .exchange:
            ExchangeStepView(viewModel: viewModel)
        }
    }
    
    // MARK: - Navigation Footer
    
    private var navigationFooter: some View {
        HStack(spacing: 12) {
            // Back button
            if viewModel.currentStep != .photos {
                Button("BACK") {
                    viewModel.previousStep()
                }
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color.modaicsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
                .cornerRadius(8)
            }
            
            Spacer()
            
            // Next/Submit button
            if viewModel.currentStep != .exchange {
                Button("CONTINUE") {
                    viewModel.nextStep()
                }
                .font(.forestBodyMedium)
                .foregroundColor(.modaicsBackground)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color.luxeGold)
                .cornerRadius(8)
                .disabled(!viewModel.canProceed)
                .opacity(viewModel.canProceed ? 1 : 0.5)
            } else {
                Button("PUBLISH") {
                    Task {
                        await viewModel.submit()
                    }
                }
                .font(.forestBodyMedium)
                .foregroundColor(.modaicsBackground)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color.luxeGold)
                .cornerRadius(8)
                .disabled(!viewModel.canSubmit)
                .opacity(viewModel.canSubmit ? 1 : 0.5)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.modaicsSurface)
        .overlay(
            Rectangle()
                .fill(Color.modaicsSurfaceHighlight)
                .frame(height: 0.5)
                , alignment: .top
        )
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            Color.modaicsBackground.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color.luxeGold)
                
                Text("PUBLISHING YOUR STORY...")
                    .font(.forestCaptionLarge)
                    .foregroundColor(.sageWhite)
                    .tracking(2)
            }
            .padding(32)
            .background(Color.modaicsSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
            )
        }
    }
}

// MARK: - Step Indicator (Dark Green Porsche)

struct StepIndicator: View {
    let step: TellStoryStep
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 28, height: 28)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.modaicsBackground)
                } else {
                    Text("\(step.rawValue)")
                        .font(.forestCaptionSmall)
                        .foregroundColor(foregroundColor)
                }
            }
            
            Text(step.title)
                .font(.forestCaptionSmall)
                .foregroundColor(textColor)
                .tracking(1)
        }
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return Color.emerald
        } else if isActive {
            return Color.luxeGold
        } else {
            return Color.modaicsSurfaceHighlight
        }
    }
    
    private var foregroundColor: Color {
        isActive ? Color.modaicsBackground : Color.sageMuted
    }
    
    private var textColor: Color {
        if isActive {
            return Color.sageWhite
        } else if isCompleted {
            return Color.sageWhite
        } else {
            return Color.sageSubtle
        }
    }
}

// MARK: - Photos Step View

struct PhotosStepView: View {
    @ObservedObject var viewModel: TellStoryViewModel
    @State private var selectedImageIndex: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("ADD PHOTOS")
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.sageWhite)
                    .tracking(1)
                
                Text("Upload clear photos of your garment. Include front, back, and any details.")
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageMuted)
            }
            
            // Photo grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 12)], spacing: 12) {
                // Add photo button
                addPhotoButton
                
                // Selected photos
                ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                    photoThumbnail(image, at: index)
                }
            }
            
            // Tips
            VStack(alignment: .leading, spacing: 8) {
                Text("TIPS FOR GREAT PHOTOS:")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageWhite)
                    .tracking(1)
                
                ForEach(["Use natural lighting", "Show the garment flat or on a hanger", "Include close-ups of fabric and details"], id: \.self) { tip in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.emerald)
                        
                        Text(tip)
                            .font(.forestCaptionRegular)
                            .foregroundColor(.sageMuted)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
    
    private var addPhotoButton: some View {
        Button {
            viewModel.showPhotoPicker = true
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.modaicsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.luxeGold.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.luxeGold)
                        
                        Text("ADD")
                            .font(.forestCaptionSmall)
                            .foregroundColor(.luxeGold)
                            .tracking(1)
                    }
                )
                .aspectRatio(1, contentMode: .fill)
        }
    }
    
    private func photoThumbnail(_ image: UIImage, at index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 100, minHeight: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Remove button
            Button {
                viewModel.removeImage(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.modaicsError)
                    .background(Color.modaicsBackground.clipShape(Circle()))
            }
            .offset(x: 6, y: -6)
        }
    }
}

// MARK: - Basics Step View

struct BasicsStepView: View {
    @ObservedObject var viewModel: TellStoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("GARMENT DETAILS")
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.sageWhite)
                    .tracking(1)
                
                Text("Tell us about the piece you're sharing.")
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageMuted)
            }
            
            // Form fields
            VStack(alignment: .leading, spacing: 16) {
                // Title
                formField(title: "TITLE") {
                    TextField("e.g., Vintage Leather Jacket", text: $viewModel.garmentTitle)
                        .textFieldStyle(DarkGreenTextFieldStyle())
                }
                
                // Category
                formField(title: "CATEGORY") {
                    Menu {
                        ForEach(ModaicsCategory.allCases, id: \.self) { category in
                            Button(category.displayName) {
                                viewModel.selectedCategory = category
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedCategory?.displayName ?? "Select category")
                                .foregroundColor(viewModel.selectedCategory == nil ? Color.sageSubtle : Color.sageWhite)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.sageMuted)
                        }
                        .padding()
                        .background(Color.modaicsSurface)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
                        )
                    }
                }
                
                // Condition
                formField(title: "CONDITION") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ModaicsCondition.allCases, id: \.self) { condition in
                                ConditionButton(
                                    condition: condition,
                                    isSelected: viewModel.selectedCondition == condition
                                ) {
                                    viewModel.selectedCondition = condition
                                }
                            }
                        }
                    }
                }
                
                // Size
                formField(title: "SIZE") {
                    HStack(spacing: 8) {
                        // Size system picker
                        Menu {
                            ForEach(ModaicsSizeSystem.allCases, id: \.self) { system in
                                Button(system.displayName) {
                                    viewModel.selectedSizeSystem = system
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedSizeSystem.rawValue.uppercased())
                                    .font(.forestCaptionSmall)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(.sageWhite)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.modaicsSurface)
                            .cornerRadius(6)
                        }
                        
                        // Size input
                        TextField("e.g., M or 8", text: $viewModel.sizeLabel)
                            .textFieldStyle(DarkGreenTextFieldStyle())
                    }
                }
            }
        }
    }
    
    private func formField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.forestCaptionMedium)
                .foregroundColor(.sageMuted)
                .tracking(1)
            
            content()
        }
    }
}

// MARK: - Condition Button

struct ConditionButton: View {
    let condition: ModaicsCondition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(condition.displayName.uppercased())
                .font(.forestCaptionSmall)
                .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
                .tracking(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
                .cornerRadius(6)
        }
    }
}

// MARK: - Story Step View

struct StoryStepView: View {
    @ObservedObject var viewModel: TellStoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("THE STORY")
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.sageWhite)
                    .tracking(1)
                
                Text("This is what makes your garment special. Share its journey.")
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageMuted)
            }
            
            // Form fields
            VStack(alignment: .leading, spacing: 16) {
                // Provenance
                StoryInput(
                    "Where did this garment come from? A specific shop, city, or person?",
                    text: $viewModel.provenance,
                    title: "Provenance",
                    helpText: "e.g., 'A boutique in Lisbon' or 'Handed down from my grandmother'"
                )
                
                // Memories
                StoryInput(
                    "What memories do you have with this piece? Special occasions, travels, milestones?",
                    text: $viewModel.memories,
                    title: "Memories",
                    helpText: "Share the moments that made this garment meaningful"
                )
                
                // Why selling
                StoryInput(
                    "Why are you parting with this piece?",
                    text: $viewModel.whySelling,
                    title: "Why I'm Passing It On",
                    helpText: "Buyers connect with honest stories about letting go"
                )
            }
        }
    }
}

// MARK: - Exchange Step View

struct ExchangeStepView: View {
    @ObservedObject var viewModel: TellStoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("HOW TO EXCHANGE")
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.sageWhite)
                    .tracking(1)
                
                Text("Choose how you'd like to find your garment a new home.")
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageMuted)
            }
            
            // Exchange type selection
            VStack(alignment: .leading, spacing: 12) {
                Text("EXCHANGE TYPE")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
                
                VStack(spacing: 12) {
                    ExchangeTypeButton(
                        type: .sell,
                        isSelected: viewModel.exchangeType == .sell,
                        action: { viewModel.exchangeType = .sell }
                    )
                    
                    ExchangeTypeButton(
                        type: .trade,
                        isSelected: viewModel.exchangeType == .trade,
                        action: { viewModel.exchangeType = .trade }
                    )
                    
                    ExchangeTypeButton(
                        type: .sellOrTrade,
                        isSelected: viewModel.exchangeType == .sellOrTrade,
                        action: { viewModel.exchangeType = .sellOrTrade }
                    )
                }
            }
            
            // Price input (if selling)
            if viewModel.exchangeType == .sell || viewModel.exchangeType == .sellOrTrade {
                VStack(alignment: .leading, spacing: 6) {
                    Text("PRICE")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                        .tracking(1)
                    
                    HStack {
                        Text("$")
                            .font(.forestBodyLarge)
                            .foregroundColor(.sageWhite)
                        
                        TextField("0.00", text: $viewModel.price)
                            .keyboardType(.decimalPad)
                            .font(.forestBodyLarge)
                            .foregroundColor(.sageWhite)
                    }
                    .padding()
                    .background(Color.modaicsSurface)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
                    )
                    
                    if let suggestedPrice = viewModel.suggestedPrice {
                        Text("SUGGESTED: \(suggestedPrice) BASED ON CONDITION")
                            .font(.forestCaptionSmall)
                            .foregroundColor(.emerald)
                            .tracking(1)
                    }
                }
            }
        }
    }
}

// MARK: - Exchange Type Button

struct ExchangeTypeButton: View {
    let type: ModaicsExchangeType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color.luxeGold : Color.sageMuted)
                    .frame(width: 40)
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.displayName.uppercased())
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageWhite)
                        .tracking(1)
                    
                    Text(description)
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageMuted)
                }
                
                Spacer()
                
                // Selection indicator
                Circle()
                    .stroke(isSelected ? Color.luxeGold : Color.modaicsSurfaceHighlight, lineWidth: 2)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .fill(Color.luxeGold)
                            .frame(width: 12, height: 12)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding()
            .background(isSelected ? Color.luxeGold.opacity(0.05) : Color.modaicsSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.luxeGold : Color.clear, lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconName: String {
        switch type {
        case .sell: return "dollarsign.circle"
        case .trade: return "arrow.left.arrow.right"
        case .sellOrTrade: return "bag.badge.plus"
        }
    }
    
    private var description: String {
        switch type {
        case .sell: return "Sell for a fixed price"
        case .trade: return "Exchange for another item"
        case .sellOrTrade: return "Open to selling or trading"
        }
    }
}

// MARK: - Text Field Style

struct DarkGreenTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.forestBodyMedium)
            .foregroundColor(.sageWhite)
            .padding()
            .background(Color.modaicsSurface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
            )
    }
}

// MARK: - Preview

#Preview {
    TellStoryView()
}