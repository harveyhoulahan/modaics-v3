import SwiftUI

// MARK: - Home View
/// Personalized feed with new arrivals and recommendations
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.modaicsDarkNavy
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("MODAICS")
                                    .font(.modaicsDisplaySmall)
                                    .foregroundColor(.modaicsTextWhite)
                                Text("Home")
                                    .font(.modaicsBodyRegular)
                                    .foregroundColor(.modaicsTextMedium)
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.modaicsSilver)
                            }
                        }
                        .padding(.horizontal)
                        
                        // New Arrivals Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("NEW ARRIVALS")
                                .font(.modaicsLabel)
                                .foregroundColor(.modaicsIndustrialRed)
                            
                            // Placeholder for horizontal scroll
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(0..<5) { i in
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.modaicsPanelBlue)
                                            .frame(width: 140, height: 180)
                                            .overlay(
                                                Text("ITEM \(i+1)")
                                                    .font(.modaicsFinePrint)
                                                    .foregroundColor(.modaicsTextMedium)
                                            )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Personalized Feed Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("RECOMMENDED FOR YOU")
                                .font(.modaicsLabel)
                                .foregroundColor(.modaicsIndustrialRed)
                            
                            VStack(spacing: 16) {
                                ForEach(0..<3) { i in
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.modaicsPanelBlue)
                                        .frame(height: 200)
                                        .overlay(
                                            Text("RECOMMENDATION \(i+1)")
                                                .font(.modaicsBodyRegular)
                                                .foregroundColor(.modaicsTextMedium)
                                        )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppState())
    }
}
