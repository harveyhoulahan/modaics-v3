import SwiftUI

// MARK: - CommunityPostCard
/// Editorial community post card — canvas base, no OOTD pills, no emoji icons
public struct CommunityPostCard: View {
    let post: CommunityPost
    let onLikeTapped: () -> Void
    let onCommentTapped: () -> Void
    let onShareTapped: () -> Void
    let onBookmarkTapped: () -> Void

    @State private var isLiked: Bool
    @State private var showFullCaption: Bool = false

    public init(
        post: CommunityPost,
        onLikeTapped: @escaping () -> Void,
        onCommentTapped: @escaping () -> Void,
        onShareTapped: @escaping () -> Void,
        onBookmarkTapped: @escaping () -> Void
    ) {
        self.post = post
        self.onLikeTapped = onLikeTapped
        self.onCommentTapped = onCommentTapped
        self.onShareTapped = onShareTapped
        self.onBookmarkTapped = onBookmarkTapped
        _isLiked = State(initialValue: post.isLiked)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            postHeader
            if !post.imageURLs.isEmpty { imageGrid }
            captionBlock
            engagementLine
            Rectangle().fill(Color.hairline).frame(height: 0.5)
        }
        .background(Color.canvas)
    }

    // MARK: — Header: avatar + username + timestamp
    private var postHeader: some View {
        HStack(spacing: 10) {
            // Avatar 32pt
            ZStack {
                Circle()
                    .fill(Color.canvasSecond)
                    .frame(width: 32, height: 32)
                Text(post.username.prefix(1).uppercased())
                    .font(.labelS)
                    .foregroundColor(.inkSecondary)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(post.username)
                    .font(.labelS)
                    .foregroundColor(.inkPrimary)
                Text(post.formattedTime)
                    .font(.bodyS)
                    .foregroundColor(.inkMuted)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: — Image grid (1:1 cells, 8pt gutter)
    private var imageGrid: some View {
        Group {
            if post.imageURLs.count == 1 {
                imageCell(post.imageURLs[0])
                    .aspectRatio(4/5, contentMode: .fit)
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)],
                    spacing: 2
                ) {
                    ForEach(post.imageURLs.prefix(4).indices, id: \.self) { idx in
                        imageCell(post.imageURLs[idx])
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                if idx == 3 && post.imageURLs.count > 4 {
                                    Color.black.opacity(0.45)
                                    Text("+\(post.imageURLs.count - 4)")
                                        .font(.displayS)
                                        .foregroundColor(.white)
                                }
                            }
                    }
                }
            }
        }
        .clipped()
    }

    private func imageCell(_ url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let img):
                img.resizable().scaledToFill()
            default:
                Color.canvasSecond
                    .overlay(Image(systemName: "photo").foregroundColor(.inkMuted))
            }
        }
        .clipped()
    }

    // MARK: — Caption
    private var captionBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.caption)
                .font(.bodyM)
                .foregroundColor(.inkPrimary)
                .lineLimit(showFullCaption ? nil : 3)

            if post.caption.count > 120 {
                Button(showFullCaption ? "Less" : "More") {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showFullCaption.toggle()
                    }
                }
                .font(.bodyS)
                .foregroundColor(.brass)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: — Engagement line: "12 likes · 3 comments"
    private var engagementLine: some View {
        HStack(spacing: 16) {
            let likeCount = post.likes + (isLiked ? 1 : 0)
            Text("\(likeCount) like\(likeCount == 1 ? "" : "s") · \(post.comments.count) comment\(post.comments.count == 1 ? "" : "s")")
                .font(.bodyS)
                .foregroundColor(.inkMuted)

            Spacer()

            // Compact action row
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { isLiked.toggle() }
                    onLikeTapped()
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(isLiked ? .brass : .inkMuted)
                }

                Button(action: onCommentTapped) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.inkMuted)
                }

                Button(action: onShareTapped) {
                    Image(systemName: "arrow.up.forward")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.inkMuted)
                }

                Button(action: onBookmarkTapped) {
                    Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(post.isBookmarked ? .brass : .inkMuted)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}
