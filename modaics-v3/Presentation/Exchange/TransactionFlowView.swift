import SwiftUI
import Combine

// MARK: - Transaction Flow View
/// The handoff experience — feels like preparing a parcel with a note tucked inside
struct TransactionFlowView: View {
    let mode: ExchangeMode
    @ObservedObject var viewModel: ExchangeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: TransactionStep = .intro
    @State private var handoffNote: String = ""
    @State private var selectedGarment: Garment?
    @State private var selectedPaymentMethod: PaymentMethod?
    @State private var tradeOffer: TradeOffer?
    @State private var listingPrice: String = ""
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsWarmSand
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    navigationBar
                    
                    ProgressView(value: progressValue, total: 1.0)
                        .tint(.modaicsTerracotta)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            currentStepView
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                        }
                        .padding(.bottom, 100)
                    }
                    
                    Spacer()
                    
                    bottomActionBar
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        .background(
                            LinearGradient(
                                colors: [.modaicsWarmSand, .modaicsWarmSand.opacity(0.9)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            .ignoresSafeArea()
                        )
                }
            }
            .navigationBarHidden(true)
        }
        .overlay(
            Group {
                if showConfirmation {
                    HandoffConfirmationView(mode: mode) {
                        dismiss()
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
        )
    }
    
    private var navigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.modaicsCharcoalClay)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
            
            Text(modeTitle)
                .font(.modaicsHeadingSemiBold(size: 18))
                .foregroundColor(.modaicsCharcoalClay)
            
            Spacer()
            
            Color.clear
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    @ViewBuilder
    private var currentStepView: some View {
        switch currentStep {
        case .intro:
            IntroStepView(mode: mode)
        case .selection:
            GarmentSelectionView(mode: mode, selectedGarment: $selectedGarment, viewModel: viewModel)
        case .details:
            TransactionDetailsView(mode: mode, listingPrice: $listingPrice, selectedPaymentMethod: $selectedPaymentMethod, tradeOffer: $tradeOffer)
        case .handoff:
            HandoffNoteView(handoffNote: $handoffNote)
        case .review:
            ReviewStepView(mode: mode, garment: selectedGarment, handoffNote: handoffNote, listingPrice: listingPrice, paymentMethod: selectedPaymentMethod, tradeOffer: tradeOffer)
        }
    }
    
    private var bottomActionBar: some View {
        HStack(spacing: 16) {
            if currentStep != .intro {
                Button(action: previousStep) {
                    Text("Back")
                        .font(.modaicsBodyMedium(size: 16))
                        .foregroundColor(.modaicsCharcoalClay)
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                        )
                }
            }
            
            Button(action: nextStep) {
                HStack(spacing: 8) {
                    Text(nextButtonText)
                        .font(.modaicsBodySemiBold(size: 16))
                    
                    if currentStep == .review {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                    } else {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(canProceed ? Color.modaicsTerracotta : Color.modaicsTerracotta.opacity(0.4))
                )
            }
            .disabled(!canProceed)
        }
    }
    
    private var modeTitle: String {
        switch mode {
        case .buy: return "Discover"
        case .sell: return "Pass On"
        case .trade: return "Exchange"
        }
    }
    
    private var progressValue: Double {
        Double(currentStep.rawValue) / 4.0
    }
    
    private var nextButtonText: String {
        switch currentStep {
        case .intro: return "Begin"
        case .selection: return "Continue"
        case .details: return "Add Note"
        case .handoff: return "Review"
        case .review: return "Complete"
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .intro:
            return true
        case .selection:
            return selectedGarment != nil
        case .details:
            switch mode {
            case .buy:
                return selectedPaymentMethod != nil
            case .sell:
                return !listingPrice.isEmpty
            case .trade:
                return tradeOffer != nil
            }
        case .handoff:
            return true
        case .review:
            return true
        }
    }
    
    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep == .review {
                showConfirmation = true
            } else {
                currentStep = TransactionStep(rawValue: currentStep.rawValue + 1) ?? .review
            }
        }
    }
    
    private func previousStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = TransactionStep(rawValue: currentStep.rawValue - 1) ?? .intro
        }
    }
}

enum TransactionStep: Int, CaseIterable {
    case intro, selection, details, handoff, review
}

struct IntroStepView: View {
    let mode: ExchangeMode
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(mode.backgroundColor)
                    .frame(width: 160, height: 160)
                
                Image(systemName: mode == .buy ? "gift" : mode == .sell ? "arrow.up.heart" : "arrow.left.arrow.right.circle")
                    .font(.system(size: 64))
                    .foregroundColor(mode.accentColor)
            }
            
            VStack(spacing: 16) {
                Text(introTitle)
                    .font(.modaicsDisplayMedium(size: 28))
                    .foregroundColor(.modaicsCharcoalClay)
                    .multilineTextAlignment(.center)
                
                Text(introDescription)
                    .font(.modaicsBodyRegular(size: 16))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(ritualSteps, id: \.self) { step in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.modaicsDeepOlive.opacity(0.1))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("\(ritualSteps.firstIndex(of: step)! + 1)")
                                    .font(.modaicsCaptionMedium(size: 14))
                                    .foregroundColor(.modaicsDeepOlive)
                            )
                        
                        Text(step)
                            .font(.modaicsBodyRegular(size: 15))
                            .foregroundColor(.modaicsCharcoalClay)
                        
                        Spacer()
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    private var introTitle: String {
        switch mode {
        case .buy: return "Discover Something Special"
        case .sell: return "Pass On With Care"
        case .trade: return "Exchange Stories"
        }
    }
    
    private var introDescription: String {
        switch mode {
        case .buy:
            return "Every piece in our exchange has been loved before. You're not just buying clothing—you're continuing a story."
        case .sell:
            return "Your garment has been part of your journey. Now it's time for someone else to create memories with it."
        case .trade:
            return "Connect directly with community members. Trade pieces that no longer serve you for something that sparks joy."
        }
    }
    
    private var ritualSteps: [String] {
        switch mode {
        case .buy:
            return ["Browse curated pieces", "Read their stories", "Complete your purchase", "Receive with a note"]
        case .sell:
            return ["Select your garment", "Set your price", "Write a note", "Send to its new home"]
        case .trade:
            return ["Choose what to offer", "Browse trade requests", "Negotiate with care", "Exchange stories"]
        }
    }
}

struct GarmentSelectionView: View {
    let mode: ExchangeMode
    @Binding var selectedGarment: Garment?
    @ObservedObject var viewModel: ExchangeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(mode == .sell ? "Which piece are you passing on?" : "What are you looking for?")
                .font(.modaicsHeadingSemiBold(size: 22))
                .foregroundColor(.modaicsCharcoalClay)
            
            LazyVStack(spacing: 12) {
                ForEach(mode == .sell ? viewModel.userGarments : viewModel.availableGarments) { garment in
                    SelectableGarmentRow(garment: garment, isSelected: selectedGarment?.id == garment.id) {
                        selectedGarment = garment
                    }
                }
            }
        }
    }
}

struct SelectableGarmentRow: View {
    let garment: Garment
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.modaicsWarmSand)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Image(systemName: "tshirt")
                            .font(.system(size: 24))
                            .foregroundColor(.modaicsCharcoalClay.opacity(0.3))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(garment.name)
                        .font(.modaicsBodyMedium(size: 16))
                        .foregroundColor(.modaicsCharcoalClay)
                    
                    Text(garment.brand)
                        .font(.modaicsCaptionRegular(size: 14))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                    
                    if let size = garment.size {
                        Text("Size \(size)")
                            .font(.modaicsCaptionRegular(size: 12))
                            .foregroundColor(.modaicsDeepOlive)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.modaicsDeepOlive.opacity(0.1)))
                    }
                }
                
                Spacer()
                
                Circle()
                    .stroke(isSelected ? Color.modaicsTerracotta : Color.modaicsCharcoalClay.opacity(0.2), lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(isSelected ? Color.modaicsTerracotta : Color.clear)
                            .frame(width: 14, height: 14)
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: isSelected ? .modaicsTerracotta.opacity(0.15) : .black.opacity(0.03), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.modaicsTerracotta.opacity(0.3) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TransactionDetailsView: View {
    let mode: ExchangeMode
    @Binding var listingPrice: String
    @Binding var selectedPaymentMethod: PaymentMethod?
    @Binding var tradeOffer: TradeOffer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            switch mode {
            case .buy:
                PaymentMethodSelection(selectedMethod: $selectedPaymentMethod)
            case .sell:
                ListingPriceView(price: $listingPrice)
            case .trade:
                TradeNegotiationView(tradeOffer: $tradeOffer)
            }
        }
    }
}

struct PaymentMethodSelection: View {
    @Binding var selectedMethod: PaymentMethod?
    
    let methods: [PaymentMethod] = [
        .init(id: "card", name: "Credit Card", icon: "creditcard", last4: "•••• 4242"),
        .init(id: "apple_pay", name: "Apple Pay", icon: "apple.logo", last4: nil),
        .init(id: "paypal", name: "PayPal", icon: "paypal", last4: nil)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Method")
                .font(.modaicsHeadingSemiBold(size: 22))
                .foregroundColor(.modaicsCharcoalClay)
            
            Text("Secure payment powered by Stripe")
                .font(.modaicsCaptionRegular(size: 14))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
            
            LazyVStack(spacing: 12) {
                ForEach(methods) { method in
                    PaymentMethodRow(method: method, isSelected: selectedMethod?.id == method.id) {
                        selectedMethod = method
                    }
                }
            }
            
            Text("Your payment information is encrypted and secure")
                .font(.modaicsCaptionRegular(size: 12))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.5))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
        }
    }
}

struct PaymentMethodRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: method.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.modaicsCharcoalClay)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.name)
                        .font(.modaicsBodyMedium(size: 16))
                        .foregroundColor(.modaicsCharcoalClay)
                    
                    if let last4 = method.last4 {
                        Text(last4)
                            .font(.modaicsCaptionRegular(size: 14))
                            .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                    }
                }
                
                Spacer()
                
                Circle()
                    .stroke(isSelected ? Color.modaicsTerracotta : Color.modaicsCharcoalClay.opacity(0.2), lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(isSelected ? Color.modaicsTerracotta : Color.clear)
                            .frame(width: 14, height: 14)
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: isSelected ? .modaicsTerracotta.opacity(0.1) : .black.opacity(0.02), radius: 6, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.modaicsTerracotta.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ListingPriceView: View {
    @Binding var price: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Set Your Price")
                .font(.modaicsHeadingSemiBold(size: 22))
                .foregroundColor(.modaicsCharcoalClay)
            
            Text("Consider the garment's condition, brand value, and original price")
                .font(.modaicsCaptionRegular(size: 14))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
            
            HStack(spacing: 8) {
                Text("$")
                    .font(.modaicsDisplayMedium(size: 32))
                    .foregroundColor(.modaicsCharcoalClay)
                
                TextField("0.00", text: $price)
                    .font(.modaicsDisplayMedium(size: 32))
                    .keyboardType(.decimalPad)
                    .foregroundColor(.modaicsCharcoalClay)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
            
            HStack(spacing: 8) {
                ForEach(["$25", "$50", "$75", "$100"], id: \.self) { suggestion in
                    Button(action: { price = String(suggestion.dropFirst()) }) {
                        Text(suggestion)
                            .font(.modaicsBodyMedium(size: 14))
                            .foregroundColor(.modaicsDeepOlive)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.modaicsDeepOlive.opacity(0.1)))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct TradeNegotiationView: View {
    @Binding var tradeOffer: TradeOffer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Propose an Exchange")
                .font(.modaicsHeadingSemiBold(size: 22))
                .foregroundColor(.modaicsCharcoalClay)
            
            VStack(spacing: 16) {
                Image(systemName: "arrow.left.arrow.right.circle")
                    .font(.system(size: 48))
                    .foregroundColor(.modaicsTerracotta.opacity(0.5))
                
                Text("Trade negotiation coming soon")
                    .font(.modaicsBodyMedium(size: 16))
                    .foregroundColor(.modaicsCharcoalClay)
                
                Text("Direct swap functionality is being refined for the best experience")
                    .font(.modaicsCaptionRegular(size: 14))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
            )
        }
    }
}

struct HandoffNoteView: View {
    @Binding var handoffNote: String
    @State private var selectedTemplate: String?
    
    let noteTemplates = [
        "This piece has been with me through so many memories...",
        "I hope this brings you as much joy as it brought me...",
        "Take good care of this one—it deserves to be loved...",
        "Wishing you wonderful adventures in this..."
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("A Note for the Next Caretaker")
                .font(.modaicsHeadingSemiBold(size: 22))
                .foregroundColor(.modaicsCharcoalClay)
            
            Text("Write something personal. This is what makes the exchange special.")
                .font(.modaicsBodyRegular(size: 15))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.7))
                .lineSpacing(4)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                
                if handoffNote.isEmpty {
                    Text("Write your note here...")
                        .font(.modaicsBodyRegular(size: 16))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.4))
                        .padding(20)
                        .padding(.top, 4)
                }
                
                TextEditor(text: $handoffNote)
                    .font(.modaicsBodyRegular(size: 16))
                    .foregroundColor(.modaicsCharcoalClay)
                    .padding(16)
                    .frame(minHeight: 150)
            }
            
            Text("Quick starters:")
                .font(.modaicsCaptionMedium(size: 14))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                .padding(.top, 8)
            
            FlowLayout(spacing: 8) {
                ForEach(noteTemplates, id: \.self) { template in
                    Button(action: { handoffNote = template }) {
                        Text(template)
                            .font(.modaicsCaptionRegular(size: 13))
                            .foregroundColor(.modaicsDeepOlive)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.modaicsDeepOlive.opacity(0.1))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct ReviewStepView: View {
    let mode: ExchangeMode
    let garment: Garment?
    let handoffNote: String
    let listingPrice: String
    let paymentMethod: PaymentMethod?
    let tradeOffer: TradeOffer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Review & Confirm")
                .font(.modaicsHeadingSemiBold(size: 22))
                .foregroundColor(.modaicsCharcoalClay)
            
            // Garment summary
            if let garment = garment {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Garment")
                        .font(.modaicsCaptionMedium(size: 14))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                    
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.modaicsWarmSand)
                            .frame(width: 48, height: 48)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(garment.name)
                                .font(.modaicsBodyMedium(size: 16))
                                .foregroundColor(.modaicsCharcoalClay)
                            Text(garment.brand)
                                .font(.modaicsCaptionRegular(size: 14))
                                .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
                )
            }
            
            // Transaction details
            VStack(alignment: .leading, spacing: 12) {
                Text("Details")
                    .font(.modaicsCaptionMedium(size: 14))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                
                switch mode {
                case .buy:
                    if let payment = paymentMethod {
                        DetailRow(label: "Payment", value: payment.name)
                    }
                case .sell:
                    if !listingPrice.isEmpty {
                        DetailRow(label: "Price", value: "\u{0024}\(listingPrice)")
                    }
                case .trade:
                    DetailRow(label: "Type", value: "Direct Exchange")
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
            )
            
            // Handoff note
            if !handoffNote.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Note")
                        .font(.modaicsCaptionMedium(size: 14))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                    
                    Text(handoffNote)
                        .font(.modaicsBodyRegular(size: 15))
                        .foregroundColor(.modaicsCharcoalClay)
                        .italic()
                        .lineSpacing(4)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.modaicsWarmSand.opacity(0.5))
                )
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.modaicsBodyRegular(size: 15))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.modaicsBodyMedium(size: 15))
                .foregroundColor(.modaicsCharcoalClay)
        }
    }
}

struct HandoffConfirmationView: View {
    let mode: ExchangeMode
    let onComplete: () -> Void
    @State private var showCheckmark = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(Color.modaicsTerracotta.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .fill(Color.modaicsTerracotta)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: showCheckmark ? "checkmark" : "sealed.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 12) {
                    Text(confirmationTitle)
                        .font(.modaicsDisplayMedium(size: 24))
                        .foregroundColor(.modaicsCharcoalClay)
                    
                    Text(confirmationMessage)
                        .font(.modaicsBodyRegular(size: 16))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                Button(action: onComplete) {
                    Text("Done")
                        .font(.modaicsBodySemiBold(size: 16))
                        .foregroundColor(.white)
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.modaicsTerracotta)
                        )
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.modaicsWarmSand)
            )
            .padding(40)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                showCheckmark = true
            }
        }
    }
    
    private var confirmationTitle: String {
        switch mode {
        case .buy: return "Order Confirmed!"
        case .sell: return "Listed Successfully!"
        case .trade: return "Trade Request Sent!"
        }
    }
    
    private var confirmationMessage: String {
        switch mode {
        case .buy:
            return "Your new piece is being prepared with care. You'll receive a tracking number once it's on its way."
        case .sell:
            return "Your garment is now listed. When someone discovers it, you'll be notified to prepare the handoff."
        case .trade:
            return "Your trade proposal has been sent. We'll notify you when they respond."
        }
    }
}

// MARK: - Supporting Models
struct PaymentMethod: Identifiable {
    let id: String
    let name: String
    let icon: String
    let last4: String?
}

struct TradeOffer: Identifiable {
    let id = UUID()
    let offeredGarmentId: String
    let requestedGarmentId: String
    let message: String?
}

struct Garment: Identifiable {
    let id = UUID()
    let name: String
    let brand: String
    let size: String?
    let imageUrl: String?
}

// MARK: - Flow Layout Helper
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

struct TransactionFlowView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionFlowView(mode: .buy, viewModel: ExchangeViewModel())
    }
}