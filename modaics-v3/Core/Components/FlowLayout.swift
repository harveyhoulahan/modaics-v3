import SwiftUI

// MARK: - FlowLayout
/// A layout container that arranges views in a flowing, wrapping layout
/// Similar to CSS flex-wrap behavior
public struct FlowLayout: Layout {
    var spacing: CGFloat
    var rowSpacing: CGFloat
    
    public init(spacing: CGFloat = 8, rowSpacing: CGFloat? = nil) {
        self.spacing = spacing
        self.rowSpacing = rowSpacing ?? spacing
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing, rowSpacing: rowSpacing)
        return result.size
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing, rowSpacing: rowSpacing)
        
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat, rowSpacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                // Check if we need to wrap to next row
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + rowSpacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                
                x += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
            
            // Calculate total size
            let totalHeight = y + rowHeight
            self.size = CGSize(width: maxWidth, height: totalHeight)
        }
    }
}

// MARK: - Preview
struct FlowLayout_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Categories")
                .font(.headline)
                .foregroundColor(.sageWhite)
            
            FlowLayout(spacing: 8) {
                ForEach(["Vintage", "Sustainable", "Local", "Handmade", "Organic", "Recycled", "Eco-Friendly", "Artisan"], id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.modaicsSurface)
                        .foregroundColor(.sageWhite)
                        .cornerRadius(16)
                }
            }
            .padding()
            .background(Color.modaicsBackground)
        }
        .preferredColorScheme(.dark)
    }
}
