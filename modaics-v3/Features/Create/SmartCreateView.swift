import SwiftUI

// MARK: - SmartCreateView
/// AI-assisted listing flow (separate sheet)
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
                                withAnimation { currentPhase = .analyzing }
                                Task { await viewModel.analyzeWithAI() }
                            })
                        case .analyzing:
                            AnalyzingPhaseView()
                        case .review:
                            ReviewPhaseView(viewModel: viewModel, onNext: {
                                withAnimation { currentPhase = .finalReview }
                            })
                        case .finalReview:
                            FinalReviewPhaseView(viewModel: viewModel, onSubmit: {
                                Task {
                                    try? await viewModel.submit()
                                    if viewModel.submissionSuccess {
                                        dismiss()
                                    }
                                }
                            }, onEdit: {
                                viewModel.showSmartCreate = false
                            })
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                Spacer()
            }
        }
        .onChange(of: viewModel.aiAnalysisState) { state in
            if case .completed = state {
                withAnimation { currentPhase = .review }
            } else if case .failed = state {
                // Show error, go back to photo
                withAnimation { currentPhase = .photo }
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
                
                Text("SMART CREATE")
                    .font(.forestHeadlineSmall)
                    .foregroundColor(.sageWhite)
                    .tracking(2)
                
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
        HStack(spacing: 0) {
            ForEach(SmartCreatePhase.allCases, id: \.self) { phase in
                HStack(spacing: 0) {
                    // Segment
                    Rectangle()
                        .fill(phase.rawValue <= currentPhase.rawValue ? Color.luxeGold : Color.modaicsSurface)
                        .frame(height: 4)
                    
                    // Connector (except for last)
                    if phase != .finalReview {
                        Rectangle()
                            .fill(phase.rawValue < currentPhase.rawValue ? Color.luxeGold : Color.modaicsSurface)
                            .frame(width: 8, height: 4)
                    }
                }
            }
        }
    }
}

// MARK: - Photo Phase View (C8)
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
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.luxeGold)
                        
                        Text("ADD PHOTOS")
                            .font(.forestHeadlineSmall)
                            .foregroundColor(.sageWhite)
                        
                        Text("Take or select photos of your item. AI will analyze them.")
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
                    .stroke(Color.luxeGold.opacity(0.3), lineWidth: viewModel.form.images.isEmpty ? 2 : 0)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: viewModel.form.images.isEmpty ? 0 : 1)
            )
            .padding(.horizontal, 20)
            
            // Image picker grid
            if !viewModel.form.images.isEmpty {
                ImagePicker(
                    selectedImages: $viewModel.form.images,
                    heroImageIndex: $viewModel.form.heroImageIndex,
                    maxImages: 8
                )
                .padding(.horizontal, 20)
            } else {
                // Quick add button
                Button(action: {
                    // Trigger image picker - in real app this would open picker
                    // For demo, we'll just add a placeholder
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("ADD PHOTOS")
                    }
                    .font(.forestBodyMedium)
                    .foregroundColor(.modaicsBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.luxeGold)
                    .cornerRadius(8)
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
                .padding(.vertical, 16)
                .background(viewModel.form.images.isEmpty ? Color.luxeGold.opacity(0.3) : Color.luxeGold)
                .cornerRadius(8)
            }
            .disabled(viewModel.form.images.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Analyzing Phase View (C8)
struct AnalyzingPhaseView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.luxeGold.opacity(0.2), lineWidth: 4)
                    .frame(width: 120, height: 120)
                
                // Spinning arc
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(Color.luxeGold, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(rotation))
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.luxeGold)
            }
            
            VStack(spacing: 12) {
                Text("ANALYZING...")
                    .font(.forestDisplaySmall)
                    .foregroundColor(.sageWhite)
                
                Text("Our AI is examining your photos and extracting details")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
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
}

// MARK: - Review Phase View (C8)
struct ReviewPhaseView: View {
    @ObservedObject var viewModel: CreateViewModel
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            if case .completed(let analysis) = viewModel.aiAnalysisState {
                // AI Results
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.modaicsEco)
                        
                        Text("AI ANALYSIS COMPLETE")
                            .font(.forestHeadlineSmall)
                            .foregroundColor(.sageWhite)
                        
                        Spacer()
                    }
                    
                    Text("Confidence: \(Int(analysis.confidence * 100))%")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageMuted)
                }
                .padding(16)
                .background(Color.modaicsSurface)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                // Detected Details
                ScrollView {
                    VStack(spacing: 16) {
                        AIResultRow(icon: "tag", label: "TITLE", value: analysis.title)
                        AIResultRow(icon: "square.grid.2x2", label: "CATEGORY", value: analysis.category.displayName)
                        AIResultRow(icon: "star", label: "CONDITION", value: analysis.condition.displayName)
                        
                        // Materials
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "leaf")
                                    .foregroundColor(.modaicsEco)
                                Text("MATERIALS")
                                    .font(.forestCaptionSmall)
                                    .foregroundColor(.sageMuted)
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
                        AIResultRow(icon: "dollarsign.circle", label: "ESTIMATED PRICE", value: "\(analysis.estimatedPrice)")
                        
                        // Sustainability score
                        HStack {
                            Image(systemName: "leaf.circle")
                                .foregroundColor(.modaicsEco)
                            Text("SUSTAINABILITY SCORE")
                                .font(.forestCaptionSmall)
                                .foregroundColor(.sageMuted)
                            Spacer()
                            Text("\(analysis.sustainabilityScore)/100")
                                .font(.forestBodyMedium)
                                .foregroundColor(.modaicsEco)
                        }
                        .padding(16)
                        .background(Color.modaicsSurface)
                        .cornerRadius(12)
                        
                        // AI Suggestions
                        if !analysis.suggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "lightbulb")
                                        .foregroundColor(.luxeGold)
                                    Text("AI SUGGESTIONS")
                                        .font(.forestCaptionSmall)
                                        .foregroundColor(.sageMuted)
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
                }
                
                Spacer()
                
                // Continue button
                Button(action: onNext) {
                    Text("REVIEW & SUBMIT")
                        .font(.forestBodyMedium)
                        .foregroundColor(.modaicsBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.luxeGold)
                        .cornerRadius(8)
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
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.luxeGold)
            Text(label)
                .font(.forestCaptionSmall)
                .foregroundColor(.sageMuted)
            Spacer()
            Text(value)
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
        }
        .padding(16)
        .background(Color.modaicsSurface)
        .cornerRadius(12)
    }
}

// MARK: - Final Review Phase View (C8)
struct FinalReviewPhaseView: View {
    @ObservedObject var viewModel: CreateViewModel
    let onSubmit: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Preview
            PreviewCard(
                images: viewModel.form.images,
                title: viewModel.form.title,
                category: viewModel.form.category,
                price: viewModel.form.listingPriceDecimal,
                condition: viewModel.form.condition
            )
            .padding(.horizontal, 20)
            
            // Quick edit options
            VStack(alignment: .leading, spacing: 12) {
                Text("QUICK ACTIONS")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
                
                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("EDIT IN FULL FORM")
                            .font(.forestBodyMedium)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.sageWhite)
                    .padding(16)
                    .background(Color.modaicsSurface)
                    .cornerRadius(12)
                }
                
                // Listing mode
                HStack(spacing: 12) {
                    ForEach(ListingMode.allCases) { mode in
                        ListingModeButton(
                            mode: mode,
                            isSelected: viewModel.form.listingMode == mode
                        ) {
                            viewModel.form.listingMode = mode
                        }
                    }
                }
                
                // Price input if selling
                if viewModel.form.listingMode == .sell {
                    HStack(spacing: 12) {
                        Text("$")
                            .font(.forestBodyMedium)
                            .foregroundColor(.sageWhite)
                        
                        TextField("Price", text: $viewModel.form.listingPrice)
                            .font(.forestBodyMedium)
                            .foregroundColor(.sageWhite)
                            .keyboardType(.decimalPad)
                    }
                    .padding(16)
                    .background(Color.modaicsSurface)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Submit button
            Button(action: onSubmit) {
                if viewModel.isSubmitting {
                    ProgressView()
                        .tint(.modaicsBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.luxeGold)
                        .cornerRadius(8)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                        Text("SUBMIT LISTING")
                    }
                    .font(.forestBodyMedium)
                    .foregroundColor(.modaicsBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.luxeGold)
                    .cornerRadius(8)
                }
            }
            .disabled(viewModel.isSubmitting)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}
