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
            }
        }
    }
    
    // MARK: - Sketchbook Content
    private var sketchbookContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(sketchbookViewModel.posts) { post in
                    sketchbookPostRow(for: post)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Sketchbook Post Row
    private func sketchbookPostRow(for post: SketchbookPost) -> some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 12) {
                // Brand Header
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.luxeGold.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Text(String(post.authorDisplayName?.prefix(1) ?? "B"))
                            .font(.forestHeadlineSmall)
                            .foregroundColor(.luxeGold)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.authorDisplayName ?? "Brand")
                            .font(.forestBodyMedium)
                            .foregroundColor(.sageWhite)
                        
                        Text(post.postType.displayName.uppercased())
                            .font(.forestCaptionSmall)
                            .foregroundColor(Color(hex: post.postType.color))
                    }
                    
                    Spacer()
                    
                    if post.visibility == .membersOnly {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.luxeGold)
                    }
                }
                
                // Post Content
                Text(post.title)
                    .font(.forestHeadlineSmall)
                    .foregroundColor(.sageWhite)
                    .multilineTextAlignment(.leading)
                
                if let body = post.body {
                    Text(body)
                        .font(.forestBodySmall)
                        .foregroundColor(.sageMuted)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Engagement
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                            .font(.system(size: 14))
                        Text("\(post.reactionCount)")
                            .font(.forestCaptionSmall)
                    }
                    .foregroundColor(.sageMuted)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 14))
                        Text("\(post.commentCount)")
                            .font(.forestCaptionSmall)
                    }
                    .foregroundColor(.sageMuted)
                    
                    Spacer()
                    
                    Text(post.createdAt?.timeAgo() ?? "")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageSubtle)
                }
            }
            .padding(16)
            .background(Color.modaicsSurface)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Date Helper
extension Date {
    func timeAgo() -> String {
        let interval = Date().timeIntervalSince(self)
        if interval < 60 { return "Just now" }
        else if interval < 3600 { return "\(Int(interval / 60))m ago" }
        else if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        else if interval < 604800 { return "\(Int(interval / 86400))d ago" }
        else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: self)
        }
    }
}

// MARK: - Preview
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}