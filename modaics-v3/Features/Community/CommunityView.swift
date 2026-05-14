import SwiftUI

// MARK: - Community Segment
public enum CommunitySegment: String, CaseIterable, Identifiable {
    case feed       = "Feed"
    case sketchbook = "Sketchbook"
    public var id: String { rawValue }
    public var icon: String {
        switch self {
        case .feed:       return "bubble.left.and.bubble.right"
        case .sketchbook: return "book.closed"
        }
    }
}

// MARK: - Community View
public struct CommunityView: View {
    @StateObject private var feedViewModel = FeedViewModel()
    @State private var selectedSegment: CommunitySegment = .feed

    public init() {}

    public var body: some View {
        ZStack {
            Color.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                communityHeader
                segmentSelector
                contentArea
            }
        }
    }

    // MARK: — Header
    private var communityHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Community")
                    .font(.displayL)
                    .foregroundColor(.inkPrimary)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.inkPrimary)
                }
            }
            Text("Connect with the people of Modaics.")
                .font(.bodyM)
                .foregroundColor(.inkSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(Color.canvas)
    }

    // MARK: — Segment selector (underline tabs — no brass-filled pill)
    private var segmentSelector: some View {
        VStack(spacing: 0) {
            HStack(spacing: 24) {
                ForEach(CommunitySegment.allCases) { segment in
                    UnderlineFilter(segment.rawValue,
                                    isSelected: selectedSegment == segment,
                                    useBrass: true) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSegment = segment
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            Rectangle().fill(Color.hairline).frame(height: 0.5)
        }
        .background(Color.canvas)
    }

    // MARK: — Content
    private var contentArea: some View {
        Group {
            switch selectedSegment {
            case .feed:       SocialFeedView(viewModel: feedViewModel)
            case .sketchbook: SketchbookFeedView()
            }
        }
    }
}

// MARK: - Preview
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View { CommunityView() }
}
