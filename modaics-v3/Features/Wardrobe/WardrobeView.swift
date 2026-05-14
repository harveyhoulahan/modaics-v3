import SwiftUI
import Combine

// MARK: - WardrobeView
public struct WardrobeView: View {
    @StateObject private var viewModel = WardrobeViewModel()
    @State private var showingAddGarment = false
    @State private var selectedGarment: ModaicsGarment?

    public init() {}

    public var body: some View {
        ZStack {
            Color.canvas.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    wardrobeHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 4)

                    summaryLine
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)

                    garmentsSection
                        .padding(.horizontal, 16)

                    Color.clear.frame(height: 100)
                }
            }
        }
        .sheet(isPresented: $showingAddGarment) {
            AddGarmentPlaceholderView()
        }
        .onAppear { viewModel.loadWardrobe() }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: — Header
    private var wardrobeHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("My wardrobe")
                .font(.displayL)
                .foregroundColor(.inkPrimary)
            Spacer()
            Menu {
                Button("Recently added") { viewModel.sortBy = .recent }
                Button("Alphabetical")   { viewModel.sortBy = .alphabetical }
                Button("Brand")          { viewModel.sortBy = .brand }
                Button("Condition")      { viewModel.sortBy = .condition }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.inkPrimary)
            }
        }
    }

    // MARK: — Single summary line (replaces 4-icon stat grid)
    private var summaryLine: some View {
        Text("\(viewModel.garmentCount) pieces · est. \(viewModel.estimatedValue) · \(viewModel.sustainabilityScore) eco · \(String(format: "%.0f", viewModel.carbonSavedKg)) kg CO₂ saved")
            .font(.bodyS)
            .foregroundColor(.inkSecondary)
    }

    // MARK: — Garments grid
    private var garmentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 16) {
                    ForEach(0..<6, id: \.self) { _ in DSItemCardSkeleton() }
                }
            } else if viewModel.garments.isEmpty {
                wardrobeEmptyState
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 16
                ) {
                    ForEach(viewModel.garments) { garment in
                        DSItemCard(
                            brand: garment.brand ?? "Unknown",
                            name: garment.title,
                            price: garment.askingPrice.map { "$\(Int($0))" }
                        )
                        .onTapGesture { selectedGarment = garment }
                        .contextMenu {
                            Button(role: .destructive) {
                                Task { await viewModel.removeGarment(garment.id) }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: — Empty state
    private var wardrobeEmptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 60)
            Text("Your wardrobe is empty.")
                .font(.displayS)
                .foregroundColor(.inkPrimary)
            Text("Add pieces with stories to tell.")
                .font(.bodyM)
                .foregroundColor(.inkMuted)
                .multilineTextAlignment(.center)
            GhostCTA("Add a piece") { showingAddGarment = true }
                .frame(width: 200)
            Spacer().frame(height: 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

// MARK: - Add Garment Placeholder
struct AddGarmentPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.canvas.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()
                    Text("Add a piece")
                        .font(.displayL)
                        .foregroundColor(.inkPrimary)
                    Text("Take photos, tell its story, and add it to your wardrobe.")
                        .font(.bodyM)
                        .foregroundColor(.inkSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.bodyM)
                        .foregroundColor(.inkPrimary)
                }
            }
        }
    }
}

// MARK: - Preview
struct WardrobeView_Previews: PreviewProvider {
    static var previews: some View {
        WardrobeView()
    }
}
