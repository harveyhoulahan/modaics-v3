import SwiftUI

// MARK: - Error State View
/// Helpful, on-brand messaging for when things go wrong
struct ErrorStateView: View {
    let error: Error
    let retryAction: (() -> Void)?
    
    init(error: Error, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Illustration
            errorIllustration
            
            // Content
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
                
                if let suggestion = recoverySuggestion {
                    Text(suggestion)
                        .font(.modaicsCaptionRegular(size: 14))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .padding(.horizontal, 40)
                }
            }
            
            // Retry button
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Try Again")
                            .font(.modaicsBodySemiBold(size: 16))
                    }
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
    
    // MARK: - Error Illustration
    private var errorIllustration: some View {
        ZStack {
            // Background
            Circle()
                .fill(errorBackgroundColor.opacity(0.1))
                .frame(width: 140, height: 140)
            
            // Mosaic accent
            ErrorMosaicPattern(color: errorBackgroundColor)
                .frame(width: 100, height: 100)
                .opacity(0.3)
            
            // Icon
            Image(systemName: errorIcon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(errorBackgroundColor)
        }
    }
    
    // MARK: - Error Properties
    private var title: String {
        if let localizedError = error as? LocalizedError {
            return localizedError.errorDescription ?? "Something went wrong"
        }
        return "Something went wrong"
    }
    
    private var message: String {
        // Extract a user-friendly message from the error
        switch error {
        case is URLError:
            return "We're having trouble connecting. Please check your internet connection."
        case is DecodingError:
            return "We received unexpected data. We're working on it."
        default:
            if let localizedError = error as? LocalizedError {
                return localizedError.failureReason ?? "An unexpected error occurred."
            }
            return error.localizedDescription
        }
    }
    
    private var recoverySuggestion: String? {
        if let localizedError = error as? LocalizedError {
            return localizedError.recoverySuggestion
        }
        return nil
    }
    
    private var errorIcon: String {
        switch error {
        case is URLError:
            return "wifi.exclamationmark"
        case is DecodingError:
            return "doc.text.magnifyingglass"
        default:
            return "exclamationmark.triangle"
        }
    }
    
    private var errorBackgroundColor: Color {
        switch error {
        case is URLError:
            return .orange
        case is DecodingError:
            return .blue
        default:
            return .modaicsTerracotta
        }
    }
}

// MARK: - Error Mosaic Pattern
struct ErrorMosaicPattern: View {
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            // Create a subtle mosaic pattern
            let tileSize = size.width / 3
            
            for row in 0..<3 {
                for col in 0..<3 {
                    if (row + col) % 2 == 0 {
                        let rect = CGRect(
                            x: CGFloat(col) * tileSize + 2,
                            y: CGFloat(row) * tileSize + 2,
                            width: tileSize - 4,
                            height: tileSize - 4
                        )
                        let path = Path(roundedRect: rect, cornerRadius: 2)
                        context.fill(path, with: .color(color))
                    }
                }
            }
        }
    }
}

// MARK: - Inline Error View
/// Compact error view for inline display
struct InlineErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.modaicsTerracotta)
            
            Text(message)
                .font(.modaicsBodyRegular(size: 14))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.8))
            
            Spacer()
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.modaicsTerracotta)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.modaicsTerracotta.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.modaicsTerracotta.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Toast Error View
/// Brief error notification that appears and disappears
struct ErrorToastView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.modaicsBodyMedium(size: 15))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.modaicsCharcoalClay.opacity(0.9))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding(.top, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
}

// MARK: - Network Error View
/// Specific view for network connectivity issues
struct NetworkErrorView: View {
    let retryAction: () -> Void
    
    var body: some View {
        ErrorStateView(
            error: NetworkError.noConnection,
            retryAction: retryAction
        )
    }
}

// MARK: - Network Error
enum NetworkError: LocalizedError {
    case noConnection
    case timeout
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No connection"
        case .timeout:
            return "Request timed out"
        case .serverError:
            return "Server error"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .noConnection:
            return "We can't reach our servers right now. Please check your internet connection."
        case .timeout:
            return "This is taking longer than expected. The server might be busy."
        case .serverError:
            return "Something went wrong on our end. We're working to fix it."
        }
    }
    
    var recoverySuggestion: String? {
        "Pull down to refresh or try again in a moment."
    }
}

// MARK: - Preview Helpers
struct PreviewError: LocalizedError {
    let errorDescription: String?
    let failureReason: String?
    let recoverySuggestion: String?
}

// MARK: - Preview
struct ErrorStateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Full error state
            ErrorStateView(
                error: PreviewError(
                    errorDescription: "Couldn't load your wardrobe",
                    failureReason: "We had trouble connecting to our servers.",
                    recoverySuggestion: "Pull down to refresh or try again later."
                ),
                retryAction: {}
            )
            
            Divider()
            
            // Inline error
            InlineErrorView(
                message: "Failed to save changes. Please try again.",
                retryAction: {}
            )
            .padding(.horizontal, 24)
            
            Divider()
            
            // Network error
            NetworkErrorView {}
        }
        .padding(.vertical)
        .background(Color.modaicsWarmSand)
    }
}