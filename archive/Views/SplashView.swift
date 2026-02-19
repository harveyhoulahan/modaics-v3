import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var showLogo = false
    @State private var showTagline = false
    
    // Mosaic tile positions for animation
    private let mosaicTiles: [(x: CGFloat, y: CGFloat, size: CGFloat, delay: Double)] = [
        (0, -60, 40, 0.0),
        (-35, -35, 30, 0.05),
        (35, -35, 30, 0.1),
        (-60, 10, 35, 0.15),
        (0, 10, 35, 0.2),
        (60, 10, 35, 0.25),
        (-35, 55, 30, 0.3),
        (35, 55, 30, 0.35),
        (0, 90, 40, 0.4)
    ]
    
    var body: some View {
        ZStack {
            // Warm sand background
            DesignSystem.Colors.warmSand
                .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xlarge) {
                // Mosaic Animation
                ZStack {
                    ForEach(0..<mosaicTiles.count, id: \.self) { index in
                        let tile = mosaicTiles[index]
                        MosaicTile(
                            size: tile.size,
                            delay: tile.delay,
                            isAnimating: isAnimating
                        )
                        .offset(x: tile.x, y: tile.y)
                    }
                }
                .frame(width: 150, height: 150)
                
                // Logo Text
                VStack(spacing: DesignSystem.Spacing.small) {
                    Text("Modaics")
                        .font(DesignSystem.Typography.splashTitle)
                        .foregroundColor(DesignSystem.Colors.charcoal)
                        .opacity(showLogo ? 1 : 0)
                        .offset(y: showLogo ? 0 : 20)
                    
                    Text("Stories woven into what we wear")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.7))
                        .opacity(showTagline ? 1 : 0)
                        .offset(y: showTagline ? 0 : 15)
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Start mosaic animation
        withAnimation(.easeOut(duration: 0.6)) {
            isAnimating = true
        }
        
        // Show logo after mosaic forms
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.5)) {
                showLogo = true
            }
        }
        
        // Show tagline
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.easeOut(duration: 0.5)) {
                showTagline = true
            }
        }
    }
}

// MARK: - Mosaic Tile
struct MosaicTile: View {
    let size: CGFloat
    let delay: Double
    let isAnimating: Bool
    
    @State private var scale: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(DesignSystem.Colors.terracotta)
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onChange(of: isAnimating) { newValue in
                if newValue {
                    animateTile()
                }
            }
    }
    
    private func animateTile() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay)) {
            scale = 1
            rotation = 0
            opacity = 1
        }
    }
}

// MARK: - Preview
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}