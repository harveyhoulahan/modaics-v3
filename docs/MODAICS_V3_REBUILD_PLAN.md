# MODAICS V3.0 — COMPREHENSIVE REBUILD PLAN
## Unified Technical, Vision & Design Specification

---

## EXECUTIVE SUMMARY

**The Realization:** Our v2.0 build had the wrong aesthetic entirely.

**What We Built:** Dark Green Porsche (forest greens #0A1F15, luxe gold #D4AF37, chrome metallic)

**What Modaics Actually Is:** Mediterranean warmth (terracotta #C2703E, warm sand #E8D5B7, deep olive #5B6B4A) — sun-baked ceramics, natural textiles, editorial lifestyle.

**The Shift:** From "AI-powered marketplace" (tech-first) to "peer-to-peer circular fashion platform where every garment has a story" (story-first, quietly intelligent).

**Mission:** Build a wardrobe mosaic — assembled piece by piece, with care. Every piece has a history. Every transaction is a handoff, a note tucked inside the parcel.

---

## PART 1: THE VISION (FROM V6)

### 1.1 Core Philosophy

**"We've forgotten how to love our clothes."**

- 92 million tonnes of textiles to landfill annually
- Average garment worn just 7 times
- Secondhand market: $350B by 2028
- But existing platforms feel transactional, not intentional

**Modaics fills the whitespace:**
- Not youth-first like Depop
- Not luxury-gated like Vestiaire  
- Not bargain-bin like Vinted
- **Curated and warm, community-driven, accessible but not cheap, sustainable but not preachy**

### 1.2 Three Ways to Participate

1. **Buy** — Discover pieces curated to your style. Considered selection, not endless scroll.
2. **Sell** — Pass along what no longer serves you. Every listing tells the garment's story.
3. **Trade** — The oldest form of fashion circularity. Swap directly with others.

### 1.3 Quietly Intelligent Technology

**The best technology is invisible.**

- **Smart Discovery** — Matching learns taste (textures, eras, silhouettes), not just filters
- **Fair Pricing** — Market data-driven guidance so exchanges feel fair
- **Trust & Verification** — Authentication partnerships for provenance
- **The Garment's Story** — History, not product description. A handoff.

### 1.4 The Intentional Dresser (Target User)

**Age:** 18-35 (mindset matters more than number)
**Values:** Sustainability as way of life, quality over quantity, community over competition
**Behavior:** Already shops secondhand but wants something more curated, more *them*
**Geographic Focus:** Australia first ($2.6B market, 15% growth) → APAC expansion

### 1.5 Revenue Model

1. **Transaction Commission (8-12%)** — Fair fee, scaled by value
2. **Modaics Atelier ($9.99/mo)** — Premium tier:
   - Priority placement
   - Advanced analytics
   - Reduced commission (6%)
   - Early feature access
   - Custom storefront
3. **Thoughtful Brand Partnerships** — Curated collaborations, not banner ads

### 1.6 The Vision Close

> "Imagine opening your wardrobe and knowing the story of every piece inside it. The linen shirt found on Modaics, listed by a ceramicist in Byron Bay who'd worn it soft over three summers. The wool coat passed along by a student in Melbourne. The silk scarf traded at a swap meet."
> 
> **That's the wardrobe Modaics builds. Not a collection of transactions — a mosaic of choices, each one intentional, each one extending the life of something beautiful.**

---

## PART 2: THE DESIGN SYSTEM (FROM DESIGN DIRECTION)

### 2.1 Color Palette — Mediterranean Warmth

| Color | Hex | Usage |
|-------|-----|-------|
| **Terracotta** | #C2703E | Primary accent. Buttons, highlights, key callouts. The signature Modaics color. |
| **Warm Sand** | #E8D5B7 | Primary background. Warm, soft, never stark white. |
| **Deep Olive** | #5B6B4A | Secondary accent. Section dividers, supporting text, icons. |
| **Charcoal Clay** | #3B3632 | Primary text. Warm black — never pure #000000. |
| **Cream** | #F5F0E8 | Light background variant. Cards, callout boxes. |

**Supporting:**
- Burnt Sienna #A0522D — hover states, depth
- Sage #9CAF88 — light accents, tags, badges
- Oatmeal #D4C5A9 — subtle borders, dividers
- Burgundy #6B2D3E — premium features, Atelier (sparingly)

**NEVER USE:**
- Pure white (#FFFFFF) — too clinical
- Pure black (#000000) — too harsh
- Neon/saturated colors — nothing synthetic
- Cool greys or blues — everything warm-toned
- Gradients — keep flat, matte, tactile

### 2.2 Typography — Editorial Warmth

**Recommended:**
- **Headlines:** Freight Display (serif, elegant, slightly vintage) OR Lora (Google Font, free)
- **Body:** Source Sans 3 (humanist sans-serif) OR Nunito (Google Font, rounded)
- **Accents/Labels:** DM Sans OR Inter

**Rules:**
- Headlines large and unhurried — let them breathe
- Body: 16–18px minimum, line height 1.6–1.8
- Never ALL CAPS for more than 2–3 words
- Headlines: slightly tight letter-spacing (-0.5 to -1%)
- Labels: slightly loose (+2–5%)
- Avoid bold/heavy weights — medium at most

### 2.3 Photography Direction

**The Feel:** Natural light, taken by someone who cares.

**DO:**
- Golden hour, soft window light, overcast warmth
- Textural close-ups (weave, grain, buttons, stitching)
- Hands and human touch (folding, wrapping, adjusting)
- Styled environments (linen, wooden chairs, terracotta walls)
- Imperfect beauty (slightly rumpled, lived-in, real)
- Earthy settings (wood, ceramic, dried flowers)
- Warm color grading (+5–10% warmth, lifted shadows, soft highlights)

**DON'T:**
- Stark white studio backgrounds
- Flash photography
- Heavily filtered/over-saturated
- Stock photo energy
- Tech/device mockups as heroes
- Flat-lay inventory grids

### 2.4 Layout & Composition

- **Generous margins** — at least 15% each side
- **Asymmetric layouts** — not everything centered
- **One idea per page** — white space is a feature
- **Soft grid** — magazine spreads, not rigid 12-column
- **Section dividers:** thin terracotta rule or textural element
- **Pull quotes** — compelling lines as large quotes (28–36pt)

### 2.5 The Mosaic Motif

**Subtle visual thread throughout:**
- Cover: Mosaic pattern from terracotta, olive, sand tiles — modern geometric interpretation
- Section headers: Small mosaic fragment as decorative element
- Photo grid: Mosaic layout — different sizes, organic arrangement
- Background: Very subtle, low-opacity mosaic tile pattern

**Whisper, not shout.**

### 2.6 Tone Reference Brands

- **Aesop** — warm, literary, substance over flash
- **Patagonia** — purpose-driven, honest, earthy
- **Toast (UK)** — artisanal, unhurried, beautiful editorial
- **Kinfolk magazine** — clean, warm, intentional lifestyle
- **Le Labo** — craft-focused, handwritten, no decoration

**Shared thread: They make you slow down.**

---

## PART 3: TECHNICAL ARCHITECTURE

### 3.1 Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│  SwiftUI Views → ViewModels → State Management              │
│  - Story-first, not feature-first                           │
│  - Editorial layout, not tech dashboard                     │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│  Use Cases → Repository Interfaces → Entity Definitions     │
│  - Business logic: Stories, Discovery, Exchange             │
│  - NOT: API endpoints, algorithms, data structures          │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                     DATA LAYER                               │
│  Repository Implementations → API Clients → Database        │
│  - "Quietly intelligent" — invisible enablers               │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Project Structure

```
Modaics/
├── 📱 App/
│   ├── ModaicsApp.swift
│   ├── ContentView.swift
│   └── AppDelegate.swift
│
├── 🎨 DesignSystem/
│   ├── Colors.swift (Terracotta, Sand, Olive)
│   ├── Typography.swift (Freight/Lora, Source Sans)
│   ├── Layout.swift (Generous margins, asymmetric)
│   └── Components/
│       ├── MosaicButton.swift (Terracotta accent)
│       ├── MosaicCard.swift (Cream background)
│       ├── StoryInput.swift (Garment narrative)
│       └── DiscoveryCard.swift (Editorial layout)
│
├── 🏗️ Core/
│   ├── Domain/
│   │   ├── Entities/
│   │   │   ├── User.swift (The Intentional Dresser)
│   │   │   ├── Garment.swift (with Story)
│   │   │   ├── Exchange.swift (Buy/Sell/Trade)
│   │   │   ├── Wardrobe.swift (The Mosaic)
│   │   │   └── Atelier.swift (Premium tier)
│   │   │
│   │   ├── UseCases/
│   │   │   ├── DiscoverGarments.swift (Smart matching)
│   │   │   ├── TellGarmentStory.swift (Listing with narrative)
│   │   │   ├── ExchangeGarment.swift (Buy/Sell/Trade)
│   │   │   ├── BuildWardrobe.swift (Collection curation)
│   │   │   └── JoinAtelier.swift (Premium features)
│   │   │
│   │   └── RepositoryProtocols/
│   │       ├── GarmentRepository.swift
│   │       ├── ExchangeRepository.swift
│   │       ├── StoryRepository.swift
│   │       └── AtelierRepository.swift
│   │
│   └── Data/
│       ├── Repositories/
│       ├── API/
│       └── Database/
│
├── 🎭 Presentation/
│   ├── Common/
│   │   ├── EditorialLayout/
│   │   ├── PhotoTreatment/
│   │   └── MosaicMotif/
│   │
│   ├── Discovery/
│   │   ├── DiscoveryView.swift (Editorial, not grid)
│   │   ├── GarmentCard.swift (Photo + story excerpt)
│   │   └── DiscoveryViewModel.swift
│   │
│   ├── Story/
│   │   ├── TellStoryView.swift (Garment narrative input)
│   │   ├── PhotoCaptureView.swift (Styled capture)
│   │   └── StoryViewModel.swift
│   │
│   ├── Exchange/
│   │   ├── ExchangeView.swift (Buy/Sell/Trade)
│   │   ├── HandoffView.swift (Transaction ritual)
│   │   └── ExchangeViewModel.swift
│   │
│   ├── Wardrobe/
│   │   ├── WardrobeView.swift (The Mosaic)
│   │   ├── CollectionView.swift (Curated sets)
│   │   └── WardrobeViewModel.swift
│   │
│   ├── Atelier/
│   │   ├── AtelierView.swift (Premium tier)
│   │   ├── AnalyticsView.swift (Seller insights)
│   │   └── AtelierViewModel.swift
│   │
│   └── Community/
│       ├── CirclesView.swift (Style circles)
│       ├── SwapMeetView.swift (In-person events)
│       └── CommunityViewModel.swift
│
├── 🔧 Services/
│   ├── AI/
│   │   ├── StyleMatching.swift (Quietly intelligent)
│   │   ├── PricingGuidance.swift (Fair market data)
│   │   └── StoryEnhancement.swift (AI-assisted narrative)
│   │
│   └── Media/
│       ├── PhotoEditor.swift (Warm color grading)
│       └── Cache.swift
│
└── 🧪 Tests/
```

### 3.3 Complete Entity Definitions

```swift
// MARK: - Garment (The Core Entity)

struct Garment: Identifiable, Codable, Hashable {
    let id: String
    let ownerId: String
    
    // The Basics
    let title: String
    let category: GarmentCategory
    let condition: GarmentCondition
    let size: String
    let brand: String?
    
    // The Story (CRITICAL)
    let story: GarmentStory
    let provenance: Provenance?
    
    // Visuals
    let photos: [GarmentPhoto]
    let primaryPhotoIndex: Int
    
    // The Exchange
    let exchangeType: ExchangeType // .buy, .sell, .trade
    let price: Price?
    let tradePreferences: [GarmentCategory]?
    
    // Discovery
    let styleAttributes: StyleAttributes
    let embedding: [Float]? // For visual similarity
    
    // Community
    let viewCount: Int
    let saveCount: Int
    let createdAt: Date
    let expiresAt: Date?
}

// MARK: - Garment Story (The Heart of Modaics)

struct GarmentStory: Codable, Hashable {
    let narrative: String // "Found this linen shirt at a market in Lisbon..."
    let history: String? // Previous owners, alterations, repairs
    let whySelling: String? // "It no longer fits my style, but deserves more summers"
    let careInstructions: String?
    let memories: [StoryMemory]?
}

struct StoryMemory: Codable, Hashable {
    let description: String
    let photoId: String?
}

// MARK: - Provenance (Where It Came From)

struct Provenance: Codable, Hashable {
    let source: ProvenanceSource // .vintage, .thrift, .designer, .handmade
    let location: String? // "Byron Bay, Australia"
    let era: String? // "1970s"
    let authenticity: AuthenticityStatus
}

// MARK: - Exchange Types

enum ExchangeType: String, Codable, CaseIterable {
    case buy = "buy"
    case sell = "sell"
    case trade = "trade"
    
    var displayName: String {
        switch self {
        case .buy: return "Buy"
        case .sell: return "Sell"
        case .trade: return "Trade"
        }
    }
    
    var icon: String {
        switch self {
        case .buy: return "bag.fill"
        case .sell: return "tag.fill"
        case .trade: return "arrow.left.arrow.right"
        }
    }
}

// MARK: - Price (Fair Pricing)

struct Price: Codable, Hashable {
    let amount: Double
    let currency: String
    let guidance: PricingGuidance?
    let negotiable: Bool
}

struct PricingGuidance: Codable, Hashable {
    let estimatedRange: ClosedRange<Double>
    let basedOn: [PricingFactor]
    let confidence: Double // 0.0 - 1.0
}

enum PricingFactor: String, Codable {
    case brandValue
    case condition
    case rarity
    case demand
    case comparableSales
}

// MARK: - Style Attributes (For Discovery)

struct StyleAttributes: Codable, Hashable {
    let textures: [Texture]
    let era: Era?
    let silhouette: Silhouette?
    let colors: [DominantColor]
    let mood: [Mood]
}

enum Texture: String, Codable, CaseIterable {
    case linen, silk, wool, cotton, leather, denim, velvet
}

enum Era: String, Codable, CaseIterable {
    case vintage1970s = "1970s"
    case vintage1980s = "1980s"
    case vintage1990s = "1990s"
    case y2k = "Y2K"
    case contemporary = "Contemporary"
}

enum Mood: String, Codable, CaseIterable {
    case minimal, bohemian, preppy, edgy, romantic, utilitarian
}

// MARK: - Wardrobe (The Mosaic)

struct Wardrobe: Identifiable, Codable {
    let id: String
    let ownerId: String
    let name: String // "My Summer Mosaic"
    let garments: [WardrobeGarment]
    let collections: [Collection]
    let story: String? // "Built over three years of careful curation..."
    let sustainabilityScore: SustainabilityScore
}

struct SustainabilityScore: Codable {
    let totalScore: Int // 0-100
    let garmentsSaved: Int
    let carbonOffset: Double // kg CO2
    let waterSaved: Double // liters
}
```

### 3.4 AI/ML Architecture — "Quietly Intelligent"

```swift
// MARK: - Style Discovery (Not Search)

protocol StyleDiscoveryService {
    /// Learns user's style from interactions, not explicit filters
    func learn(from interactions: [UserInteraction]) async
    
    /// Surfaces garments that "feel right" — not keyword matches
    func discover(for userId: String) async throws -> [GarmentRecommendation]
}

struct GarmentRecommendation {
    let garment: Garment
    let reason: RecommendationReason // Why this feels right
    let confidence: Double
}

enum RecommendationReason {
    case textureMatch // "You seem to love linen..."
    case eraMatch // "1970s pieces catch your eye..."
    case silhouetteMatch // "Relaxed fits work for you..."
    case storyResonance // "This narrative might speak to you..."
    case curatorPick // "Hand-selected for your style..."
}

// MARK: - Fair Pricing (Not Algorithm)

protocol PricingGuidanceService {
    /// Provides pricing guidance that "feels fair" — transparent market data
    func guidance(for garment: Garment) async throws -> PricingGuidance
}

// MARK: - Story Enhancement (AI-Assisted, Not AI-Written)

protocol StoryEnhancementService {
    /// Suggests story elements based on photos — user decides
    func suggestions(for photos: [GarmentPhoto]) async throws -> StorySuggestions
    
    /// Helps with wording — keeps human voice
    func refine(narrative: String) async throws -> String
}

struct StorySuggestions {
    let possibleTextures: [Texture]
    let possibleEra: Era?
    let suggestedPrompts: [String] // "Tell us about where you found this..."
}
```

---

## PART 4: FEATURE ROADMAP

### Phase 1: Foundation (Weeks 1-4)
**Goal:** Working app that feels like Modaics

**Features:**
1. ✅ Splash/Onboarding (Mosaic animation, Terracotta accent)
2. ✅ Firebase Auth (Email, Apple, Google)
3. ✅ Discovery Feed (Editorial layout, not grid)
4. ✅ Garment Story Input (Narrative-first listing)
5. ✅ Photo Capture (Styled for warmth)
6. ✅ Basic Exchange (Buy/Sell/Trade)
7. ✅ Wardrobe View (The Mosaic)

**Design System:**
- All colors implemented (Terracotta, Sand, Olive, Charcoal)
- Typography (Lora + Nunito)
- Editorial layouts
- Generous margins
- NO gradients

### Phase 2: Intelligence (Weeks 5-8)

**Features:**
1. Style Discovery (Quietly intelligent matching)
2. Fair Pricing Guidance (Market data)
3. AI Story Enhancement (Suggestions, not replacement)
4. Saved/Favorites
5. Basic Messaging (The handoff)

### Phase 3: Community (Weeks 9-12)

**Features:**
1. Following/Followers
2. Style Circles
3. Collections/Curation
4. Swap Meet Events (In-person gatherings)
5. Sustainability Score

### Phase 4: Atelier (Weeks 13-16)

**Features:**
1. Premium Subscription
2. Advanced Analytics
3. Custom Storefront
4. Priority Placement
5. Verification Partnerships

---

## PART 5: BACKEND SPECIFICATION

### 5.1 FastAPI Structure

```python
app/
├── main.py
├── config.py
├── routers/
│   ├── discovery.py      # Style matching, not search
│   ├── stories.py        # Garment narratives
│   ├── exchange.py       # Buy/Sell/Trade
│   ├── wardrobes.py      # The Mosaic
│   ├── atelier.py        # Premium features
│   └── community.py      # Circles, events
├── models/
│   ├── garment.py        # With story JSON field
│   ├── exchange.py
│   ├── wardrobe.py
│   └── atelier.py
├── services/
│   ├── style_matching.py # CLIP + behavioral
│   ├── pricing.py        # Market data aggregation
│   ├── story_ai.py       # GPT-4 for enhancement
│   └── verification.py   # Authentication partners
└── utils/
    └── embeddings.py
```

### 5.2 Database Schema (PostgreSQL)

```sql
-- Garments table with story as first-class citizen
CREATE TABLE garments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES users(id),
    
    -- The Basics
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    condition TEXT NOT NULL,
    size TEXT NOT NULL,
    brand TEXT,
    
    -- The Story (JSONB for flexibility)
    story JSONB NOT NULL,
    provenance JSONB,
    
    -- Exchange
    exchange_type TEXT NOT NULL, -- 'buy', 'sell', 'trade'
    price DECIMAL(10,2),
    trade_preferences TEXT[],
    
    -- Discovery
    style_attributes JSONB,
    embedding VECTOR(512),
    
    -- Community
    view_count INT DEFAULT 0,
    save_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    
    -- Full-text search on stories
    search_vector TSVECTOR
);

-- Enable story search
CREATE INDEX idx_garments_search ON garments USING GIN(search_vector);

-- Style matching with pgvector
CREATE INDEX idx_garments_embedding ON garments 
USING ivfflat (embedding vector_cosine_ops);

-- Wardrobes (The Mosaic)
CREATE TABLE wardrobes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES users(id),
    name TEXT NOT NULL,
    story TEXT,
    sustainability_score JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Collections within wardrobes
CREATE TABLE collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wardrobe_id UUID REFERENCES wardrobes(id),
    name TEXT NOT NULL,
    description TEXT,
    garment_ids UUID[]
);
```

---

## PART 6: KEY PRINCIPLES

### 6.1 Design Principles

1. **Warm over white** — Never #FFFFFF
2. **Tactile over digital** — No gradients, no neon
3. **Editorial over e-commerce** — Magazine spreads, not grids
4. **Asymmetric over centered** — Visual interest
5. **Generous over cramped** — 15%+ margins
6. **Mosaic over grid** — Organic arrangements

### 6.2 Copy Principles (From Changelog)

| Don't Use | Use Instead |
|-----------|-------------|
| Revolutionize | (Remove) |
| Seamless experience | Effortless and human |
| Game-changer | (Remove) |
| Leverage/utilize | Use/draw on |
| Disrupt | (Remove) |
| Users | Members/people |
| Items/products | Pieces/garments |
| Listing | Story |
| Monetize | Sustain |
| Scalable | (Show, don't tell) |
| Innovative | Thoughtful |
| Ecosystem | Community/gathering |
| Onboard | Welcome/invite |
| Pain point | (Describe naturally) |

### 6.3 Technical Principles

1. **Build bottom-up** — Models → Services → ViewModels → Views
2. **Single source of truth** — One definition per type
3. **Complete before complex** — Finish MVP before features
4. **Test everything** — Unit, integration, UI
5. **Quietly intelligent** — AI enables, doesn't headline

---

## PART 7: NEXT STEPS

### Immediate Actions:

1. ✅ **Read & approve this plan** — Confirm alignment
2. 🎨 **Create design system** — Colors, typography, components
3. 🏗️ **Build core models** — Garment, Story, Exchange, Wardrobe
4. 📱 **Implement Phase 1 features** — Foundation app
5. 🤖 **Add intelligence** — Style matching, pricing, story AI

### Success Metrics:

- **Week 4:** Working app with Terracotta aesthetic, story-first listing
- **Week 8:** Style discovery feels "quietly intelligent"
- **Week 12:** Community features (circles, collections) active
- **Week 16:** Atelier premium tier launched

---

## CONCLUSION

**This plan synthesizes:**
- V6 Vision (story-first, Intentional Dresser, "quietly intelligent")
- Design Direction (Mediterranean warmth, editorial, mosaic motif)
- Technical Architecture (clean, scalable, maintainable)
- Lessons from v2.0 (build bottom-up, complete definitions, test everything)

**The shift:** From "AI-powered marketplace" to "peer-to-peer circular fashion platform where every garment has a story."

**The aesthetic:** From Dark Green Porsche to Mediterranean warmth.

**The timeline:** 16 weeks to full feature set, 4 weeks to working MVP.

---

*Ready to build the wardrobe you want to open.*

🐉 **Alfred — Your Strategic Partner**
