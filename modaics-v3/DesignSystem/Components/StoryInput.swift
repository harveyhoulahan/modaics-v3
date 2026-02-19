import SwiftUI

// MARK: - StoryInput
// Multi-line text input for garment narratives
// Editorial feel, generous spacing, warm styling
// Where the story of each piece comes to life

public struct StoryInput: View {
    let placeholder: String
    let title: String?
    let helpText: String?
    let minHeight: CGFloat
    let maxHeight: CGFloat
    
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    public init(
        _ placeholder: String,
        text: Binding<String>,
        title: String? = nil,
        helpText: String? = nil,
        minHeight: CGFloat = 120,
        maxHeight: CGFloat = 300
    ) {
        self.placeholder = placeholder
        self._text = text
        self.title = title
        self.helpText = helpText
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
            // Title
            if let title = title {
                Text(title)
                    .font(MosaicTypography.label)
                    .foregroundColor(MosaicColors.textPrimary)
            }
            
            // Input container
            ZStack(alignment: .topLeading) {
                // Background
                RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius)
                    .fill(MosaicColors.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius)
                            .stroke(
                                isFocused ? MosaicColors.borderFocused : MosaicColors.border,
                                lineWidth: isFocused ? 2 : 1
                            )
                    )
                
                // TextEditor
                TextEditor(text: $text)
                    .font(MosaicTypography.story)
                    .foregroundColor(MosaicColors.textPrimary)
                    .padding(MosaicLayout.margin)
                    .frame(minHeight: minHeight, maxHeight: maxHeight)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                
                // Placeholder
                if text.isEmpty {
                    Text(placeholder)
                        .font(MosaicTypography.story)
                        .foregroundColor(MosaicColors.textTertiary)
                        .padding(MosaicLayout.margin + 4)
                        .allowsHitTesting(false)
                }
            }
            
            // Help text
            if let helpText = helpText {
                Text(helpText)
                    .font(MosaicTypography.finePrint)
                    .foregroundColor(MosaicColors.textTertiary)
            }
        }
    }
}

// MARK: - Compact Story Input

public struct CompactStoryInput: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    public init(
        _ placeholder: String,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self._text = text
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: MosaicLayout.cornerRadiusSmall)
                .fill(MosaicColors.backgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: MosaicLayout.cornerRadiusSmall)
                        .stroke(
                            isFocused ? MosaicColors.borderFocused : MosaicColors.border,
                            lineWidth: isFocused ? 1.5 : 1
                        )
                )
            
            TextEditor(text: $text)
                .font(MosaicTypography.body)
                .foregroundColor(MosaicColors.textPrimary)
                .padding(MosaicLayout.itemSpacing)
                .frame(minHeight: 60, maxHeight: 120)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
            
            if text.isEmpty {
                Text(placeholder)
                    .font(MosaicTypography.body)
                    .foregroundColor(MosaicColors.textTertiary)
                    .padding(MosaicLayout.itemSpacing + 4)
                    .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - Caption Input

public struct CaptionInput: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    public init(
        _ placeholder: String,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self._text = text
    }
    
    public var body: some View {
        HStack {
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(MosaicColors.textTertiary))
                .font(MosaicTypography.caption)
                .foregroundColor(MosaicColors.textPrimary)
                .focused($isFocused)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(MosaicColors.textTertiary)
                }
            }
        }
        .padding(MosaicLayout.itemSpacing)
        .background(MosaicColors.backgroundSecondary)
        .cornerRadius(MosaicLayout.cornerRadiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: MosaicLayout.cornerRadiusSmall)
                .stroke(
                    isFocused ? MosaicColors.borderFocused : MosaicColors.border,
                    lineWidth: isFocused ? 1.5 : 0
                )
        )
    }
}

// MARK: - SwiftUI Preview
#Preview {
    struct PreviewWrapper: View {
        @State var storyText = ""
        @State var compactText = ""
        @State var captionText = ""
        
        var body: some View {
            ScrollView {
                VStack(spacing: MosaicLayout.sectionSpacing) {
                    Text("Story Input")
                        .font(MosaicTypography.display)
                        .foregroundColor(MosaicColors.textPrimary)
                        .generousMargins()
                    
                    // Full story input
                    StoryInput(
                        "Tell the story behind this garment—where it came from, who made it, what makes it special...",
                        text: $storyText,
                        title: "Garment Story",
                        helpText: "This will be displayed on the garment's detail page"
                    )
                    .generousMargins()
                    
                    // Compact input
                    VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
                        Text("Quick Note")
                            .font(MosaicTypography.label)
                            .foregroundColor(MosaicColors.textPrimary)
                        
                        CompactStoryInput(
                            "Add a brief note...",
                            text: $compactText
                        )
                    }
                    .generousMargins()
                    
                    // Caption input
                    VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
                        Text("Photo Caption")
                            .font(MosaicTypography.label)
                            .foregroundColor(MosaicColors.textPrimary)
                        
                        CaptionInput("Add a caption...", text: $captionText)
                    }
                    .generousMargins()
                    
                    // Character count example
                    VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
                        Text("With Character Count")
                            .font(MosaicTypography.label)
                            .foregroundColor(MosaicColors.textPrimary)
                        
                        StoryInput(
                            "Share the story behind this piece...",
                            text: $storyText,
                            helpText: "\(storyText.count) / 500 characters"
                        )
                    }
                    .generousMargins()
                }
                .padding(.vertical, MosaicLayout.sectionSpacing)
            }
            .background(MosaicColors.backgroundPrimary)
        }
    }
    
    return PreviewWrapper()
}
