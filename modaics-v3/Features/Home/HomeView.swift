import SwiftUI

// MARK: - Home View (Editorial v3)
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedItem: ModaicsGarment?
    @State private var selectedEvent: ModaicsEvent?
    @State private var showItemDetail = false
    @State private var showEventDetail = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.canvas.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Spacer for floating header
                    Spacer().frame(height: 60)

                    // Greeting + hero headline
                    heroSection
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 48)

                    // Trending now
                    trendingSection
                        .padding(.bottom, 48)

                    // Moda's Edit — dark forest editorial card
                    DSEditorialCard(
                        headline: "Moda's Edit",
                        subheadline: "This week's curated selection",
                        ctaLabel: "Read →",
                        variant: .dark
                    ) {}
                    .padding(.horizontal, 20)
                    .padding(.bottom, 48)

                    // Picked for you
                    pickedForYouSection
                        .padding(.bottom, 48)

                    // Happening near you
                    eventsSection
                        .padding(.bottom, 48)

                    // Sustainability editorial card
                    DSEditorialCard(
                        headline: "Your impact",
                        subheadline: "How your wardrobe is changing fashion.",
                        ctaLabel: "Discover →",
                        variant: .light
                    ) {}
                    .padding(.horizontal, 20)
                    .padding(.bottom, 48)

                    // New in
                    newInSection
                        .padding(.bottom, 80)
                }
            }

            // Floating header
            floatingHeader
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showItemDetail) {
            if let item = selectedItem { ItemDetailSheet(item: item) }
        }
        .sheet(isPresented: $showEventDetail) {
            if let event = selectedEvent { LegacyEventDetailSheet(event: event) }
        }
        .onAppear { viewModel.loadHomeData() }
    }

    // MARK: — Floating header
    private var floatingHeader: some View {
        HStack {
            Text("modaics")
                .font(.editorialDisplayMedium(24))
                .foregroundColor(.inkPrimary)

            Spacer()

            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(.inkPrimary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Color.canvas.opacity(0.95))
    }

    // MARK: — Hero
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.greeting)
                .font(.labelM)
                .foregroundColor(.inkSecondary)

            Text("Pieces with stories")
                .font(.displayXL)
                .foregroundColor(.inkPrimary)
                .lineSpacing(4)
        }
    }

    // MARK: — Trending
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionLabel("Trending now")
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    if viewModel.trendingPieces.isEmpty {
                        ForEach(0..<4, id: \.self) { _ in
                            DSItemCardSkeleton().frame(width: 140)
                        }
                    } else {
                        ForEach(viewModel.trendingPieces.prefix(6)) { garment in
                            DSItemCard(
                                brand: garment.brand?.name,
                                name: garment.title,
                                price: garment.listingPrice
                            )
                            .frame(width: 140)
                            .onTapGesture { selectedItem = garment; showItemDetail = true }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: — Picked for you
    private var pickedForYouSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionLabel("Picked for you")
                .padding(.horizontal, 20)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                spacing: 24
            ) {
                ForEach(viewModel.pickedForYou.prefix(4)) { item in
                    DSItemCard(
                        brand: item.garment.brand?.name,
                        name: item.garment.title,
                        price: item.garment.listingPrice
                    )
                    .onTapGesture { selectedItem = item.garment; showItemDetail = true }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: — Events
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionLabel("Happening near you")
                Spacer()
                Button("See all") {}
                    .font(.bodyS)
                    .foregroundColor(.inkPrimary)
                    .underline()
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.nearbyEvents) { event in
                        DSEventCard(
                            title: event.title,
                            venue: event.location,
                            dateLabel: "\(event.day) \(event.month)",
                            attendees: event.attendees,
                            width: 260
                        )
                        .onTapGesture { selectedEvent = event; showEventDetail = true }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: — New in
    private var newInSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionLabel("New in")
                .padding(.horizontal, 20)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                spacing: 24
            ) {
                ForEach(viewModel.trendingPieces.suffix(4)) { garment in
                    DSItemCard(
                        brand: garment.brand?.name,
                        name: garment.title,
                        price: garment.listingPrice
                    )
                    .onTapGesture { selectedItem = garment; showItemDetail = true }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Legacy EventDetailSheet wrapper (for Home's ModaicsEvent type)
struct LegacyEventDetailSheet: View {
    let event: ModaicsEvent
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.inkPrimary)
                }
            }
            .padding()

            Text(event.title)
                .font(.displayL)
                .foregroundColor(.inkPrimary)
                .padding(.horizontal, 20)

            Text(event.location)
                .font(.bodyM)
                .foregroundColor(.inkSecondary)

            Spacer()
        }
        .background(Color.canvas)
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppState())
    }
}
