import SwiftUI

// MARK: - Item Detail Sheet
struct ItemDetailSheet: View {
    let item: ModaicsGarment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Image
                        imageSection
                        
                        // Content
                        VStack(alignment: .leading, spacing: 20) {
                            // Title & Brand
                            titleSection
                            
                            // Price & Exchange Type
                            priceSection
                            
                            // Condition & Size
                            detailsSection
                            
                            // Story/Description
                            if !item.description.isEmpty {
                                storySection
                            }
                            
                            // Actions
                            actionsSection
                            
                            Spacer(minLength: 40)
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.sageMuted)
                    }
                }
            }
        }
    }
    
    // MARK: - Image Section
    private var imageSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.modaicsSurface)
                .frame(height: 400)
            
            Image(systemName: "photo")
                .font(.system(size: 80))
                .foregroundColor(.sageSubtle)
        }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text((item.brand?.name ?? "Unknown").uppercased())
                .font(.forestCaptionLarge)
                .foregroundColor(.luxeGold)
                .tracking(2)
            
            Text(item.title)
                .font(.forestDisplaySmall)
                .foregroundColor(.sageWhite)
            
            Text(item.category.rawValue.capitalized)
                .font(.forestBodyMedium)
                .foregroundColor(.sageMuted)
        }
    }
    
    // MARK: - Price Section
    private var priceSection: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            if let listingPrice = item.listingPrice {
                Text("\(listingPrice, format: .currency(code: "USD"))")
                    .font(.forestDisplaySmall)
                    .foregroundColor(.luxeGold)
                
                if let originalPrice = item.originalPrice, originalPrice > listingPrice {
                    Text("\(originalPrice, format: .currency(code: "USD"))")
                        .font(.forestBodyLarge)
                        .foregroundColor(.sageMuted)
                        .strikethrough()
                }
            }
            
            Spacer()
            
            // Exchange type badge
            Text(exchangeTypeText)
                .font(.forestCaptionMedium)
                .foregroundColor(.modaicsBackground)
                .tracking(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.modaicsFern))
        }
    }
    
    private var exchangeTypeText: String {
        switch item.exchangeType {
        case .sell: return "FOR SALE"
        case .trade: return "FOR TRADE"
        case .sellOrTrade: return "SALE OR TRADE"
        case .none: return ""
        }
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        HStack(spacing: 16) {
            DetailPill(icon: "star.fill", text: item.condition.displayName)
            DetailPill(icon: "ruler", text: item.size.label)
            
            if let era = item.era {
                DetailPill(icon: "clock", text: era.rawValue)
            }
        }
    }
    
    // MARK: - Story Section
    private var storySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("THE STORY")
                .font(.forestCaptionMedium)
                .foregroundColor(.sageMuted)
                .tracking(1)
            
            Text(item.description)
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.modaicsSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
        )
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: {}) {
                HStack {
                    Image(systemName: "message.fill")
                    Text("MESSAGE SELLER")
                        .tracking(1)
                }
                .font(.forestBodyMedium)
                .foregroundColor(.modaicsBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.luxeGold)
                .cornerRadius(12)
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "heart")
                    Text("SAVE FOR LATER")
                        .tracking(1)
                }
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.modaicsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.luxeGold.opacity(0.5), lineWidth: 1)
                )
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Detail Pill
struct DetailPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text.uppercased())
                .font(.forestCaptionSmall)
                .tracking(1)
        }
        .foregroundColor(.modaicsFern)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.modaicsFern.opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(Color.modaicsFern.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Legacy Event Detail Sheet (for Home page)
struct LegacyEventDetailSheet: View {
    let event: ModaicsEvent
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Date header
                        dateHeader
                        
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text(event.title)
                                .font(.forestDisplaySmall)
                                .foregroundColor(.sageWhite)
                            
                            Text(event.location)
                                .font(.forestBodyLarge)
                                .foregroundColor(.sageMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Attendees
                        HStack(spacing: 8) {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.modaicsFern)
                            Text("\(event.attendees) people attending")
                                .font(.forestBodyMedium)
                                .foregroundColor(.sageWhite)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Description placeholder
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ABOUT THIS EVENT")
                                .font(.forestCaptionMedium)
                                .foregroundColor(.sageMuted)
                                .tracking(1)
                            
                            Text("Join us for an amazing fashion event featuring vintage finds, sustainable brands, and community connection.")
                                .font(.forestBodyMedium)
                                .foregroundColor(.sageWhite)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Actions
                        VStack(spacing: 12) {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("ATTEND EVENT")
                                        .tracking(1)
                                }
                                .font(.forestBodyMedium)
                                .foregroundColor(.modaicsBackground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.luxeGold)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("SHARE EVENT")
                                        .tracking(1)
                                }
                                .font(.forestBodyMedium)
                                .foregroundColor(.sageWhite)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.modaicsSurface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
                                )
                                .cornerRadius(12)
                            }
                        }
                        .padding(.top, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.sageMuted)
                    }
                }
            }
        }
    }
    
    private var dateHeader: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text(event.day)
                    .font(.forestDisplayMedium)
                    .foregroundColor(.luxeGold)
                Text(event.month)
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.sageMuted)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.modaicsSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.luxeGold.opacity(0.3), lineWidth: 2)
                    )
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Save the date")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                Text("Starts at 10:00 AM")
                    .font(.forestBodyLarge)
                    .foregroundColor(.sageWhite)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct ItemDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailSheet(
            item: MockData.vintageDenimJacket
        )
    }
}

struct LegacyEventDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        LegacyEventDetailSheet(
            event: ModaicsEvent(
                title: "Vintage Market",
                location: "Bondi Beach, Sydney",
                day: "15",
                month: "MAR",
                attendees: 234
            )
        )
    }
}