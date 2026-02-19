import SwiftUI

// MARK: - Empty State View
/// Warm, encouraging copy for empty states
/// Makes the user feel invited, not rejected
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)?
    var actionTitle: String?
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon with decorative background
            ZStack {
                // Mosaic-inspired background pattern
                EmptyStateBackground()
                    .frame(width: 140, height: 140)
                
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.4))
            }
            
            // Text content
            VStack(spacing: 12) {
                Text(title)
                    .font(.modaicsHeadingSemiBold(size: 22))
                    .foregroundColor(.modaicsCharcoalClay)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.modaicsBodyRegular(size: 16))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            
            // Optional action button
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.modaicsBodySemiBold(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.modaicsTerracotta)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 8)
            }
        }
        .padding(24)
    }
}

// MARK: - Empty State Background
struct EmptyStateBackground: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2
            
            // Draw mosaic-inspired pattern
            for i in 0..<8 {
                let angle = Double(i) * .pi / 4
                let x = center.x + CGFloat(cos(angle)) * radius * 0.7
                let y = center.y + CGFloat(sin(angle)) * radius * 0.7
                
                let rect = CGRect(
                    x: x - 12,
                    y: y - 12,
                    width: 24,
                    height: 24
                )
                
                let path = Path(roundedRect: rect, cornerRadius: 4)
                context.fill(path, with: .color(.modaicsTerracotta.opacity(0.1)))
            }
            
            // Center circle
            let centerCircle = Path(ellipseIn: CGRect(
                x: center.x - 20,
                y: center.y - 20,
                width: 40,
                height: 40
            ))
            context.fill(centerCircle, with: .color(.modaicsDeepOlive.opacity(0.08)))
        }
    }
}

// MARK: - Common Empty State Presets
extension EmptyStateView {
    /// Empty wardrobe state
    static var emptyWardrobe: EmptyStateView {
        EmptyStateView(
            icon: "hanger",
            title: "Your wardrobe is waiting",
            message: "Start building your mosaic by adding pieces from the exchange or your existing collection.",
            action: {},
            actionTitle: "Browse Exchange"
        )
    }
    
    /// Empty search results
    static func noSearchResults(query: String) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No matches found",
            message: "We couldn't find anything for \"\(query)\". Try different keywords or browse our categories."
        )
    }
    
    /// Empty exchange history
    static var emptyExchangeHistory: EmptyStateView {
        EmptyStateView(
            icon: "arrow.left.arrow.right",
            title: "No exchanges yet",
            message: "Your exchange journey starts with a single step. Discover, sell, or trade to begin your story."
        )
    }
    
    /// Empty collection
    static var emptyCollection: EmptyStateView {
        EmptyStateView(
            icon: "square.stack.3d.up",
            title: "An empty canvas",
            message: "This collection is waiting for pieces that share a story. Add garments to curate your set."
        )
    }
    
    /// Network error
    static var networkError: EmptyStateView {
        EmptyStateView(
            icon: "wifi.exclamationmark",
            title: "Connection hiccup",
            message: "We're having trouble reaching our servers. Check your connection and we'll try again."
        )
    }
}

// MARK: - Preview
struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            EmptyStateView.emptyWardrobe
            
            Divider()
            
            EmptyStateView(
                icon: "sparkles",
                title: "Just getting started?",
                message: "Every great wardrobe begins with a single piece that sparks joy."
            )
        }
        .padding()
        .background(Color.modaicsWarmSand)
    }
}