import SwiftUI

// MARK: - Story Input Component (Dark Green Porsche)
/// Multi-line text input for story content with title and help text
public struct StoryInput: View {
    let placeholder: String
    @Binding var text: String
    let title: String
    let helpText: String
    
    public init(
        _ placeholder: String,
        text: Binding<String>,
        title: String,
        helpText: String
    ) {
        self.placeholder = placeholder
        self._text = text
        self.title = title
        self.helpText = helpText
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.forestCaptionMedium)
                .foregroundColor(Color.sageMuted)
                .tracking(1)
            
            TextEditor(text: $text)
                .font(.forestBodyMedium)
                .foregroundColor(Color.sageWhite)
                .frame(minHeight: 100)
                .padding(10)
                .background(Color.modaicsSurface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
                .overlay(
                    Group {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.forestBodyMedium)
                                .foregroundColor(Color.sageSubtle)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 18)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
            
            Text(helpText)
                .font(.forestCaptionSmall)
                .foregroundColor(Color.sageSubtle)
        }
    }
}