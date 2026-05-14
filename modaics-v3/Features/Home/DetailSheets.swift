import SwiftUI

// MARK: - Item Detail Sheet
struct ItemDetailSheet: View {
    let item: ModaicsGarment
    @Environment(\.dismiss) private var dismiss
    @State private var isSaved: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.canvas.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Full-bleed hero image — no corner radius
                        heroImage

                        VStack(alignment: .leading, spacing: 24) {
                            // Brand + title + price
                            titleBlock

                            Rectangle().fill(Color.hairline).frame(height: 0.5)

                            // Condition + size (two-column, no pills)
                            conditionSizeRow

                            Rectangle().fill(Color.hairline).frame(height: 0.5)

                            // Story
                            if !item.description.isEmpty {
                                storyBlock
                            }

                            // CTAs
                            actionBlock

                            Spacer(minLength: 60)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.inkPrimary)
                    }
                }
            }
        }
    }

    // MARK: — Full-bleed hero
    private var heroImage: some View {
        ZStack(alignment: .topTrailing) {
            GeometryReader { geo in
                Color.canvasSecond
                    .frame(width: geo.size.width, height: geo.size.width * 1.25)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 48, weight: .ultraLight))
                            .foregroundColor(.inkMuted)
                    )
            }
            .frame(height: UIScreen.main.bounds.width * 1.25)

            // Save link — top-right of image
            Button(action: { isSaved.toggle() }) {
                Text(isSaved ? "Saved" : "Save")
                    .font(.labelS)
                    .foregroundColor(isSaved ? .hunter : .inkSecondary)
                    .underline()
            }
            .padding(16)
        }
    }

    // MARK: — Title block
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text((item.brand?.name ?? "Unknown").uppercased())
                .font(.labelS)
                .foregroundColor(.hunter)
                .kerning(1.5)

            Text(item.title)
                .font(.displayL)
                .foregroundColor(.inkPrimary)

            if let price = item.listingPrice {
                Text(price, format: .currency(code: "AUD"))
                    .font(.displayM)
                    .foregroundColor(.hunter)
            }
        }
    }

    // MARK: — Condition + Size (no pill bubbles)
    private var conditionSizeRow: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Condition")
                    .font(.labelS)
                    .foregroundColor(.inkMuted)
                Text(item.condition.displayName)
                    .font(.bodyM)
                    .foregroundColor(.inkPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text("Size")
                    .font(.labelS)
                    .foregroundColor(.inkMuted)
                Text(item.size.label)
                    .font(.bodyM)
                    .foregroundColor(.inkPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }

    // MARK: — Story block
    private var storyBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("Story")
            Text(item.description)
                .font(.bodyM)
                .foregroundColor(.inkPrimary)
                .lineSpacing(4)
        }
    }

    // MARK: — Action block
    private var actionBlock: some View {
        VStack(spacing: 12) {
            PrimaryCTA("Buy now") {}
            GhostCTA("Make offer") {}
        }
    }
}

// MARK: - Legacy Event Detail Sheet
struct LegacyEventDetailSheet: View {
    let event: ModaicsEvent
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.canvas.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Date + title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(event.day) \(event.month)")
                                .font(.labelS)
                                .foregroundColor(.hunter)
                                .kerning(1.5)

                            Text(event.title)
                                .font(.displayL)
                                .foregroundColor(.inkPrimary)

                            Text(event.location)
                                .font(.bodyM)
                                .foregroundColor(.inkSecondary)
                        }

                        Rectangle().fill(Color.hairline).frame(height: 0.5)

                        Text("\(event.attendees) attending")
                            .font(.bodyM)
                            .foregroundColor(.inkMuted)

                        SectionLabel("About this event")
                        Text("Join us for an amazing fashion event featuring vintage finds, sustainable brands, and community connection.")
                            .font(.bodyM)
                            .foregroundColor(.inkPrimary)
                            .lineSpacing(4)

                        VStack(spacing: 12) {
                            PrimaryCTA("Attend event") {}
                            GhostCTA("Share event") {}
                        }
                        .padding(.top, 12)

                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.inkPrimary)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct ItemDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailSheet(item: MockData.vintageDenimJacket)
    }
}
