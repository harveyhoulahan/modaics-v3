import SwiftUI
import PhotosUI

// MARK: - Create View
/// Multi-step form to list a new item (photos, details, story, pricing)
struct CreateView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep: CreateStep = .photos
    @State private var selectedImages: [UIImage] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.modaicsDarkNavy
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("LIST ITEM")
                            .font(.modaicsHeadline2)
                            .foregroundColor(.modaicsTextWhite)
                        Spacer()
                        Button("Cancel") {
                            appState.selectTab(.home)
                        }
                        .font(.modaicsBodyEmphasis)
                        .foregroundColor(.modaicsSilver)
                    }
                    .padding()
                    
                    // Progress Steps
                    HStack(spacing: 8) {
                        ForEach(CreateStep.allCases) { step in
                            StepIndicator(
                                step: step,
                                isActive: step == currentStep,
                                isCompleted: step.rawValue < currentStep.rawValue
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Content Area
                    ScrollView {
                        VStack(spacing: 24) {
                            switch currentStep {
                            case .photos:
                                PhotosStepView(selectedImages: $selectedImages)
                            case .details:
                                DetailsStepView()
                            case .story:
                                StoryStepView()
                            case .pricing:
                                PricingStepView()
                            }
                        }
                        .padding()
                    }
                    
                    // Bottom Navigation
                    HStack {
                        if currentStep != .photos {
                            Button("BACK") {
                                withAnimation {
                                    currentStep = CreateStep(rawValue: currentStep.rawValue - 1) ?? .photos
                                }
                            }
                            .font(.modaicsButton)
                            .foregroundColor(.modaicsSilver)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                if currentStep == .pricing {
                                    // Submit item
                                    appState.selectTab(.home)
                                    currentStep = .photos
                                } else {
                                    currentStep = CreateStep(rawValue: currentStep.rawValue + 1) ?? .pricing
                                }
                            }
                        }) {
                            Text(currentStep == .pricing ? "LIST ITEM" : "NEXT")
                                .font(.modaicsButton)
                                .foregroundColor(.modaicsDarkBlue)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 14)
                                .background(Color.modaicsIndustrialRed)
                                .cornerRadius(4)
                        }
                    }
                    .padding()
                    .background(Color.modaicsDarkBlue)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Create Steps
enum CreateStep: Int, CaseIterable, Identifiable {
    case photos = 0
    case details = 1
    case story = 2
    case pricing = 3
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .photos: return "PHOTOS"
        case .details: return "DETAILS"
        case .story: return "STORY"
        case .pricing: return "PRICING"
        }
    }
}

// MARK: - Step Indicator
struct StepIndicator: View {
    let step: CreateStep
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(backgroundColor)
                .frame(width: 32, height: 32)
                .overlay(
                    Group {
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.modaicsDarkBlue)
                        } else {
                            Text("\(step.rawValue + 1)")
                                .font(.modaicsFinePrint)
                                .foregroundColor(textColor)
                        }
                    }
                )
            
            Text(step.title)
                .font(.modaicsMicro)
                .foregroundColor(isActive ? .modaicsIndustrialRed : .modaicsTextMedium)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var backgroundColor: Color {
        if isCompleted { return .modaicsSuccessGreen }
        if isActive { return .modaicsIndustrialRed }
        return .modaicsPanelBlue
    }
    
    private var textColor: Color {
        if isActive { return .modaicsTextWhite }
        return .modaicsTextMedium
    }
}

// MARK: - Step Views
struct PhotosStepView: View {
    @Binding var selectedImages: [UIImage]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Photos")
                .font(.modaicsHeadline3)
                .foregroundColor(.modaicsTextWhite)
            
            // Photo Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(0..<6) { i in
                    if i < selectedImages.count {
                        Image(uiImage: selectedImages[i])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Button(action: {}) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.modaicsPanelBlue)
                                .frame(height: 100)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 24))
                                        .foregroundColor(.modaicsSilver)
                                )
                        }
                    }
                }
            }
            
            Text("Add up to 6 photos of your item")
                .font(.modaicsCaption)
                .foregroundColor(.modaicsTextMedium)
        }
    }
}

struct DetailsStepView: View {
    @State private var title = ""
    @State private var category = ""
    @State private var size = ""
    @State private var condition = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Item Details")
                .font(.modaicsHeadline3)
                .foregroundColor(.modaicsTextWhite)
            
            VStack(spacing: 16) {
                TextField("Title", text: $title)
                    .textFieldStyle(IndustrialTextFieldStyle())
                
                TextField("Category", text: $category)
                    .textFieldStyle(IndustrialTextFieldStyle())
                
                TextField("Size", text: $size)
                    .textFieldStyle(IndustrialTextFieldStyle())
                
                TextField("Condition", text: $condition)
                    .textFieldStyle(IndustrialTextFieldStyle())
            }
        }
    }
}

struct StoryStepView: View {
    @State private var story = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tell Your Story")
                .font(.modaicsHeadline3)
                .foregroundColor(.modaicsTextWhite)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.modaicsPanelBlue)
                    .frame(height: 200)
                
                TextEditor(text: $story)
                    .font(.modaicsBodyRegular)
                    .foregroundColor(.modaicsTextWhite)
                    .padding(12)
                    .frame(height: 200)
                    .scrollContentBackground(.hidden)
            }
            
            Text("Share the history and significance of this piece")
                .font(.modaicsCaption)
                .foregroundColor(.modaicsTextMedium)
        }
    }
}

struct PricingStepView: View {
    @State private var price = ""
    @State private var allowSwap = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Set Your Price")
                .font(.modaicsHeadline3)
                .foregroundColor(.modaicsTextWhite)
            
            HStack {
                Text("$")
                    .font(.modaicsDisplaySmall)
                    .foregroundColor(.modaicsTextWhite)
                
                TextField("0.00", text: $price)
                    .font(.modaicsDisplaySmall)
                    .foregroundColor(.modaicsTextWhite)
                    .keyboardType(.decimalPad)
            }
            .padding()
            .background(Color.modaicsPanelBlue)
            .cornerRadius(8)
            
            Toggle("Accept Swap Offers", isOn: $allowSwap)
                .font(.modaicsBodyRegular)
                .foregroundColor(.modaicsTextWhite)
                .tint(.modaicsIndustrialRed)
        }
    }
}

// MARK: - Industrial Text Field Style
struct IndustrialTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.modaicsBodyRegular)
            .foregroundColor(.modaicsTextWhite)
            .padding(14)
            .background(Color.modaicsPanelBlue)
            .cornerRadius(8)
    }
}

// MARK: - Preview
struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView()
            .environmentObject(AppState())
    }
}
