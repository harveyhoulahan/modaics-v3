import SwiftUI
import Combine

// MARK: - Exchange View
/// The main exchange hub — Buy/Sell/Trade selection
/// Feels like stepping into a curated atelier, not a marketplace
struct ExchangeView: View {
    @StateObject private var viewModel = ExchangeViewModel()
    @State private var selectedMode: ExchangeMode?
    
    var body: some View {
        ZStack {
            // Warm sand background
            Color.modaicsWarmSand
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    
                    // Mode selection cards
                    modeSelectionSection
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    
                    // Recent activity
                    if !viewModel.recentExchanges.isEmpty {
                        recentActivitySection
                            .padding(.top, 40)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .fullScreenCover(item: $selectedMode) { mode in
            TransactionFlowView(mode: mode, viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadRecentExchanges()
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The Exchange")
                .font(.modaicsDisplayMedium(size: 32))
                .foregroundColor(.modaicsCharcoalClay)
            
            Text("Every garment has a journey. Continue the story.")
                .font(.modaicsBodyRegular(size: 16))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.7))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Mode Selection
    private var modeSelectionSection: some View {
        VStack(spacing: 16) {
            ExchangeModeCard(
                mode: .buy,
                title: "Discover",
                subtitle: "Find pieces with history",
                icon: "sparkles",
                description: "Browse curated pre-loved garments, each with a story to tell"
            ) {
                selectedMode = .buy
            }
            
            ExchangeModeCard(
                mode: .sell,
                title: "Pass On",
                subtitle: "Find your garment's next chapter",
                icon: "arrow.up.heart",
                description: "List pieces you no longer wear. Someone else is waiting."
            ) {
                selectedMode = .sell
            }
            
            ExchangeModeCard(
                mode: .trade,
                title: "Exchange",
                subtitle: "Direct swaps within the community",
                icon: "arrow.left.arrow.right",
                description: "Trade with fellow members. No money, just mutual appreciation."
            ) {
                selectedMode = .trade
            }
        }
    }
    
    // MARK: - Recent Activity
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.modaicsHeadingSemiBold(size: 20))
                .foregroundColor(.modaicsCharcoalClay)
                .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recentExchanges) { exchange in
                        RecentExchangeCard(exchange: exchange)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Exchange Mode Card
struct ExchangeModeCard: View {
    let mode: ExchangeMode
    let title: String
    let subtitle: String
    let icon: String
    let description: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon container
                ZStack {
                    Circle()
                        .fill(mode.backgroundColor)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(mode.accentColor)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.modaicsHeadingSemiBold(size: 18))
                        .foregroundColor(.modaicsCharcoalClay)
                    
                    Text(subtitle)
                        .font(.modaicsBodyRegular(size: 14))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.4))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(mode.accentColor.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Recent Exchange Card
struct RecentExchangeCard: View {
    let exchange: ExchangeActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Garment image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(exchange.mode.backgroundColor)
                .frame(width: 140, height: 160)
                .overlay(
                    Image(systemName: exchange.mode.iconName)
                        .font(.system(size: 32))
                        .foregroundColor(exchange.mode.accentColor.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exchange.garmentName)
                    .font(.modaicsBodyMedium(size: 14))
                    .foregroundColor(.modaicsCharcoalClay)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(exchange.status.color)
                        .frame(width: 6, height: 6)
                    
                    Text(exchange.status.displayText)
                        .font(.modaicsCaptionRegular(size: 12))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                }
            }
        }
        .frame(width: 140)
    }
}

// MARK: - Exchange Mode Enum
enum ExchangeMode: String, Identifiable {
    case buy, sell, trade
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .buy: return "sparkles"
        case .sell: return "arrow.up.heart"
        case .trade: return "arrow.left.arrow.right"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .buy: return .modaicsTerracotta.opacity(0.1)
        case .sell: return .modaicsDeepOlive.opacity(0.1)
        case .trade: return .modaicsWarmSand.opacity(0.5)
        }
    }
    
    var accentColor: Color {
        switch self {
        case .buy: return .modaicsTerracotta
        case .sell: return .modaicsDeepOlive
        case .trade: return .modaicsCharcoalClay
        }
    }
}

// MARK: - Exchange Status
enum ExchangeStatus {
    case pending, confirmed, shipped, delivered, completed
    
    var displayText: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .shipped: return "Shipped"
        case .delivered: return "Delivered"
        case .completed: return "Completed"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .confirmed: return .blue
        case .shipped: return .purple
        case .delivered: return .green
        case .completed: return .modaicsDeepOlive
        }
    }
}

// MARK: - Models
struct ExchangeActivity: Identifiable {
    let id = UUID()
    let garmentName: String
    let mode: ExchangeMode
    let status: ExchangeStatus
    let date: Date
}

// MARK: - Preview
struct ExchangeView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeView()
    }
}