# Modaics API Documentation

> **Version**: 3.0  
> **Base URL**: `https://api.modaics.com/v1` (production)  
> **Base URL**: `http://localhost:8000/v1` (development)

---

## 🚀 Getting Started

All API requests require authentication via Bearer token:

```http
Authorization: Bearer <your-jwt-token>
```

### Content Types
- Request body: `application/json`
- Image uploads: `multipart/form-data`
- Response: `application/json`

---

## 👤 Authentication

### POST /auth/register
Register a new user account.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "first_name": "Jane",
  "last_name": "Doe"
}
```

**Response (201):**
```json
{
  "user_id": "uuid",
  "email": "user@example.com",
  "first_name": "Jane",
  "last_name": "Doe",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

---

### POST /auth/login
Authenticate existing user.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response (200):**
```json
{
  "user_id": "uuid",
  "email": "user@example.com",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

---

### POST /auth/refresh
Refresh access token.

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

---

## 👕 Clothing Items

### GET /items
List all clothing items for the authenticated user.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `category` | string | Filter by category (tops, bottoms, dresses, etc.) |
| `color` | string | Filter by color |
| `season` | string | Filter by season |
| `occasion` | string | Filter by occasion |
| `limit` | integer | Items per page (default: 20, max: 100) |
| `offset` | integer | Pagination offset |

**Response (200):**
```json
{
  "items": [
    {
      "id": "uuid",
      "name": "Silk Blouse",
      "category": "tops",
      "subcategory": "blouses",
      "color": "cream",
      "color_hex": "#F5F5DC",
      "pattern": "solid",
      "material": "silk",
      "season": ["spring", "summer"],
      "occasion": ["work", "casual"],
      "image_url": "https://cdn.modaics.com/items/uuid.jpg",
      "thumbnail_url": "https://cdn.modaics.com/items/uuid_thumb.jpg",
      "attributes": {
        "sleeve_length": "long",
        "neckline": "v-neck",
        "fit": "relaxed"
      },
      "created_at": "2026-02-18T14:00:00Z",
      "updated_at": "2026-02-18T14:00:00Z"
    }
  ],
  "total": 150,
  "limit": 20,
  "offset": 0
}
```

---

### POST /items
Add a new clothing item with image upload.

**Request:**
```http
Content-Type: multipart/form-data
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | file | Yes | Clothing item image (JPEG/PNG, max 10MB) |
| `name` | string | No | Custom name (auto-generated if omitted) |
| `category` | string | No | Override auto-detected category |

**Response (201):**
```json
{
  "id": "uuid",
  "name": "Silk Blouse",
  "category": "tops",
  "subcategory": "blouses",
  "color": "cream",
  "color_hex": "#F5F5DC",
  "pattern": "solid",
  "material": "silk",
  "season": ["spring", "summer"],
  "occasion": ["work", "casual"],
  "image_url": "https://cdn.modaics.com/items/uuid.jpg",
  "thumbnail_url": "https://cdn.modaics.com/items/uuid_thumb.jpg",
  "attributes": {
    "sleeve_length": "long",
    "neckline": "v-neck",
    "fit": "relaxed"
  },
  "ai_confidence": 0.94,
  "created_at": "2026-02-18T14:00:00Z"
}
```

---

### GET /items/{item_id}
Get details for a specific clothing item.

**Response (200):**
```json
{
  "id": "uuid",
  "name": "Silk Blouse",
  "category": "tops",
  "subcategory": "blouses",
  "color": "cream",
  "color_hex": "#F5F5DC",
  "pattern": "solid",
  "material": "silk",
  "season": ["spring", "summer"],
  "occasion": ["work", "casual"],
  "image_url": "https://cdn.modaics.com/items/uuid.jpg",
  "thumbnail_url": "https://cdn.modaics.com/items/uuid_thumb.jpg",
  "attributes": {
    "sleeve_length": "long",
    "neckline": "v-neck",
    "fit": "relaxed"
  },
  "tags": ["favorite", "workwear"],
  "notes": "Hand wash only",
  "created_at": "2026-02-18T14:00:00Z",
  "updated_at": "2026-02-18T14:00:00Z"
}
```

---

### PUT /items/{item_id}
Update clothing item details.

**Request:**
```json
{
  "name": "Updated Name",
  "category": "tops",
  "color": "navy",
  "season": ["fall", "winter"],
  "occasion": ["formal"],
  "tags": ["favorite", "evening"],
  "notes": "Dry clean only"
}
```

**Response (200):** Updated item object

---

### DELETE /items/{item_id}
Delete a clothing item.

**Response (204):** No content

---

## 👗 Outfits

### GET /outfits
List all outfits for the user.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `occasion` | string | Filter by occasion |
| `season` | string | Filter by season |
| `favorite` | boolean | Filter favorites only |

**Response (200):**
```json
{
  "outfits": [
    {
      "id": "uuid",
      "name": "Summer Office Look",
      "occasion": "work",
      "season": "summer",
      "items": [
        { "item_id": "uuid1", "category": "tops", "image_url": "..." },
        { "item_id": "uuid2", "category": "bottoms", "image_url": "..." },
        { "item_id": "uuid3", "category": "shoes", "image_url": "..." }
      ],
      "is_favorite": true,
      "created_at": "2026-02-18T14:00:00Z"
    }
  ]
}
```

---

### POST /outfits/generate
Generate outfit suggestions.

**Request:**
```json
{
  "occasion": "casual",
  "season": "summer",
  "item_count": 3,
  "style_preference": "minimalist"
}
```

**Response (200):**
```json
{
  "outfits": [
    {
      "id": "generated-1",
      "name": "Casual Summer Day",
      "occasion": "casual",
      "season": "summer",
      "items": [
        { "item_id": "uuid1", "category": "tops", "image_url": "..." },
        { "item_id": "uuid2", "category": "bottoms", "image_url": "..." },
        { "item_id": "uuid3", "category": "shoes", "image_url": "..." }
      ],
      "ai_reasoning": "Light colors suitable for warm weather",
      "confidence": 0.87
    }
  ]
}
```

---

### POST /outfits
Save a generated outfit.

**Request:**
```json
{
  "name": "My Summer Look",
  "item_ids": ["uuid1", "uuid2", "uuid3"],
  "occasion": "casual",
  "season": "summer",
  "is_favorite": false
}
```

**Response (201):** Saved outfit object

---

## 🤖 AI Features

### POST /ai/analyze-image
Analyze a clothing image and return attributes.

**Request:**
```http
Content-Type: multipart/form-data
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | file | Yes | Clothing image |

**Response (200):**
```json
{
  "category": "tops",
  "subcategory": "blouses",
  "color": "cream",
  "color_hex": "#F5F5DC",
  "pattern": "solid",
  "material": "silk",
  "attributes": {
    "sleeve_length": "long",
    "neckline": "v-neck",
    "fit": "relaxed"
  },
  "confidence_scores": {
    "category": 0.96,
    "color": 0.89,
    "material": 0.82
  }
}
```

---

### GET /ai/style-recommendations
Get personalized style recommendations.

**Response (200):**
```json
{
  "recommendations": [
    {
      "type": "item_usage",
      "message": "You haven't worn your navy blazer in 3 weeks",
      "item_id": "uuid",
      "suggested_outfit_id": "uuid"
    },
    {
      "type": "gap_analysis",
      "message": "Consider adding more neutral tops for versatile outfits",
      "category": "tops"
    }
  ]
}
```

---

## 📊 Categories & Metadata

### GET /categories
List all clothing categories and subcategories.

**Response (200):**
```json
{
  "categories": [
    {
      "id": "tops",
      "name": "Tops",
      "icon": "👕",
      "subcategories": [
        { "id": "t-shirts", "name": "T-Shirts" },
        { "id": "blouses", "name": "Blouses" },
        { "id": "sweaters", "name": "Sweaters" }
      ]
    },
    {
      "id": "bottoms",
      "name": "Bottoms",
      "icon": "👖",
      "subcategories": [
        { "id": "jeans", "name": "Jeans" },
        { "id": "skirts", "name": "Skirts" },
        { "id": "shorts", "name": "Shorts" }
      ]
    }
  ]
}
```

---

### GET /colors
List all available colors.

**Response (200):**
```json
{
  "colors": [
    { "id": "black", "name": "Black", "hex": "#000000" },
    { "id": "white", "name": "White", "hex": "#FFFFFF" },
    { "id": "navy", "name": "Navy", "hex": "#000080" },
    { "id": "cream", "name": "Cream", "hex": "#F5F5DC" }
  ]
}
```

---

## ❌ Error Responses

All errors follow this format:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      {
        "field": "email",
        "message": "Valid email address required"
      }
    ]
  }
}
```

### Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Missing or invalid authentication |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `VALIDATION_ERROR` | 422 | Invalid request parameters |
| `RATE_LIMITED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |

---

## 📈 Rate Limits

| Endpoint | Limit |
|----------|-------|
| General API | 100 requests/minute |
| Image uploads | 10 uploads/minute |
| AI generation | 20 requests/minute |

Rate limit headers included in all responses:
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1645200000
```

---

## 🔄 Versioning

API versioning is handled via URL path:
- Current: `/v1/`
- Future versions: `/v2/`, etc.

Deprecated endpoints will include a warning header:
```http
Deprecation: true
Sunset: Sat, 01 Jun 2026 00:00:00 GMT
```

---

*Last updated: February 2026*
