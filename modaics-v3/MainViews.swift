import SwiftUI

struct DiscoveryView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Discover")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Find pre-loved pieces with stories")
                        .foregroundColor(.secondary)
                    
                    // Placeholder for discovery feed
                    LazyVStack(spacing: 16) {
                        ForEach(0..<5) { _ in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Discover")
        }
    }
}