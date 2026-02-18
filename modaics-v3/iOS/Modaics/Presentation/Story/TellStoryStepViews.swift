import SwiftUI
import PhotosUI

// MARK: - Photo Step View
// Step 1: Photo capture (styled)

struct PhotoStepView: View {
    @ObservedObject var viewModel: StoryViewModel
    
    var body: some View {
        VStack(spacing: MosaicLayout.groupSpacing) {
            // Header text
            VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
                Text("Show your garment's character")
                    .font(MosaicTypography.headline2)
                    .foregroundColor(MosaicColors.textPrimary)
                
                Text("Natural light works best. Capture details, texture, and any unique features.")
                    .font(MosaicTypography.body)
                    .foregroundColor(MosaicColors.textSecondary)
                    .lineSpacing(6)
            }
            
            // Photo Grid
            photoGrid
            
            // Tips
            photoTips
        }
    }
    
    private var photoGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: MosaicLayout.itemSpacing
        ) {
            // Add Photo Button
            addPhotoButton
            
            // Existing Photos
            ForEach(Array(viewModel.capturedPhotos.enumerated()), id: \.offset) { index, photo in
                photoThumbnail(photo, index: index)
            }
            
            // Empty placeholders
            ForEach(0..<max(0, 5 - viewModel.capturedPhotos.count), id: \.self) { _ in
                emptyPhotoSlot
            }
        }
    }
    
    private var addPhotoButton: some View {
        Button(action: {
            viewModel.showPhotoPicker = true
        }) {
            VStack(spacing: MosaicLayout.tightSpacing) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                    .foregroundColor(MosaicColors.terracotta)
                
                Text("Add Photo")
                    .font(MosaicTypography.caption)
                    .foregroundColor(MosaicColors.terracotta)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(MosaicColors.cream)
            .cornerRadius(MosaicLayout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius)
                    .stroke(MosaicColors.terracotta.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6]))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func photoThumbnail(_ image: UIImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius))
            
            // Delete button
            Button(action: {
                viewModel.removePhoto(at: index)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(MosaicColors.cream)
                    .background(Circle().fill(MosaicColors.charcoalClay.opacity(0.6)))
            }
            .padding(4)
            
            // Cover indicator
            if index == 0 {
                VStack {
                    Spacer()
                    Text("Cover")
                        .font(MosaicTypography.finePrint)
                        .foregroundColor(MosaicColors.cream)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(MosaicColors.terracotta)
                        .cornerRadius(MosaicLayout.cornerRadiusSmall, corners: [.topRight])
                }
            }
        }
    }
    
    private var emptyPhotoSlot: some View {
        Rectangle()
            .fill(MosaicColors.oatmeal.opacity(0.5))
            .frame(height: 100)
            .cornerRadius(MosaicLayout.cornerRadius)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(MosaicColors.textTertiary.opacity(0.5))
            )
    }
    
    private var photoTips: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
            Text("Photo Tips")
                .font(MosaicTypography.label)
                .foregroundColor(MosaicColors.textPrimary)
            
            VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
                tipRow(icon: "sun.max.fill", text: "Use natural daylight near a window")
                tipRow(icon: "crop.rotate", text: "Include flat lays and detail shots")
                tipRow(icon: "tag.fill", text: "Show labels, tags, and any flaws")
            }
        }
        .padding(MosaicLayout.margin)
        .background(MosaicColors.cream)
        .cornerRadius(MosaicLayout.cornerRadius)
    }
    
    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: MosaicLayout.tightSpacing) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(MosaicColors.deepOlive)
            
            Text(text)
                .font(MosaicTypography.caption)
                .foregroundColor(MosaicColors.textSecondary)
        }
    }
}

// MARK: - Basics Step View
// Step 2: The Basics (category, condition, size)

struct BasicsStepView: View {
    @ObservedObject var viewModel: StoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.groupSpacing) {
            // Header
            VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
                Text("The essentials")
                    .font(MosaicTypography.headline2)
                    .foregroundColor(MosaicColors.textPrimary)
                
                Text("These details help others find and understand your piece.")
                    .font(MosaicTypography.body)
                    .foregroundColor(MosaicColors.textSecondary)
                    .lineSpacing(6)
            }
            
            // Category Section
            categorySection
            
            // Condition Section
            conditionSection
            
            // Size Section
            sizeSection
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
            Text("Category")
                .font(MosaicTypography.label)
                .foregroundColor(MosaicColors.textPrimary)
            
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 100))],
                spacing: MosaicLayout.tightSpacing
            ) {
                ForEach(Category.allCases, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
        }
    }
    
    private var conditionSection: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
            Text("Condition")
                .font(MosaicTypography.label)
                .foregroundColor(MosaicColors.textPrimary)
            
            VStack(spacing: MosaicLayout.tightSpacing) {
                ForEach(Condition.allCases, id: \.self) { condition in
                    ConditionRow(
                        condition: condition,
                        isSelected: viewModel.selectedCondition == condition
                    ) {
                        viewModel.selectedCondition = condition
                    }
                }
            }
            .padding(MosaicLayout.itemSpacing)
            .background(MosaicColors.cream)
            .cornerRadius(MosaicLayout.cornerRadius)
        }
    }
    
    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
            Text("Size")
                .font(MosaicTypography.label)
                .foregroundColor(MosaicColors.textPrimary)
            
            HStack(spacing: MosaicLayout.itemSpacing) {
                // Size System Picker
                Menu {
                    ForEach(SizeSystem.allCases, id: \.self) { system in
                        Button(system.displayName) {
                            viewModel.selectedSizeSystem = system
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedSizeSystem.displayName)
                            .font(MosaicTypography.body)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(MosaicColors.textPrimary)
                    .padding(.horizontal, MosaicLayout.itemSpacing)
                    .padding(.vertical, 12)
                    .background(MosaicColors.cream)
                    .cornerRadius(MosaicLayout.cornerRadiusSmall)
                }
                
                // Size Input
                TextField("Size", text: $viewModel.sizeLabel)
                    .font(MosaicTypography.body)
                    .foregroundColor(MosaicColors.textPrimary)
                    .padding(.horizontal, MosaicLayout.itemSpacing)
                    .padding(.vertical, 12)
                    .background(MosaicColors.cream)
                    .cornerRadius(MosaicLayout.cornerRadiusSmall)
            }
        }
    }
}

// MARK: - Story Step View
// Step 3: The Story (narrative, history, whySelling)

struct StoryStepView: View {
    @ObservedObject var viewModel: StoryViewModel
    @FocusState private var focusedField: StoryField?
    
    enum StoryField {
        case narrative
        case provenance
        case whySelling
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.groupSpacing) {
            // Header
            VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
                Text("This is where the magic happens")
                    .font(MosaicTypography.headline2)
                    .foregroundColor(MosaicColors.textPrimary)
                
                Text("Stories transform garments into memories. Be generous with detail.")
                    .font(MosaicTypography.body)
                    .foregroundColor(MosaicColors.textSecondary)
                    .lineSpacing(6)
            }
            
            // Narrative (The main story)
            StoryInput(
                "Tell the story behind this piece—where it came from, who made it, what makes it special...",
                text: $viewModel.storyNarrative,
                title: "The Story",
                helpText: "This will be displayed prominently on your garment's page",
                minHeight: 160,
                maxHeight: 400
            )
            .focused($focusedField, equals: .narrative)
            
            // Provenance
            VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
                Text("Provenance")
                    .font(MosaicTypography.label)
                    .foregroundColor(MosaicColors.textPrimary)
                
                TextField("Where did this come from? (Brand, maker, vintage source...)", text: $viewModel.storyProvenance)
                    .font(MosaicTypography.body)
                    .foregroundColor(MosaicColors.textPrimary)
                    .padding(MosaicLayout.itemSpacing)
                    .background(MosaicColors.cream)
                    .cornerRadius(MosaicLayout.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius)
                            .stroke(focusedField == .provenance ? MosaicColors.borderFocused : MosaicColors.border)
                    )
                    .focused($focusedField, equals: .provenance)
            }
            
            // Why Selling
            VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
                Text("Why are you parting with it?")
                    .font(MosaicTypography.label)
                    .foregroundColor(MosaicColors.textPrimary)
                
                CompactStoryInput(
                    "Share why you're letting this piece go...",
                    text: $viewModel.whySelling
                )
                .focused($focusedField, equals: .whySelling)
            }
            
            // AI Enhancement Button
            if !viewModel.storyNarrative.isEmpty {
                aiEnhancementButton
            }
        }
    }
    
    private var aiEnhancementButton: some View {
        Button(action: {
            Task {
                await viewModel.enhanceWithAI()
            }
        }) {
            HStack(spacing: MosaicLayout.tightSpacing) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                Text(viewModel.isEnhancing ? "Enhancing..." : "Enhance with AI")
                    .font(MosaicTypography.label)
            }
            .foregroundColor(MosaicColors.deepOlive)
            .padding(.horizontal, MosaicLayout.itemSpacing)
            .padding(.vertical, 12)
            .background(MosaicColors.sage.opacity(0.2))
            .cornerRadius(MosaicLayout.cornerRadius)
        }
        .disabled(viewModel.isEnhancing)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Exchange Step View
// Step 4: Exchange (price or trade preferences)

struct ExchangeStepView: View {
    @ObservedObject var viewModel: StoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.groupSpacing) {
            // Header
            VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
                Text("How would you like to find it a new home?")
                    .font(MosaicTypography.headline2)
                    .foregroundColor(MosaicColors.textPrimary)
                
                Text("Set your preferences for selling, trading, or both.")
                    .font(MosaicTypography.body)
                    .foregroundColor(MosaicColors.textSecondary)
                    .lineSpacing(6)
            }
            
            // Exchange Type
            exchangeTypeSection
            
            // Price Section (if selling)
            if viewModel.exchangeType == .sell || viewModel.exchangeType == .sellOrTrade {
                priceSection
            }
            
            // Trade Preferences (if trading)
            if viewModel.exchangeType == .trade || viewModel.exchangeType == .sellOrTrade {
                tradeSection
            }
            
            // Preview
            previewSection
        }
    }
    
    private var exchangeTypeSection: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
            Text("Exchange Type")
                .font(MosaicTypography.label)
                .foregroundColor(MosaicColors.textPrimary)
            
            VStack(spacing: MosaicLayout.tightSpacing) {
                ForEach(ExchangeType.allCases, id: \.self) { type in
                    ExchangeTypeRow(
                        type: type,
                        isSelected: viewModel.exchangeType == type
                    ) {
                        viewModel.exchangeType = type
                    }
                }
            }
        }
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
            Text("Price")
                .font(MosaicTypography.label)
                .foregroundColor(MosaicColors.textPrimary)
            
            VStack(spacing: MosaicLayout.itemSpacing) {
                // Price Input
                HStack(spacing: MosaicLayout.tightSpacing) {
                    Text("$")
                        .font(MosaicTypography.bodyEmphasis)
                        .foregroundColor(MosaicColors.textPrimary)
                    
                    TextField("0.00", text: $viewModel.listingPrice)
                        .font(MosaicTypography.bodyEmphasis)
                        .foregroundColor(MosaicColors.textPrimary)
                        .keyboardType(.decimalPad)
                }
                .padding(MosaicLayout.itemSpacing)
                .background(MosaicColors.cream)
                .cornerRadius(MosaicLayout.cornerRadius)
                
                // Suggested price hint
                if let suggestedPrice = viewModel.suggestedPrice {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 12))
                            .foregroundColor(MosaicColors.terracotta)
                        
                        Text("Suggested: \(suggestedPrice)")
                            .font(MosaicTypography.caption)
                            .foregroundColor(MosaicColors.textSecondary)
                        
                        Spacer()
                        
                        Button("Use Suggested") {
                            viewModel.listingPrice = suggestedPrice
                        }
                        .font(MosaicTypography.caption)
                        .foregroundColor(MosaicColors.terracotta)
                    }
                }
                
                // Original price (if known)
                if let originalPrice = viewModel.originalPrice {
                    Text("Original price: \(originalPrice)")
                        .font(MosaicTypography.finePrint)
                        .foregroundColor(MosaicColors.textTertiary)
                }
            }
        }
    }
    
    private var tradeSection: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
            Text("Trade Preferences")
                .font(MosaicTypography.label)
                .foregroundColor(MosaicColors.textPrimary)
            
            CompactStoryInput(
                "What would you like in exchange? (Sizes, styles, brands you're interested in...)",
                text: $viewModel.tradePreferences
            )
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.itemSpacing) {
            Text("Preview")
                .font(MosaicTypography.label)
                .foregroundColor(MosaicColors.textPrimary)
            
            // Mini preview card
            HStack(spacing: MosaicLayout.itemSpacing) {
                // Photo thumbnail
                if let firstPhoto = viewModel.capturedPhotos.first {
                    Image(uiImage: firstPhoto)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: MosaicLayout.cornerRadiusSmall))
                } else {
                    RoundedRectangle(cornerRadius: MosaicLayout.cornerRadiusSmall)
                        .fill(MosaicColors.oatmeal)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(MosaicColors.textTertiary)
                        )
                }
                
                // Info
                VStack(alignment: .leading, spacing: MosaicLayout.microSpacing) {
                    Text(viewModel.garmentTitle.isEmpty ? "Your Garment" : viewModel.garmentTitle)
                        .font(MosaicTypography.label)
                        .foregroundColor(MosaicColors.textPrimary)
                    
                    if let category = viewModel.selectedCategory {
                        Text(category.displayName)
                            .font(MosaicTypography.caption)
                            .foregroundColor(MosaicColors.terracotta)
                    }
                    
                    if let price = viewModel.formattedPrice {
                        Text(price)
                            .font(MosaicTypography.bodyEmphasis)
                            .foregroundColor(MosaicColors.textPrimary)
                    }
                    
                    if let exchangeType = viewModel.exchangeType {
                        Text(exchangeType.displayName)
                            .font(MosaicTypography.finePrint)
                            .foregroundColor(MosaicColors.deepOlive)
                    }
                }
                
                Spacer()
            }
            .padding(MosaicLayout.itemSpacing)
            .background(MosaicColors.cream)
            .cornerRadius(MosaicLayout.cornerRadius)
        }
    }
}

// MARK: - Helper Components

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.displayName)
                .font(MosaicTypography.caption)
                .foregroundColor(isSelected ? MosaicColors.cream : MosaicColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? MosaicColors.terracotta : MosaicColors.cream)
                .cornerRadius(MosaicLayout.cornerRadiusSmall)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ConditionRow: View {
    let condition: Condition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(condition.displayName)
                        .font(MosaicTypography.body)
                        .foregroundColor(MosaicColors.textPrimary)
                    
                    Text(condition.description)
                        .font(MosaicTypography.finePrint)
                        .foregroundColor(MosaicColors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(MosaicColors.terracotta)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExchangeTypeRow: View {
    let type: ExchangeType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MosaicLayout.itemSpacing) {
                Image(systemName: type.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? MosaicColors.terracotta : MosaicColors.textSecondary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.displayName)
                        .font(MosaicTypography.body)
                        .foregroundColor(MosaicColors.textPrimary)
                    
                    Text(type.description)
                        .font(MosaicTypography.finePrint)
                        .foregroundColor(MosaicColors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(MosaicColors.terracotta)
                }
            }
            .padding(MosaicLayout.itemSpacing)
            .background(isSelected ? MosaicColors.sage.opacity(0.1) : MosaicColors.cream)
            .cornerRadius(MosaicLayout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius)
                    .stroke(isSelected ? MosaicColors.deepOlive.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions

extension SizeSystem {
    var displayName: String {
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

extension Condition {
    var displayName: String {
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
    
    var description: String {
        switch self {
        case .newWithTags: return "Never worn, original tags attached"
        case .newWithoutTags: return "Never worn, tags removed"
        case .excellent: return "Worn lightly, no visible flaws"
        case .veryGood: return "Minor signs of wear"
        case .good: return "Some wear, still in good condition"
        case .fair: return "Noticeable wear, priced accordingly"
        case .vintage: return "Character from age and history"
        case .needsRepair: return "Needs some TLC"
        }
    }
}

extension ExchangeType {
    var description: String {
        switch self {
        case .sell: return "List for purchase"
        case .trade: return "Exchange for another item"
        case .sellOrTrade: return "Open to either option"
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}