import SwiftUI

// MARK: - Sketchbook Feed View (Redesigned)
public struct SketchbookFeedView: View {
    @StateObject private var viewModel = ConsumerSketchbookViewModel()
    @State private var selectedPost: SketchbookPost? = nil
    @State private var showPostDetail = false
    @State private var selectedBrand: Sketchbook? = nil
    @State private var showBrandDetail = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 24) {
                    // Featured sketchbooks carousel
                    featuredSketchbooksSection
                    
                    // Latest posts
                    ForEach(viewModel.posts) { post in
                        ModaicsSketchbookCard(
                            post: post,
                            viewModel: viewModel,
                            onTap: {
                                selectedPost = post
                                showPostDetail = true
                            },
                            onBrandTap: { brand in
                                selectedBrand = brand
                                showBrandDetail = true
                            },
                            onVote: { optionId in
                                viewModel.voteInPoll(post: post, optionId: optionId)
                            },
                            onReact: {
                                viewModel.toggleReaction(for: post)
                            }
                        )
                    }
                    
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .sheet(item: $selectedPost) { post in
            SketchbookPostDetailSheet(post: post, viewModel: viewModel)
        }
        .sheet(item: $selectedBrand) { brand in
            BrandSketchbookDetailSheet(sketchbook: brand, viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadMockData()
        }
    }
    
    // MARK: - Featured Sketchbooks
    private var featuredSketchbooksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("FEATURED SKETCHBOOKS")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.luxeGold)
                
                Spacer()
                
                Button("SEE ALL") {
                    // Show all sketchbooks
                }
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.sageMuted)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Sketchbook.mockSketchbooks) { sketchbook in
                        FeaturedSketchbookCard(sketchbook: sketchbook) {
                            selectedBrand = sketchbook
                            showBrandDetail = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Featured Sketchbook Card
struct FeaturedSketchbookCard: View {
    let sketchbook: Sketchbook
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Brand avatar placeholder
                ZStack {
                    Rectangle()
                        .fill(Color.modaicsSurfaceHighlight)
                        .frame(width: 80, height: 80)
                    
                    Text(sketchbook.title?.prefix(1) ?? "S")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.luxeGold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(sketchbook.title ?? "Sketchbook")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.sageWhite)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 10))
                        Text("\(sketchbook.memberCount)")
                            .font(.system(size: 11, design: .monospaced))
                    }
                    .foregroundColor(.sageMuted)
                }
                
                // Access badge
                HStack(spacing: 4) {
                    Image(systemName: sketchbook.accessPolicy == .public_access ? "globe" : "lock.fill")
                        .font(.system(size: 8))
                    Text(sketchbook.accessPolicy.displayName.uppercased())
                        .font(.system(size: 9, design: .monospaced))
                }
                .foregroundColor(sketchbook.accessPolicy == .public_access ? .modaicsEco : .luxeGold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    (sketchbook.accessPolicy == .public_access ? Color.modaicsEco : Color.luxeGold)
                        .opacity(0.15)
                )
            }
            .frame(width: 120)
            .padding(12)
            .background(Color.modaicsSurface)
            .overlay(
                Rectangle()
                    .stroke(Color.luxeGold.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modaics Sketchbook Card
struct ModaicsSketchbookCard: View {
    let post: SketchbookPost
    @ObservedObject var viewModel: ConsumerSketchbookViewModel
    let onTap: () -> Void
    let onBrandTap: (Sketchbook) -> Void
    let onVote: (String) -> Void
    let onReact: () -> Void
    
    @State private var hasVoted = false
    @State private var selectedOption: String? = nil
    @State private var isReacted = false
    
    var sketchbook: Sketchbook? {
        Sketchbook.mockSketchbooks.first { $0.id == post.sketchbookId }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Header with brand info
                HStack(spacing: 12) {
                    // Brand avatar
                    ZStack {
                        Rectangle()
                            .fill(Color.modaicsSurfaceHighlight)
                            .frame(width: 44, height: 44)
                        
                        Text(post.authorDisplayName?.prefix(1) ?? "B")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.luxeGold)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.authorDisplayName?.uppercased() ?? "BRAND")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.sageWhite)
                        
                        Text(post.postType.displayName.uppercased())
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(hex: post.postType.color))
                    }
                    
                    Spacer()
                    
                    // Visibility badge
                    if post.visibility == .membersOnly {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                            Text("MEMBERS")
                                .font(.system(size: 9, design: .monospaced))
                        }
                        .foregroundColor(.luxeGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.luxeGold.opacity(0.15))
                    }
                }
                .padding(16)
                .background(Color.modaicsBackground)
                
                // Content
                VStack(alignment: .leading, spacing: 12) {
                    Text(post.title)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(.sageWhite)
                        .lineLimit(2)
                    
                    if let body = post.body {
                        Text(body)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.sageMuted)
                            .lineLimit(3)
                    }
                    
                    // Poll if present
                    if let pollQuestion = post.pollQuestion, let options = post.pollOptions {
                        pollSection(question: pollQuestion, options: options)
                    }
                    
                    // Drop countdown if present
                    if post.postType == .drop {
                        dropCountdown
                    }
                    
                    // Event info if present
                    if post.postType == .event {
                        eventInfo
                    }
                }
                .padding(16)
                
                // Action bar
                HStack(spacing: 0) {
                    Button(action: {
                        isReacted.toggle()
                        onReact()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: isReacted ? "flame.fill" : "flame")
                                .font(.system(size: 16))
                                .foregroundColor(isReacted ? .luxeGold : .sageMuted)
                            
                            Text("\(post.reactionCount + (isReacted ? 1 : 0))")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.sageMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    
                    Divider().background(Color.modaicsSurfaceHighlight)
                    
                    Button(action: onTap) {
                        HStack(spacing: 6) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 16))
                                .foregroundColor(.sageMuted)
                            
                            Text("\(post.commentCount)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.sageMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    
                    Divider().background(Color.modaicsSurfaceHighlight)
                    
                    Button(action: { /* Share */ }) {
                        Image(systemName: "arrow.up.forward")
                            .font(.system(size: 16))
                            .foregroundColor(.sageMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .background(Color.modaicsBackground)
                .overlay(
                    Rectangle()
                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
            }
            .background(Color.modaicsSurface)
            .overlay(
                Rectangle()
                    .stroke(Color.luxeGold.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Poll Section
    private func pollSection(question: String, options: [PollOption]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(question)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(.sageWhite)
            
            ForEach(options) { option in
                Button(action: {
                    if !hasVoted {
                        selectedOption = option.id
                        hasVoted = true
                        onVote(option.id)
                    }
                }) {
                    HStack {
                        Text(option.text)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.sageWhite)
                        
                        Spacer()
                        
                        if hasVoted {
                            let total = options.reduce(0) { $0 + $1.voteCount }
                            let percentage = total > 0 ? Int(Double(option.voteCount) / Double(total) * 100) : 0
                            
                            Text("\(percentage)%")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(selectedOption == option.id ? .luxeGold : .sageMuted)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        GeometryReader { geo in
                            if hasVoted {
                                let total = options.reduce(0) { $0 + $1.voteCount }
                                let width = total > 0 ? geo.size.width * CGFloat(option.voteCount) / CGFloat(total) : 0
                                
                                HStack {
                                    Rectangle()
                                        .fill(selectedOption == option.id ? Color.luxeGold.opacity(0.3) : Color.luxeGold.opacity(0.1))
                                        .frame(width: width)
                                    Spacer()
                                }
                            }
                        }
                    )
                    .background(Color.modaicsSurfaceHighlight)
                    .overlay(
                        Rectangle()
                            .stroke(selectedOption == option.id ? Color.luxeGold : Color.modaicsSurfaceHighlight, lineWidth: selectedOption == option.id ? 2 : 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(hasVoted)
            }
        }
        .padding(12)
        .background(Color.modaicsBackground.opacity(0.5))
    }
    
    // MARK: - Drop Countdown
    private var dropCountdown: some View {
        HStack(spacing: 12) {
            Image(systemName: "bag.fill")
                .font(.system(size: 20))
                .foregroundColor(.luxeGold)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("DROP IN")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.sageMuted)
                
                Text("2 DAYS 14 HOURS")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.luxeGold)
            }
            
            Spacer()
            
            Text("REMIND ME")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.modaicsBackground)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.luxeGold)
        }
        .padding(12)
        .background(Color.luxeGold.opacity(0.1))
        .overlay(
            Rectangle()
                .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Event Info
    private var eventInfo: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 20))
                .foregroundColor(.modaicsEco)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("EVENT")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.sageMuted)
                
                Text("MAR 15 · 7:00 PM")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.modaicsEco)
            }
            
            Spacer()
            
            Text("RSVP")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.modaicsBackground)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.modaicsEco)
        }
        .padding(12)
        .background(Color.modaicsEco.opacity(0.1))
        .overlay(
            Rectangle()
                .stroke(Color.modaicsEco.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Sketchbook Post Detail Sheet
struct SketchbookPostDetailSheet: View {
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
                            Rectangle()
                                .fill(Color.modaicsSurfaceHighlight)
                                .frame(width: 50, height: 50)
                            
                            Text(post.authorDisplayName?.prefix(1) ?? "B")
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundColor(.luxeGold)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(post.authorDisplayName?.uppercased() ?? "BRAND")
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                                .foregroundColor(.sageWhite)
                            
                            Text(post.postType.displayName.uppercased())
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color(hex: post.postType.color))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 16) {
                        Text(post.title)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.sageWhite)
                        
                        if let body = post.body {
                            Text(body)
                                .font(.system(size: 15, design: .monospaced))
                                .foregroundColor(.sageWhite)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal, 20)
                    
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

// MARK: - Brand Sketchbook Detail Sheet
struct BrandSketchbookDetailSheet: View {
    let sketchbook: Sketchbook
    @ObservedObject var viewModel: ConsumerSketchbookViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingJoinConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    SketchbookHeaderView(sketchbook: sketchbook, membership: viewModel.membership)
                        .padding(.horizontal, 20)
                    
                    // Membership CTA
                    if viewModel.membership?.status != .active {
                        membershipCTA
                            .padding(.horizontal, 20)
                    }
                    
                    // Posts
                    VStack(alignment: .leading, spacing: 16) {
                        Text("LATEST POSTS")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.luxeGold)
                            .padding(.horizontal, 20)
                        
                        ForEach(viewModel.posts.filter { $0.sketchbookId == sketchbook.id }) { post in
                            ModaicsSketchbookCard(
                                post: post,
                                viewModel: viewModel,
                                onTap: {},
                                onBrandTap: { _ in },
                                onVote: { _ in },
                                onReact: {}
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 20)
            }
            .background(Color.modaicsBackground)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.sageWhite)
                }
            }
        }
    }
    
    private var membershipCTA: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.luxeGold)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Join the Sketchbook")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.sageWhite)
                    
                    Text("Get exclusive access to drops, events, and behind-the-scenes content")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.sageMuted)
                }
                
                Spacer()
            }
            
            Button(action: { showingJoinConfirmation = true }) {
                Text(joinButtonTitle)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.modaicsBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.luxeGold, Color.luxeGold.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .padding(16)
        .background(Color.modaicsSurface)
        .overlay(
            Rectangle()
                .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1)
        )
        .alert("Join Sketchbook?", isPresented: $showingJoinConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Join") {
                Task {
                    switch sketchbook.membershipRule {
                    case .autoApprove:
                        await viewModel.joinSketchbook()
                    default:
                        await viewModel.requestMembership()
                    }
                }
            }
        } message: {
            Text("You'll get access to exclusive content from \(sketchbook.title ?? "this brand")")
        }
    }
    
    private var joinButtonTitle: String {
        switch sketchbook.membershipRule {
        case .autoApprove: return "JOIN FOR FREE"
        case .requestApproval: return "REQUEST ACCESS"
        case .spendThreshold: return "UNLOCK WITH PURCHASE"
        case .inviteOnly: return "INVITE ONLY"
        }
    }
}