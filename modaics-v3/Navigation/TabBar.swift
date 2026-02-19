import SwiftUI
import UIKit

// MARK: - Custom Industrial Tab Bar
struct IndustrialTabBar: View {
    @Binding var selectedTab: Tab
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        VStack(spacing: 0) {
            // Top border line
            Rectangle()
                .fill(Color.modaicsGunmetal)
                .frame(height: 1)
            
            HStack(spacing: 0) {
                ForEach(Tab.allCases) { tab in
                    TabBarItem(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: { selectTab(tab) }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 70)
            .background(
                Color.modaicsDarkBlue
                    .overlay(
                        // Subtle industrial texture overlay
                        Color.modaicsGraphite.opacity(0.1)
                    )
            )
        }
    }
    
    private func selectTab(_ tab: Tab) {
        hapticFeedback.prepare()
        hapticFeedback.impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedTab = tab
        }
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Icon
                ZStack {
                    // Background glow for active state
                    if isSelected {
                        Circle()
                            .fill(Color.modaicsIndustrialRed.opacity(0.2))
                            .frame(width: 44, height: 44)
                            .blur(radius: 8)
                    }
                    
                    // Icon image
                    Image(systemName: isSelected ? tab.icon : tab.inactiveIcon)
                        .font(.system(size: tab.isSpecial ? 28 : 22, weight: .semibold))
                        .foregroundColor(iconColor)
                        .frame(width: 32, height: 32)
                }
                .frame(height: 36)
                
                // Label
                Text(tab.label)
                    .font(.modaicsTabLabel)
                    .foregroundColor(isSelected ? .modaicsActive : .modaicsInactive)
            }
        }
        .buttonStyle(IndustrialTabButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    private var iconColor: Color {
        if isSelected {
            return tab.isSpecial ? .modaicsActive : .modaicsActive
        } else {
            return .modaicsSilver
        }
    }
}

// MARK: - Industrial Button Style
struct IndustrialTabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
    }
}

// MARK: - Preview
struct IndustrialTabBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.modaicsDarkNavy
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                IndustrialTabBar(selectedTab: .constant(.home))
            }
        }
    }
}
