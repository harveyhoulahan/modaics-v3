import SwiftUI

// MARK: - Community Segment
public enum CommunitySegment: String, CaseIterable, Identifiable {
    case feed = "Feed"
    case sketchbook = "Sketchbook"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .feed: return "bubble.left.and.bubble.right"
        case .sketchbook: return "book.closed"
        }
    }
}

// MARK: - Community View
/// Main Community tab with Feed and Sketchbook segments
public struct CommunityView: View {
    @StateObject private var feedViewModel = FeedViewModel()
    @StateObject private var sketchbookViewModel = ConsumerSketchbookViewModel()
    @State private var selectedSegment: CommunitySegment = .feed
    @State private var scrollOffset: CGFloat = 0
    
    private let headerHeight: CGFloat = 80
    private let collapsedThreshold: CGFloat = 40
    
    private var headerCollapseProgress: CGFloat {
        min(CGFloat(1), max(CGFloat(0), scrollOffset / collapsedThreshold))
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Collapsable Header
                communityHeader
                
                // Segment Selector
                segmentSelector
                
                // Content
                contentArea
            }
        }
    }
    
    // MARK: - Community Header
    private var communityHeader: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("COMMUNITY")
                        .font(.forestDisplaySmall)
                        .foregroundColor(.sageWhite)
                        .tracking(2)
                    
                    Spacer()
                    
                    // Notification bell
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.sageMuted)
                    }
                }
                
                Text("Connect with the Modaics community")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(Color.modaicsBackground)
            .frame(height: headerHeight * (CGFloat(1) - headerCollapseProgress * CGFloat(0.5)))
            .opacity(CGFloat(1) - headerCollapseProgress)
            .clipped()
        }
        .background(Color.modaicsBackground)
    }
    
    // MARK: - Segment Selector
    private var segmentSelector: some View {
        HStack(spacing: 0) {
            ForEach(CommunitySegment.allCases) { segment in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSegment = segment
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: segment.icon)
                            .font(.system(size: 14))
                        Text(segment.rawValue.uppercased())
                            .font(.forestCaptionSmall)
                    }
                    .foregroundColor(selectedSegment == segment ? .modaicsBackground : .sageWhite)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedSegment == segment ? Color.luxeGold : Color.modaicsSurface)
                }
            }
        }
        .background(Color.modaicsSurface)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    // MARK: - Content Area
    private var contentArea: some View {
        Group {
            switch selectedSegment {
            case .feed:
                SocialFeedView(viewModel: feedViewModel)
            case .sketchbook:
                sketchbookContent
    
    // MARK: - Content Area
    private var contentArea: some View {
        Group {
            switch selectedSegment {
            case .feed:
                SocialFeedView(viewModel: feedViewModel)
            case .sketchbook:
                SketchbookFeedView()
            }
        }
    }
}

// MARK: - Preview
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}
