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
            Color.canvas.ignoresSafeArea()
            
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
                    
                    // HERO: The Studio card
                    TheStudioCard {
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
        .alert("Listed successfully", isPresented: $showSuccessAlert) {
            Button("Create another", role: .none) { viewModel.resetForm() }
            Button("Done", role: .cancel) {}
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
                Text("Create")
                    .font(.displayL)
                    .foregroundColor(.inkPrimary)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.inkMuted)
                }
            }

            Text("List a piece. We'll handle the rest.")
                .font(.bodyM)
                .foregroundColor(.inkSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(Color.canvas)
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

// MARK: - The Studio Card
/// Simple, elegant card - the HERO element
struct TheStudioCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text("The Studio")
                    .font(.editorialSmall)
                    .foregroundColor(.nearBlack)
                
                // Subtitle
                Text("Snap a photo. We'll fill in the details.")
                    .font(.bodyM)
                    .foregroundColor(.inkSecondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.canvasSecond)
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.hairline, lineWidth: 0.5)
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
                .fill(Color.warmDivider)
                .frame(height: 0.5)
            
            Text("or list manually")
                .font(.captionSmall)
                .foregroundColor(.mutedGray)
            
            Rectangle()
                .fill(Color.warmDivider)
                .frame(height: 0.5)
        }
    }
}

// MARK: - Listing Mode Section
struct ListingModeSection: View {
    @ObservedObject var viewModel: CreateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("How would you like to list this?")

            VStack(spacing: 0) {
                ForEach(ListingMode.allCases) { mode in
                    ListingModeButton(
                        mode: mode,
                        isSelected: viewModel.form.listingMode == mode
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.form.listingMode = mode
                        }
                    }
                    if mode != ListingMode.allCases.last {
                        Rectangle().fill(Color.hairline).frame(height: 0.5)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.hairline, lineWidth: 0.5)
            )

            if viewModel.form.listingMode == .sell {
                HStack(spacing: 16) {
                    PriceField(title: "Listing price", placeholder: "0.00",
                               text: $viewModel.form.listingPrice, isRequired: true)
                    PriceField(title: "Original price", placeholder: "0.00",
                               text: $viewModel.form.originalPrice, isRequired: false)
                }
            } else if viewModel.form.listingMode == .rent {
                PriceField(title: "Daily rate", placeholder: "0.00",
                           text: $viewModel.form.listingPrice, isRequired: true)
            }
        }
    }
}

// MARK: - Listing Mode Button
struct ListingModeButton: View {
    let mode: ListingMode
    let isSelected: Bool
    let action: () -> Void
    
    var displayText: String {
        switch mode {
        case .sell: return "Sell a piece"
        case .rent: return "List for rent"
        case .swap: return "Offer swap"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(displayText)
                    .font(.bodyMedium)
                    .foregroundColor(.nearBlack)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.nearBlack)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color.ivory)
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(isSelected ? Color.warmDivider : Color.clear, lineWidth: 0.5)
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
            SectionLabel("Basic info")
            FormField(title: "Title", placeholder: "e.g., Vintage Leather Jacket",
                      text: $viewModel.form.title, isRequired: true)
            FormField(title: "Brand", placeholder: "e.g., Gucci, Nike, Vintage",
                      text: $viewModel.form.brandName, isRequired: false)
        }
    }
}

// MARK: - Details Section
struct DetailsSection: View {
    @ObservedObject var viewModel: CreateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionLabel("Details")

            // Category
            VStack(alignment: .leading, spacing: 12) {
                Text("Category")
                    .font(.labelM)
                    .foregroundColor(.inkSecondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(Category.allCases) { category in
                        CategoryPill(category: category,
                                     isSelected: viewModel.form.category == category) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.form.category = category
                            }
                        }
                    }
                }
            }

            // Size
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
                    Text("Size")
                        .font(.labelM)
                        .foregroundColor(.inkSecondary)
                    Text("*")
                        .font(.labelM)
                        .foregroundColor(.brass)
                }
                HStack(spacing: 12) {
                    Menu {
                        ForEach(ModaicsSizeSystem.allCases, id: \.self) { system in
                            Button(system.rawValue.uppercased()) {
                                viewModel.form.sizeSystem = system
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.form.sizeSystem.rawValue.uppercased())
                                .font(.labelM)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .light))
                        }
                        .foregroundColor(.inkPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.canvasSecond)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.hairline, lineWidth: 0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                    }

                    TextField("e.g., M, 8, 38", text: $viewModel.form.sizeLabel)
                        .font(.bodyM)
                        .foregroundColor(.inkPrimary)
                        .padding(14)
                        .background(Color.canvasSecond)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.hairline, lineWidth: 0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                }
            }

            // Condition
            VStack(alignment: .leading, spacing: 12) {
                Text("Condition")
                    .font(.labelM)
                    .foregroundColor(.inkSecondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(Condition.allCases) { condition in
                        ConditionPill(condition: condition,
                                      isSelected: viewModel.form.condition == condition) {
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

// MARK: - Category Pill (light editorial)
struct CategoryPill: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(category.displayName)
                    .font(.bodyS)
                    .foregroundColor(isSelected ? .inkPrimary : .inkSecondary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.brass)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(isSelected ? Color.canvasSecond : Color.canvas)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(isSelected ? Color.brass : Color.hairline, lineWidth: isSelected ? 1 : 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 2))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Condition Pill (light editorial)
struct ConditionPill: View {
    let condition: Condition
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(condition.displayName)
                    .font(.bodyS)
                    .foregroundColor(isSelected ? .inkPrimary : .inkSecondary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.brass)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(isSelected ? Color.canvasSecond : Color.canvas)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(isSelected ? Color.brass : Color.hairline, lineWidth: isSelected ? 1 : 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 2))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Description Section
struct DescriptionSection: View {
    @ObservedObject var viewModel: CreateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Description")
            TextAreaField(
                title: "Description",
                placeholder: "Describe your item's features, fit, and style...",
                text: $viewModel.form.description,
                minHeight: 120,
                isRequired: true
            )
        }
    }
}

// MARK: - Garment Story Section
struct GarmentStorySection: View {
    @ObservedObject var viewModel: CreateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Garment story")
            Text("Where did you get this piece? What's its history? (Optional)")
                .font(.bodyS)
                .foregroundColor(.inkSecondary)

            TextEditor(text: $viewModel.form.garmentStory)
                .font(.bodyM)
                .foregroundColor(.inkPrimary)
                .frame(minHeight: 100)
                .padding(12)
                .background(Color.canvasSecond)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.hairline, lineWidth: 0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 2))
        }
    }
}

// MARK: - Sustainability Section (no gauge, no score number)
struct SustainabilitySection: View {
    @ObservedObject var viewModel: CreateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionLabel("Sustainability")

            Text("Higher transparency improves your story's reach.")
                .font(.bodyS)
                .foregroundColor(.inkSecondary)

            // Toggle: Recycled / upcycled
            Toggle(isOn: $viewModel.form.isRecycled) {
                Text("Material is recycled / upcycled")
                    .font(.bodyM)
                    .foregroundColor(.inkPrimary)
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.sage))
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color.canvasSecond)
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.hairline, lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .onChange(of: viewModel.form.isRecycled) { _, _ in
                viewModel.calculateSustainabilityScore()
            }

            // Toggle: Has certifications (expands to single-select list)
            VStack(spacing: 0) {
                Toggle(isOn: $viewModel.form.hasCertification) {
                    Text("Has certifications")
                        .font(.bodyM)
                        .foregroundColor(.inkPrimary)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color.sage))
                .padding(.vertical, 14)
                .padding(.horizontal, 16)

                if viewModel.form.hasCertification {
                    Rectangle().fill(Color.hairline).frame(height: 0.5)

                    VStack(spacing: 0) {
                        ForEach(ModaicsCertification.allCases, id: \.self) { cert in
                            Button(action: { viewModel.selectCertification(cert) }) {
                                HStack {
                                    Text(cert.displayName)
                                        .font(.bodyM)
                                        .foregroundColor(.inkPrimary)
                                    Spacer()
                                    if viewModel.form.certifications.contains(cert) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.brass)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                            }
                            .buttonStyle(PlainButtonStyle())
                            if cert != ModaicsCertification.allCases.last {
                                Rectangle().fill(Color.hairline).frame(height: 0.5)
                                    .padding(.leading, 16)
                            }
                        }
                    }
                }
            }
            .background(Color.canvasSecond)
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.hairline, lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 2))

            // Toggle: Includes care notes
            Toggle(isOn: $viewModel.form.hasCareNotes) {
                Text("Includes care notes")
                    .font(.bodyM)
                    .foregroundColor(.inkPrimary)
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.sage))
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color.canvasSecond)
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.hairline, lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 2))
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
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(color)
                    Text("/100")
                        .font(.system(size: 9, weight: .medium))
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
        VStack(spacing: 12) {
            if !viewModel.validationErrors.isEmpty && !isValid {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(viewModel.validationErrors, id: \.self) { error in
                        Text(error.localizedDescription)
                            .font(.bodyS)
                            .foregroundColor(.semanticError)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.semanticError.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.semanticError.opacity(0.3), lineWidth: 0.5))
                .clipShape(RoundedRectangle(cornerRadius: 2))
            }

            PrimaryCTA(
                "Create listing",
                isLoading: viewModel.isSubmitting,
                isEnabled: isValid
            ) {
                viewModel.validate()
                if isValid { action() }
            }
        }
    }
}
