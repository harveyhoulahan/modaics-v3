import SwiftUI

// MARK: - UnifiedCreateView
public struct UnifiedCreateView: View {
    @StateObject private var viewModel = CreateViewModel()
    @State private var showSuccessAlert = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerView
                    
                    switch viewModel.currentStep {
                    case .type:
                        CreationTypeSelector(viewModel: viewModel)
                    case .basic:
                        BasicInfoForm(viewModel: viewModel)
                    case .details:
                        DetailsForm(viewModel: viewModel)
                    case .story:
                        StoryForm(viewModel: viewModel)
                    case .sustainability:
                        SustainabilityForm(viewModel: viewModel)
                    case .review:
                        ReviewForm(viewModel: viewModel)
                    }
                    
                    Spacer().frame(height: 100)
                }
            }
            
            VStack {
                Spacer()
                navigationBar
            }
            .ignoresSafeArea(.keyboard)
        }
        .sheet(isPresented: $viewModel.showSmartCreate) {
            SmartCreateView(viewModel: viewModel)
        }
        .alert("LISTING CREATED", isPresented: $showSuccessAlert) {
            Button("CREATE ANOTHER", role: .none) { viewModel.resetForm() }
            Button("DONE", role: .cancel) {}
        } message: {
            Text("Your item has been successfully listed!")
        }
        .onChange(of: viewModel.submissionSuccess) { oldValue, success in
            if success { showSuccessAlert = true }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text(viewModel.currentStep.title)
                .font(.forestDisplaySmall)
                .foregroundColor(.sageWhite)
                .tracking(2)
                .padding(.top, 20)
            
            if viewModel.currentStep != .type {
                ProgressIndicator(currentStep: viewModel.currentStep)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var navigationBar: some View {
        VStack(spacing: 0) {
            Divider().background(Color.modaicsSurfaceHighlight)
            
            HStack(spacing: 16) {
                if viewModel.currentStep != .type {
                    Button(action: { viewModel.previousStep() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("BACK")
                        }
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                    }
                } else {
                    Spacer()
                }
                
                Spacer()
                
                Button(action: handleNext) {
                    if viewModel.isSubmitting {
                        ProgressView().tint(.modaicsBackground)
                    } else {
                        Text(viewModel.currentStep == .review ? "SUBMIT" : "NEXT")
                            .font(.forestCaptionMedium)
                            .foregroundColor(.modaicsBackground)
                    }
                }
                .disabled(viewModel.isSubmitting || !canProceed)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(canProceed ? Color.luxeGold : Color.luxeGold.opacity(0.3))
                .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.modaicsBackground.opacity(0.95))
        }
    }
    
    private var canProceed: Bool {
        switch viewModel.currentStep {
        case .type: return true
        case .basic: return !viewModel.form.title.isEmpty && !viewModel.form.images.isEmpty
        case .details: return viewModel.form.category != nil && viewModel.form.condition != nil
        case .story: return !viewModel.form.description.isEmpty
        case .sustainability: return true
        case .review: return viewModel.isFormValid
        }
    }
    
    private func handleNext() {
        if viewModel.currentStep == .review {
            Task { try? await viewModel.submit() }
        } else {
            viewModel.nextStep()
        }
    }
}

// MARK: - Progress Indicator
struct ProgressIndicator: View {
    let currentStep: CreateStep
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(CreateStep.allCases.filter { $0 != .type }, id: \.self) { step in
                Circle()
                    .fill(step.rawValue <= currentStep.rawValue ? Color.luxeGold : Color.modaicsSurface)
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - Creation Type Selector (C1)
struct CreationTypeSelector: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            SmartCreateCTA { viewModel.showSmartCreate = true }
                .padding(.horizontal, 20)
            
            HStack(spacing: 16) {
                Rectangle().fill(Color.modaicsSurfaceHighlight).frame(height: 1)
                Text("OR MANUAL").font(.forestCaptionSmall).foregroundColor(.sageMuted)
                Rectangle().fill(Color.modaicsSurfaceHighlight).frame(height: 1)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(CreationType.allCases) { type in
                    CreationTypeCard(type: type, isSelected: viewModel.creationType == type) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.creationType = type
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Smart Create CTA
struct SmartCreateCTA: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "sparkles").font(.system(size: 28))
                    Spacer()
                    Image(systemName: "arrow.right").font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("SMART CREATE").font(.forestHeadlineSmall).foregroundColor(.sageWhite)
                    Text("AI analyzes your photos and auto-fills details")
                        .font(.forestCaptionMedium).foregroundColor(.sageMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .background(LinearGradient(colors: [Color.modaicsSurface, Color.modaicsPrimary], startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.luxeGold.opacity(0.5), lineWidth: 1))
        }
        .foregroundColor(.luxeGold)
    }
}

// MARK: - Creation Type Card
struct CreationTypeCard: View {
    let type: CreationType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(isSelected ? Color.luxeGold.opacity(0.2) : Color.modaicsSurface).frame(width: 48, height: 48)
                    Image(systemName: type.icon).font(.system(size: 20)).foregroundColor(isSelected ? Color.luxeGold : Color.sageMuted)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.rawValue).font(.forestHeadlineSmall).foregroundColor(isSelected ? Color.sageWhite : Color.sageMuted)
                    Text(type.description).font(.forestCaptionSmall).foregroundColor(.sageMuted)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Color.luxeGold : Color.modaicsSurfaceHighlight)
            }
            .padding(16)
            .background(isSelected ? Color.modaicsSurfaceHighlight.opacity(0.5) : Color.modaicsSurface)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.luxeGold.opacity(0.5) : Color.modaicsSurfaceHighlight, lineWidth: 1))
        }
    }
}

// MARK: - Basic Info Form (C2, C3)
struct BasicInfoForm: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            ListingModeSelector(viewModel: viewModel)
            
            ImagePicker(selectedImages: $viewModel.form.images, heroImageIndex: $viewModel.form.heroImageIndex, maxImages: 8)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("TITLE").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                TextField("Enter title", text: $viewModel.form.title)
                    .font(.forestBodyMedium).foregroundColor(.sageWhite)
                    .padding(14).background(Color.modaicsSurface)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.modaicsSurfaceHighlight, lineWidth: 1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            
            if viewModel.form.listingMode == .sell {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PRICE ($)").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                        TextField("0.00", text: $viewModel.form.listingPrice)
                            .font(.forestBodyMedium).foregroundColor(.sageWhite).keyboardType(.decimalPad)
                            .padding(14).background(Color.modaicsSurface)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.luxeGold.opacity(0.5), lineWidth: 1))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ORIGINAL ($)").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                        TextField("0.00", text: $viewModel.form.originalPrice)
                            .font(.forestBodyMedium).foregroundColor(.sageWhite).keyboardType(.decimalPad)
                            .padding(14).background(Color.modaicsSurface)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.modaicsSurfaceHighlight, lineWidth: 1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 12)
    }
}

// MARK: - Listing Mode Selector (C2)
struct ListingModeSelector: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LISTING MODE").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                .padding(.horizontal, 20)
            
            HStack(spacing: 12) {
                ForEach(ListingMode.allCases) { mode in
                    ListingModeButton(mode: mode, isSelected: viewModel.form.listingMode == mode) {
                        viewModel.form.listingMode = mode
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Listing Mode Button
struct ListingModeButton: View {
    let mode: ListingMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon).font(.system(size: 20))
                Text(mode.rawValue).font(.forestCaptionSmall).tracking(0.5)
            }
            .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? Color.clear : Color.modaicsSurfaceHighlight, lineWidth: 1))
        }
    }
}

// MARK: - Details Form (C4)
struct DetailsForm: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("CATEGORY").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(Category.allCases) { category in
                        CategoryButton(category: category, isSelected: viewModel.form.category == category) {
                            viewModel.form.category = category
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("CONDITION").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(Condition.allCases) { condition in
                        CreateConditionButton(condition: condition, isSelected: viewModel.form.condition == condition) {
                            viewModel.form.condition = condition
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("SIZE").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                
                HStack(spacing: 12) {
                    Menu {
                        ForEach(ModaicsSizeSystem.allCases, id: \.self) { system in
                            Button(system.rawValue.uppercased()) { viewModel.form.sizeSystem = system }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.form.sizeSystem.rawValue.uppercased()).font(.forestCaptionSmall)
                            Image(systemName: "chevron.down").font(.system(size: 10))
                        }
                        .foregroundColor(.sageWhite)
                        .padding(.horizontal, 12).padding(.vertical, 14)
                        .background(Color.modaicsSurface)
                        .cornerRadius(8)
                    }
                    
                    TextField("Size (e.g., M, 8, 38)", text: $viewModel.form.sizeLabel)
                        .font(.forestBodyMedium).foregroundColor(.sageWhite)
                        .padding(14).background(Color.modaicsSurface)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.modaicsSurfaceHighlight, lineWidth: 1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("BRAND (OPTIONAL)").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                TextField("Brand name", text: $viewModel.form.brandName)
                    .font(.forestBodyMedium).foregroundColor(.sageWhite)
                    .padding(14).background(Color.modaicsSurface)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.modaicsSurfaceHighlight, lineWidth: 1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("COLORS").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                
                FlowLayout(spacing: 8) {
                    ForEach(ColorOption.all, id: \.id) { color in
                        ColorChip(color: color, isSelected: viewModel.form.selectedColors.contains(color.name)) {
                            if viewModel.form.selectedColors.contains(color.name) {
                                viewModel.removeColor(color.name)
                            } else {
                                viewModel.addColor(color.name)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 12)
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.displayName)
                .font(.forestCaptionSmall).tracking(0.5)
                .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? Color.clear : Color.modaicsSurfaceHighlight, lineWidth: 1))
        }
    }
}

// MARK: - Create Condition Button (renamed to avoid conflict with TellStoryView)
struct CreateConditionButton: View {
    let condition: Condition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(condition.displayName)
                .font(.forestCaptionSmall).tracking(0.5)
                .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? Color.clear : Color.modaicsSurfaceHighlight, lineWidth: 1))
        }
    }
}

// MARK: - Color Chip
struct ColorChip: View {
    let color: ColorOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Circle().fill(Color(hex: color.hex)).frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.5))
                Text(color.name.uppercased()).font(.forestCaptionSmall).tracking(0.5)
            }
            .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color.clear : Color.modaicsSurfaceHighlight, lineWidth: 1))
        }
    }
}

// MARK: - Story Form (C5)
struct StoryForm: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("DESCRIPTION").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                TextEditor(text: $viewModel.form.description)
                    .font(.forestBodyMedium).foregroundColor(.sageWhite)
                    .frame(minHeight: 120)
                    .padding(8).background(Color.modaicsSurface)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.modaicsSurfaceHighlight, lineWidth: 1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("GARMENT STORY").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                    Spacer()
                    Text("OPTIONAL").font(.forestCaptionSmall).foregroundColor(.sageSubtle)
                }
                
                Text("Where did you get this piece? What's its history?").font(.forestCaptionSmall).foregroundColor(.sageSubtle)
                
                TextEditor(text: $viewModel.form.garmentStory)
                    .font(.forestBodyMedium).foregroundColor(.sageWhite)
                    .frame(minHeight: 100)
                    .padding(8).background(Color.modaicsSurface)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.modaicsSurfaceHighlight, lineWidth: 1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 12)
    }
}

// MARK: - Sustainability Form (C6)
struct SustainabilityForm: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            SustainabilityScoreView(score: viewModel.sustainabilityScore)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("MATERIALS").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                    Spacer()
                    Button(action: { viewModel.addMaterial() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("ADD")
                        }
                        .font(.forestCaptionSmall).foregroundColor(.luxeGold)
                    }
                }
                
                ForEach($viewModel.form.materials) { $material in
                    MaterialRow(material: $material, onDelete: {
                        if let index = viewModel.form.materials.firstIndex(where: { $0.id == material.id }) {
                            viewModel.removeMaterial(at: index)
                        }
                    })
                }
                
                if viewModel.form.materials.isEmpty {
                    Text("No materials added. Add materials to improve your sustainability score.")
                        .font(.forestCaptionSmall).foregroundColor(.sageMuted)
                        .padding(.vertical, 20).frame(maxWidth: .infinity)
                        .background(Color.modaicsSurface.opacity(0.5)).cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            
            Toggle(isOn: $viewModel.form.isRecycled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RECYCLED / UPCYCLED").font(.forestCaptionMedium).foregroundColor(.sageWhite)
                    Text("This item contains recycled materials").font(.forestCaptionSmall).foregroundColor(.sageMuted)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.modaicsEco))
            .padding(16).background(Color.modaicsSurface).cornerRadius(8)
            .padding(.horizontal, 20)
            .onChange(of: viewModel.form.isRecycled) { oldValue, newValue in viewModel.calculateSustainabilityScore() }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("CERTIFICATIONS").font(.forestCaptionMedium).foregroundColor(.sageMuted).tracking(1)
                
                FlowLayout(spacing: 8) {
                    ForEach(ModaicsCertification.allCases, id: \.self) { cert in
                        CertificationChip(certification: cert, isSelected: viewModel.form.certifications.contains(cert)) {
                            viewModel.toggleCertification(cert)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 12)
    }
}

// MARK: - Sustainability Score View
struct SustainabilityScoreView: View {
    let score: Int
    
    var color: Color {
        switch score {
        case 80...100: return .modaicsEco
        case 60..<80: return .modaicsFern
        case 40..<60: return .luxeGold
        default: return .sageMuted
        }
    }
    
    var rating: String {
        switch score {
        case 80...100: return "EXCELLENT"
        case 60..<80: return "GOOD"
        case 40..<60: return "AVERAGE"
        default: return "NEEDS IMPROVEMENT"
        }
    }
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle().stroke(color.opacity(0.3), lineWidth: 8).frame(width: 80, height: 80)
                Circle().trim(from: 0, to: CGFloat(score) / 100).stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80).rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(score)").font(.system(size: 28, weight: .bold, design: .monospaced)).foregroundColor(color)
                    Text("/100").font(.system(size: 10, weight: .medium, design: .monospaced)).foregroundColor(.sageMuted)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("SUSTAINABILITY SCORE").font(.forestCaptionSmall).foregroundColor(.sageMuted).tracking(1)
                Text(rating).font(.forestHeadlineSmall).foregroundColor(color)
                Text("Items with higher scores get more visibility").font(.forestCaptionSmall).foregroundColor(.sageSubtle)
            }
            
            Spacer()
        }
        .padding(20).background(Color.modaicsSurface).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.modaicsSurfaceHighlight, lineWidth: 1))
    }
}

// MARK: - Material Row
struct MaterialRow: View {
    @Binding var material: MaterialEntry
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Menu {
                ForEach(MaterialOption.allCases, id: \.self) { option in
                    Button(option.rawValue) {
                        material.name = option.rawValue
                        material.isSustainable = option.isSustainable
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(material.name.isEmpty ? "Select" : material.name).font(.forestBodySmall)
                        .foregroundColor(material.name.isEmpty ? .sageMuted : .sageWhite)
                    Image(systemName: "chevron.down").font(.system(size: 10)).foregroundColor(.sageMuted)
                }
                .frame(width: 100).padding(10).background(Color.modaicsBackground).cornerRadius(6)
            }
            
            HStack(spacing: 2) {
                TextField("100", value: $material.percentage, format: .number)
                    .font(.forestBodySmall).foregroundColor(.sageWhite).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                Text("%").font(.forestBodySmall).foregroundColor(.sageMuted)
            }
            .frame(width: 60).padding(10).background(Color.modaicsBackground).cornerRadius(6)
            
            if material.isSustainable {
                Image(systemName: "leaf.fill").font(.system(size: 14)).foregroundColor(.modaicsEco)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundColor(.sageMuted)
                    .frame(width: 28, height: 28).background(Color.modaicsBackground).cornerRadius(6)
            }
        }
        .padding(12).background(Color.modaicsSurface).cornerRadius(8)
    }
}

// MARK: - Certification Chip
struct CertificationChip: View {
    let certification: ModaicsCertification
    let isSelected: Bool
    let action: () -> Void
    
    var displayName: String {
        switch certification {
        case .organic: return "ORGANIC"
        case .fairTrade: return "FAIR TRADE"
        case .recycled: return "RECYCLED"
        case .vegan: return "VEGAN"
        case .carbonNeutral: return "CARBON NEUTRAL"
        case .bCorp: return "B-CORP"
        case .gots: return "GOTS"
        case .oekoTex: return "OEKO-TEX"
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(displayName).font(.forestCaptionSmall).tracking(0.5)
                .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color.clear : Color.modaicsSurfaceHighlight, lineWidth: 1))
        }
    }
}

// MARK: - Review Form (C7)
struct ReviewForm: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            if !viewModel.validationErrors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("PLEASE FIX THE FOLLOWING:").font(.forestCaptionMedium).foregroundColor(.modaicsError)
                    ForEach(viewModel.validationErrors, id: \.self) { error in
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle").foregroundColor(.modaicsError)
                            Text(error.localizedDescription ?? "Unknown error").font(.forestCaptionSmall).foregroundColor(.modaicsError)
                        }
                    }
                }
                .padding(16).background(Color.modaicsError.opacity(0.1)).cornerRadius(8)
                .padding(.horizontal, 20)
            }
            
            PreviewCard(images: viewModel.form.images, title: viewModel.form.title, category: viewModel.form.category, price: viewModel.form.listingPriceDecimal as Decimal?, condition: viewModel.form.condition)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                ReviewSection(title: "LISTING TYPE") {
                    HStack {
                        Image(systemName: viewModel.form.listingMode.icon)
                        Text(viewModel.form.listingMode.rawValue).font(.forestBodyMedium)
                    }
                    .foregroundColor(.sageWhite)
                }
                
                ReviewSection(title: "DETAILS") {
                    VStack(alignment: .leading, spacing: 8) {
                        let categoryDisplayName: String = viewModel.form.category?.displayName ?? "Not set"
                        let conditionDisplayName: String = viewModel.form.condition?.displayName ?? "Not set"
                        ReviewRow(label: "Category", value: categoryDisplayName)
                        ReviewRow(label: "Condition", value: conditionDisplayName)
                        ReviewRow(label: "Size", value: "\(viewModel.form.sizeSystem.rawValue.uppercased()) \(viewModel.form.sizeLabel)")
                        if !viewModel.form.brandName.isEmpty {
                            ReviewRow(label: "Brand", value: viewModel.form.brandName)
                        }
                        if !viewModel.form.selectedColors.isEmpty {
                            ReviewRow(label: "Colors", value: viewModel.form.selectedColors.joined(separator: ", "))
                        }
                    }
                }
                
                ReviewSection(title: "SUSTAINABILITY") {
                    HStack(spacing: 8) {
                        Image(systemName: "leaf.fill").foregroundColor(.modaicsEco)
                        Text("Score: \(viewModel.sustainabilityScore)/100").font(.forestBodyMedium).foregroundColor(.sageWhite)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 12)
        .onAppear { viewModel.validate() }
    }
}

// MARK: - Review Section
struct ReviewSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.forestCaptionSmall).foregroundColor(.sageMuted).tracking(1)
            content
        }
    }
}

// MARK: - Review Row
struct ReviewRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label).font(.forestCaptionSmall).foregroundColor(.sageMuted)
            Spacer()
            Text(value).font(.forestBodySmall).foregroundColor(.sageWhite).multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Flow Layout (Shared Component)
// Used by both UnifiedCreateView and FilterView
public struct FlowLayout: Layout {
    public var spacing: CGFloat = 8
    
    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + rowHeight
        }
    }
}
