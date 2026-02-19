import SwiftUI

// MARK: - Sketchbook Feed View
public struct SketchbookFeedView: View {
    @ObservedObject var viewModel: ConsumerSketchbookViewModel
    
    public init(viewModel: ConsumerSketchbookViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.posts) { post in
                    SketchbookPostRow(post: post, viewModel: viewModel)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Sketchbook Post Row
struct SketchbookPostRow: View {
    let post: SketchbookPost
    @ObservedObject var viewModel: ConsumerSketchbookViewModel
    @State private var showDetail = false
    
    var body: some View {
        Button(action: { showDetail = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // Brand Header
                HStack(spacing: 12) {
                    // Brand Avatar
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
                    
                    // Visibility badge
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
        .sheet(isPresented: $showDetail) {
            SketchbookPostDetailView(post: post, viewModel: viewModel)
        }
    }
}

// MARK: - Sketchbook Post Detail View
struct SketchbookPostDetailView: View {
    let post: SketchbookPost
    @ObservedObject var viewModel: ConsumerSketchbookViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.luxeGold.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Text(String(post.authorDisplayName?.prefix(1) ?? "B"))
                                .font(.forestDisplaySmall)
                                .foregroundColor(.luxeGold)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(post.authorDisplayName ?? "Brand")
                                .font(.forestHeadlineSmall)
                                .foregroundColor(.sageWhite)
                            
                            Text(post.postType.displayName.uppercased())
                                .font(.forestCaptionSmall)
                                .foregroundColor(Color(hex: post.postType.color))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 12) {
                        Text(post.title)
                            .font(.forestHeadlineMedium)
                            .foregroundColor(.sageWhite)
                        
                        if let body = post.body {
                            Text(body)
                                .font(.forestBodyMedium)
                                .foregroundColor(.sageWhite)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Poll
                    if let pollQuestion = post.pollQuestion, let options = post.pollOptions {
                        PollView(question: pollQuestion, options: options, post: post, viewModel: viewModel)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 20)
            }
            .background(Color.modaicsBackground)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.luxeGold)
                }
            }
        }
    }
}

// MARK: - Poll View
struct PollView: View {
    let question: String
    let options: [PollOption]
    let post: SketchbookPost
    @ObservedObject var viewModel: ConsumerSketchbookViewModel
    @State private var hasVoted = false
    @State private var selectedOption: String? = nil
    
    var totalVotes: Int {
        options.reduce(0) { $0 + $1.voteCount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question)
                .font(.forestHeadlineSmall)
                .foregroundColor(.sageWhite)
            
            ForEach(options) { option in
                Button(action: {
                    if !hasVoted {
                        selectedOption = option.id
                        hasVoted = true
                        viewModel.voteInPoll(post: post, optionId: option.id)
                    }
                }) {
                    HStack {
                        Text(option.text)
                            .font(.forestBodyMedium)
                            .foregroundColor(.sageWhite)
                        
                        Spacer()
                        
                        if hasVoted {
                            Text("\(Int(Double(option.voteCount) / Double(max(totalVotes, 1)) * 100))%")
                                .font(.forestCaptionSmall)
                                .foregroundColor(.sageMuted)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(hasVoted ? Color.modaicsSurface : Color.modaicsSurfaceHighlight)
                            .overlay(
                                GeometryReader { geo in
                                    if hasVoted {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedOption == option.id ? Color.luxeGold.opacity(0.3) : Color.luxeGold.opacity(0.1))
                                            .frame(width: geo.size.width * CGFloat(option.voteCount) / CGFloat(max(totalVotes, 1)))
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedOption == option.id ? Color.luxeGold : Color.modaicsSurfaceHighlight, lineWidth: selectedOption == option.id ? 2 : 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(hasVoted)
            }
            
            Text("\(totalVotes) votes")
                .font(.forestCaptionSmall)
                .foregroundColor(.sageMuted)
        }
        .padding(16)
        .background(Color.modaicsSurface.opacity(0.5))
        .cornerRadius(12)
    }
}

// MARK: - Helper Extensions
extension Date {
    func timeAgo() -> String {
        let interval = Date().timeIntervalSince(self)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else if interval < 604800 {
            return "\(Int(interval / 86400))d ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: self)
        }
    }
}

// MARK: - Preview
struct SketchbookFeedView_Previews: PreviewProvider {
    static var previews: some View {
        SketchbookFeedView(viewModel: ConsumerSketchbookViewModel())
            .background(Color.modaicsBackground)
    }
}