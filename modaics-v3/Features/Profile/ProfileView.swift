import SwiftUI

// MARK: - Profile Segment
public enum ProfileSegment: String, CaseIterable, Identifiable {
    case wardrobe = "Wardrobe"
    case saved = "Saved"
    case activity = "Activity"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .wardrobe: return "tshirt"
        case .saved: return "heart"
        case .activity: return "list.bullet"
        }
    }
}

// MARK: - Profile View
public struct ProfileView: View {
    @StateObject private var headerVM = ProfileHeaderViewModel()
    @StateObject private var sustainabilityVM = SustainabilityViewModel()
    @StateObject private var wardrobeVM = ProfileWardrobeViewModel()
    @State private var selectedSegment: ProfileSegment = .wardrobe
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile Header
                    ProfileHeaderView(viewModel: headerVM)
                    
                    // Sustainability Dashboard
                    SustainabilityDashboardView(viewModel: sustainabilityVM)
                    
                    // Segment Selector
                    segmentSelector
                    
                    // Content based on selected segment
                    contentArea
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 16)
            }
        }
    }
    
    // MARK: - Segment Selector
    private var segmentSelector: some View {
        HStack(spacing: 0) {
            ForEach(ProfileSegment.allCases) { segment in
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
                    .foregroundColor(selectedSegment == segment ? .sageWhite : .sageMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedSegment == segment
                        ? Color.luxeGold
                        : Color.modaicsSurface
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color.modaicsSurface)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Content Area
    @ViewBuilder
    private var contentArea: some View {
        switch selectedSegment {
        case .wardrobe:
            ProfileWardrobeContentView(viewModel: wardrobeVM)
        case .saved:
            SavedItemsView(viewModel: wardrobeVM)
        case .activity:
            ActivityView(viewModel: wardrobeVM)
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
}
