import SwiftUI

// MARK: - Discover View
/// Search and browse all items, filters, AI visual search
struct DiscoverView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.modaicsDarkNavy
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Search Bar
                        HStack(spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.modaicsSilver)
                                TextField("Search items...", text: $searchQuery)
                                    .font(.modaicsBodyRegular)
                                    .foregroundColor(.modaicsTextWhite)
                            }
                            .padding(12)
                            .background(Color.modaicsPanelBlue)
                            .cornerRadius(8)
                            
                            // AI Visual Search Button
                            Button(action: {}) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.modaicsDarkBlue)
                                    .frame(width: 44, height: 44)
                                    .background(Color.modaicsIndustrialRed)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FilterChip(title: "ALL", isSelected: true)
                                FilterChip(title: "CLOTHING", isSelected: false)
                                FilterChip(title: "ACCESSORIES", isSelected: false)
                                FilterChip(title: "VINTAGE", isSelected: false)
                                FilterChip(title: "DESIGNER", isSelected: false)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Results Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(0..<10) { i in
                                DiscoverItemCard(index: i)
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

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.modaicsFinePrint)
            .foregroundColor(isSelected ? .modaicsDarkBlue : .modaicsSilver)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.modaicsIndustrialRed : Color.modaicsPanelBlue)
            .cornerRadius(4)
    }
}

// MARK: - Discover Item Card
struct DiscoverItemCard: View {
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.modaicsPanelBlue)
                .aspectRatio(0.8, contentMode: .fit)
                .overlay(
                    Text("IMG")
                        .font(.modaicsFinePrint)
                        .foregroundColor(.modaicsTextMedium)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Item \(index + 1)")
                    .font(.modaicsBodyEmphasis)
                    .foregroundColor(.modaicsTextWhite)
                    .lineLimit(1)
                
                Text("$99.00")
                    .font(.modaicsCaption)
                    .foregroundColor(.modaicsIndustrialRed)
            }
        }
    }
}

// MARK: - Preview
struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
            .environmentObject(AppState())
    }
}
