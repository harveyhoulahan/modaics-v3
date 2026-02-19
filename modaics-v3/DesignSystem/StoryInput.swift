import SwiftUI

// MARK: - Story Input Component
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
        VStack(alignment: .leading, spacing: ModaicsLayout.small) {
            Text(title)
                .font(.modaicsBodySemiBold)
                .foregroundColor(Color.modaicsTextPrimary)
            
            TextEditor(text: $text)
                .font(.modaicsBodyRegular)
                .foregroundColor(Color.modaicsTextPrimary)
                .frame(minHeight: 100)
                .padding(ModaicsLayout.small)
                .background(Color.modaicsPaper)
                .cornerRadius(ModaicsLayout.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: ModaicsLayout.cornerRadius)
                        .stroke(Color.modaicsTextTertiary.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.modaicsBodyRegular)
                                .foregroundColor(Color.modaicsTextTertiary)
                                .padding(.horizontal, ModaicsLayout.small + 4)
                                .padding(.vertical, ModaicsLayout.small + 8)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
            
            Text(helpText)
                .font(.modaicsCaptionRegular)
                .foregroundColor(Color.modaicsTextSecondary)
        }
    }
}