import SwiftUI

// MARK: - SmartCreateView
/// AI-assisted listing flow - opens as sheet, populates main form on "Edit in Full Form"
public struct SmartCreateView: View {
    @ObservedObject var viewModel: CreateViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentPhase: SmartCreatePhase = .photo
    
    public init(viewModel: CreateViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content based on phase
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        switch currentPhase {
                        case .photo:
                            PhotoPhaseView(viewModel: viewModel, onNext: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPhase = .analyzing
                                }
                                Task { await viewModel.analyzeWithAI() }
                            })
                            
                        case .analyzing:
                            AnalyzingPhaseView(viewModel: viewModel)
                            
                        case .review:
                            ReviewPhaseView(viewModel: viewModel, onNext: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPhase = .finalReview
                                }
                            }, onEditInFullForm: {
                                // Populate main form and dismiss
                                dismiss()
                            })
                            
                        case .finalReview:
                            FinalReviewPhaseView(
                                viewModel: viewModel,
                                onSubmit: {
                                    Task {
                                        try? await viewModel.submit()
                                        if viewModel.submissionSuccess {
                                            dismiss()
                                        }
                                    }
                                },
                                onEditInFullForm: {
                                    // Dismiss sheet - form is already populated
                                    dismiss()
                                }
                            )
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .onChange(of: viewModel.aiAnalysisState) { _, newState in
            if case .completed = newState {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPhase = .review
                }
            } else if case .failed = newState {
                // Show error, go back to photo
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPhase = .photo
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.nearBlack)
                }
                
                Spacer()
                
                Text("The Studio")
                    .font(.editorialSmall)
                    .foregroundColor(.nearBlack)
                
                Spacer()
                
                // Reset button
                Button(action: {
                    viewModel.resetForm()
                    currentPhase = .photo
                }) {
                    Text("Reset")
                        .font(.captionSmall)
                        .foregroundColor(.warmCharcoal)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Progress
            StudioProgressBar(currentPhase: currentPhase)
                .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
}

// MARK: - Smart Create Phase
enum SmartCreatePhase: Int, CaseIterable {
    case photo = 0
    case analyzing = 1
    case review = 2
    case finalReview = 3
}

// MARK: - Studio Progress Bar
struct StudioProgressBar: View {
    let currentPhase: SmartCreatePhase
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(SmartCreatePhase.allCases, id: \.self) { phase in
                Rectangle()
                    .fill(phase.rawValue <= currentPhase.rawValue ? Color.nearBlack : Color.warmDivider)
                    .frame(height: 2)
            }
        }
    }
}

// MARK: - Photo Phase View
struct PhotoPhaseView: View {
    @ObservedObject var viewModel: CreateViewModel
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Hero image area
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.ivory)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.warmDivider, lineWidth: 0.5)
                    )
                
                if viewModel.form.images.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.nearBlack)
                        
                        Text("Add photos")
                            .font(.bodyMedium)
                            .foregroundColor(.nearBlack)
                        
                        Text("Take or select photos of your item")
                            .font(.captionSmall)
                            .foregroundColor(.mutedGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    if let firstImage = viewModel.form.images.first {
                        Image(uiImage: firstImage)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Image picker row
            if !viewModel.form.images.isEmpty {
                ImageUploadRow(
                    images: $viewModel.form.images,
                    heroImageIndex: $viewModel.form.heroImageIndex,
                    maxImages: 8
                )
                .padding(.horizontal, 20)
            } else {
                // Quick add button
                Button(action: {
                    // In real implementation, this would trigger image picker
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.stack")
                        Text("Select from library")
                    }
                    .font(.bodyMedium)
                    .foregroundColor(.nearBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.ivory)
                    .cornerRadius(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.warmDivider, lineWidth: 0.5)
                    )
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Continue button
            Button(action: onNext) {
                HStack(spacing: 8) {
                    Text("Continue")
                }
                .font(.bodyMedium)
                .foregroundColor(viewModel.form.images.isEmpty ? .mutedGray : .nearBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(viewModel.form.images.isEmpty ? Color.warmOffWhite : Color.ivory)
                .cornerRadius(2)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(viewModel.form.images.isEmpty ? Color.clear : Color.warmDivider, lineWidth: 0.5)
                )
            }
            .disabled(viewModel.form.images.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Analyzing Phase View
struct AnalyzingPhaseView: View {
    @ObservedObject var viewModel: CreateViewModel
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Simple spinner
            ZStack {
                Circle()
                    .stroke(Color.warmDivider, lineWidth: 2)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(Color.nearBlack, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(rotation))
            }
            
            VStack(spacing: 12) {
                Text(analysisTitle)
                    .font(.editorialSmall)
                    .foregroundColor(.nearBlack)
                
                Text(analysisDescription)
                    .font(.bodySmall)
                    .foregroundColor(.mutedGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
    
    private var analysisTitle: String {
        switch viewModel.aiAnalysisState {
        case .analyzing(.onDevice), .analyzing(.server):
            return "Reading your piece..."
        case .analyzing(.mergingResults):
            return "Almost there..."
        default:
            return "Reading your piece..."
        }
    }
    
    private var analysisDescription: String {
        switch viewModel.aiAnalysisState {
        case .analyzing(.onDevice), .analyzing(.server), .analyzing(.mergingResults):
            return "We're identifying details from your photo"
        default:
            return "We're identifying details from your photo"
        }
    }
}

// MARK: - Review Phase View
struct ReviewPhaseView: View {
    @ObservedObject var viewModel: CreateViewModel
    let onNext: () -> Void
    let onEditInFullForm: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            if case .completed(let analysis) = viewModel.aiAnalysisState {
                // Results Header with pencil icon
                HStack {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.nearBlack)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quick edits")
                            .font(.bodyMedium)
                            .foregroundColor(.nearBlack)
                        
                        Text("Tap any field to adjust")
                            .font(.captionSmall)
                            .foregroundColor(.mutedGray)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.ivory)
                .cornerRadius(2)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.warmDivider, lineWidth: 0.5)
                )
                .padding(.horizontal, 20)
                
                // Detected Details
                VStack(spacing: 12) {
                    StudioResultRow(label: "Title", value: analysis.title)
                    StudioResultRow(label: "Category", value: analysis.category.displayName)
                    StudioResultRow(label: "Condition", value: analysis.condition.displayName)
                    
                    // Materials
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Materials")
                            .font(.captionSmall)
                            .foregroundColor(.mutedGray)
                        
                        ForEach(analysis.materials) { material in
                            HStack {
                                Text(material.name)
                                    .font(.bodySmall)
                                    .foregroundColor(.nearBlack)
                                Spacer()
                                Text("\(material.percentage)%")
                                    .font(.captionSmall)
                                    .foregroundColor(.mutedGray)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.ivory)
                    .cornerRadius(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.warmDivider, lineWidth: 0.5)
                    )
                    
                    // Estimated price
                    StudioResultRow(
                        label: "Estimated price",
                        value: "\(analysis.estimatedPrice)"
                    )
                    
                    // Sustainability score
                    HStack {
                        Text("Sustainability")
                            .font(.captionSmall)
                            .foregroundColor(.mutedGray)
                        
                        Spacer()
                        
                        Text("\(analysis.sustainabilityScore)/100")
                            .font(.bodyMedium)
                            .foregroundColor(.nearBlack)
                    }
                    .padding(16)
                    .background(Color.ivory)
                    .cornerRadius(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.warmDivider, lineWidth: 0.5)
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: onNext) {
                        HStack(spacing: 8) {
                            Text("Review and submit")
                        }
                        .font(.bodyMedium)
                        .foregroundColor(.nearBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.ivory)
                        .cornerRadius(2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color.warmDivider, lineWidth: 0.5)
                        )
                    }
                    
                    Button(action: onEditInFullForm) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil")
                            Text("Edit details")
                        }
                        .font(.caption)
                        .foregroundColor(.warmCharcoal)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Studio Result Row
struct StudioResultRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.captionSmall)
                .foregroundColor(.mutedGray)
            
            Spacer()
            
            Text(value)
                .font(.bodySmall)
                .foregroundColor(.nearBlack)
        }
        .padding(16)
        .background(Color.ivory)
        .cornerRadius(2)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.warmDivider, lineWidth: 0.5)
        )
    }
}

// MARK: - Final Review Phase View
struct FinalReviewPhaseView: View {
    @ObservedObject var viewModel: CreateViewModel
    let onSubmit: () -> Void
    let onEditInFullForm: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Preview Card
            if let firstImage = viewModel.form.images.first {
                VStack(spacing: 0) {
                    // Image
                    Image(uiImage: firstImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                    
                    // Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.form.title.isEmpty ? "Untitled Item" : viewModel.form.title)
                            .font(.forestHeadlineSmall)
                            .foregroundColor(.sageWhite)
                        
                        HStack {
                            if let category = viewModel.form.category {
                                Text(category.displayName.uppercased())
                                    .font(.forestCaptionSmall)
                                    .foregroundColor(.sageMuted)
                            }
                            
                            Spacer()
                            
                            if let condition = viewModel.form.condition {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                    Text(condition.displayName.uppercased())
                                }
                                .font(.forestCaptionSmall)
                                .foregroundColor(.luxeGold)
                            }
                        }
                        
                        if viewModel.form.listingMode == .sell, !viewModel.form.listingPrice.isEmpty {
                            HStack(spacing: 4) {
                                Text("$")
                                    .font(.forestHeadlineMedium)
                                Text(viewModel.form.listingPrice)
                                    .font(.forestHeadlineMedium)
                            }
                            .foregroundColor(.luxeGold)
                        }
                    }
                    .padding(16)
                    .background(Color.modaicsSurface)
                }
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
                .padding(.horizontal, 20)
            }
            
            // Listing Mode Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("LISTING MODE")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
                
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
            }
            .padding(.horizontal, 20)
            
            // Price input if selling/renting
            if viewModel.form.listingMode != .swap {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.form.listingMode == .rent ? "DAILY RATE" : "PRICE")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                        .tracking(1)
                    
                    HStack(spacing: 12) {
                        Text("$")
                            .font(.forestBodyMedium)
                            .foregroundColor(.sageWhite)
                        
                        TextField("0.00", text: $viewModel.form.listingPrice)
                            .font(.forestBodyMedium)
                            .foregroundColor(.sageWhite)
                            .keyboardType(.decimalPad)
                    }
                    .padding(14)
                    .background(Color.modaicsSurface)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: onSubmit) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .tint(.modaicsBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.luxeGold)
                            .cornerRadius(12)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("SUBMIT LISTING")
                                .tracking(1)
                        }
                        .font(.forestBodyMedium)
                        .foregroundColor(.modaicsBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.luxeGold)
                        .cornerRadius(12)
                    }
                }
                .disabled(viewModel.isSubmitting)
                
                Button(action: onEditInFullForm) {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                        Text("EDIT IN FULL FORM")
                    }
                    .font(.forestCaptionMedium)
                    .foregroundColor(.luxeGold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.luxeGold.opacity(0.5), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}
