import SwiftUI

// MARK: - Community View
/// Posts, events, swaps, sketchbook feed
struct CommunityView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedSegment: CommunitySegment = .posts
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.modaicsDarkNavy
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Text("COMMUNITY")
                                .font(.modaicsDisplaySmall)
                                .foregroundColor(.modaicsTextWhite)
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20))
                                    .foregroundColor(.modaicsIndustrialRed)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Segmented Control
                        HStack(spacing: 0) {
                            ForEach(CommunitySegment.allCases) { segment in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedSegment = segment
                                    }
                                }) {
                                    Text(segment.title)
                                        .font(.modaicsLabel)
                                        .foregroundColor(selectedSegment == segment ? .modaicsDarkBlue : .modaicsSilver)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            selectedSegment == segment ? Color.modaicsIndustrialRed : Color.modaicsPanelBlue
                                        )
                                }
                            }
                        }
                        .background(Color.modaicsPanelBlue)
                        .cornerRadius(4)
                        .padding(.horizontal)
                        
                        // Content
                        LazyVStack(spacing: 16) {
                            switch selectedSegment {
                            case .posts:
                                ForEach(0..<5) { i in
                                    CommunityPostCard(index: i)
                                }
                            case .events:
                                ForEach(0..<3) { i in
                                    EventCard(index: i)
                                }
                            case .swaps:
                                ForEach(0..<4) { i in
                                    SwapCard(index: i)
                                }
                            case .sketchbook:
                                ForEach(0..<6) { i in
                                    SketchbookCard(index: i)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Community Segments
enum CommunitySegment: Int, CaseIterable, Identifiable {
    case posts = 0
    case events = 1
    case swaps = 2
    case sketchbook = 3
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .posts: return "POSTS"
        case .events: return "EVENTS"
        case .swaps: return "SWAPS"
        case .sketchbook: return "SKETCHES"
        }
    }
}

// MARK: - Community Post Card
struct CommunityPostCard: View {
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User Header
            HStack {
                Circle()
                    .fill(Color.modaicsPanelBlue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.modaicsSilver)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("User \(index + 1)")
                        .font(.modaicsBodyEmphasis)
                        .foregroundColor(.modaicsTextWhite)
                    Text("2h ago")
                        .font(.modaicsCaption)
                        .foregroundColor(.modaicsTextMedium)
                }
                
                Spacer()
            }
            
            // Post Content
            Text("Just added this vintage piece to my collection! Love the details and craftsmanship. What do you think?")
                .font(.modaicsBodyRegular)
                .foregroundColor(.modaicsTextLight)
            
            // Post Image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.modaicsPanelBlue)
                .frame(height: 200)
                .overlay(
                    Text("POST IMAGE")
                        .font(.modaicsFinePrint)
                        .foregroundColor(.modaicsTextMedium)
                )
            
            // Actions
            HStack(spacing: 24) {
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart")
                        Text("24")
                    }
                    .font(.modaicsCaption)
                    .foregroundColor(.modaicsSilver)
                }
                
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                        Text("8")
                    }
                    .font(.modaicsCaption)
                    .foregroundColor(.modaicsSilver)
                }
                
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.2.squarepath")
                        Text("3")
                    }
                    .font(.modaicsCaption)
                    .foregroundColor(.modaicsSilver)
                }
            }
        }
        .padding()
        .background(Color.modaicsDarkBlue)
        .cornerRadius(8)
    }
}

// MARK: - Event Card
struct EventCard: View {
    let index: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Date Badge
            VStack {
                Text("FEB")
                    .font(.modaicsFinePrint)
                    .foregroundColor(.modaicsIndustrialRed)
                Text("\(index + 15)")
                    .font(.modaicsHeadline3)
                    .foregroundColor(.modaicsTextWhite)
            }
            .frame(width: 60)
            .padding(.vertical, 12)
            .background(Color.modaicsPanelBlue)
            .cornerRadius(8)
            
            // Event Info
            VStack(alignment: .leading, spacing: 6) {
                Text("Vintage Market Pop-up \(index + 1)")
                    .font(.modaicsBodyEmphasis)
                    .foregroundColor(.modaicsTextWhite)
                
                Text("Brooklyn, NY • 2PM - 8PM")
                    .font(.modaicsCaption)
                    .foregroundColor(.modaicsTextMedium)
                
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.modaicsSilver)
                    Text("\(45 + index * 10) attending")
                        .font(.modaicsMicro)
                        .foregroundColor(.modaicsSilver)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.modaicsDarkBlue)
        .cornerRadius(8)
    }
}

// MARK: - Swap Card
struct SwapCard: View {
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("SWAP REQUEST")
                    .font(.modaicsFinePrint)
                    .foregroundColor(.modaicsIndustrialRed)
                Spacer()
                Text("Pending")
                    .font(.modaicsFinePrint)
                    .foregroundColor(.modaicsWarningAmber)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.modaicsWarningAmber.opacity(0.2))
                    .cornerRadius(4)
            }
            
            HStack(spacing: 12) {
                // User's item
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.modaicsPanelBlue)
                        .frame(width: 80, height: 80)
                    Text("Your Item")
                        .font(.modaicsMicro)
                        .foregroundColor(.modaicsTextMedium)
                }
                
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 20))
                    .foregroundColor(.modaicsSilver)
                
                // Their item
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.modaicsPanelBlue)
                        .frame(width: 80, height: 80)
                    Text("Their Item")
                        .font(.modaicsMicro)
                        .foregroundColor(.modaicsTextMedium)
                }
            }
            
            HStack {
                Button("Decline") {}
                    .font(.modaicsLabel)
                    .foregroundColor(.modaicsSilver)
                
                Spacer()
                
                Button("Accept") {}
                    .font(.modaicsLabel)
                    .foregroundColor(.modaicsDarkBlue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.modaicsIndustrialRed)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color.modaicsDarkBlue)
        .cornerRadius(8)
    }
}

// MARK: - Sketchbook Card
struct SketchbookCard: View {
    let index: Int
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.modaicsPanelBlue)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                VStack {
                    Spacer()
                    Text("Sketch \(index + 1)")
                        .font(.modaicsFinePrint)
                        .foregroundColor(.modaicsTextMedium)
                        .padding(.bottom, 8)
                }
            )
    }
}

// MARK: - Preview
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
            .environmentObject(AppState())
    }
}
