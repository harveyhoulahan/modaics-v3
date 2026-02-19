import SwiftUI

// MARK: - Collection View
/// Detailed view of a curated set within the wardrobe
/// Like opening a curated folder of stories
struct CollectionView: View {
    let collection: Collection
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGarment: Garment?
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            Color.modaicsWarmSand
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    
                    // Mood/Inspiration section
                    if let mood = collection.mood {
                        moodSection(mood: mood)
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                    }
                    
                    // Garments grid
                    garmentsSection
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    
                    // Collection story
                    if let story = collection.story {
                        storySection(story: story)
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedGarment) { garment in
            GarmentDetailView(garment: garment)
        }
        .alert("Delete Collection?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteCollection()
            }
        } message: {
            Text("This will remove the collection but keep all garments in your wardrobe.")
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.modaicsCharcoalClay)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
                
                Menu {
                    Button(action: { isEditing = true }) {
                        Label("Edit Collection", systemImage: "pencil")
                    }
                    
                    Button(action: { shareCollection() }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                        Label("Delete Collection", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.modaicsCharcoalClay)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                }
            }
            
            // Collection info
            VStack(spacing: 8) {
                Text(collection.name)
                    .font(.modaicsDisplayMedium(size: 28))
                    .foregroundColor(.modaicsCharcoalClay)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    Label("\(collection.garmentCount) pieces", systemImage: "hanger")
                        .font(.modaicsCaptionRegular(size: 14))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.7))
                    
                    if let createdAt = collection.createdAtFormatted {
                        Label(createdAt, systemImage: "calendar")
                            .font(.modaicsCaptionRegular(size: 14))
                            .foregroundColor(.modaicsCharcoalClay.opacity(0.7))
                    }
                }
            }
        }
    }
    
    // MARK: - Mood Section
    private func moodSection(mood: CollectionMood) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The Feeling")
                .font(.modaicsCaptionMedium(size: 14))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                .textCase(.uppercase)
            
            HStack(spacing: 12) {
                ForEach(mood.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.modaicsBodyMedium(size: 14))
                        .foregroundColor(.modaicsDeepOlive)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.modaicsDeepOlive.opacity(0.1))
                        )
                }
            }
            
            if let colorPalette = mood.colorPalette {
                HStack(spacing: 8) {
                    ForEach(colorPalette, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Garments Section
    private var garmentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Pieces")
                    .font(.modaicsHeadingSemiBold(size: 20))
                    .foregroundColor(.modaicsCharcoalClay)
                
                Spacer()
                
                Button(action: { addGarments() }) {
                    Label("Add", systemImage: "plus")
                        .font(.modaicsBodyMedium(size: 15))
                        .foregroundColor(.modaicsTerracotta)
                }
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 16)], spacing: 16) {
                ForEach(collection.garments) { garment in
                    CollectionGarmentCard(garment: garment) {
                        selectedGarment = garment
                    }
                }
            }
        }
    }
    
    // MARK: - Story Section
    private func storySection(story: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The Story")
                .font(.modaicsCaptionMedium(size: 14))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                .textCase(.uppercase)
            
            Text(story)
                .font(.modaicsBodyRegular(size: 16))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.8))
                .lineSpacing(6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.modaicsWarmSand.opacity(0.5))
        )
    }
    
    // MARK: - Actions
    private func shareCollection() {
        // Share functionality
    }
    
    private func addGarments() {
        // Add garments to collection
    }
    
    private func deleteCollection() {
        // Delete collection
        dismiss()
    }
}

// MARK: - Collection Garment Card
struct CollectionGarmentCard: View {
    let garment: Garment
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Image
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.modaicsWarmSand)
                        .aspectRatio(3/4, contentMode: .fit)
                    
                    Image(systemName: "tshirt")
                        .font(.system(size: 36))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.2))
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(garment.name)
                        .font(.modaicsBodyMedium(size: 15))
                        .foregroundColor(.modaicsCharcoalClay)
                        .lineLimit(1)
                    
                    Text(garment.brand)
                        .font(.modaicsCaptionRegular(size: 13))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                    
                    if let provenance = garment.provenance {
                        ProvenanceBadge(provenance: provenance)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Provenance Badge
struct ProvenanceBadge: View {
    let provenance: GarmentProvenance
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "person.circle")
                .font(.system(size: 10))
            
            Text("From \(provenance.previousOwner)")
                .font(.modaicsCaptionRegular(size: 11))
        }
        .foregroundColor(.modaicsTerracotta)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.modaicsTerracotta.opacity(0.1))
        )
    }
}

// MARK: - Garment Detail View (Sheet)
struct GarmentDetailView: View {
    let garment: Garment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Large garment image
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.modaicsWarmSand)
                            .frame(height: 400)
                        
                        Image(systemName: "tshirt")
                            .font(.system(size: 80))
                            .foregroundColor(.modaicsCharcoalClay.opacity(0.15))
                    }
                    .padding(.horizontal, 24)
                    
                    // Garment info
                    VStack(alignment: .leading, spacing: 16) {
                        Text(garment.name)
                            .font(.modaicsDisplayMedium(size: 28))
                            .foregroundColor(.modaicsCharcoalClay)
                        
                        Text(garment.brand)
                            .font(.modaicsHeadingSemiBold(size: 18))
                            .foregroundColor(.modaicsCharcoalClay.opacity(0.8))
                        
                        // Details
                        HStack(spacing: 24) {
                            if let size = garment.size {
                                DetailItem(label: "Size", value: size)
                            }
                            if let color = garment.color {
                                DetailItem(label: "Color", value: color)
                            }
                            if let condition = garment.condition {
                                DetailItem(label: "Condition", value: condition)
                            }
                        }
                        
                        // Provenance story
                        if let provenance = garment.provenance {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Its Journey")
                                    .font(.modaicsCaptionMedium(size: 14))
                                    .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                                    .textCase(.uppercase)
                                
                                Text("Previously loved by \(provenance.previousOwner)")
                                    .font(.modaicsBodyMedium(size: 16))
                                    .foregroundColor(.modaicsCharcoalClay)
                                
                                if let note = provenance.handoffNote {
                                    Text("\"\(note)\"")
                                        .font(.modaicsBodyRegular(size: 15))
                                        .foregroundColor(.modaicsCharcoalClay.opacity(0.8))
                                        .italic()
                                        .lineSpacing(4)
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.modaicsWarmSand.opacity(0.5))
                                        )
                                }
                            }
                            .padding(.top, 16)
                        }
                        
                        // Sustainability impact
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Impact")
                                .font(.modaicsCaptionMedium(size: 14))
                                .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                                .textCase(.uppercase)
                            
                            HStack(spacing: 24) {
                                ImpactBadge(value: "2,400L", label: "Water saved")
                                ImpactBadge(value: "8.5kg", label: "CO₂ prevented")
                            }
                        }
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationBarHidden(true)
            .background(Color.modaicsWarmSand.ignoresSafeArea())
        }
    }
}

// MARK: - Detail Item
struct DetailItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.modaicsCaptionRegular(size: 12))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.5))
            
            Text(value)
                .font(.modaicsBodyMedium(size: 15))
                .foregroundColor(.modaicsCharcoalClay)
        }
    }
}

// MARK: - Impact Badge
struct ImpactBadge: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.modaicsHeadingSemiBold(size: 18))
                .foregroundColor(.modaicsDeepOlive)
            
            Text(label)
                .font(.modaicsCaptionRegular(size: 12))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.modaicsDeepOlive.opacity(0.1))
        )
    }
}

// MARK: - Extended Models
struct CollectionMood {
    let tags: [String]
    let colorPalette: [Color]?
    let inspiration: String?
}

struct GarmentProvenance {
    let previousOwner: String
    let handoffNote: String?
    let acquiredDate: Date
    let exchangeType: ExchangeMode
}

// Extension to Collection for CollectionView
extension Collection {
    var mood: CollectionMood? {
        // Return mock mood for preview
        CollectionMood(
            tags: ["Minimal", "Timeless", "Neutral"],
            colorPalette: [.brown, .beige, .gray, .black],
            inspiration: "Quiet luxury meets sustainable living"
        )
    }
    
    var story: String? {
        "This collection represents my journey toward a more intentional wardrobe. Each piece was chosen for its quality, versatility, and the story it carries."
    }
    
    var createdAtFormatted: String? {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    // Mock garments for preview
    var garments: [Garment] {
        [
            Garment(name: "Cashmere Sweater", brand: "Everlane", size: "M", color: "Cream", condition: "Excellent", provenance: GarmentProvenance(previousOwner: "Sarah M.", handoffNote: "This sweater kept me warm through so many winters. I hope it does the same for you.", acquiredDate: Date(), exchangeType: .buy)),
            Garment(name: "Wool Trousers", brand: "COS", size: "32", color: "Charcoal", condition: "Good", provenance: nil),
            Garment(name: "Linen Shirt", brand: "ARKET", size: "M", color: "White", condition: "Like New", provenance: GarmentProvenance(previousOwner: "James L.", handoffNote: "Perfect for summer days. Treat it well!", acquiredDate: Date(), exchangeType: .trade))
        ]
    }
}

// Extension to Garment
extension Garment {
    var color: String? { "Neutral" }
    var condition: String? { "Excellent" }
    var provenance: GarmentProvenance? {
        GarmentProvenance(
            previousOwner: "Sarah M.",
            handoffNote: "This piece traveled with me to three countries. May it bring you adventures too.",
            acquiredDate: Date(),
            exchangeType: .buy
        )
    }
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView(collection: Collection(name: "Capsule Wardrobe", garmentCount: 12, previewGarments: [], createdAt: Date()))
    }
}