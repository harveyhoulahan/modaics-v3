import SwiftUI

// MARK: - PhotoFrame
// Styled container for editorial photography
// Warm, film-like aesthetic with subtle styling
// Like pages from Kinfolk magazine

public struct PhotoFrame: View {
    public enum FrameStyle {
        case minimal      // Clean, subtle border
        case polaroid     // White border with shadow
        case editorial    // Generous cream matting
        case vintage      // Warm tinted border
    }
    
    public enum AspectRatio {
        case square       // 1:1
        case portrait     // 4:5
        case landscape    // 3:2
        case wide         // 16:9
        case free         // No constraint
        
        var ratio: CGFloat? {
            switch self {
            case .square: return 1.0
            case .portrait: return 4.0 / 5.0
            case .landscape: return 3.0 / 2.0
            case .wide: return 16.0 / 9.0
            case .free: return nil
            }
        }
    }
    
    let image: Image?
    let style: FrameStyle
    let aspectRatio: AspectRatio
    let caption: String?
    let credit: String?
    
    public init(
        _ image: Image? = nil,
        style: FrameStyle = .editorial,
        aspectRatio: AspectRatio = .portrait,
        caption: String? = nil,
        credit: String? = nil
    ) {
        self.image = image
        self.style = style
        self.aspectRatio = aspectRatio
        self.caption = caption
        self.credit = credit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
            // Frame
            frameContent
            
            // Caption area
            if caption != nil || credit != nil {
                VStack(alignment: .leading, spacing: MosaicLayout.microSpacing) {
                    if let caption = caption {
                        Text(caption)
                            .font(MosaicTypography.caption)
                            .foregroundColor(MosaicColors.textSecondary)
                    }
                    
                    if let credit = credit {
                        Text(credit)
                            .font(MosaicTypography.finePrint)
                            .foregroundColor(MosaicColors.textTertiary)
                    }
                }
                .padding(.horizontal, style == .editorial ? MosaicLayout.margin : 0)
                .padding(.top, style == .editorial ? MosaicLayout.itemSpacing : MosaicLayout.tightSpacing)
            }
        }
    }
    
    @ViewBuilder
    private var frameContent: some View {
        switch style {
        case .minimal:
            imageView
                .overlay(
                    RoundedRectangle(cornerRadius: MosaicLayout.cornerRadiusSmall)
                        .stroke(MosaicColors.border, lineWidth: 1)
                )
                .cornerRadius(MosaicLayout.cornerRadiusSmall)
        
        case .polaroid:
            VStack(spacing: 0) {
                imageView
                    .padding(MosaicLayout.tightSpacing)
                
                // White space at bottom like Polaroid
                Rectangle()
                    .fill(MosaicColors.cream)
                    .frame(height: 40)
            }
            .background(MosaicColors.cream)
            .cornerRadius(MosaicLayout.cornerRadiusSmall)
            .mosaicShadow(MosaicLayout.shadowSmall)
            
        case .editorial:
            VStack(spacing: 0) {
                imageView
                    .padding(MosaicLayout.margin)
            }
            .background(MosaicColors.backgroundSecondary)
            .cornerRadius(MosaicLayout.cornerRadius)
            .mosaicShadow(MosaicLayout.shadowSmall)
            
        case .vintage:
            imageView
                .padding(MosaicLayout.tightSpacing)
                .background(MosaicColors.oatmeal)
                .overlay(
                    RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius)
                        .stroke(MosaicColors.terracotta.opacity(0.2), lineWidth: 2)
                )
                .cornerRadius(MosaicLayout.cornerRadius)
                .mosaicShadow(MosaicLayout.shadowSmall)
        }
    }
    
    @ViewBuilder
    private var imageView: some View {
        if let image = image {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .applyAspectRatio()
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        ZStack {
            Rectangle()
                .fill(MosaicColors.oatmeal)
            
            VStack(spacing: MosaicLayout.itemSpacing) {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(MosaicColors.textTertiary)
                
                Text("Photo")
                    .font(MosaicTypography.caption)
                    .foregroundColor(MosaicColors.textTertiary)
            }
        }
        .applyAspectRatio()
    }
    
    private func applyAspectRatio() -> some View {
        Group {
            if let ratio = aspectRatio.ratio {
                self.aspectRatio(ratio, contentMode: .fill)
            } else {
                self
            }
        }
    }
}

// MARK: - Photo Grid

public struct MosaicPhotoGrid: View {
    let photos: [PhotoItem]
    let columns: Int
    
    public struct PhotoItem: Identifiable {
        public let id = UUID()
        let image: Image?
        let caption: String?
        
        public init(image: Image? = nil, caption: String? = nil) {
            self.image = image
            self.caption = caption
        }
    }
    
    public init(photos: [PhotoItem], columns: Int = 2) {
        self.photos = photos
        self.columns = columns
    }
    
    public var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: MosaicLayout.gridSpacing), count: columns),
            spacing: MosaicLayout.gridSpacing
        ) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                PhotoFrame(
                    photo.image,
                    style: .minimal,
                    aspectRatio: .square,
                    caption: photo.caption
                )
                .offset(y: MosaicMotif.staggeredOffset(for: index))
            }
        }
    }
}

// MARK: - Hero Photo

public struct MosaicHeroPhoto: View {
    let image: Image?
    let title: String?
    let subtitle: String?
    
    public init(
        _ image: Image? = nil,
        title: String? = nil,
        subtitle: String? = nil
    ) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Image
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(MosaicColors.oatmeal)
            }
            
            // Gradient overlay for text (NOT a gradient - using solid colors with opacity)
            VStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                MosaicColors.charcoalClay.opacity(0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 150)
            }
            
            // Text content
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(MosaicTypography.caption)
                            .foregroundColor(MosaicColors.cream.opacity(0.8))
                    }
                    
                    if let title = title {
                        Text(title)
                            .font(MosaicTypography.headline)
                            .foregroundColor(MosaicColors.cream)
                    }
                }
                .padding(MosaicLayout.margin)
                .padding(.bottom, MosaicLayout.itemSpacing)
            }
        }
        .frame(height: 400)
        .clipped()
    }
}

// MARK: - SwiftUI Preview
#Preview {
    ScrollView {
        VStack(spacing: MosaicLayout.sectionSpacing) {
            Text("Photo Frame")
                .font(MosaicTypography.display)
                .foregroundColor(MosaicColors.textPrimary)
                .generousMargins()
            
            // Editorial style (default)
            PhotoFrame(
                nil,
                style: .editorial,
                aspectRatio: .portrait,
                caption: "The atelier in Lisbon where every piece begins its journey",
                credit: "Photography by Ana Santos"
            )
            .generousMargins()
            
            // Minimal style
            PhotoFrame(
                nil,
                style: .minimal,
                aspectRatio: .square,
                caption: "Minimal frame with subtle border"
            )
            .frame(width: 200)
            .generousMargins()
            
            // Polaroid style
            PhotoFrame(
                nil,
                style: .polaroid,
                aspectRatio: .square
            )
            .frame(width: 200)
            .generousMargins()
            
            // Vintage style
            PhotoFrame(
                nil,
                style: .vintage,
                aspectRatio: .landscape,
                caption: "Vintage warmth with terracotta tint"
            )
            .generousMargins()
            
            // Photo grid
            Text("Photo Grid")
                .font(MosaicTypography.headline)
                .foregroundColor(MosaicColors.textPrimary)
                .generousMargins()
            
            MosaicPhotoGrid(photos: [
                .init(caption: "Lisbon"),
                .init(caption: "Porto"),
                .init(caption: "Madrid"),
                .init(caption: "Barcelona")
            ])
            
            // Hero photo
            MosaicHeroPhoto(
                nil,
                title: "Summer Collection",
                subtitle: "The Mediterranean Edit"
            )
            .generousMargins()
        }
        .padding(.vertical, MosaicLayout.sectionSpacing)
    }
    .background(MosaicColors.backgroundPrimary)
}
