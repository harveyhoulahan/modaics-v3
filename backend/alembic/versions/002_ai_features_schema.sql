-- ============================================
-- Migration: 002_ai_features_schema
-- Description: Add AI feature tables and indexes for Modaics AI
-- ============================================

BEGIN;

-- ============================================
-- Phase 1: Extensions
-- ============================================

-- Ensure pgvector is enabled
CREATE EXTENSION IF NOT EXISTS vector;

-- For geospatial queries on donation partners
CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;

-- ============================================
-- Phase 2: Enums
-- ============================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ai_activity_type') THEN
        CREATE TYPE ai_activity_type AS ENUM (
            'image_analysis',
            'similarity_search',
            'chat_message',
            'alert_created',
            'alert_match',
            'condition_grading',
            'style_recommendation',
            'wardrobe_analysis',
            'embedding_generated',
            'donation_routing'
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'chat_message_role') THEN
        CREATE TYPE chat_message_role AS ENUM ('user', 'assistant', 'system', 'tool');
    END IF;
END $$;

-- ============================================
-- Phase 3: Reference Tables
-- ============================================

-- Brand tiers for donation routing
CREATE TABLE IF NOT EXISTS brand_tiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_name VARCHAR(100) NOT NULL UNIQUE,
    tier INT NOT NULL CHECK (tier BETWEEN 1 AND 5),
    category VARCHAR(50),
    typical_resale_range_min DECIMAL(10, 2),
    typical_resale_range_max DECIMAL(10, 2),
    sustainability_rating DECIMAL(3,2),
    has_sustainability_initiatives BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_brand_tiers_tier ON brand_tiers(tier);
CREATE INDEX IF NOT EXISTS idx_brand_tiers_name ON brand_tiers(brand_name);

-- Donation partners
CREATE TABLE IF NOT EXISTS donation_partners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization VARCHAR(100) NOT NULL,
    location_name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    suburb VARCHAR(50) NOT NULL,
    state VARCHAR(10) NOT NULL CHECK (state IN ('NSW', 'VIC', 'QLD', 'SA', 'WA', 'TAS', 'ACT', 'NT')),
    postcode VARCHAR(10) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    phone VARCHAR(20),
    website TEXT,
    accepts_clothing BOOLEAN NOT NULL DEFAULT TRUE,
    accepts_accessories BOOLEAN NOT NULL DEFAULT TRUE,
    accepts_shoes BOOLEAN NOT NULL DEFAULT TRUE,
    has_donation_bin BOOLEAN NOT NULL DEFAULT FALSE,
    opening_hours JSONB,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_donation_partners_org ON donation_partners(organization);
CREATE INDEX IF NOT EXISTS idx_donation_partners_state ON donation_partners(state);
CREATE INDEX IF NOT EXISTS idx_donation_partners_location ON donation_partners USING gist (
    ll_to_earth(latitude, longitude)
);

-- ============================================
-- Phase 4: AI Attribute Tables
-- ============================================

-- AI-generated garment attributes
CREATE TABLE IF NOT EXISTS garment_ai_attributes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    garment_id UUID NOT NULL REFERENCES garments(id) ON DELETE CASCADE,
    category_primary VARCHAR(50) NOT NULL,
    category_confidence DECIMAL(4,3) NOT NULL CHECK (category_confidence BETWEEN 0 AND 1),
    category_alternatives JSONB DEFAULT '[]',
    color_primary VARCHAR(30) NOT NULL,
    color_confidence DECIMAL(4,3) NOT NULL,
    color_alternatives JSONB DEFAULT '[]',
    detected_colors JSONB DEFAULT '[]',
    material_primary VARCHAR(50),
    material_confidence DECIMAL(4,3),
    material_alternatives JSONB DEFAULT '[]',
    condition_grade CHAR(1) CHECK (condition_grade IN ('A', 'B', 'C', 'D', 'F')),
    condition_confidence DECIMAL(4,3),
    condition_details JSONB DEFAULT '{}',
    style_primary VARCHAR(50),
    style_confidence DECIMAL(4,3),
    style_alternatives JSONB DEFAULT '[]',
    pattern_primary VARCHAR(50),
    pattern_confidence DECIMAL(4,3),
    model_version VARCHAR(20) NOT NULL DEFAULT 'fashionclip-1.0',
    processed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(garment_id)
);

CREATE INDEX IF NOT EXISTS idx_garment_ai_attrs_garment ON garment_ai_attributes(garment_id);
CREATE INDEX IF NOT EXISTS idx_garment_ai_attrs_category ON garment_ai_attributes(category_primary);
CREATE INDEX IF NOT EXISTS idx_garment_ai_attrs_color ON garment_ai_attributes(color_primary);
CREATE INDEX IF NOT EXISTS idx_garment_ai_attrs_condition ON garment_ai_attributes(condition_grade);

-- Image-level embeddings
CREATE TABLE IF NOT EXISTS garment_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    garment_id UUID NOT NULL REFERENCES garments(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    image_order INT NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    embedding VECTOR(512),
    detected_objects JSONB DEFAULT '[]',
    blur_score DECIMAL(4,3),
    brightness_score DECIMAL(4,3),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_garment_images_garment ON garment_images(garment_id);
CREATE INDEX IF NOT EXISTS idx_garment_images_primary ON garment_images(garment_id, is_primary) WHERE is_primary = true;

-- ============================================
-- Phase 5: Search Alert Tables
-- ============================================

-- User search alerts
CREATE TABLE IF NOT EXISTS search_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    text_embedding VECTOR(512) NOT NULL,
    reference_image_url TEXT,
    image_embedding VECTOR(512),
    max_price DECIMAL(10, 2),
    category VARCHAR(50),
    condition_min CHAR(1) CHECK (condition_min IN ('A', 'B', 'C', 'D')),
    size VARCHAR(20),
    similarity_threshold DECIMAL(3,2) NOT NULL DEFAULT 0.72 CHECK (similarity_threshold BETWEEN 0 AND 1),
    match_mode VARCHAR(20) NOT NULL DEFAULT 'hybrid' CHECK (match_mode IN ('text', 'image', 'hybrid')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    notification_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    matches_found INT NOT NULL DEFAULT 0,
    last_match_at TIMESTAMPTZ,
    last_notified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_search_alerts_user ON search_alerts(user_id);
CREATE INDEX IF NOT EXISTS idx_search_alerts_active ON search_alerts(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_search_alerts_category ON search_alerts(category) WHERE category IS NOT NULL;

-- Alert match log
CREATE TABLE IF NOT EXISTS search_alert_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id UUID NOT NULL REFERENCES search_alerts(id) ON DELETE CASCADE,
    garment_id UUID NOT NULL REFERENCES garments(id) ON DELETE CASCADE,
    similarity_score DECIMAL(4,3) NOT NULL,
    match_reasons JSONB NOT NULL DEFAULT '[]',
    notification_sent BOOLEAN NOT NULL DEFAULT FALSE,
    notification_sent_at TIMESTAMPTZ,
    notification_read BOOLEAN NOT NULL DEFAULT FALSE,
    notification_read_at TIMESTAMPTZ,
    user_clicked BOOLEAN NOT NULL DEFAULT FALSE,
    user_clicked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alert_matches_alert ON search_alert_matches(alert_id);
CREATE INDEX IF NOT EXISTS idx_alert_matches_garment ON search_alert_matches(garment_id);
CREATE INDEX IF NOT EXISTS idx_alert_matches_notification ON search_alert_matches(alert_id, notification_sent);
CREATE INDEX IF NOT EXISTS idx_alert_matches_created ON search_alert_matches(created_at);

-- ============================================
-- Phase 6: AI Activity Logging
-- ============================================

CREATE TABLE IF NOT EXISTS ai_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    activity_type ai_activity_type NOT NULL,
    request_id VARCHAR(100),
    input_data JSONB,
    input_tokens INT,
    output_data JSONB,
    output_tokens INT,
    processing_time_ms INT,
    model_version VARCHAR(50),
    user_feedback VARCHAR(20) CHECK (user_feedback IN ('positive', 'negative', 'neutral')),
    confidence_score DECIMAL(4,3),
    error_occurred BOOLEAN NOT NULL DEFAULT FALSE,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_logs_user ON ai_activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_logs_type ON ai_activity_logs(activity_type);
CREATE INDEX IF NOT EXISTS idx_ai_logs_created ON ai_activity_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_ai_logs_user_type ON ai_activity_logs(user_id, activity_type);
CREATE INDEX IF NOT EXISTS idx_ai_logs_error ON ai_activity_logs(error_occurred) WHERE error_occurred = true;

-- ============================================
-- Phase 7: Chat Tables
-- ============================================

CREATE TABLE IF NOT EXISTS chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200),
    session_id VARCHAR(100) NOT NULL UNIQUE,
    wardrobe_context JSONB,
    alert_context JSONB,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_message_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_conversations_user ON chat_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_active ON chat_conversations(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_chat_conversations_updated ON chat_conversations(updated_at);

CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    role chat_message_role NOT NULL,
    content TEXT NOT NULL,
    tool_calls JSONB,
    tool_call_id VARCHAR(100),
    input_tokens INT,
    output_tokens INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created ON chat_messages(created_at);

-- ============================================
-- Phase 8: HNSW Indexes (High Performance)
-- ============================================

-- Garment embeddings (primary similarity search)
CREATE INDEX IF NOT EXISTS idx_garments_embedding_hnsw ON garments 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- Search alert text embeddings
CREATE INDEX IF NOT EXISTS idx_search_alerts_text_embedding_hnsw ON search_alerts 
USING hnsw (text_embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- Search alert image embeddings (conditional)
CREATE INDEX IF NOT EXISTS idx_search_alerts_image_embedding_hnsw ON search_alerts 
USING hnsw (image_embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64)
WHERE image_embedding IS NOT NULL;

-- Garment image embeddings
CREATE INDEX IF NOT EXISTS idx_garment_images_embedding_hnsw ON garment_images 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64)
WHERE embedding IS NOT NULL;

-- ============================================
-- Phase 9: Seed Data
-- ============================================

-- Brand tiers seed data
INSERT INTO brand_tiers (brand_name, tier, category, sustainability_rating, has_sustainability_initiatives) VALUES
    -- Tier 1: Ultra fast fashion
    ('shein', 1, 'ultra_fast_fashion', 0.1, false),
    ('temu', 1, 'ultra_fast_fashion', 0.1, false),
    ('romwe', 1, 'ultra_fast_fashion', 0.1, false),
    ('zaful', 1, 'ultra_fast_fashion', 0.15, false),
    ('fashionnova', 1, 'ultra_fast_fashion', 0.15, false),
    
    -- Tier 2: Fast fashion
    ('h&m', 2, 'fast_fashion', 0.35, true),
    ('zara', 2, 'fast_fashion', 0.35, true),
    ('kmart', 2, 'fast_fashion', 0.25, false),
    ('target au', 2, 'fast_fashion', 0.30, true),
    ('cotton on', 2, 'fast_fashion', 0.30, true),
    ('boohoo', 2, 'fast_fashion', 0.20, false),
    ('asos', 2, 'fast_fashion', 0.35, true),
    ('forever 21', 2, 'fast_fashion', 0.20, false),
    ('primark', 2, 'fast_fashion', 0.20, false),
    ('old navy', 2, 'fast_fashion', 0.25, false),
    ('gap', 2, 'fast_fashion', 0.30, true),
    ('bonds', 2, 'fast_fashion', 0.35, true),
    ('best&less', 2, 'fast_fashion', 0.20, false),
    ('big w', 2, 'fast_fashion', 0.25, false),
    
    -- Tier 3: Mid-range
    ('uniqlo', 3, 'mid_range', 0.45, true),
    ('cos', 3, 'mid_range', 0.50, true),
    ('country road', 3, 'mid_range', 0.50, true),
    ('witchery', 3, 'mid_range', 0.50, true),
    ('trenery', 3, 'mid_range', 0.50, true),
    ('& other stories', 3, 'mid_range', 0.50, true),
    ('arket', 3, 'mid_range', 0.55, true),
    ('massimo dutti', 3, 'mid_range', 0.45, true),
    ('mango', 3, 'mid_range', 0.40, true),
    ('assembly label', 3, 'mid_range', 0.55, true),
    ('nobody denim', 3, 'mid_range', 0.70, true),
    ('bassike basics', 3, 'mid_range', 0.60, true),
    
    -- Tier 4: Premium
    ('sandro', 4, 'premium', 0.50, false),
    ('maje', 4, 'premium', 0.50, false),
    ('allsaints', 4, 'premium', 0.55, true),
    ('ted baker', 4, 'premium', 0.50, true),
    ('reiss', 4, 'premium', 0.50, false),
    ('acne studios', 4, 'premium', 0.60, true),
    ('apc', 4, 'premium', 0.60, true),
    ('rag & bone', 4, 'premium', 0.55, true),
    ('theory', 4, 'premium', 0.50, false),
    ('zimmermann', 4, 'premium', 0.55, true),
    ('scanlan theodore', 4, 'premium', 0.55, true),
    ('camilla and marc', 4, 'premium', 0.55, false),
    ('bassike', 4, 'premium', 0.65, true),
    ('ellery', 4, 'premium', 0.55, true),
    ('dion lee', 4, 'premium', 0.55, true),
    ('alice mccall', 4, 'premium', 0.50, true),
    
    -- Tier 5: Designer/Luxury
    ('gucci', 5, 'luxury', 0.50, true),
    ('prada', 5, 'luxury', 0.50, true),
    ('louis vuitton', 5, 'luxury', 0.50, true),
    ('chanel', 5, 'luxury', 0.55, true),
    ('dior', 5, 'luxury', 0.55, true),
    ('saint laurent', 5, 'luxury', 0.50, false),
    ('balenciaga', 5, 'luxury', 0.50, false),
    ('bottega veneta', 5, 'luxury', 0.50, false),
    ('celine', 5, 'luxury', 0.50, false),
    ('loewe', 5, 'luxury', 0.55, true),
    ('valentino', 5, 'luxury', 0.50, false),
    ('versace', 5, 'luxury', 0.45, false),
    ('fendi', 5, 'luxury', 0.50, false),
    ('burberry', 5, 'luxury', 0.55, true),
    ('alexander mcqueen', 5, 'luxury', 0.50, false),
    ('tom ford', 5, 'luxury', 0.50, false),
    ('rick owens', 5, 'luxury', 0.50, false),
    ('comme des garcons', 5, 'luxury', 0.55, true),
    ('maison margiela', 5, 'luxury', 0.55, true),
    ('issey miyake', 5, 'luxury', 0.60, true)
ON CONFLICT (brand_name) DO NOTHING;

-- ============================================
-- Phase 10: Trigger Functions
-- ============================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers
CREATE TRIGGER update_brand_tiers_updated_at BEFORE UPDATE ON brand_tiers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_donation_partners_updated_at BEFORE UPDATE ON donation_partners
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_garment_ai_attrs_updated_at BEFORE UPDATE ON garment_ai_attributes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_garment_images_updated_at BEFORE UPDATE ON garment_images
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_search_alerts_updated_at BEFORE UPDATE ON search_alerts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_conversations_updated_at BEFORE UPDATE ON chat_conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMIT;

-- ============================================
-- Migration Verification
-- ============================================

-- Verify tables created
SELECT 
    'brand_tiers' as table_name, COUNT(*) as row_count FROM brand_tiers
UNION ALL
SELECT 'donation_partners', 0
UNION ALL
SELECT 'garment_ai_attributes', 0
UNION ALL
SELECT 'garment_images', 0
UNION ALL
SELECT 'search_alerts', 0
UNION ALL
SELECT 'search_alert_matches', 0
UNION ALL
SELECT 'ai_activity_logs', 0
UNION ALL
SELECT 'chat_conversations', 0
UNION ALL
SELECT 'chat_messages', 0;
