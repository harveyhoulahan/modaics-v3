import SwiftUI

// MARK: - UnifiedCreateView
/// Single scrollable page with all fields - NO WIZARD
public struct UnifiedCreateView: View {
    @StateObject private var viewModel = CreateViewModel()
    @State private var showSuccessAlert = false
    @State private var scrollOffset: CGFloat = 0
    
    private let headerHeight: CGFloat = 80
    private let collapsedThreshold: CGFloat = 40
    
    private var headerCollapseProgress: CGFloat {
        let progress = min(1, max(0, scrollOffset / collapsedThreshold))
        return progress
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                // Scroll offset tracker
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: CreateScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("createScroll")).minY)
                }
                .frame(height: 0)
                
                VStack(spacing: 32) {
                    // Collapsable Header
                    createHeader
                    
                    // HERO: Smart Create CTA (Gold gradient, biggest element)
                    HeroSmartCreateCard {
                        viewModel.showSmartCreate = true
                    }
                    .padding(.horizontal, 20)
                    
                    // Divider with "OR MANUAL" text
                    ManualDivider()
                        .padding(.horizontal, 20)
                    
                    // MARK: - Images Section
                    ImageUploadRow(
                        images: $viewModel.form.images,
                        heroImageIndex: $viewModel.form.heroImageIndex,
                        maxImages: 8
                    )
                    .padding(.horizontal, 20)
                    
                    // MARK: - Listing Mode Selector
                    ListingModeSection(viewModel: viewModel)
                        .padding(.horizontal, 20)
                    
                    // MARK: - Basic Info Section
                    BasicInfoSection(viewModel: viewModel)
                        .padding(.horizontal, 20)
                    
                    // MARK: - Details Section (Category, Size, Condition)
                    DetailsSection(viewModel: viewModel)
                        .padding(.horizontal, 20)
                    
                    // MARK: - Description Section
                    DescriptionSection(viewModel: viewModel)
                        .padding(.horizontal, 20)
                    
                    // MARK: - Garment Story Section (with book icon)
                    GarmentStorySection(viewModel: viewModel)
                        .padding(.horizontal, 20)
                    
                    // MARK: - Sustainability Section
                    SustainabilitySection(viewModel: viewModel)
                        .padding(.horizontal, 20)
                    
                    // MARK: - Submit Button (Full width at bottom)
                    SubmitSection(viewModel: viewModel) {
                        Task {
                            try? await viewModel.submit()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .coordinateSpace(name: "createScroll")
            .onPreferenceChange(CreateScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
            }
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
        .onChange(of: viewModel.submissionSuccess) { _, success in
            if success { showSuccessAlert = true }
        }
    }
    
    // MARK: - Collapsable Header
    private var createHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("CREATE")
                    .font(.forestDisplaySmall)
                    .foregroundColor(.sageWhite)
                    .tracking(2)
                
                Spacer()
                
                // Help button
                Button(action: {}) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.sageMuted)
                }
            }
            
            Text("List a piece or let AI do it")
                .font(.forestCaptionMedium)
                .foregroundColor(.sageMuted)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(Color.modaicsBackground)
        // Collapse animation
        .frame(height: headerHeight * (1 - headerCollapseProgress * 0.5))
        .opacity(1 - headerCollapseProgress)
        .clipped()
    }
}

// MARK: - Scroll Offset Preference Key
struct CreateScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Hero Smart Create Card
/// Big, prominent, gold gradient card - the HERO element
struct HeroSmartCreateCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 20) {
                // Top row: Icon and arrow
                HStack {
                    // Sparkle icon with glow effect
                    ZStack {
                        Circle()
                            .fill(Color.luxeGold.opacity(0.2))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.luxeGold)
                    }
                    
                    Spacer()
                    
                    // Arrow indicator
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.luxeGold)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text("SMART CREATE")
                        .font(.forestDisplaySmall)
                        .foregroundColor(.sageWhite)
                        .tracking(2)
                    
                    Text("AI analyzes your photos and auto-fills details")
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageMuted)
                        .multilineTextAlignment(.leading)
                }
                
                // Bottom badge row
                HStack(spacing: 8) {
                    SmartBadge(icon: "bolt.fill", text: "INSTANT")
                    SmartBadge(icon: "wand.and.stars", text: "AI-POWERED")
                    SmartBadge(icon: "checkmark.shield", text: "ACCURATE")
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "2A2415"),  // Dark gold
                        Color(hex: "1A1810"),  // Near black with gold undertone
                        Color.modaicsSurface
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.luxeGold.opacity(0.6), .luxeGold.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Smart Badge
struct SmartBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.forestCaptionSmall)
                .tracking(0.5)
        }
        .foregroundColor(.luxeGold.opacity(0.9))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.luxeGold.opacity(0.15))
        .overlay(
            Capsule()
                .stroke(Color.luxeGold.opacity(0.3), lineWidth: 0.5)
        )
        .clipShape(Capsule())
    }
}

// MARK: - Manual Divider
struct ManualDivider: View {
    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(Color.modaicsSurfaceHighlight)
                .frame(height: 1)
            
            Text("OR MANUAL")
                .font(.forestCaptionSmall)
                .foregroundColor(.sageMuted)
                .tracking(1)
            
            Rectangle()
                .fill(Color.modaicsSurfaceHighlight)
                .frame(height: 1)
        }
    }
}

// MARK: - Listing Mode Section
struct ListingModeSection: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "LISTING MODE",
                icon: "tag.fill",
                subtitle: "Choose how you want to list this item"
            )
            
            HStack(spacing: 12) {
                ForEach(ListingMode.allCases) { mode in
                    ListingModeButton(
                        mode: mode,
                        isSelected: viewModel.form.listingMode == mode
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.form.listingMode = mode
                        }
                    }
                }
            }
            
            // Dynamic price fields based on mode
            if viewModel.form.listingMode == .sell {
                HStack(spacing: 16) {
                    PriceField(
                        title: "Listing Price",
                        placeholder: "0.00",
                        text: $viewModel.form.listingPrice,
                        isRequired: true
                    )
                    
                    PriceField(
                        title: "Original Price",
                        placeholder: "0.00",
                        text: $viewModel.form.originalPrice,
                        isRequired: false
                    )
                }
            } else if viewModel.form.listingMode == .rent {
                PriceField(
                    title: "Daily Rate",
                    placeholder: "0.00",
                    text: $viewModel.form.listingPrice,
                    isRequired: true
                )
            }
            // Swap mode shows no price fields
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
                Image(systemName: mode.icon)
                    .font(.system(size: 24))
                Text(mode.rawValue)
                    .font(.forestCaptionMedium)
                    .tracking(0.5)
            }
            .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.modaicsSurfaceHighlight, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Basic Info Section
struct BasicInfoSection: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "BASIC INFO",
                icon: "doc.text.fill"
            )
            
            FormField(
                title: "Title",
                placeholder: "e.g., Vintage Leather Jacket",
                text: $viewModel.form.title,
                isRequired: true
            )
            
            FormField(
                title: "Brand",
                placeholder: "e.g., Gucci, Nike, Vintage",
                text: $viewModel.form.brandName,
                isRequired: false
            )
        }
    }
}

// MARK: - Details Section
struct DetailsSection: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(
                title: "DETAILS",
                icon: "slider.horizontal.3"
            )
            
            // Category Grid
            VStack(alignment: .leading, spacing: 12) {
                Text("CATEGORY")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(Category.allCases) { category in
                        CategoryPill(
                            category: category,
                            isSelected: viewModel.form.category == category
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.form.category = category
                            }
                        }
                    }
                }
            }
            
            // Size Section
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
                    Text("SIZE")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                        .tracking(1)
                    Text("*")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.luxeGold)
                }
                
                HStack(spacing: 12) {
                    // Size system picker
                    Menu {
                        ForEach(ModaicsSizeSystem.allCases, id: \.self) { system in
                            Button(system.rawValue.uppercased()) {
                                viewModel.form.sizeSystem = system
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.form.sizeSystem.rawValue.uppercased())
                                .font(.forestCaptionMedium)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.sageWhite)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.modaicsSurface)
                        .cornerRadius(8)
                    }
                    
                    // Size input
                    TextField("e.g., M, 8, 38", text: $viewModel.form.sizeLabel)
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageWhite)
                        .padding(14)
                        .background(Color.modaicsSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
            }
            
            // Condition Grid
            VStack(alignment: .leading, spacing: 12) {
                Text("CONDITION")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(Condition.allCases) { condition in
                        ConditionPill(
                            condition: condition,
                            isSelected: viewModel.form.condition == condition
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.form.condition = condition
                                viewModel.calculateSustainabilityScore()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.displayName.uppercased())
                .font(.forestCaptionSmall)
                .tracking(0.5)
                .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.clear : Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Condition Pill
struct ConditionPill: View {
    let condition: Condition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(condition.displayName.uppercased())
                .font(.forestCaptionSmall)
                .tracking(0.5)
                .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.clear : Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Description Section
struct DescriptionSection: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "DESCRIPTION",
                icon: "text.alignleft",
                subtitle: "Describe your item's features, fit, and style"
            )
            
            TextAreaField(
                title: "Description",
                placeholder: "Tell buyers about your item...",
                text: $viewModel.form.description,
                minHeight: 120,
                isRequired: true
            )
        }
    }
}

// MARK: - Garment Story Section (with book icon)
struct GarmentStorySection: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "GARMENT STORY",
                icon: "book.fill",
                subtitle: "Where did you get this piece? What's its history? (Optional)"
            )
            
            TextEditor(text: $viewModel.form.garmentStory)
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color.modaicsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
                .cornerRadius(8)
        }
    }
}

// MARK: - Sustainability Section
struct SustainabilitySection: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(
                title: "SUSTAINABILITY",
                icon: "leaf.fill",
                subtitle: "Help buyers understand the environmental impact"
            )
            
            // Score display
            SustainabilityScoreCard(score: viewModel.sustainabilityScore)
            
            // Materials
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("MATERIALS")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                        .tracking(1)
                    
                    Spacer()
                    
                    Button(action: { viewModel.addMaterial() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("ADD")
                        }
                        .font(.forestCaptionSmall)
                        .foregroundColor(.luxeGold)
                    }
                }
                
                if viewModel.form.materials.isEmpty {
                    Text("No materials added. Add materials to improve your sustainability score.")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageMuted)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color.modaicsSurface.opacity(0.5))
                        .cornerRadius(8)
                } else {
                    ForEach($viewModel.form.materials) { $material in
                        MaterialEntryRow(
                            material: $material,
                            onDelete: {
                                if let index = viewModel.form.materials.firstIndex(where: { $0.id == material.id }) {
                                    viewModel.removeMaterial(at: index)
                                }
                            }
                        )
                    }
                }
            }
            
            // Recycled toggle
            Toggle(isOn: $viewModel.form.isRecycled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RECYCLED / UPCYCLED")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageWhite)
                    Text("This item contains recycled materials")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageMuted)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.modaicsEco))
            .padding(16)
            .background(Color.modaicsSurface)
            .cornerRadius(12)
            .onChange(of: viewModel.form.isRecycled) { _, _ in
                viewModel.calculateSustainabilityScore()
            }
            
            // Certifications
            VStack(alignment: .leading, spacing: 12) {
                Text("CERTIFICATIONS")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
                
                FlowLayout(spacing: 8) {
                    ForEach(ModaicsCertification.allCases, id: \.self) { cert in
                        CertificationChip(
                            certification: cert,
                            isSelected: viewModel.form.certifications.contains(cert)
                        ) {
                            viewModel.toggleCertification(cert)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Sustainability Score Card
struct SustainabilityScoreCard: View {
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
            // Circular progress
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)
                    .frame(width: 72, height: 72)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(score)")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(color)
                    Text("/100")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.sageMuted)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("SUSTAINABILITY SCORE")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
                Text(rating)
                    .font(.forestHeadlineSmall)
                    .foregroundColor(color)
                Text("Items with higher scores get more visibility")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageSubtle)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.modaicsSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
        )
    }
}

// MARK: - Material Entry Row
struct MaterialEntryRow: View {
    @Binding var material: MaterialEntry
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Material picker
            Menu {
                ForEach(MaterialOption.allCases, id: \.self) { option in
                    Button(option.rawValue) {
                        material.name = option.rawValue
                        material.isSustainable = option.isSustainable
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(material.name.isEmpty ? "Select" : material.name)
                        .font(.forestBodySmall)
                        .foregroundColor(material.name.isEmpty ? .sageMuted : .sageWhite)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.sageMuted)
                }
                .frame(width: 100)
                .padding(10)
                .background(Color.modaicsBackground)
                .cornerRadius(6)
            }
            
            // Percentage input
            HStack(spacing: 2) {
                TextField("100", value: $material.percentage, format: .number)
                    .font(.forestBodySmall)
                    .foregroundColor(.sageWhite)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                Text("%")
                    .font(.forestBodySmall)
                    .foregroundColor(.sageMuted)
            }
            .frame(width: 60)
            .padding(10)
            .background(Color.modaicsBackground)
            .cornerRadius(6)
            
            // Sustainable indicator
            if material.isSustainable {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.modaicsEco)
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.sageMuted)
                    .frame(width: 28, height: 28)
                    .background(Color.modaicsBackground)
                    .cornerRadius(6)
            }
        }
        .padding(12)
        .background(Color.modaicsSurface)
        .cornerRadius(8)
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
            Text(displayName)
                .font(.forestCaptionSmall)
                .tracking(0.5)
                .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.clear : Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Submit Section
struct SubmitSection: View {
    @ObservedObject var viewModel: CreateViewModel
    let action: () -> Void
    
    var isValid: Bool {
        !viewModel.form.title.isEmpty &&
        !viewModel.form.description.isEmpty &&
        viewModel.form.category != nil &&
        viewModel.form.condition != nil &&
        !viewModel.form.images.isEmpty &&
        !viewModel.form.sizeLabel.isEmpty &&
        (viewModel.form.listingMode == .swap || !viewModel.form.listingPrice.isEmpty)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Validation errors
            if !viewModel.validationErrors.isEmpty && !isValid {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.validationErrors, id: \.self) { error in
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.modaicsError)
                            Text(error.localizedDescription)
                                .font(.forestCaptionSmall)
                                .foregroundColor(.modaicsError)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.modaicsError.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Submit button
            Button(action: {
                viewModel.validate()
                if isValid {
                    action()
                }
            }) {
                if viewModel.isSubmitting {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.modaicsBackground)
                        Text("SUBMITTING...")
                            .font(.forestBodyMedium)
                            .foregroundColor(.modaicsBackground)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.luxeGold)
                    .cornerRadius(12)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("CREATE LISTING")
                            .font(.forestBodyMedium)
                            .tracking(1)
                    }
                    .foregroundColor(isValid ? .modaicsBackground : .sageMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(isValid ? Color.luxeGold : Color.modaicsSurface)
                    .cornerRadius(12)
                }
            }
            .disabled(!isValid || viewModel.isSubmitting)
        }
    }
}
