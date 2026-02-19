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
        case .photos: return "Photos"
        case .basics: return "Details"
        case .story: return "Story"
        case .exchange: return "Exchange"
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

// MARK: - Tell Story View
/// Multi-step form for creating a new garment listing
/// Warm, editorial aesthetic inspired by Mediterranean craft
public struct TellStoryView: View {
    @StateObject private var viewModel: TellStoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: TellStoryViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? TellStoryViewModel())
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Warm sand background
                Color.modaicsWarmSand
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress header
                    progressHeader
                    
                    // Step content
                    ScrollView {
                        stepContent
                            .padding(.horizontal, ModaicsLayout.large)
                            .padding(.vertical, ModaicsLayout.medium)
                    }
                    
                    // Navigation footer
                    navigationFooter
                }
            }
            .navigationTitle("Tell Your Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.modaicsStone)
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
        VStack(spacing: ModaicsLayout.small) {
            // Step indicators
            HStack(spacing: ModaicsLayout.small) {
                ForEach(TellStoryStep.allCases, id: \.self) { step in
                    StepIndicator(
                        step: step,
                        isActive: step == viewModel.currentStep,
                        isCompleted: step.rawValue < viewModel.currentStep.rawValue
                    )
                }
            }
            .padding(.horizontal, ModaicsLayout.large)
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.modaicsOatmeal)
                        .frame(height: 2)
                    
                    Rectangle()
                        .fill(Color.modaicsTerracotta)
                        .frame(
                            width: geo.size.width * viewModel.progressPercentage,
                            height: 2
                        )
                }
            }
            .frame(height: 2)
            
            // Step title
            VStack(spacing: ModaicsLayout.tightSpacing) {
                Text(viewModel.currentStep.title)
                    .font(.modaicsHeadline3)
                    .foregroundColor(Color.modaicsTextPrimary)
                
                Text(viewModel.currentStep.subtitle)
                    .font(.modaicsCaptionRegular)
                    .foregroundColor(Color.modaicsTextSecondary)
            }
            .padding(.top, ModaicsLayout.small)
        }
        .padding(.vertical, ModaicsLayout.small)
        .background(Color.modaicsPaper)
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
        HStack(spacing: ModaicsLayout.small) {
            // Back button
            if viewModel.currentStep != .photos {
                Button("Back") {
                    viewModel.previousStep()
                }
                .buttonStyle(ModaicsGhostButtonStyle())
            }
            
            Spacer()
            
            // Next/Submit button
            if viewModel.currentStep != .exchange {
                Button("Continue") {
                    viewModel.nextStep()
                }
                .buttonStyle(ModaicsPrimaryButtonStyle())
                .disabled(!viewModel.canProceed)
            } else {
                Button("Publish") {
                    Task {
                        await viewModel.submit()
                    }
                }
                .buttonStyle(ModaicsPrimaryButtonStyle())
                .disabled(!viewModel.canSubmit)
            }
        }
        .padding(.horizontal, ModaicsLayout.large)
        .padding(.vertical, ModaicsLayout.medium)
        .background(Color.modaicsPaper)
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            Color.modaicsCharcoal.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: ModaicsLayout.large) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color.modaicsTerracotta)
                
                Text("Publishing your story...")
                    .font(.modaicsBodyRegular)
                    .foregroundColor(Color.modaicsTextPrimary)
            }
            .padding(ModaicsLayout.xlarge)
            .background(Color.modaicsPaper)
            .cornerRadius(ModaicsLayout.cornerRadius)
        }
    }
}

// MARK: - Step Indicator

struct StepIndicator: View {
    let step: TellStoryStep
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: ModaicsLayout.tightSpacing) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 28, height: 28)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.modaicsCream)
                } else {
                    Text("\(step.rawValue)")
                        .font(.modaicsCaption)
                        .foregroundColor(foregroundColor)
                }
            }
            
            Text(step.title)
                .font(.modaicsFinePrint)
                .foregroundColor(textColor)
        }
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return Color.modaicsSage
        } else if isActive {
            return Color.modaicsTerracotta
        } else {
            return Color.modaicsOatmeal
        }
    }
    
    private var foregroundColor: Color {
        isActive ? Color.modaicsCream : Color.modaicsTextSecondary
    }
    
    private var textColor: Color {
        if isActive {
            return Color.modaicsTextPrimary
        } else if isCompleted {
            return Color.modaicsTextPrimary
        } else {
            return Color.modaicsTextSecondary.opacity(0.6)
        }
    }
}

// MARK: - Photos Step View

struct PhotosStepView: View {
    @ObservedObject var viewModel: TellStoryViewModel
    @State private var selectedImageIndex: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: ModaicsLayout.large) {
            // Header
            VStack(alignment: .leading, spacing: ModaicsLayout.tightSpacing) {
                Text("Add Photos")
                    .font(.modaicsHeadingSemiBold)
                    .foregroundColor(Color.modaicsTextPrimary)
                
                Text("Upload clear photos of your garment. Include front, back, and any details.")
                    .font(.modaicsBodyRegular)
                    .foregroundColor(Color.modaicsTextSecondary)
            }
            
            // Photo grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 120), spacing: ModaicsLayout.small)], spacing: ModaicsLayout.small) {
                // Add photo button
                addPhotoButton
                
                // Selected photos
                ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                    photoThumbnail(image, at: index)
                }
            }
            
            // Tips
            VStack(alignment: .leading, spacing: ModaicsLayout.tightSpacing) {
                Text("Tips for great photos:")
                    .font(.modaicsLabel)
                    .foregroundColor(Color.modaicsTextPrimary)
                
                ForEach(["Use natural lighting", "Show the garment flat or on a hanger", "Include close-ups of fabric and details"], id: \.self) { tip in
                    HStack(spacing: ModaicsLayout.tightSpacing) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.modaicsSage)
                        
                        Text(tip)
                            .font(.modaicsCaptionRegular)
                            .foregroundColor(Color.modaicsTextSecondary)
                    }
                }
            }
            .padding(.top, ModaicsLayout.small)
        }
    }
    
    private var addPhotoButton: some View {
        Button {
            viewModel.showPhotoPicker = true
        } label: {
            RoundedRectangle(cornerRadius: ModaicsLayout.cornerRadiusSmall)
                .fill(Color.modaicsCream)
                .overlay(
                    RoundedRectangle(cornerRadius: ModaicsLayout.cornerRadiusSmall)
                        .stroke(Color.modaicsTerracotta.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
                .overlay(
                    VStack(spacing: ModaicsLayout.small) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(Color.modaicsTerracotta)
                        
                        Text("Add")
                            .font(.modaicsCaption)
                            .foregroundColor(Color.modaicsTerracotta)
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
                .clipShape(RoundedRectangle(cornerRadius: ModaicsLayout.cornerRadiusSmall))
            
            // Remove button
            Button {
                viewModel.removeImage(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.modaicsRust)
                    .background(Color.modaicsCream.clipShape(Circle()))
            }
            .offset(x: 6, y: -6)
        }
    }
}

// MARK: - Basics Step View

struct BasicsStepView: View {
    @ObservedObject var viewModel: TellStoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: ModaicsLayout.large) {
            // Header
            VStack(alignment: .leading, spacing: ModaicsLayout.tightSpacing) {
                Text("Garment Details")
                    .font(.modaicsHeadingSemiBold)
                    .foregroundColor(Color.modaicsTextPrimary)
                
                Text("Tell us about the piece you're sharing.")
                    .font(.modaicsBodyRegular)
                    .foregroundColor(Color.modaicsTextSecondary)
            }
            
            // Form fields
            VStack(alignment: .leading, spacing: ModaicsLayout.medium) {
                // Title
                formField(title: "Title") {
                    TextField("e.g., Vintage Leather Jacket", text: $viewModel.garmentTitle)
                        .textFieldStyle(ModaicsTextFieldStyle())
                }
                
                // Category
                formField(title: "Category") {
                    Menu {
                        ForEach(ModaicsCategory.allCases, id: \.self) { category in
                            Button(category.displayName) {
                                viewModel.selectedCategory = category
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedCategory?.displayName ?? "Select category")
                                .foregroundColor(viewModel.selectedCategory == nil ? Color.modaicsTextTertiary : Color.modaicsTextPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(Color.modaicsTextSecondary)
                        }
                        .padding()
                        .background(Color.modaicsPaper)
                        .cornerRadius(ModaicsLayout.cornerRadiusMedium)
                    }
                }
                
                // Condition
                formField(title: "Condition") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: ModaicsLayout.small) {
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
                formField(title: "Size") {
                    HStack(spacing: ModaicsLayout.small) {
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
                                    .font(.modaicsCaption)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(Color.modaicsTextPrimary)
                            .padding(.horizontal, ModaicsLayout.small)
                            .padding(.vertical, ModaicsLayout.tightSpacing)
                            .background(Color.modaicsOatmeal)
                            .cornerRadius(ModaicsLayout.cornerRadiusSmall)
                        }
                        
                        // Size input
                        TextField("e.g., M or 8", text: $viewModel.sizeLabel)
                            .textFieldStyle(ModaicsTextFieldStyle())
                    }
                }
            }
        }
    }
    
    private func formField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: ModaicsLayout.tightSpacing) {
            Text(title)
                .font(.modaicsLabel)
                .foregroundColor(Color.modaicsTextPrimary)
            
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
            Text(condition.displayName)
                .font(.modaicsCaption)
                .foregroundColor(isSelected ? Color.modaicsCream : Color.modaicsTextPrimary)
                .padding(.horizontal, ModaicsLayout.small)
                .padding(.vertical, ModaicsLayout.tightSpacing)
                .background(isSelected ? Color.modaicsTerracotta : Color.modaicsOatmeal)
                .cornerRadius(ModaicsLayout.cornerRadiusSmall)
        }
    }
}

// MARK: - Story Step View

struct StoryStepView: View {
    @ObservedObject var viewModel: TellStoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: ModaicsLayout.large) {
            // Header
            VStack(alignment: .leading, spacing: ModaicsLayout.tightSpacing) {
                Text("The Story")
                    .font(.modaicsHeadingSemiBold)
                    .foregroundColor(Color.modaicsTextPrimary)
                
                Text("This is what makes your garment special. Share its journey.")
                    .font(.modaicsBodyRegular)
                    .foregroundColor(Color.modaicsTextSecondary)
            }
            
            // Form fields
            VStack(alignment: .leading, spacing: ModaicsLayout.medium) {
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
        VStack(alignment: .leading, spacing: ModaicsLayout.large) {
            // Header
            VStack(alignment: .leading, spacing: ModaicsLayout.tightSpacing) {
                Text("How to Exchange")
                    .font(.modaicsHeadingSemiBold)
                    .foregroundColor(Color.modaicsTextPrimary)
                
                Text("Choose how you'd like to find your garment a new home.")
                    .font(.modaicsBodyRegular)
                    .foregroundColor(Color.modaicsTextSecondary)
            }
            
            // Exchange type selection
            VStack(alignment: .leading, spacing: ModaicsLayout.small) {
                Text("Exchange Type")
                    .font(.modaicsLabel)
                    .foregroundColor(Color.modaicsTextPrimary)
                
                VStack(spacing: ModaicsLayout.small) {
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
                VStack(alignment: .leading, spacing: ModaicsLayout.tightSpacing) {
                    Text("Price")
                        .font(.modaicsLabel)
                        .foregroundColor(Color.modaicsTextPrimary)
                    
                    HStack {
                        Text("$")
                            .font(.modaicsBodyLarge)
                            .foregroundColor(Color.modaicsTextPrimary)
                        
                        TextField("0.00", text: $viewModel.price)
                            .keyboardType(.decimalPad)
                            .font(.modaicsBodyLarge)
                    }
                    .padding()
                    .background(Color.modaicsPaper)
                    .cornerRadius(ModaicsLayout.cornerRadiusMedium)
                    
                    if let suggestedPrice = viewModel.suggestedPrice {
                        Text("Suggested: \(suggestedPrice) based on condition")
                            .font(.modaicsFinePrint)
                            .foregroundColor(Color.modaicsSage)
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
            HStack(spacing: ModaicsLayout.small) {
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color.modaicsTerracotta : Color.modaicsTextSecondary)
                    .frame(width: 40)
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.displayName)
                        .font(.modaicsBodyEmphasis)
                        .foregroundColor(Color.modaicsTextPrimary)
                    
                    Text(description)
                        .font(.modaicsCaptionRegular)
                        .foregroundColor(Color.modaicsTextSecondary)
                }
                
                Spacer()
                
                // Selection indicator
                Circle()
                    .stroke(isSelected ? Color.modaicsTerracotta : Color.modaicsOatmeal, lineWidth: 2)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .fill(Color.modaicsTerracotta)
                            .frame(width: 12, height: 12)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding()
            .background(isSelected ? Color.modaicsTerracotta.opacity(0.05) : Color.modaicsPaper)
            .overlay(
                RoundedRectangle(cornerRadius: ModaicsLayout.cornerRadius)
                    .stroke(isSelected ? Color.modaicsTerracotta : Color.clear, lineWidth: 1)
            )
            .cornerRadius(ModaicsLayout.cornerRadius)
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

struct ModaicsTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.modaicsBodyRegular)
            .padding()
            .background(Color.modaicsPaper)
            .cornerRadius(ModaicsLayout.cornerRadiusMedium)
    }
}

// MARK: - Preview

#Preview {
    TellStoryView()
}
