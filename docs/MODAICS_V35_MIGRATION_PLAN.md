# MODAICS V3.5 — UNIFIED BACKEND MIGRATION PLAN
## Merging v2.0 (25K items + working CLIP) with v3.0 (clean architecture + story-first)

---

## CURRENT STATE

### v2.0 Backend (Existing)
- **Location:** `/root/.openclaw/workspace/modaics-audit/backend/`
- **Data:** 25,677 Depop items in PostgreSQL
- **Embeddings:** 768-dim CLIP (OpenAI CLIP ViT-L/14)
- **Features:** Visual search, payments (Stripe), sketchbook, subscriptions
- **Issues:** Monolithic app.py (1,359 lines), mixed concerns

### v3.0 Backend (New)
- **Location:** `/root/.openclaw/workspace/modaics-v3/backend/`
- **Data:** Empty, clean schema
- **Embeddings:** 512-dim (different model!)
- **Features:** Story-first models, clean architecture, async SQLAlchemy 2.0
- **Strengths:** Proper separation, JSONB stories, domain-driven

---

## MIGRATION STRATEGY

### Phase 1: Schema Unification (Keep v3.0 structure, adapt for v2.0 data)

**Critical Decision:** Keep v3.0's 512-dim embeddings OR migrate v2.0's 768-dim?

**Answer:** Keep 768-dim (v2.0) — re-embedding 25K items is expensive. Update v3.0 models.

**Unified Schema:**
```sql
-- Garments (merged from both)
CREATE TABLE garments (
    id UUID PRIMARY KEY,
    owner_id UUID REFERENCES users(id),
    
    -- From v2.0 (Depop data)
    external_id TEXT, -- Original Depop ID
    source TEXT DEFAULT 'modaics', -- 'depop', 'grailed', 'vinted', 'modaics'
    original_url TEXT,
    original_image_url TEXT,
    
    -- From v3.0 (Story-first)
    title TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL,
    condition TEXT NOT NULL,
    size TEXT,
    brand TEXT,
    
    -- The Story (v3.0 concept applied to v2.0 data)
    story JSONB, -- narrative, mood, memories
    provenance JSONB, -- source, materials, made_in
    
    -- Exchange (v3.0)
    exchange_type TEXT DEFAULT 'sell', -- buy, sell, trade, gift
    price DECIMAL(10,2),
    currency TEXT DEFAULT 'AUD',
    
    -- Style & AI (merged)
    style_attributes JSONB, -- colors, patterns, tags
    embedding VECTOR(768), -- From v2.0
    
    -- Engagement (merged)
    view_count INT DEFAULT 0,
    save_count INT DEFAULT 0,
    status TEXT DEFAULT 'active',
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Search
    search_vector TSVECTOR
);

-- Full-text search index
CREATE INDEX idx_garments_search ON garments USING GIN(search_vector);

-- Vector similarity index (ivfflat for 768-dim)
CREATE INDEX idx_garments_embedding ON garments 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Migration: Copy v2.0 Depop items with auto-generated stories
-- For each depop item:
--   title -> title
--   description -> description + story.text
--   price -> price
--   image_url -> original_image_url
--   external_id -> external_id
--   embedding -> embedding (768-dim)
--   source -> 'depop'
--   Auto-generate story from description using GPT
```

### Phase 2: Architecture (Keep v3.0 clean structure)

**Folder Structure:**
```
modaics-v3.5/backend/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI entry (from v3.0)
│   ├── config.py               # Settings (merge both)
│   ├── database.py             # Async SQLAlchemy (v3.0)
│   ├── lifespan.py             # Startup/shutdown (merge)
│   │
│   ├── models/                 # SQLAlchemy models (v3.0 base)
│   │   ├── __init__.py
│   │   ├── garment.py          # UPDATED for 768-dim + v2.0 fields
│   │   ├── user.py             # v3.0 + v2.0 auth
│   │   ├── exchange.py         # v3.0 + v2.0 transactions
│   │   ├── wardrobe.py         # v3.0
│   │   ├── story.py            # NEW - story management
│   │   ├── payment.py          # FROM v2.0 payments.py
│   │   └── sketchbook.py       # FROM v2.0 sketchbook.py
│   │
│   ├── schemas/                # Pydantic models (merge)
│   │   ├── __init__.py
│   │   ├── garment.py          # v3.0 + v2.0 fields
│   │   ├── search.py           # FROM v2.0 models.py
│   │   ├── payment.py          # FROM v2.0
│   │   └── sketchbook.py       # FROM v2.0
│   │
│   ├── routers/                # API endpoints (merge)
│   │   ├── __init__.py
│   │   ├── garments.py         # CRUD (v3.0 style)
│   │   ├── discovery.py        # Visual search (v2.0 logic + v3.0 style)
│   │   ├── search.py           # FROM v2.0 - image search
│   │   ├── exchange.py         # v3.0 + v2.0 payments
│   │   ├── payments.py         # FROM v2.0 payments.py
│   │   ├── wardrobes.py        # v3.0
│   │   ├── sketchbook.py       # FROM v2.0
│   │   └── stories.py          # NEW - story generation
│   │
│   ├── services/               # Business logic (merge)
│   │   ├── __init__.py
│   │   ├── embeddings.py       # FROM v2.0 - CLIP 768-dim
│   │   ├── search.py           # FROM v2.0 - vector search
│   │   ├── story_generator.py  # NEW - AI story from description
│   │   ├── pricing.py          # v3.0
│   │   ├── style_matching.py   # v3.0 + v2.0
│   │   └── payments.py         # FROM v2.0
│   │
│   └── repositories/           # Data access (v3.0 pattern)
│       ├── __init__.py
│       ├── garment.py
│       ├── user.py
│       └── search.py
│
├── migrations/                 # Alembic migrations
│   ├── env.py
│   └── versions/
│       ├── 001_unified_schema.py
│       └── 002_migrate_v2_data.py
│
├── scripts/                    # Migration scripts
│   ├── migrate_depot_data.py   # Copy 25K items with story gen
│   └── verify_embeddings.py    # Check 768-dim compatibility
│
├── tests/
├── docker-compose.yml          # PostgreSQL + pgvector + Redis
├── Dockerfile
├── requirements.txt            # Merge both
└── README.md
```

### Phase 3: Data Migration Script

**`scripts/migrate_v2_data.py`:**
```python
"""
Migrate v2.0 Depop data to v3.5 unified schema.

Process:
1. Connect to v2.0 database (port 5433)
2. Fetch all 25,677 items
3. For each item:
   - Map fields to new schema
   - Generate story from description using GPT-4
   - Copy 768-dim embedding (no re-computation!)
4. Insert into v3.5 database
5. Verify counts
"""

# Pseudocode:
# - Connect to source DB (v2.0)
# - Connect to target DB (v3.5)
# - Batch process items (100 at a time)
# - Use OpenAI to enhance descriptions into stories
# - Preserve all embeddings
# - Log progress
```

### Phase 4: API Compatibility

**Keep v2.0 endpoints working:**
- `POST /search_by_image` → Keep (used by iOS app)
- `POST /analyze` → Keep (GPT-4 Vision)
- `POST /payment_intent` → Keep (Stripe)
- `GET /sketchbook/...` → Keep

**Add v3.0 endpoints:**
- `GET /garments` → New RESTful API
- `POST /garments` → New listing with story
- `GET /discovery` → Smart matching
- `GET /wardrobes` → Wardrobe management

### Phase 5: Embedding Strategy

**Critical:** v2.0 uses 768-dim, v3.0 planned 512-dim.

**Solution:** Standardize on 768-dim.

**Why:**
- Re-embedding 25K items = expensive + slow
- v2.0 CLIP ViT-L/14 is better quality than v3.0's smaller model
- iOS app expects 768-dim (based on handoff doc)

**Action:** Update v3.0 models to use 768-dim vectors.

---

## AGENT DEPLOYMENT PLAN

### Agent 1: Schema Migration (`v35-schema`)
**Task:** Update v3.0 SQLAlchemy models for 768-dim + v2.0 fields
**Files:** `app/models/garment.py`, `app/models/user.py`, etc.

### Agent 2: Service Migration (`v35-services`)
**Task:** Port v2.0 embedding/search logic to v3.0 service layer
**Files:** `app/services/embeddings.py`, `app/services/search.py`

### Agent 3: Router Migration (`v35-routers`)
**Task:** Merge v2.0 endpoints with v3.0 structure
**Files:** `app/routers/search.py`, `app/routers/payments.py`, `app/routers/sketchbook.py`

### Agent 4: Data Migration Script (`v35-migration`)
**Task:** Build script to migrate 25K items with story generation
**Files:** `scripts/migrate_v2_data.py`, `scripts/verify_embeddings.py`

### Agent 5: iOS Integration (`v35-ios`)
**Task:** Update iOS models for 768-dim + new API endpoints
**Files:** `iOS/Modaics/Core/...`, update repository implementations

### Agent 6: Testing & Verification (`v35-testing`)
**Task:** Build test suite, verify migration, performance tests
**Files:** `tests/...`, docker-compose for testing

---

## SUCCESS CRITERIA

1. ✅ All 25,677 items migrated with stories
2. ✅ 768-dim embeddings preserved
3. ✅ Visual search works (same speed/quality)
4. ✅ Payments/subscriptions functional
5. ✅ Sketchbook features preserved
6. ✅ New story-first API working
7. ✅ iOS app connects and works

---

## TIMELINE (All-Night Sprint)

**Hour 1-2:** Schema + Services (parallel)
**Hour 3-4:** Routers + Migration script (parallel)
**Hour 5-6:** iOS integration + Testing setup
**Hour 7-8:** Full integration test, bug fixes, documentation

**Goal:** Working v3.5 by morning with all 25K items + stories.

---

*Let's build this.*
