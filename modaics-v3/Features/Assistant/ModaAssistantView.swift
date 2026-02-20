import SwiftUI
import Combine

// MARK: - Message Model
struct ModaMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}

// MARK: - View Model
@MainActor
class ModaAssistantViewModel: ObservableObject {
    @Published var messages: [ModaMessage] = []
    @Published var inputText = ""
    @Published var isStreaming = false
    
    private var eventSource: EventSource?
    private var currentStreamingMessage = ""
    
    init() {
        // Add welcome message
        messages.append(ModaMessage(
            content: "Hey! I'm Moda — your style companion. I can help you find pieces, style outfits, or just chat about fashion. What are you looking for today? ✨",
            isUser: false
        ))
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let userMessage = ModaMessage(content: inputText, isUser: true)
        messages.append(userMessage)
        
        let messageToSend = inputText
        inputText = ""
        isStreaming = true
        currentStreamingMessage = ""
        
        // Start streaming response
        Task {
            await streamResponse(userMessage: messageToSend)
        }
    }
    
    private func streamResponse(userMessage: String) async {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/chat/stream") else {
            appendErrorMessage("Sorry, I can't connect right now. Mind trying again?")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth if available
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Build request body
        let body: [String: Any] = [
            "message": userMessage,
            "conversation_history": messages.map { [
                "role": $0.isUser ? "user" : "assistant",
                "content": $0.content
            ]}
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (stream, response) = try await URLSession.shared.bytes(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                appendErrorMessage("I'm having trouble thinking right now. One sec...")
                return
            }
            
            var accumulatedText = ""
            
            for try await line in stream.lines {
                if line.hasPrefix("data: ") {
                    let jsonString = String(line.dropFirst(6))
                    if let data = jsonString.data(using: .utf8),
                       let event = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        
                        if let type = event["type"] as? String {
                            switch type {
                            case "text":
                                if let content = event["content"] as? String {
                                    accumulatedText += content
                                    await updateStreamingMessage(accumulatedText)
                                }
                            case "done":
                                await finishStreaming(accumulatedText)
                                return
                            case "error":
                                appendErrorMessage("Something went wrong. Let's try that again?")
                                return
                            default:
                                break
                            }
                        }
                    }
                }
            }
            
            // Finish if stream ends without done event
            await finishStreaming(accumulatedText)
            
        } catch {
            appendErrorMessage("Connection hiccup. Mind trying again?")
        }
    }
    
    private func updateStreamingMessage(_ text: String) async {
        // Update the last message if it's from assistant and streaming
        if let lastIndex = messages.indices.last,
           !messages[lastIndex].isUser,
           isStreaming {
            messages[lastIndex] = ModaMessage(content: text, isUser: false)
        } else {
            // Add new streaming message
            messages.append(ModaMessage(content: text, isUser: false))
        }
    }
    
    private func finishStreaming(_ text: String) async {
        isStreaming = false
        
        // Ensure final message is set
        if let lastIndex = messages.indices.last,
           !messages[lastIndex].isUser {
            messages[lastIndex] = ModaMessage(content: text, isUser: false)
        }
    }
    
    private func appendErrorMessage(_ text: String) {
        isStreaming = false
        messages.append(ModaMessage(content: text, isUser: false))
    }
    
    // MARK: - Quick Actions
    
    func sendQuickAction(_ action: QuickAction) {
        let prompt: String
        switch action {
        case .findItem:
            prompt = "Help me find something specific"
        case .styleOutfit:
            prompt = "Style me an outfit"
        case .sustainability:
            prompt = "How's my sustainability impact?"
        case .discovery:
            prompt = "Surprise me with something new"
        }
        
        inputText = prompt
        sendMessage()
    }
    
    enum QuickAction {
        case findItem
        case styleOutfit
        case sustainability
        case discovery
    }
}

// MARK: - API Config
private struct APIConfig {
    static let baseURL = "https://api.modaics.com"
}

// MARK: - View
struct ModaAssistantView: View {
    @StateObject private var viewModel = ModaAssistantViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Messages
                messagesList
                
                // Quick actions
                if viewModel.messages.count <= 2 {
                    quickActions
                }
                
                // Input bar
                inputBar
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("MODA")
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.luxeGold)
                
                Text("Your style companion")
                    .font(.forestCaption)
                    .foregroundColor(.sageMuted)
            }
            
            Spacer()
            
            Button(action: { /* dismiss */ }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.sageMuted)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Color.modaicsBackground)
    }
    
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }
                    
                    if viewModel.isStreaming {
                        TypingIndicator()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: viewModel.messages.count) { _ in
                withAnimation {
                    if let lastId = viewModel.messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var quickActions: some View {
        VStack(spacing: 8) {
            Text("Quick actions")
                .font(.forestCaption)
                .foregroundColor(.sageMuted)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "magnifyingglass",
                    label: "Find",
                    action: { viewModel.sendQuickAction(.findItem) }
                )
                
                QuickActionButton(
                    icon: "sparkles",
                    label: "Style Me",
                    action: { viewModel.sendQuickAction(.styleOutfit) }
                )
                
                QuickActionButton(
                    icon: "leaf",
                    label: "Impact",
                    action: { viewModel.sendQuickAction(.sustainability) }
                )
                
                QuickActionButton(
                    icon: "wand.and.stars",
                    label: "Discover",
                    action: { viewModel.sendQuickAction(.discovery) }
                )
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
    }
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask Moda anything...", text: $viewModel.inputText, axis: .vertical)
                .font(.forestBody)
                .foregroundColor(.forestDark)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(24)
                .focused($isInputFocused)
                .lineLimit(1...4)
            
            Button(action: viewModel.sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(viewModel.inputText.isEmpty ? .sageMuted : .luxeGold)
            }
            .disabled(viewModel.inputText.isEmpty || viewModel.isStreaming)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.modaicsBackground
                .shadow(color: .black.opacity(0.1), radius: 8, y: -4)
        )
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ModaMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.content)
                    .font(.forestBody)
                    .foregroundColor(message.isUser ? .white : .forestDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .background(message.isUser ? Color.luxeGold : Color.white)
            .cornerRadius(20, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
            
            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var dots = 0
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.sageMuted)
                        .frame(width: 8, height: 8)
                        .opacity(dots == i ? 1.0 : 0.4)
                        .animation(.easeInOut(duration: 0.3), value: dots)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(20, corners: [.topLeft, .topRight, .bottomRight])
            
            Spacer(minLength: 60)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                dots = (dots + 1) % 3
            }
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.forestSmall)
            }
            .foregroundColor(.forestDark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct ModaAssistantView_Previews: PreviewProvider {
    static var previews: some View {
        ModaAssistantView()
    }
}
