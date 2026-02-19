import SwiftUI

// MARK: - CommunityPostCard
/// Card component for displaying community posts in the feed
public struct CommunityPostCard: View {
    let post: CommunityPost
    let onLikeTapped: () -> Void
    let onCommentTapped: () -> Void
    let onShareTapped: () -> Void
    let onBookmarkTapped: () -> Void
    let onUserTapped: (() -> Void)?
    let onImageTapped: ((Int) -> Void)?
    let onMoreTapped: (() -> Void)?
    
    @State private var currentImageIndex: Int = 0
    @State private var showFullCaption: Bool = false
    @State private var isCaptionTruncated: Bool = false
    
    public init(
        post: CommunityPost,
        onLikeTapped: @escaping () -> Void,
        onCommentTapped: @escaping () -> Void,
        onShareTapped: @escaping () -> Void,
        onBookmarkTapped: @escaping () -> Void,
        onUserTapped: (() -> Void)? = nil,
        onImageTapped: ((Int) -> Void)? = nil,
        onMoreTapped: (() -> Void)? = nil
    ) {
        self.post = post
        self.onLikeTapped = onLikeTapped
        self.onCommentTapped = onCommentTapped
        self.onShareTapped = onShareTapped
        self.onBookmarkTapped = onBookmarkTapped
        self.onUserTapped = onUserTapped
        self.onImageTapped = onImageTapped
        self.onMoreTapped = onMoreTapped
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Image Carousel
            if !post.imageURLs.isEmpty {
                imageCarousel
            }
            
            // Action Bar
            actionBar
            
            // Caption
            captionSection
            
            // Tags
            if !post.tags.isEmpty {
                tagsSection
            }
            
            // Comments Preview
            if !post.comments.isEmpty {
                commentsPreview
            }
            
            // Time
            timeSection
        }
        .background(Color.modaicsSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
        )
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 12) {
            // Avatar
            Button(action: { onUserTapped?() }) {
                ZStack {
                    Circle()
                        .fill(Color.modaicsSurfaceHighlight)
                        .frame(width: 40, height: 40)
                    
                    if let avatar = post.avatar, let url = URL(string: avatar) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.sageMuted)
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.sageMuted)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // User Info
            VStack(alignment: .leading, spacing: 2) {
                Button(action: { onUserTapped?() }) {
                    Text(post.username)
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageWhite)
                }
                .buttonStyle(PlainButtonStyle())
                
                HStack(spacing: 6) {
                    // Post Type Badge
                    HStack(spacing: 4) {
                        Image(systemName: post.postType.icon)
                            .font(.system(size: 8))
                        Text(post.postType.rawValue.uppercased())
                            .font(.forestCaptionSmall)
                    }
                    .foregroundColor(Color(hex: post.postType.color))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: post.postType.color).opacity(0.15))
                    .cornerRadius(4)
                    
                    // Location
                    if let location = post.location {
                        HStack(spacing: 2) {
                            Image(systemName: "mappin")
                                .font(.system(size: 8))
                            Text(location)
                                .font(.forestCaptionSmall)
                        }
                        .foregroundColor(.sageMuted)
                    }
                }
            }
            
            Spacer()
            
            // More Button
            Button(action: { onMoreTapped?() }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18))
                    .foregroundColor(.sageMuted)
                    .rotationEffect(.degrees(90))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Image Carousel
    private var imageCarousel: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentImageIndex) {
                ForEach(0..<post.imageURLs.count, id: \.self) { index in
                    if let url = URL(string: post.imageURLs[index]) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(Color.modaicsSurfaceHighlight)
                                    .overlay(
                                        ProgressView()
                                            .tint(Color.luxeGold)
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(Color.modaicsSurfaceHighlight)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.sageMuted)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .tag(index)
                        .onTapGesture {
                            onImageTapped?(index)
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 400)
            .background(Color.modaicsBackgroundSecondary)
            
            // Page Indicators
            if post.imageURLs.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<post.imageURLs.count, id: \.self) { index in
                        Circle()
                            .fill(currentImageIndex == index ? Color.luxeGold : Color.sageWhite.opacity(0.5))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 12)
            }
        }
    }
    
    // MARK: - Action Bar
    private var actionBar: some View {
        HStack(spacing: 16) {
            // Like Button
            Button(action: onLikeTapped) {
                HStack(spacing: 4) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 22))
                        .foregroundColor(post.isLiked ? .red : .sageWhite)
                    
                    if post.likes > 0 {
                        Text(post.likeCountText)
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageWhite)
                    }
                }
            }
            
            // Comment Button
            Button(action: onCommentTapped) {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 22))
                        .foregroundColor(.sageWhite)
                    
                    if post.commentCount > 0 {
                        Text(post.commentCountText)
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageWhite)
                    }
                }
            }
            
            // Share Button
            Button(action: onShareTapped) {
                Image(systemName: "paperplane")
                    .font(.system(size: 22))
                    .foregroundColor(.sageWhite)
            }
            
            Spacer()
            
            // Bookmark Button
            Button(action: onBookmarkTapped) {
                Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 22))
                    .foregroundColor(post.isBookmarked ? Color.luxeGold : .sageWhite)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Caption Section
    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 4) {
                Text(post.username)
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageWhite)
                
                if showFullCaption {
                    Text(post.caption)
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageWhite)
                } else {
                    Text(post.caption)
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageWhite)
                        .lineLimit(2)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        let size = CGSize(
                                            width: geometry.size.width,
                                            height: .greatestFiniteMagnitude
                                        )
                                        let boundingRect = (post.caption as NSString)
                                            .boundingRect(
                                                with: size,
                                                options: .usesLineFragmentOrigin,
                                                attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)],
                                                context: nil
                                            )
                                        isCaptionTruncated = boundingRect.height > geometry.size.height
                                    }
                            }
                        )
                }
            }
            
            if isCaptionTruncated || showFullCaption {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showFullCaption.toggle()
                    }
                }) {
                    Text(showFullCaption ? "Show less" : "more")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Tags Section
    private var tagsSection: some View {
        FlowLayout(spacing: 8) {
            ForEach(post.tags, id: \.self) { tag in
                Text("#\(tag)")
                    .font(.forestCaptionMedium)
                    .foregroundColor(Color.luxeGold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Comments Preview
    private var commentsPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            if post.comments.count > 2 {
                Button(action: onCommentTapped) {
                    Text("View all \(post.commentCount) comments")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                }
            }
            
            ForEach(post.comments.prefix(2)) { comment in
                HStack(alignment: .top, spacing: 4) {
                    Text(comment.username)
                        .font(.forestBodySmall)
                        .foregroundColor(.sageWhite)
                    Text(comment.text)
                        .font(.forestBodySmall)
                        .foregroundColor(.sageWhite)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Time Section
    private var timeSection: some View {
        Text(post.formattedTime.uppercased())
            .font(.forestCaptionSmall)
            .foregroundColor(.sageSubtle)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
    }
}

// MARK: - Flow Layout (Helper)
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX,
                                      y: result.positions[index].y + bounds.minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var positions: [CGPoint] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - Preview
struct CommunityPostCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            ScrollView {
                CommunityPostCard(
                    post: CommunityPost.mockPosts[0],
                    onLikeTapped: {},
                    onCommentTapped: {},
                    onShareTapped: {},
                    onBookmarkTapped: {}
                )
                .padding()
            }
        }
    }
}
