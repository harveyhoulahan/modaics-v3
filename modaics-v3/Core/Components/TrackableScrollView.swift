import SwiftUI
import UIKit

// MARK: - TrackableScrollView
// UIViewRepresentable wrapper for UIScrollView with reliable scroll offset detection
// Uses threshold of -10 for header collapse detection
// NOT using GeometryReader for better performance

public struct TrackableScrollView<Content: View>: UIViewRepresentable {
    let axes: Axis.Set
    let showIndicators: Bool
    let threshold: CGFloat
    let onScroll: (CGPoint) -> Void
    let onScrollNearTop: ((Bool) -> Void)?
    let content: Content
    
    @Binding var scrollOffset: CGPoint
    
    public init(
        _ axes: Axis.Set = .vertical,
        showIndicators: Bool = false,
        threshold: CGFloat = -10,
        scrollOffset: Binding<CGPoint>,
        onScroll: @escaping (CGPoint) -> Void = { _ in },
        onScrollNearTop: ((Bool) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showIndicators = showIndicators
        self.threshold = threshold
        self._scrollOffset = scrollOffset
        self.onScroll = onScroll
        self.onScrollNearTop = onScrollNearTop
        self.content = content()
    }
    
    public func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsVerticalScrollIndicator = showIndicators
        scrollView.showsHorizontalScrollIndicator = showIndicators
        scrollView.alwaysBounceVertical = axes.contains(.vertical)
        scrollView.alwaysBounceHorizontal = axes.contains(.horizontal)
        scrollView.backgroundColor = .clear
        
        // Create hosting controller for SwiftUI content
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(hostingController.view)
        
        // Store reference to hosting controller
        context.coordinator.hostingController = hostingController
        
        // Set up constraints
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Enable refresh control if needed
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(Color(hex: "#D9BD6B"))
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        context.coordinator.refreshControl = refreshControl
        
        return scrollView
    }
    
    public func updateUIView(_ uiView: UIScrollView, context: Context) {
        // Update content
        context.coordinator.hostingController?.rootView = content
        context.coordinator.hostingController?.view.setNeedsLayout()
        context.coordinator.hostingController?.view.layoutIfNeeded()
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    public class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: TrackableScrollView
        var hostingController: UIHostingController<Content>?
        var refreshControl: UIRefreshControl?
        var isNearTop: Bool = true
        
        init(_ parent: TrackableScrollView) {
            self.parent = parent
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset
            
            DispatchQueue.main.async {
                self.parent.scrollOffset = offset
                self.parent.onScroll(offset)
                
                // Check threshold for header collapse
                let nearTop = offset.y <= self.parent.threshold
                if nearTop != self.isNearTop {
                    self.isNearTop = nearTop
                    self.parent.onScrollNearTop?(nearTop)
                }
            }
        }
        
        @objc func handleRefresh() {
            // Parent view should handle refresh via onScroll callback or binding
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.refreshControl?.endRefreshing()
            }
        }
        
        public func endRefreshing() {
            refreshControl?.endRefreshing()
        }
    }
}

// MARK: - Preference Key for Scroll Offset
public struct ScrollOffsetPreferenceKey: PreferenceKey {
    public static var defaultValue: CGPoint = .zero
    
    public static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

// MARK: - Helper Extension for Pull-to-Refresh
extension TrackableScrollView {
    public func onRefresh(action: @escaping () -> Void) -> some View {
        // This would be used with a custom refresh control implementation
        self
    }
}

// MARK: - Preview
struct TrackableScrollView_Previews: PreviewProvider {
    static var previews: some View {
        @State var offset: CGPoint = .zero
        @State var isNearTop = true
        
        return TrackableScrollView(
            .vertical,
            showIndicators: false,
            threshold: -10,
            scrollOffset: $offset,
            onScrollNearTop: { nearTop in
                isNearTop = nearTop
            }
        ) {
            VStack(spacing: 20) {
                ForEach(0..<20) { i in
                    Text("Item \(i)")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Color.black)
    }
}
