import SwiftUI

// MARK: - CommunityPostCard
/// Simplified community post card with editorial aesthetic
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
    @State private var isLiked: Bool = false
    @State private var likeScale: CGFloat = 1.0
    
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
        _isLiked = State(initialValue: post.isLiked)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Simplified header
            headerBar
            
            // Image grid
            if !post.imageURLs.isEmpty {
                editorialImageGrid
                    .frame(maxHeight: 320)
                    .clipped()
            }
            
            // Story/Caption section
            storySection
                .frame(maxHeight: 200, alignment: .top)
            
            // Simplified sustainability info
            if post.postType == .thriftFind || post.postType == .ecoTip {
                sustainabilityInfo
            }
            
            // Simplified action bar
            actionBar
        }
        .background(Color.modaicsSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.warmDivider, lineWidth: 0.5)
        )
        .cornerRadius(12)
    }
    
    // MARK: - Header Bar
    private var headerBar: some View {
        HStack(spacing: 0) {
            // Left: User info - simplified
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.modaicsSurfaceHighlight)
                        .frame(width: 40, height: 40)
                    
                    Text(post.username.prefix(1).uppercased())
                        .font(.bodyText(16, weight: .medium))
                        .foregroundColor(.sageWhite)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .font(.bodyText(14, weight: .medium))
                        .foregroundColor(.sageWhite)
                    
                    Text(post.formattedTime)
                        .font(.bodyText(11))
                        .foregroundColor(.sageMuted)
                }
            }
            
            Spacer()
            
            // Right: Post type as text label (NOT coloured pill)
            Text(post.postType.rawValue)
                .font(.bodyText(11, weight: .medium))
                .foregroundColor(.agedBrass)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.modaicsBackground)
    }
    
    // MARK: - Editorial Image Grid
    private var editorialImageGrid: some View {
        Group {
            if post.imageURLs.count == 1 {
                singleImageView(url: post.imageURLs[0])
                    .frame(height: 280)
                    .clipped()
            } else if post.imageURLs.count == 2 {
                HStack(spacing: 2) {
                    ForEach(0..<2, id: \.self) { index in
                        singleImageView(url: post.imageURLs[index])
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipped()
                    }
                }
            } else {
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        ForEach(0..<min(2, post.imageURLs.count), id: \.self) { index in
                            singleImageView(url: post.imageURLs[index])
                                .frame(maxWidth: .infinity)
                                .frame(height: 140)
                                .clipped()
                        }
                    }
                    if post.imageURLs.count > 2 {
                        HStack(spacing: 2) {
                            ForEach(2..<min(4, post.imageURLs.count), id: \.self) { index in
                                singleImageView(url: post.imageURLs[index])
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 140)
                                    .clipped()
                                    .overlay(
                                        post.imageURLs.count > 4 && index == 3 ?
                                        ZStack {
                                            Color.black.opacity(0.5)
                                            Text("+\(post.imageURLs.count - 4)")
                                                .font(.bodyText(16, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                        : nil
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func singleImageView(url: String) -> some View {
        Group {
            if let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.modaicsSurfaceHighlight)
                            .overlay(
                                ProgressView()
                                    .tint(Color.agedBrass)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Rectangle()
                            .fill(Color.modaicsSurfaceHighlight)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundColor(.sageMuted)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
    }
    
    // MARK: - Story Section
    private var storySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Caption
            Text(post.caption)
                .font(.bodyText(14))
                .foregroundColor(.sageWhite)
                .lineLimit(showFullCaption ? 8 : 3)
            
            if post.caption.count > 150 {
                Button(action: { withAnimation { showFullCaption.toggle() } }) {
                    Text(showFullCaption ? "Less" : "Read more")
                        .font(.bodyText(11, weight: .medium))
                        .foregroundColor(.agedBrass)
                }
            }
            
            // Tags - simplified, no excessive styling
            if !post.tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(post.tags.prefix(6), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.bodyText(11))
                            .foregroundColor(.sageMuted)
                    }
                }
            }
            
            // Location
            if let location = post.location {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                        .foregroundColor(.agedBrass)
                    Text(location)
                        .font(.bodyText(11))
                        .foregroundColor(.sageMuted)
                }
            }
        }
        .padding(16)
    }
    
    // MARK: - Sustainability Info (simplified)
    private var sustainabilityInfo: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.agedBrass)
                Text("CO₂ saved: 2.4kg")
                    .font(.bodyText(11))
                    .foregroundColor(.agedBrass)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.agedBrass)
                Text("Water: 1,800L")
                    .font(.bodyText(11))
                    .foregroundColor(.agedBrass)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Action Bar (simplified)
    private var actionBar: some View {
        HStack(spacing: 0) {
            // Like button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isLiked.toggle()
                    likeScale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation { likeScale = 1.0 }
                }
                onLikeTapped()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isLiked ? .agedBrass : .sageMuted)
                        .scaleEffect(likeScale)
                    
                    Text("\(post.likes + (isLiked ? 1 : 0))")
                        .font(.bodyText(12))
                        .foregroundColor(.sageMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            
            Divider()
                .background(Color.warmDivider)
            
            // Comment button
            Button(action: onCommentTapped) {
                HStack(spacing: 6) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 16))
                        .foregroundColor(.sageMuted)
                    
                    Text("\(post.comments.count)")
                        .font(.bodyText(12))
                        .foregroundColor(.sageMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            
            Divider()
                .background(Color.warmDivider)
            
            // Share button
            Button(action: onShareTapped) {
                Image(systemName: "arrow.up.forward")
                    .font(.system(size: 16))
                    .foregroundColor(.sageMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            
            Divider()
                .background(Color.warmDivider)
            
            // Bookmark button
            Button(action: onBookmarkTapped) {
                Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16))
                    .foregroundColor(post.isBookmarked ? .agedBrass : .sageMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
        .background(Color.modaicsBackground)
    }
}
