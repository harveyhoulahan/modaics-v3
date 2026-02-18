# Modaics Architecture

> **Overview of the technical architecture for Modaics v3.0**

---

## 🏗️ System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   iOS App   │  │  Web App    │  │     Admin Dashboard     │  │
│  │  (SwiftUI)  │  │  (Future)   │  │       (Future)          │  │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘  │
└─────────┼────────────────┼────────────────────┼────────────────┘
          │                │                    │
          └────────────────┴────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   API Gateway   │
                    │   (Rate Limit)  │
                    └────────┬────────┘
                             │
┌────────────────────────────┼────────────────────────────────────┐
│                    BACKEND LAYER                                │
│  ┌─────────────────────────▼────────────────────────────────┐  │
│  │              FastAPI Application Server                   │  │
│  │  ┌────────────┐ ┌──────────┐ ┌─────────┐ ┌───────────┐  │  │
│  │  │   Auth     │ │   API    │ │  AI/ML  │ │  Storage  │  │  │
│  │  │   Module   │ │  Routes  │ │ Services│ │  Service  │  │  │
│  │  └────────────┘ └──────────┘ └─────────┘ └───────────┘  │  │
│  └─────────────────────────┬────────────────────────────────┘  │
└────────────────────────────┼────────────────────────────────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
   ┌──────▼──────┐   ┌───────▼────────┐  ┌─────▼──────┐
   │  PostgreSQL │   │  Image Store   │  │ AI/ML APIs │
   │  (Primary)  │   │   (S3/CDN)     │  │ (External) │
   └─────────────┘   └────────────────┘  └────────────┘
```

---

## 📱 iOS Application Architecture

### MVVM + Clean Architecture

```
iOS/Modaics/
├── App/
│   ├── ModaicsApp.swift          # App entry point
│   ├── AppDelegate.swift         # Lifecycle, notifications
│   └── Info.plist
│
├── DesignSystem/
│   ├── Colors.swift              # Color definitions
│   ├── Typography.swift          # Font definitions
│   ├── Spacing.swift             # Layout constants
│   └── Components/
│       ├── Buttons/
│       ├── Cards/
│       ├── Inputs/
│       └── Loading/
│
├── Core/
│   ├── Extensions/               # Swift extensions
│   ├── Utilities/                # Helpers, formatters
│   ├── Protocols/                # Common interfaces
│   └── Constants.swift           # App constants
│
├── Domain/
│   ├── Entities/                 # Data models
│   ├── UseCases/                 # Business logic
│   └── RepositoryInterfaces/     # Repository contracts
│
├── Data/
│   ├── Repositories/             # Repository implementations
│   ├── Network/                  # API clients
│   ├── Storage/                  # Core Data/SwiftData
│   └── Mappers/                  # DTO <-> Entity mapping
│
└── Presentation/
    ├── Common/                   # Shared view components
    ├── Features/
    │   ├── Auth/
    │   ├── Wardrobe/
    │   ├── OutfitGenerator/
    │   ├── ItemDetail/
    │   └── Profile/
    └── Navigation/               # Navigation/routing
```

### Data Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│     UI      │───▶│  ViewModel  │───▶│  UseCase    │
│   (View)    │◀───│             │◀───│             │
└─────────────┘    └─────────────┘    └──────┬──────┘
                                             │
                                    ┌────────▼────────┐
                                    │   Repository    │
                                    │   Interface     │
                                    └────────┬────────┘
                                             │
                              ┌──────────────┼──────────────┐
                              │              │              │
                       ┌──────▼──────┐ ┌────▼─────┐ ┌──────▼──────┐
                       │  Network    │ │  Local   │ │   Cache     │
                       │ Repository  │ │ Repository│ │ Repository  │
                       └─────────────┘ └───────────┘ └─────────────┘
```

---

## ⚙️ Backend Architecture

### FastAPI Application Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                   # FastAPI app factory
│   ├── config.py                 # Environment config
│   │
│   ├── api/
│   │   ├── __init__.py
│   │   ├── deps.py               # Dependencies (auth, db)
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── router.py         # API router aggregation
│   │       ├── auth.py           # Authentication endpoints
│   │       ├── items.py          # Clothing items endpoints
│   │       ├── outfits.py        # Outfit endpoints
│   │       └── ai.py             # AI feature endpoints
│   │
│   ├── core/
│   │   ├── security.py           # JWT, password hashing
│   │   ├── logging.py            # Logging config
│   │   └── exceptions.py         # Custom exceptions
│   │
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py               # User SQLAlchemy model
│   │   ├── item.py               # Clothing item model
│   │   ├── outfit.py             # Outfit model
│   │   └── base.py               # Base model class
│   │
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── user.py               # User Pydantic schemas
│   │   ├── item.py               # Item schemas
│   │   └── outfit.py             # Outfit schemas
│   │
│   ├── services/
│   │   ├── __init__.py
│   │   ├── auth_service.py       # Auth business logic
│   │   ├── item_service.py       # Item business logic
│   │   ├── outfit_service.py     # Outfit business logic
│   │   ├── ai_service.py         # AI/ML integration
│   │   └── storage_service.py    # File storage
│   │
│   └── db/
│       ├── __init__.py
│       ├── session.py            # Database session
│       └── base_class.py         # Declarative base
│
├── tests/
│   ├── unit/                     # Unit tests
│   ├── integration/              # Integration tests
│   └── conftest.py               # pytest fixtures
│
├── alembic/                      # Database migrations
├── requirements.txt
├── Dockerfile
└── docker-compose.yml
```

---

## 🗄️ Database Schema

### Entity Relationship Diagram

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│    users     │       │    items     │       │   outfits    │
├──────────────┤       ├──────────────┤       ├──────────────┤
│ id (PK)      │◄──────┤ user_id (FK) │       │ id (PK)      │
│ email        │       │ id (PK)      │       │ user_id (FK) │◄────┐
│ password_hash│       │ name         │       │ name         │     │
│ first_name   │       │ category     │       │ occasion     │     │
│ last_name    │       │ color        │       │ season       │     │
│ created_at   │       │ image_url    │       │ is_favorite  │     │
│ updated_at   │       │ attributes   │       │ created_at   │     │
└──────────────┘       │ created_at   │       └──────────────┘     │
                       │ updated_at   │              ▲             │
                       └──────────────┘              │             │
                                                     │             │
                              ┌──────────────────────┘             │
                              │                                    │
                              │       ┌────────────────────────────┘
                              │       │
                              │  ┌────▼───────────┐
                              │  │ outfit_items   │
                              │  ├────────────────┤
                              └──┤ outfit_id (FK) │
                                 │ item_id (FK)   │
                                 │ position       │
                                 └────────────────┘
```

### Key Tables

**users**
- Primary user account information
- Authentication credentials (hashed)
- Profile data

**items**
- Clothing items owned by users
- AI-extracted attributes (color, category, etc.)
- Image references
- Custom tags and notes

**outfits**
- User-created and AI-generated outfits
- Occasion and season metadata
- Favorite flag

**outfit_items**
- Many-to-many junction table
- Defines item order within outfit

---

## 🤖 AI/ML Integration

### Image Analysis Pipeline

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  User Upload │───▶│   Preprocess │───▶│  OpenAI      │
│   Image      │    │   & Validate │    │  Vision API  │
└──────────────┘    └──────────────┘    └──────┬───────┘
                                               │
┌──────────────┐    ┌──────────────┐    ┌──────▼───────┐
│   Store      │◀───│   Parse      │◀───│   Extract    │
│  Attributes  │    │   Response   │    │  Features    │
└──────────────┘    └──────────────┘    └──────────────┘
```

### AI Services

1. **Image Classification**
   - Service: OpenAI Vision API
   - Identifies: Category, subcategory, color, pattern, material
   - Confidence scoring

2. **Attribute Extraction**
   - Extracts detailed attributes (sleeve length, neckline, fit)
   - Structured output parsing

3. **Outfit Generation**
   - Rule-based matching with ML enhancement
   - Color theory application
   - Occasion and season compatibility

4. **Style Recommendations**
   - Usage pattern analysis
   - Wardrobe gap detection
   - Personal style learning

---

## 🔐 Security Architecture

### Authentication Flow

```
┌─────────┐                    ┌─────────┐                    ┌─────────┐
│  Client │───────────────────▶│   API   │───────────────────▶│   DB    │
│         │  POST /auth/login  │         │  Validate credentials│         │
│         │◀───────────────────│         │◀───────────────────│         │
│         │  JWT + Refresh     │         │                    │         │
│         │                    │         │                    │         │
│         │───API Request─────▶│         │                    │         │
│         │  Authorization:    │         │                    │         │
│         │  Bearer <token>    │         │                    │         │
│         │◀───Protected───────│         │                    │         │
│         │     Resource       │         │                    │         │
└─────────┘                    └─────────┘                    └─────────┘
```

### Security Measures

- **Authentication**: JWT with short expiry (15 min)
- **Refresh Tokens**: Long-lived (7 days), single-use
- **Passwords**: Bcrypt hashing (cost factor 12)
- **HTTPS**: Required for all communications
- **Rate Limiting**: Prevents brute force attacks
- **Input Validation**: Pydantic schemas, SQL injection prevention
- **Image Validation**: File type, size limits, malware scanning

---

## 🚀 Deployment Architecture

### Production Stack

```
┌──────────────────────────────────────────────────────────┐
│                      CDN (CloudFront)                    │
└──────────────────────┬───────────────────────────────────┘
                       │
┌──────────────────────▼───────────────────────────────────┐
│                 Load Balancer (ALB)                      │
└──────────────┬─────────────────────┬─────────────────────┘
               │                     │
    ┌──────────▼────────┐   ┌────────▼────────┐
    │   API Server 1    │   │  API Server 2   │
    │   (Docker)        │   │   (Docker)      │
    │   - FastAPI       │   │   - FastAPI     │
    │   - Gunicorn      │   │   - Gunicorn    │
    └──────────┬────────┘   └────────┬────────┘
               │                     │
               └──────────┬──────────┘
                          │
    ┌─────────────────────┼─────────────────────┐
    │                     │                     │
┌───▼────┐          ┌────▼────┐         ┌─────▼─────┐
│PostgreSQL│          │  Redis   │         │    S3     │
│ Primary │          │  Cache   │         │  Images   │
└─────────┘          └──────────┘         └───────────┘
```

### Infrastructure Components

| Component | Technology | Purpose |
|-----------|------------|---------|
| Container Orchestration | AWS ECS / Kubernetes | Run API servers |
| Database | PostgreSQL 14+ | Primary data store |
| Cache | Redis | Session store, rate limiting |
| Object Storage | AWS S3 | Image storage |
| CDN | CloudFront | Image delivery |
| Load Balancer | AWS ALB | Traffic distribution |
| Secrets | AWS Secrets Manager | Credentials |
| Monitoring | CloudWatch + DataDog | Observability |

---

## 📊 Monitoring & Observability

### Logging
- Structured JSON logging
- Correlation IDs for request tracing
- Log aggregation (CloudWatch, ELK stack)

### Metrics
- Request rate, latency, error rate
- Business metrics (uploads, outfit generations)
- Infrastructure metrics (CPU, memory, DB connections)

### Alerting
- High error rate (>1%)
- Latency degradation (>500ms p95)
- Database connection issues
- Disk space warnings

---

## 🔄 CI/CD Pipeline

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Push   │───▶│  Build  │───▶│  Test   │───▶│ Deploy  │
│         │    │         │    │         │    │         │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
     │              │              │              │
  GitHub      Dockerfile      Unit Tests    Staging
  Actions     Build Image     Integration   Production
              Push to ECR     E2E Tests
```

### Deployment Strategy
- **Staging**: Auto-deploy on merge to `develop`
- **Production**: Manual approval for `main` merges
- **Rollback**: Blue-green deployment with instant rollback

---

## 📝 Future Considerations

### Scalability
- Read replicas for database
- Horizontal scaling of API servers
- Image processing queue (Celery/RabbitMQ)
- CDN edge caching

### Features
- Real-time notifications (WebSockets)
- Offline support (iOS)
- Social features (sharing outfits)
- E-commerce integration
- Advanced analytics dashboard

### Multi-platform
- Android app (Kotlin/Jetpack Compose)
- Web app (React/Vue)
- Admin dashboard

---

*Last updated: February 2026*
