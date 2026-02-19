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
                            AnalyzingPhaseView()
                            
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
                        .foregroundColor(.sageWhite)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundColor(.luxeGold)
                    Text("SMART CREATE")
                        .font(.forestHeadlineSmall)
                        .foregroundColor(.sageWhite)
                        .tracking(2)
                }
                
                Spacer()
                
                // Reset button
                Button(action: {
                    viewModel.resetForm()
                    currentPhase = .photo
                }) {
                    Text("RESET")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.luxeGold)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Progress
            SmartProgressBar(currentPhase: currentPhase)
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

// MARK: - Smart Progress Bar
struct SmartProgressBar: View {
    let currentPhase: SmartCreatePhase
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(SmartCreatePhase.allCases, id: \.self) { phase in
                HStack(spacing: 0) {
                    // Segment
                    RoundedRectangle(cornerRadius: 2)
                        .fill(phase.rawValue <= currentPhase.rawValue ? Color.luxeGold : Color.modaicsSurface)
                        .frame(height: 4)
                }
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
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.modaicsSurface)
                    .aspectRatio(1, contentMode: .fit)
                
                if viewModel.form.images.isEmpty {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.luxeGold.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.luxeGold)
                        }
                        
                        Text("ADD PHOTOS")
                            .font(.forestHeadlineSmall)
                            .foregroundColor(.sageWhite)
                            .tracking(1)
                        
                        Text("Take or select photos of your item.\nAI will analyze them and auto-fill details.")
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    if let firstImage = viewModel.form.images.first {
                        Image(uiImage: firstImage)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.luxeGold.opacity(viewModel.form.images.isEmpty ? 0.3 : 0), lineWidth: viewModel.form.images.isEmpty ? 2 : 0)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: viewModel.form.images.isEmpty ? 0 : 1)
            )
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
                        Text("SELECT FROM LIBRARY")
                    }
                    .font(.forestBodyMedium)
                    .foregroundColor(.modaicsBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.luxeGold)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Continue button
            Button(action: onNext) {
                HStack(spacing: 8) {
                    Text("ANALYZE WITH AI")
                    Image(systemName: "sparkles")
                }
                .font(.forestBodyMedium)
                .foregroundColor(.modaicsBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(viewModel.form.images.isEmpty ? Color.luxeGold.opacity(0.3) : Color.luxeGold)
                .cornerRadius(12)
            }
            .disabled(viewModel.form.images.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Analyzing Phase View
struct AnalyzingPhaseView: View {
    @State private var rotation: Double = 0
    @State private var pulse: Bool = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                // Outer glow rings
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.luxeGold.opacity(0.1), lineWidth: 1)
                        .frame(width: 120 + CGFloat(i * 40), height: 120 + CGFloat(i * 40))
                        .scaleEffect(pulse ? 1.1 : 1.0)
                        .opacity(pulse ? 0.3 : 0.6)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.2),
                            value: pulse
                        )
                }
                
                // Main spinner
                ZStack {
                    Circle()
                        .stroke(Color.luxeGold.opacity(0.2), lineWidth: 4)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(
                            LinearGradient(
                                colors: [.luxeGold, .luxeGoldBright],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(rotation))
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 32))
                        .foregroundColor(.luxeGold)
                }
            }
            
            VStack(spacing: 12) {
                Text("ANALYZING...")
                    .font(.forestDisplaySmall)
                    .foregroundColor(.sageWhite)
                    .tracking(2)
                
                Text("Our AI is examining your photos\nand extracting garment details")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            pulse = true
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
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
                // AI Results Header
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.modaicsEco)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ANALYSIS COMPLETE")
                            .font(.forestHeadlineSmall)
                            .foregroundColor(.sageWhite)
                        
                        Text("\(Int(analysis.confidence * 100))% confidence")
                            .font(.forestCaptionSmall)
                            .foregroundColor(.sageMuted)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.modaicsSurface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.modaicsEco.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                
                // Detected Details
                VStack(spacing: 12) {
                    AIResultRow(icon: "tag.fill", label: "TITLE", value: analysis.title)
                    AIResultRow(icon: "square.grid.2x2", label: "CATEGORY", value: analysis.category.displayName)
                    AIResultRow(icon: "star.fill", label: "CONDITION", value: analysis.condition.displayName)
                    
                    // Materials
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.modaicsEco)
                            Text("MATERIALS")
                                .font(.forestCaptionSmall)
                                .foregroundColor(.sageMuted)
                                .tracking(1)
                        }
                        
                        ForEach(analysis.materials) { material in
                            HStack {
                                Text(material.name)
                                    .font(.forestBodySmall)
                                    .foregroundColor(.sageWhite)
                                Spacer()
                                Text("\(material.percentage)%")
                                    .font(.forestCaptionSmall)
                                    .foregroundColor(.sageMuted)
                                if material.isSustainable {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.modaicsEco)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.modaicsSurface)
                    .cornerRadius(12)
                    
                    // Estimated price
                    AIResultRow(
                        icon: "dollarsign.circle.fill",
                        label: "ESTIMATED PRICE",
                        value: "\(analysis.estimatedPrice)",
                        highlight: true
                    )
                    
                    // Sustainability score
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "leaf.circle.fill")
                                .foregroundColor(.modaicsEco)
                            Text("SUSTAINABILITY")
                                .font(.forestCaptionSmall)
                                .foregroundColor(.sageMuted)
                                .tracking(1)
                        }
                        
                        Spacer()
                        
                        Text("\(analysis.sustainabilityScore)/100")
                            .font(.forestHeadlineSmall)
                            .foregroundColor(.modaicsEco)
                    }
                    .padding(16)
                    .background(Color.modaicsSurface)
                    .cornerRadius(12)
                    
                    // AI Suggestions
                    if !analysis.suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.luxeGold)
                                Text("AI SUGGESTIONS")
                                    .font(.forestCaptionSmall)
                                    .foregroundColor(.sageMuted)
                                    .tracking(1)
                            }
                            
                            ForEach(analysis.suggestions, id: \.self) { suggestion in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.luxeGold)
                                    Text(suggestion)
                                        .font(.forestBodySmall)
                                        .foregroundColor(.sageWhite)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.modaicsSurface)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: onNext) {
                        HStack(spacing: 8) {
                            Text("REVIEW & SUBMIT")
                            Image(systemName: "arrow.right")
                        }
                        .font(.forestBodyMedium)
                        .foregroundColor(.modaicsBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.luxeGold)
                        .cornerRadius(12)
                    }
                    
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
}

// MARK: - AI Result Row
struct AIResultRow: View {
    let icon: String
    let label: String
    let value: String
    var highlight: Bool = false
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(highlight ? .luxeGold : .luxeGold.opacity(0.8))
                Text(label)
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
            }
            
            Spacer()
            
            Text(value)
                .font(.forestBodyMedium)
                .foregroundColor(highlight ? .luxeGold : .sageWhite)
        }
        .padding(16)
        .background(Color.modaicsSurface)
        .cornerRadius(12)
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
