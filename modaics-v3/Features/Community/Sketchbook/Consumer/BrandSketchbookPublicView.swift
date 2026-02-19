import SwiftUI

// MARK: - Sketchbook Header View
public struct SketchbookHeaderView: View {
    let sketchbook: Sketchbook
    let membership: SketchbookMembership?
    let isBrandView: Bool
    
    public init(sketchbook: Sketchbook, membership: SketchbookMembership? = nil, isBrandView: Bool = false) {
        self.sketchbook = sketchbook
        self.membership = membership
        self.isBrandView = isBrandView
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sketchbook.title ?? "Sketchbook")
                        .font(.forestHeadlineMedium)
                        .foregroundColor(.sageWhite)
                    
                    HStack(spacing: 8) {
                        Label("\(sketchbook.memberCount) members", systemImage: "person.2")
                            .font(.forestCaptionSmall)
                            .foregroundColor(.sageMuted)
                        
                        Label("\(sketchbook.postsCount) posts", systemImage: "doc.text")
                            .font(.forestCaptionSmall)
                            .foregroundColor(.sageMuted)
                    }
                }
                
                Spacer()
                
                // Access policy badge
                accessPolicyBadge
            }
            
            if let description = sketchbook.description {
                Text(description)
                    .font(.forestBodySmall)
                    .foregroundColor(.sageMuted)
                    .lineLimit(2)
            }
            
            if let membership = membership, membership.status == .active {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.modaicsEco)
                    Text("You're a member")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.modaicsEco)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.modaicsEco.opacity(0.15))
                .cornerRadius(16)
            }
        }
        .padding(16)
        .background(Color.modaicsSurface)
        .cornerRadius(12)
    }
    
    private var accessPolicyBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: iconForPolicy(sketchbook.accessPolicy))
                .font(.system(size: 12))
            Text(sketchbook.accessPolicy.displayName.uppercased())
                .font(.forestCaptionSmall)
        }
        .foregroundColor(colorForPolicy(sketchbook.accessPolicy))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(colorForPolicy(sketchbook.accessPolicy).opacity(0.15))
        .cornerRadius(16)
    }
    
    private func iconForPolicy(_ policy: SketchbookAccessPolicy) -> String {
        switch policy {
        case .public_access: return "globe"
        case .members_only: return "lock"
        case .private_access: return "eye.slash"
        }
    }
    
    private func colorForPolicy(_ policy: SketchbookAccessPolicy) -> Color {
        switch policy {
        case .public_access: return .modaicsEco
        case .members_only: return .luxeGold
        case .private_access: return .sageMuted
        }
    }
}

// MARK: - Brand Sketchbook Public View
public struct BrandSketchbookPublicView: View {
    let brandId: String
    @StateObject private var viewModel = ConsumerSketchbookViewModel()
    @Environment(\.dismiss) private var dismiss
    
    public init(brandId: String) {
        self.brandId = brandId
    }
    
    public var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let sketchbook = viewModel.sketchbook {
                        // Header
                        SketchbookHeaderView(sketchbook: sketchbook, membership: viewModel.membership)
                            .padding(.horizontal, 20)
                        
                        // Membership CTA
                        if viewModel.membership?.status != .active {
                            membershipCTA(sketchbook: sketchbook)
                                .padding(.horizontal, 20)
                        }
                        
                        // Posts
                        postsSection(sketchbook: sketchbook)
                            .padding(.horizontal, 20)
                        
                        // Locked content indicator
                        if viewModel.hasLockedContent {
                            lockedContentIndicator
                                .padding(.horizontal, 20)
                        }
                    } else {
                        ProgressView()
                            .tint(Color.luxeGold)
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
        .onAppear {
            Task {
                await viewModel.loadSketchbook(brandId: brandId)
                await viewModel.checkMembership()
            }
        }
    }
    
    private func membershipCTA(sketchbook: Sketchbook) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.luxeGold)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Members Only Content")
                        .font(.forestHeadlineSmall)
                        .foregroundColor(.sageWhite)
                    
                    Text("Join to access exclusive posts and early drops")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageMuted)
                }
                
                Spacer()
            }
            
            Button(action: {
                Task {
                    switch sketchbook.membershipRule {
                    case .autoApprove:
                        await viewModel.joinSketchbook()
                    case .requestApproval, .spendThreshold:
                        await viewModel.requestMembership()
                    case .inviteOnly:
                        break // Can't join via button
                    }
                }
            }) {
                HStack {
                    Image(systemName: buttonIcon(for: sketchbook.membershipRule))
                    Text(buttonTitle(for: sketchbook.membershipRule))
                        .font(.forestHeadlineSmall)
                }
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
                .cornerRadius(12)
            }
            .disabled(sketchbook.membershipRule == .inviteOnly)
            
            if sketchbook.membershipRule == .spendThreshold,
               let amount = sketchbook.minSpendAmount,
               let months = sketchbook.minSpendWindowMonths {
                Text("Spend $\(Int(amount)) in the last \(months) months to unlock")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.modaicsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func postsSection(sketchbook: Sketchbook) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("POSTS")
                .font(.forestCaptionMedium)
                .foregroundColor(.sageMuted)
            
            ForEach(viewModel.visiblePosts) { post in
                SketchbookPostRow(post: post, viewModel: viewModel)
            }
        }
    }
    
    private var lockedContentIndicator: some View {
        HStack {
            Image(systemName: "lock.fill")
                .foregroundColor(.luxeGold)
            
            Text("🔒 \(viewModel.lockedPostCount) more posts — Become a member to unlock")
                .font(.forestCaptionSmall)
                .foregroundColor(.sageMuted)
            
            Spacer()
        }
        .padding(12)
        .background(Color.modaicsSurface)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.luxeGold.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
        )
    }
    
    private func buttonTitle(for rule: SketchbookMembershipRule) -> String {
        switch rule {
        case .autoApprove: return "Join for Free"
        case .requestApproval: return "Request Access"
        case .spendThreshold: return "Unlock Sketchbook"
        case .inviteOnly: return "Invite Only"
        }
    }
    
    private func buttonIcon(for rule: SketchbookMembershipRule) -> String {
        switch rule {
        case .autoApprove: return "person.badge.plus"
        case .requestApproval: return "paperplane"
        case .spendThreshold: return "lock.open"
        case .inviteOnly: return "envelope.badge"
        }
    }
}

// MARK: - Preview
struct BrandSketchbookPublicView_Previews: PreviewProvider {
    static var previews: some View {
        BrandSketchbookPublicView(brandId: "brand-001")
            .background(Color.modaicsBackground)
    }
}