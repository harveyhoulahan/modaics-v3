import SwiftUI
import PhotosUI

// MARK: - Story Step

public enum StoryStep: Int, CaseIterable {
    case photos = 1
    case basics = 2
    case story = 3
    case exchange = 4
    
    var title: String {
        switch self {
        case .photos: return "Photos"
        case .basics: return "The Basics"
        case .story: return "The Story"
        case .exchange: return "Exchange"
        }
    }
    
    var subtitle: String {
        switch self {
        case .photos: return "Capture the essence"
        case .basics: return "The details that matter"
        case .story: return "Where it came from"
        case .exchange: return "How to find it a home"
        }
    }
}

// MARK: - Tell Story View
// Multi-step garment narrative input
// Kinfolk magazine aesthetic - warm, intentional, unhurried

public struct TellStoryView: View {
    @StateObject private var viewModel: StoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: StoryViewModel = StoryViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                MosaicColors.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Header
                    progressHeader
                    
                    // Step Content
                    ScrollView {
                        stepContent
                            .padding(.horizontal, MosaicLayout.marginGenerous)
                            .padding(.vertical, MosaicLayout.groupSpacing)
                    }
                    
                    // Navigation Footer
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
                    .foregroundColor(MosaicColors.textSecondary)
                }
                
                if viewModel.currentStep == .exchange {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Publish") {
                            Task {
                                await viewModel.publish()
                            }
                        }
                        .foregroundColor(MosaicColors.terracotta)
                        .fontWeight(.medium)
                        .disabled(!viewModel.canPublish)
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $viewModel.showPhotoPicker) {
                PhotoPicker(selectedItems: $viewModel.selectedPhotos)
            }
            .overlay {
                if viewModel.isPublishing {
                    publishingOverlay
                }
            }
        }
    }
    
    // MARK: - Progress Header
    
    private var progressHeader: some View {
        VStack(spacing: MosaicLayout.tightSpacing) {
            // Step Indicators
            HStack(spacing: MosaicLayout.itemSpacing) {
                ForEach(StoryStep.allCases, id: \.self) { step in
                    StepIndicator(
                        step: step,
                        isActive: step == viewModel.currentStep,
                        isCompleted: step.rawValue < viewModel.currentStep.rawValue
                    )
                }
            }
            .padding(.horizontal, MosaicLayout.marginGenerous)
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(MosaicColors.oatmeal)
                        .frame(height: 2)
                    
                    Rectangle()
                        .fill(MosaicColors.terracotta)
                        .frame(
                            width: geo.size.width * viewModel.progressPercentage,
                            height: 2
                        )
                }
            }
            .frame(height: 2)
            
            // Step Title
            VStack(spacing: MosaicLayout.microSpacing) {
                Text(viewModel.currentStep.title)
                    .font(MosaicTypography.headline)
                    .foregroundColor(MosaicColors.textPrimary)
                
                Text(viewModel.currentStep.subtitle)
                    .font(MosaicTypography.caption)
                    .foregroundColor(MosaicColors.textSecondary)
            }
            .padding(.top, MosaicLayout.itemSpacing)
        }
        .padding(.vertical, MosaicLayout.itemSpacing)
        .background(MosaicColors.cream)
    }
    
    // MARK: - Step Content
    
    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .photos:
            PhotoStepView(viewModel: viewModel)
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
        HStack(spacing: MosaicLayout.itemSpacing) {
            // Back Button
            if viewModel.currentStep != .photos {
                MosaicButton("Back", style: .subtle, size: .medium) {
                    viewModel.previousStep()
                }
            }
            
            Spacer()
            
            // Next Button
            if viewModel.currentStep != .exchange {
                MosaicButton("Continue", style: .primary, size: .medium) {
                    viewModel.nextStep()
                }
            } else {
                MosaicButton("Publish Story", style: .primary, size: .large) {
                    Task {
                        await viewModel.publish()
                    }
                }
                .disabled(!viewModel.canPublish)
            }
        }
        .padding(.horizontal, MosaicLayout.margin)
        .padding(.vertical, MosaicLayout.itemSpacing)
        .background(MosaicColors.cream)
    }
    
    // MARK: - Publishing Overlay
    
    private var publishingOverlay: some View {
        ZStack {
            MosaicColors.charcoalClay.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: MosaicLayout.groupSpacing) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(MosaicColors.terracotta)
                
                Text("Publishing your story...")
                    .font(MosaicTypography.body)
                    .foregroundColor(MosaicColors.textPrimary)
            }
            .padding(MosaicLayout.marginGenerous)
            .background(MosaicColors.cream)
            .cornerRadius(MosaicLayout.cornerRadius)
        }
    }
}

// MARK: - Step Indicator

struct StepIndicator: View {
    let step: StoryStep
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: MosaicLayout.tightSpacing) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 32, height: 32)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(MosaicColors.cream)
                } else {
                    Text("\(step.rawValue)")
                        .font(MosaicTypography.label)
                        .foregroundColor(foregroundColor)
                }
            }
            
            Text(step.title)
                .font(MosaicTypography.finePrint)
                .foregroundColor(textColor)
        }
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return MosaicColors.deepOlive
        } else if isActive {
            return MosaicColors.terracotta
        } else {
            return MosaicColors.oatmeal
        }
    }
    
    private var foregroundColor: Color {
        isActive ? MosaicColors.cream : MosaicColors.textSecondary
    }
    
    private var textColor: Color {
        if isActive || isCompleted {
            return MosaicColors.textPrimary
        } else {
            return MosaicColors.textTertiary
        }
    }
}

// MARK: - Photo Picker

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedItems: [PhotosPickerItem]
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 10
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            // Handle selected items
        }
    }
}

// MARK: - Preview

#Preview {
    TellStoryView()
}