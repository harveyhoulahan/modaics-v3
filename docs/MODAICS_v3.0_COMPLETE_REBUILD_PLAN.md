# MODAICS v3.0 — COMPLETE REBUILD MASTERPLAN
## Technical Specification & Implementation Guide
### Incorporating V6 Vision, Design Direction & Lessons from v2.0

---

## PART 0: CRITICAL AESTHETIC PIVOT

### The New Visual Direction (Mediterranean Warmth)

**THIS IS NOT THE DARK GREEN PORSCHE AESTHETIC.**

Based on the Design Direction document, Modaics v3.0 uses a **warm, Mediterranean, artisanal palette** inspired by sun-baked ceramics and natural textiles.

#### Color Palette (UPDATED)

| Colour | Hex | Usage |
|--------|-----|-------|
| **Terracotta** | #C2703E | Primary accent. Buttons, highlights, CTAs. The signature Modaics colour. |
| **Warm Sand** | #E8D5B7 | Primary background. Warm, soft, never stark white. |
| **Deep Olive** | #5B6B4A | Secondary accent. Section dividers, supporting text, icons. |
| **Charcoal Clay** | #3B3632 | Primary text colour. Warm black — never pure #000000. |
| **Cream** | #F5F0E8 | Light background variant. Cards, callout boxes. |
| **Burnt Sienna** | #A0522D | Darker terracotta for hover states, depth. |
| **Sage** | #9CAF88 | Light accents, tags, badges, positive states. |
| **Oatmeal** | #D4C5A9 | Subtle borders, divider lines. |
| **Burgundy** | #6B2D3E | Premium features, Atelier branding (sparingly). |

#### Typography (UPDATED)

**Primary Pairing:**
- **Headlines:** Freight Display (serif, elegant but warm) OR Cormorant Garamond (free alternative)
- **Body:** Source Sans 3 (clean, readable humanist sans) OR Karla (free alternative)
- **Accents/Labels:** DM Sans (geometric but soft) OR Inter (neutral)

**Rules:**
- Headlines: Large, unhurried, breathing room
- Body: 16–18px minimum, 1.6–1.8 line height
- Never ALL CAPS for more than 2–3 words
- Letter-spacing: tight on headlines (-0.5 to -1%), loose on labels (+2–5%)
- Avoid bold — use medium at most

#### Photography Direction

**The Feel:**
- Natural light (golden hour, soft window light)
- Textural close-ups (weave, grain, buttons, stitching)
- Hands and human touch (folding, wrapping, adjusting)
- Styled environments (linen, wood, terracotta walls)
- Imperfect beauty (slightly rumpled, lived-in, real)
- Warm colour grading (+5–10% warmth, lifted shadows, soft highlights)

---

## PART 1: CORE VISION (From V6 Document)

### The Mission
**"Every piece, a story. Together, a mosaic."**

Modaics is a peer-to-peer circular fashion platform where every garment has a story and every wardrobe is a mosaic — assembled piece by piece, with care.

### Three Ways to Participate
1. **Buy** — Discover pieces curated to your style
2. **Sell** — Pass along what no longer serves you, with the garment's story
3. **Trade** — The oldest form of fashion circularity. Swap directly.

### The Problem
We've forgotten how to love our clothes.
- 92 million tonnes of textiles to landfill annually
- Average garment worn just 7 times before discard
- Secondhand market growing 3x faster than retail ($350B by 2028)

### The Solution
A platform for **The Intentional Dresser** — not chasing trends, building a wardrobe that lasts. Sustainability as a way of life, quality over quantity, community over competition.

---

## PART 2: FEATURE SPECIFICATION

### 2.1 Core Features (MVP - Phase 1)

#### 1. Smart Discovery (AI-Powered)
**Not just filters — style understanding.**

**User Input:**
- Sizes, preferred brands
- Texture preferences (natural fibres, vintage silhouettes)
- Colour preferences (muted earth tones)
- Fit preferences (tailored, oversized, etc.)

**AI Matching:**
- CLIP embeddings for visual similarity
- Collaborative filtering for taste matching
- Learns from: saves, purchases, time spent viewing
- Surfaces pieces that "feel right" — like a friend who knows your style

**UI:**
- "For You" feed (personalized)
- "New Arrivals" (chronological)
- "Trending" (community-driven)
- Infinite scroll with masonry layout (mosaic concept)

#### 2. Garment Stories (Core Differentiator)
**Every listing invites the seller to share the piece's history.**

**Fields:**
- Where was it found? (vintage store, inherited, purchased new)
- How was it worn? (occasions, memories)
- What makes it special? (craftsmanship, provenance, sentimental value)
- Condition details (honest assessment)
- Why passing it on? (outgrown, style evolution, making space)

**UI:**
- Story appears prominently in item detail
- Collapsible but default expanded
- Rich text support (not just plain text)
- Photo gallery integrated with story

#### 3. Fair Pricing Guidance
**AI-powered price recommendation based on:**

**Data Inputs:**
- Brand, condition, rarity
- Real market data across platforms (Depop, Vestiaire, etc.)
- Comparable sales on Modaics
- Current demand indicators

**Output:**
- Suggested price range
- "Priced fairly" badge if within range
- "Below market" / "Above market" indicators
- Historical price trends for similar items

**UI:**
- Appears during listing creation
- Optional — seller can override
- Transparency: show how price was calculated

#### 4. AI-Powered Item Creation
**30-second listing with GPT-4 Vision + CLIP.**

**User Flow:**
1. Upload photo(s) of garment
2. AI analyzes instantly:
   - Brand detection (from logo/text)
   - Category classification (tops, bottoms, etc.)
   - Colour identification (primary + secondary)
   - Material estimation (visual cues)
   - Condition assessment (wear patterns)
3. AI suggests price based on similar items
4. AI generates description draft
5. Seller reviews, edits, adds story, confirms

**Technology:**
- GPT-4 Vision for brand/colour/condition
- CLIP for similarity search (price estimation)
- On-device CoreML for fast initial classification

#### 5. Three-Mode Commerce
**Buy, Sell, Trade — all equally supported.**

**Buy:**
- Standard purchase flow
- Secure payment (Stripe)
- Buyer protection

**Sell:**
- List with AI assistance
- Receive offers
- Ship with tracking

**Trade:**
- Propose swaps
- Counter-offer system
- Mutual acceptance required
- Simultaneous shipping (both parties)

#### 6. Trust & Verification
**Building confidence in the community.**

**User Verification:**
- Email verification
- Phone verification (optional)
- Social connection (optional)
- Review system (buyers review sellers, vice versa)

**Item Verification (Premium):**
- Modaics Atelier members can request authentication
- Partnerships with authentication services
- Verified badge on listings
- Photographic evidence of verification

**Safety:**
- Secure in-app messaging (no personal contact until transaction)
- Report system for inappropriate behaviour
- Moderation queue for flagged content

---

### 2.2 Community Features (Phase 2)

#### 1. Following & Collections
**Curated spaces within the platform.**

**Following:**
- Follow sellers whose taste you admire
- See their new listings in feed
- Get notified when they list

**Collections:**
- Users create themed collections ("Summer Linens", "Vintage Denim", etc.)
- Can include own items + items from others (bookmark-style)
- Public or private
- Shareable

#### 2. Style Circles
**Small, curated groups based on shared taste.**

**Formation:**
- Algorithm-suggested based on style similarity
- Users can invite others
- Limited size (e.g., 50 max) to maintain intimacy

**Features:**
- Private feed of member listings
- Group chat for styling advice
- First access to member sales
- Virtual "swap meets" (scheduled trading events)

#### 3. Sustainability Tracking
**Visualise your impact.**

**Personal Dashboard:**
- Garments saved from landfill (count)
- Estimated carbon offset vs. buying new
- Water saved
- Money saved vs. retail
- Comparison to community average

**Sharing:**
- Share stats to social media
- Monthly impact reports
- Achievement badges ("100 garments saved")

---

### 2.3 Brand Features (Phase 3)

#### 1. Brand Sketchbooks
**Curated spaces for brands and sellers with distinct aesthetic.**

**For Brands:**
- Dedicated profile page
- Story/about section
- Collection showcases
- Behind-the-scenes content
- Direct messaging with customers

**For Power Sellers:**
- Mini-storefront within Modaics
- Customisable header/styling
- Analytics on views/sales
- Promotional tools

#### 2. Brand Partnerships
**Curated collaborations — not banner ads.**

**Types:**
- Featured collections from emerging designers
- Repair workshops sponsored by heritage brands
- Material guides co-created with fabric houses
- Limited edition drops
- Exclusive early access

**Integration:**
- Native to feed (not disruptive)
- Clearly marked as "Partner"
- Adds value to community (educational content, not just product)

---

### 2.4 Premium Features (Modaics Atelier)

**Subscription: $9.99/month**

**Benefits:**
- **Priority Placement** — Listings appear higher in discovery
- **Advanced Analytics** — Views, saves, conversion rates per item
- **Reduced Commission** — 6% instead of 8-12%
- **Early Access** — Beta features, new tools
- **Custom Storefront** — Personalised styling, banner image
- **Verified Badge** — Signals serious seller
- **Direct Support** — Priority customer service

**Target:** Dedicated sellers, vintage curators, small brands

---

## PART 3: TECHNICAL ARCHITECTURE

### 3.1 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        iOS CLIENT (SwiftUI)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │   Presentation │  │   Domain     │  │   Data               │  │
│  │   (Views)      │  │   (Use Cases)│  │   (Repositories)     │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│         ↓                 ↓                    ↓                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              SwiftUI State Management (MVVM)              │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↕️ HTTPS/REST + WebSocket
┌─────────────────────────────────────────────────────────────────┐
│                      FASTAPI BACKEND                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │   API Layer  │  │   Services   │  │   ML/AI Services     │  │
│  │   (Routers)  │  │   (Business) │  │   (CLIP, GPT-4)      │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↕️ SQL + Vector Search
┌─────────────────────────────────────────────────────────────────┐
│                      DATA STORES                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  PostgreSQL  │  │  Redis       │  │  S3 / Cloud Storage  │  │
│  │  + pgvector  │  │  (Cache)     │  │  (Images)            │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↕️ OAuth 2.0 / API Keys
┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES                             │
│  Firebase Auth │  Stripe │  OpenAI │  SendGrid │  Cloudflare   │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 iOS Architecture (Clean Architecture)

```
Modaics/
├── App/
│   ├── ModaicsApp.swift
│   └── AppCoordinator.swift
│
├── DesignSystem/
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Gradients.swift
│   └── Components/
│       ├── ModaicsButton.swift
│       ├── ModaicsCard.swift
│       ├── ModaicsTextField.swift
│       └── ModaicsShimmer.swift
│
├── Core/
│   ├── Domain/
│   │   ├── Entities/
│   │   │   ├── User.swift
│   │   │   ├── Item.swift
│   │   │   ├── Transaction.swift
│   │   │   ├── Trade.swift
│   │   │   ├── Story.swift
│   │   │   ├── Collection.swift
│   │   │   └── StyleCircle.swift
│   │   │
│   │   ├── RepositoryProtocols/
│   │   │   ├── AuthRepository.swift
│   │   │   ├── ItemRepository.swift
│   │   │   ├── SearchRepository.swift
│   │   │   ├── TradeRepository.swift
│   │   │   ├── PaymentRepository.swift
│   │   │   └── CommunityRepository.swift
│   │   │
│   │   └── UseCases/
│   │       ├── ListItemUseCase.swift
│   │       ├── SearchItemsUseCase.swift
│   │       ├── CreateTradeUseCase.swift
│   │       ├── ProcessPaymentUseCase.swift
│   │       ├── GenerateStoryUseCase.swift
│   │       └── JoinStyleCircleUseCase.swift
│   │
│   └── Data/
│       ├── Repositories/
│       │   ├── FirebaseAuthRepository.swift
│       │   ├── PostgreSQLItemRepository.swift
│       │   ├── CLIPSearchRepository.swift
│       │   ├── StripePaymentRepository.swift
│       │   └── APICommunityRepository.swift
│       │
│       ├── API/
│       │   ├── APIClient.swift
│       │   ├── APIConfiguration.swift
│       │   ├── Endpoints.swift
│       │   ├── RequestModels.swift
│       │   └── ResponseModels.swift
│       │
│       └── Local/
│           ├── CoreDataStack.swift
│           ├── KeychainManager.swift
│           └── UserDefaultsManager.swift
│
├── Presentation/
│   ├── Common/
│   │   ├── ViewModifiers/
│   │   └── Extensions/
│   │
│   ├── Auth/
│   │   ├── SplashView.swift
│   │   ├── OnboardingView.swift
│   │   ├── LoginView.swift
│   │   ├── SignUpView.swift
│   │   └── AuthViewModel.swift
│   │
│   ├── Discovery/
│   │   ├── DiscoveryView.swift
│   │   ├── DiscoveryViewModel.swift
│   │   ├── ItemCard.swift
│   │   └── FilterSheet.swift
│   │
│   ├── ItemDetail/
│   │   ├── ItemDetailView.swift
│   │   ├── ItemStoryView.swift
│   │   ├── SellerProfileSheet.swift
│   │   └── SimilarItemsView.swift
│   │
│   ├── Create/
│   │   ├── CreateItemView.swift
│   │   ├── CreateItemViewModel.swift
│   │   ├── AIAnalysisView.swift
│   │   ├── PhotoUploadView.swift
│   │   └── StoryEditorView.swift
│   │
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   ├── WardrobeView.swift
│   │   ├── CollectionsView.swift
│   │   ├── ImpactDashboardView.swift
│   │   └── SettingsView.swift
│   │
│   ├── Community/
│   │   ├── StyleCirclesView.swift
│   │   ├── CollectionsFeedView.swift
│   │   └── MemberDirectoryView.swift
│   │
│   ├── Trade/
│   │   ├── TradeProposeView.swift
│   │   ├── TradeCounterView.swift
│   │   └── TradeStatusView.swift
│   │
│   └── Payment/
│       ├── CheckoutView.swift
│       ├── PaymentConfirmationView.swift
│       └── TransactionHistoryView.swift
│
├── Services/
│   ├── AI/
│   │   ├── ImageAnalysisService.swift
│   │   ├── CLIPService.swift
│   │   ├── GPT4VisionService.swift
│   │   └── PriceEstimationService.swift
│   │
│   ├── Image/
│   │   ├── ImageCache.swift
│   │   ├── ImageUploader.swift
│   │   └── ImageProcessor.swift
│   │
│   └── Analytics/
│       └── AnalyticsService.swift
│
└── Tests/
    ├── Unit/
    ├── Integration/
    └── UI/
```

### 3.3 Complete Entity Definitions

#### User

```swift
struct User: Identifiable, Codable, Hashable {
    let id: String
    let email: String
    let displayName: String
    let username: String?
    let avatarURL: String?
    let bio: String?
    let location: String?
    let userType: UserType
    let isVerified: Bool
    let createdAt: Date
    let lastLoginAt: Date?
    
    // Stats
    let wardrobeCount: Int
    let followersCount: Int
    let followingCount: Int
    let sustainabilityScore: Int
    let itemsSold: Int
    let itemsPurchased: Int
    let itemsTraded: Int
    
    // Premium
    let isAtelierMember: Bool
    let atelierExpiryDate: Date?
}

enum UserType: String, Codable, CaseIterable {
    case consumer
    case brand
    case curator
}
```

#### Item

```swift
struct Item: Identifiable, Codable, Hashable {
    let id: String
    let sellerId: String
    let title: String
    let description: String?
    let story: Story?  // Garment story - core differentiator
    
    // Details
    let brand: String?
    let category: ItemCategory
    let condition: ItemCondition
    let size: String
    let colors: [String]
    let materials: [String]
    
    // Pricing
    let price: Decimal
    let originalPrice: Decimal?
    let currency: String
    let isNegotiable: Bool
    
    // Media
    let images: [ItemImage]
    let primaryImageIndex: Int
    
    // AI/ML
    let embedding: [Float]?  // CLIP embedding for visual search
    let aiGeneratedDescription: String?
    let suggestedPrice: Decimal?
    
    // Status
    let status: ItemStatus
    let isAvailableForTrade: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // Stats
    let viewCount: Int
    let saveCount: Int
    let offerCount: Int
}

struct Story: Codable, Hashable {
    let origin: String?           // Where was it found?
    let history: String?          // How was it worn?
    let specialDetails: String?   // What makes it special?
    let whySelling: String?       // Why passing it on?
}

enum ItemCategory: String, Codable, CaseIterable {
    case tops, bottoms, dresses, outerwear
    case shoes, accessories, bags, jewelry
}

enum ItemCondition: String, Codable, CaseIterable {
    case newWithTags = "new_with_tags"
    case likeNew = "like_new"
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
}

enum ItemStatus: String, Codable {
    case available
    case reserved
    case sold
    case traded
}
```

#### Trade

```swift
struct Trade: Identifiable, Codable {
    let id: String
    let proposerId: String
    let recipientId: String
    let offeredItemId: String
    let requestedItemId: String
    let status: TradeStatus
    let proposedAt: Date
    let respondedAt: Date?
    let completedAt: Date?
    let counterOffer: CounterOffer?
    let notes: String?
}

struct CounterOffer: Codable {
    let itemId: String  // Different item than originally requested
    let message: String?
}

enum TradeStatus: String, Codable {
    case pending
    case accepted
    case countered
    case declined
    case completed
    case cancelled
}
```

#### Collection & Style Circle

```swift
struct Collection: Identifiable, Codable {
    let id: String
    let creatorId: String
    let title: String
    let description: String?
    let coverImageURL: String?
    let itemIds: [String]
    let isPublic: Bool
    let createdAt: Date
}

struct StyleCircle: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let creatorId: String
    let memberIds: [String]
    let maxMembers: Int
    let isInviteOnly: Bool
    let createdAt: Date
}
```

### 3.4 Design System Implementation

```swift
// DesignSystem/Colors.swift
import SwiftUI

extension Color {
    // Primary Palette
    static let terracotta = Color(hex: "C2703E")
    static let warmSand = Color(hex: "E8D5B7")
    static let deepOlive = Color(hex: "5B6B4A")
    static let charcoalClay = Color(hex: "3B3632")
    static let cream = Color(hex: "F5F0E8")
    
    // Supporting
    static let burntSienna = Color(hex: "A0522D")
    static let sage = Color(hex: "9CAF88")
    static let oatmeal = Color(hex: "D4C5A9")
    static let burgundy = Color(hex: "6B2D3E")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// ShapeStyle extension for SwiftUI compatibility
extension ShapeStyle where Self == Color {
    static var terracotta: Color { Color.terracotta }
    static var warmSand: Color { Color.warmSand }
    static var deepOlive: Color { Color.deepOlive }
    static var charcoalClay: Color { Color.charcoalClay }
    static var cream: Color { Color.cream }
}
```

---

## PART 4: DEVELOPMENT ROADMAP

### Phase 1: Foundation (Weeks 1-4) — MVP

**Goal:** Working app with core Buy/Sell/AI Listing

**Features:**
- [ ] Splash & onboarding
- [ ] Firebase Auth (Email, Apple, Google)
- [ ] User profile & basic settings
- [ ] AI-powered item creation (GPT-4 Vision + CLIP)
- [ ] Discovery feed with personalization
- [ ] Item detail with Garment Story
- [ ] Basic search (text + visual)
- [ ] Checkout flow (Stripe)
- [ ] Push notifications

**Backend:**
- [ ] FastAPI setup
- [ ] PostgreSQL + pgvector
- [ ] GPT-4 Vision integration
- [ ] CLIP embedding pipeline
- [ ] Image upload/storage
- [ ] Payment webhooks

**Success Criteria:**
- User can create listing in <30 seconds with AI
- Visual search returns relevant results
- Purchase flow completes end-to-end

### Phase 2: Community (Weeks 5-8)

**Features:**
- [ ] Following system
- [ ] Collections
- [ ] Save/bookmark items
- [ ] Style Circles (beta)
- [ ] Sustainability dashboard
- [ ] Improved discovery algorithm
- [ ] In-app messaging

**Success Criteria:**
- 20% of users create collections
- Style Circles have active engagement

### Phase 3: Trade & Advanced (Weeks 9-12)

**Features:**
- [ ] Full trade/swap system
- [ ] Counter-offers
- [ ] Trade history
- [ ] Modaics Atelier subscription
- [ ] Advanced analytics for sellers
- [ ] Brand partnerships (beta)

**Success Criteria:**
- 10% of transactions are trades
- Atelier conversion >5%

### Phase 4: Brand Features (Weeks 13-16)

**Features:**
- [ ] Brand Sketchbooks
- [ ] Verified seller program
- [ ] Advanced storefronts
- [ ] Partnership tools
- [ ] Event system (swap meets, etc.)

---

## PART 5: KEY PRINCIPLES (From Changelog)

### Language & Tone

| ✓ DO | ✗ DON'T |
|------|---------|
| "Pieces" / "garments" | "Items" / "products" |
| "Story" | "Listing" |
| "Members" / "people" | "Users" |
| "Thoughtful" | "Innovative" |
| "Community" | "Ecosystem" |
| Plain language | Buzzwords (leverage, disrupt, game-changer) |
| Warm, human | Corporate/tech-speak |

### Design Principles

1. **Generous spacing** — Content breathes like an art book
2. **Asymmetric layouts** — Editorial quality, not rigid grids
3. **Natural photography** — Golden hour, texture, human touch
4. **Warm colour grading** — +5-10% warmth, lifted shadows
5. **Mosaic motif** — Subtle, whispered not shouted
6. **Flat, matte, tactile** — No gradients, no neon, no pure white/black

### Product Philosophy

**"The best technology is invisible"**
- AI enables features but isn't the headline
- Focus on feeling, not feature lists
- Build relationships, not transactions
- Sustainability through care, not activism

---

## PART 6: COMPLETE FILE MANIFEST (v3.0)

### Core Files (Must Exist)

```
Essential Models:
✓ User.swift (complete with all properties)
✓ Item.swift (with Story embedded)
✓ Trade.swift
✓ Transaction.swift
✓ Collection.swift
✓ StyleCircle.swift

Essential Services:
✓ AuthRepository.swift
✓ ItemRepository.swift
✓ SearchRepository.swift (CLIP-based)
✓ PaymentRepository.swift
✓ AIService.swift (GPT-4 Vision)

Essential Views:
✓ SplashView.swift
✓ DiscoveryView.swift
✓ ItemDetailView.swift
✓ CreateItemView.swift
✓ ProfileView.swift
✓ CheckoutView.swift

Design System:
✓ Colors.swift (Mediterranean palette)
✓ Typography.swift (Freight/Cormorant + Source Sans/Karla)
✓ ModaicsButton.swift
✓ ModaicsCard.swift
✓ ModaicsTextField.swift
```

### Files to Remove/Deprecate

```
Remove (causing conflicts):
✗ Old design system files with chrome gradients
✗ Duplicate type definitions
✗ Incomplete Sketchbook files (rebuild properly)
✗ Incomplete Payment files (consolidate)
✗ Mock data that references non-existent properties
```

---

## PART 7: NEXT STEPS

### Immediate Actions

1. **Archive v2.0** — Keep as reference, don't try to fix
2. **Create v3.0 repo** — Fresh start with clean architecture
3. **Build models first** — All entities defined and complete
4. **Design system** — Colors, typography, components
5. **Backend setup** — FastAPI + PostgreSQL + pgvector
6. **MVP features** — Phase 1 only, resist scope creep

### Success Metrics

- **Week 4:** App compiles, AI listing works, purchase flows
- **Week 8:** 100 beta users, positive retention
- **Week 12:** 1,000 users, 10% Atelier conversion
- **Week 16:** Ready for public launch in Australia

---

## CONCLUSION

This masterplan synthesizes:
- **V6 Vision** — The product philosophy and market positioning
- **Design Direction** — Mediterranean warmth aesthetic (not dark green!)
- **Changelog Learnings** — Language, tone, structure improvements
- **v2.0 Lessons** — Technical mistakes to avoid

**The rebuild will take 16 weeks for full feature set, 4 weeks for MVP.**

**Ready to start building v3.0?** 🐉

---

*Document compiled by Alfred 🐉 — Your Strategic Partner*
*Based on: Modaics_Rewrite_V6.md, Modaics_Design_Direction.md, Modaics_Changelog.md*
