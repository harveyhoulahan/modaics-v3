import SwiftUI

// MARK: - Loading State View
/// Mosaic shimmer effect — elegant loading that feels on-brand
struct LoadingStateView: View {
    let message: String?
    
    init(message: String? = nil) {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Mosaic shimmer
            MosaicShimmerView()
                .frame(width: 120, height: 120)
            
            // Message
            if let message = message {
                Text(message)
                    .font(.modaicsBodyRegular(size: 16))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Mosaic Shimmer View
/// The signature Modaics loading animation
struct MosaicShimmerView: View {
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            let tileSize = geometry.size.width / 4
            
            ZStack {
                // Background tiles
                ForEach(0..<4) { row in
                    ForEach(0..<4) { col in
                        let index = row * 4 + col
                        let delay = Double(index) * 0.05
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(shimmerColor(for: index))
                            .frame(width: tileSize - 4, height: tileSize - 4)
                            .position(
                                x: CGFloat(col) * tileSize + tileSize / 2,
                                y: CGFloat(row) * tileSize + tileSize / 2
                            )
                            .opacity(isAnimating ? 0.4 : 0.15)
                            .animation(
                                Animation.easeInOut(duration: 1.2)
                                    .delay(delay)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }
    
    private func shimmerColor(for index: Int) -> Color {
        let colors: [Color] = [
            .modaicsTerracotta,
            .modaicsDeepOlive,
            .modaicsTerracotta.opacity(0.7),
            .modaicsDeepOlive.opacity(0.7),
            .modaicsCharcoalClay.opacity(0.3),
            .modaicsTerracotta.opacity(0.5),
            .modaicsDeepOlive.opacity(0.5),
            .modaicsTerracotta.opacity(0.8)
        ]
        return colors[index % colors.count]
    }
}

// MARK: - Content Loading Placeholder
/// Skeleton placeholder for content loading
struct ContentLoadingPlaceholder: View {
    let rows: Int
    
    init(rows: Int = 3) {
        self.rows = rows
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<rows, id: \.self) { _ in
                LoadingRowPlaceholder()
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Loading Row Placeholder
struct LoadingRowPlaceholder: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.modaicsCharcoalClay.opacity(isAnimating ? 0.12 : 0.06))
                .frame(width: 72, height: 72)
            
            // Text placeholders
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.modaicsCharcoalClay.opacity(isAnimating ? 0.12 : 0.06))
                    .frame(width: 140, height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.modaicsCharcoalClay.opacity(isAnimating ? 0.12 : 0.06))
                    .frame(width: 80, height: 12)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.modaicsCharcoalClay.opacity(0.02))
        )
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating.toggle()
            }
        }
    }
}

// MARK: - Grid Loading Placeholder
struct GridLoadingPlaceholder: View {
    let columns: Int
    let rows: Int
    
    init(columns: Int = 3, rows: Int = 2) {
        self.columns = columns
        self.rows = rows
    }
    
    var body: some View {
        let gridItems = Array(repeating: GridItem(.flexible(), spacing: 12), count: columns)
        
        LazyVGrid(columns: gridItems, spacing: 12) {
            ForEach(0..<(columns * rows), id: \.self) { _ in
                GridItemPlaceholder()
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Grid Item Placeholder
struct GridItemPlaceholder: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.modaicsCharcoalClay.opacity(isAnimating ? 0.12 : 0.06))
            .aspectRatio(3/4, contentMode: .fit)
            .overlay(
                MosaicAccentShimmer()
                    .opacity(isAnimating ? 0.3 : 0.1)
            )
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    isAnimating.toggle()
                }
            }
    }
}

// MARK: - Mosaic Accent Shimmer
struct MosaicAccentShimmer: View {
    var body: some View {
        Canvas { context, size in
            let tileSize = size.width / 3
            
            for row in 0..<2 {
                for col in 0..<2 {
                    let rect = CGRect(
                        x: size.width - (CGFloat(col + 1) * tileSize),
                        y: size.height - (CGFloat(row + 1) * tileSize),
                        width: tileSize - 2,
                        height: tileSize - 2
                    )
                    
                    if (row + col) % 2 == 0 {
                        let path = Path(rect.insetBy(dx: 1, dy: 1))
                        context.fill(path, with: .color(.modaicsTerracotta))
                    }
                }
            }
        }
    }
}

// MARK: - Pull to Refresh Loading
struct PullToRefreshLoading: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Spinner
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.modaicsTerracotta.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .offset(y: isAnimating ? -8 : 0)
                        .animation(
                            Animation.easeInOut(duration: 0.5)
                                .delay(Double(i) * 0.15)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }
            .frame(width: 40, height: 40)
            
            Text("Refreshing...")
                .font(.modaicsBodyRegular(size: 15))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
        }
        .onAppear { isAnimating = true }
        .onDisappear { isAnimating = false }
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    let message: String?
    
    var body: some View {
        ZStack {
            Color.modaicsWarmSand.opacity(0.9)
                .ignoresSafeArea()
            
            LoadingStateView(message: message)
        }
    }
}

// MARK: - Preview
struct LoadingStateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            LoadingStateView(message: "Building your mosaic...")
            
            Divider()
            
            ContentLoadingPlaceholder(rows: 2)
            
            Divider()
            
            GridLoadingPlaceholder(columns: 3, rows: 2)
        }
        .padding(.vertical)
        .background(Color.modaicsWarmSand)
    }
}