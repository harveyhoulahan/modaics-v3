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
            Color.forest.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ProfileHeaderView(viewModel: headerVM)
                    SustainabilityDashboardView(viewModel: sustainabilityVM)
                    segmentSelector
                    contentArea
                    Spacer(minLength: 100)
                }
                .padding(.top, 16)
            }
        }
    }

    // MARK: - Segment Selector (underline tabs on forest surface)
    private var segmentSelector: some View {
        VStack(spacing: 0) {
            HStack(spacing: 24) {
                ForEach(ProfileSegment.allCases) { segment in
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
            Rectangle().fill(Color.sageWhite.opacity(0.12)).frame(height: 0.5)
        }
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
