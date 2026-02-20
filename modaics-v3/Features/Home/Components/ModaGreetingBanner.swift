import SwiftUI
import Combine

// MARK: - Greeting Banner View Model
@MainActor
class ModaGreetingViewModel: ObservableObject {
    @Published var greeting: String = "Discover pieces with stories"
    @Published var subtitle: String = "Sustainable fashion marketplace"
    @Published var searchHint: String = "Search for vintage Levi's..."
    @Published var funFact: String = ""
    @Published var showFunFact = false
    
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    
    init() {
        loadGreeting()
        loadSearchHint()
        
        // Refresh greeting periodically
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            Task { @MainActor in
                await self.refreshGreeting()
            }
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    func loadGreeting() {
        Task {
            await refreshGreeting()
        }
    }
    
    func refreshGreeting() async {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/greeting") else { return }
        
        var request = URLRequest(url: url)
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
                if let newGreeting = json["greeting"], newGreeting != greeting {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        greeting = newGreeting
                    }
                }
                if let newSubtitle = json["subtitle"] {
                    subtitle = newSubtitle
                }
            }
        } catch {
            // Keep current greeting on error
        }
    }
    
    func loadSearchHint() {
        Task {
            guard let url = URL(string: "\(APIConfig.baseURL)/api/greeting/search-hint") else { return }
            
            var request = URLRequest(url: url)
            if let token = AuthManager.shared.token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                   let hint = json["hint"] {
                    searchHint = hint
                }
            } catch {
                // Keep default on error
            }
        }
    }
    
    func loadFunFact() {
        Task {
            guard let url = URL(string: "\(APIConfig.baseURL)/api/greeting/daily-fact") else { return }
            
            var request = URLRequest(url: url)
            if let token = AuthManager.shared.token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                   let fact = json["fact"] {
                    withAnimation {
                        funFact = fact
                        showFunFact = true
                    }
                    
                    // Auto-hide after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation {
                            self.showFunFact = false
                        }
                    }
                }
            } catch {
                // Silently fail
            }
        }
    }
}

// MARK: - Dynamic Greeting Banner
struct ModaGreetingBanner: View {
    @StateObject private var viewModel = ModaGreetingViewModel()
    @Binding var searchText: String
    @State private var isSearchFocused = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Dynamic greeting
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.greeting)
                    .font(.forestHeadlineLarge)
                    .foregroundColor(.forestDark)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(viewModel.subtitle)
                    .font(.forestBody)
                    .foregroundColor(.sageMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            .onTapGesture {
                viewModel.loadFunFact()
            }
            
            // Search bar with dynamic hint
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundColor(.sageMuted)
                
                TextField(viewModel.searchHint, text: $searchText)
                    .font(.forestBody)
                    .foregroundColor(.forestDark)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.sageMuted)
                    }
                }
                
                // Moda AI button
                Button(action: { /* Open Moda chat */ }) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                        Text("Ask Moda")
                            .font(.forestSmall)
                    }
                    .foregroundColor(.luxeGold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.luxeGold.opacity(0.1))
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.modaicsBackgroundSecondary)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .overlay(
            // Fun fact tooltip
            Group {
                if viewModel.showFunFact {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.luxeGold)
                            Text(viewModel.funFact)
                                .font(.forestSmall)
                                .foregroundColor(.forestDark)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.luxeGold.opacity(0.15))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        )
    }
}

// MARK: - Search Bar with Moda Integration
struct ModaSearchBar: View {
    @Binding var text: String
    var onSubmit: () -> Void
    
    @StateObject private var viewModel = ModaGreetingViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundColor(.sageMuted)
            
            TextField(viewModel.searchHint, text: $text)
                .font(.forestBody)
                .foregroundColor(.forestDark)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit(onSubmit)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.sageMuted)
                }
            }
            
            // Moda button - only show when focused or text is empty
            if isFocused || text.isEmpty {
                Button(action: { /* Open Moda chat */ }) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                        Text("Ask Moda")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.luxeGold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.luxeGold.opacity(0.12))
                    .cornerRadius(12)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - API Config
private struct APIConfig {
    static let baseURL = "https://api.modaics.com"
}

// MARK: - Preview
struct ModaGreetingBanner_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ModaGreetingBanner(searchText: .constant(""))
            Spacer()
        }
        .background(Color.modaicsBackground)
    }
}
