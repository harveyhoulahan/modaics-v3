# Modaics

**Version 3.0 — The Complete Wardrobe Intelligence Platform**

> *"Your closet, understood. Your style, elevated."*

---

## 🌟 Project Vision

Modaics transforms how people interact with their wardrobes. Using advanced computer vision and AI, we automatically catalog clothing items, create intelligent outfits, and provide personalized style recommendations—turning everyday getting-dressed decisions into delightful experiences.

### What Makes Modaics Different

- **Intelligent Recognition**: Upload any clothing photo; our AI identifies category, color, pattern, and style attributes automatically
- **Smart Outfit Creation**: Generate occasion-appropriate outfits from your existing wardrobe
- **Personal Style Learning**: The more you use it, the better it understands your preferences
- **Visual Discovery**: Browse your wardrobe by color, season, occasion, or mood
- **Sustainable Fashion**: Maximize what you own, reduce waste, shop smarter

---

## 🛠️ Tech Stack

### Backend (FastAPI)
| Component | Technology |
|-----------|------------|
| Framework | FastAPI (Python 3.11+) |
| Database | PostgreSQL + SQLAlchemy |
| AI/ML | OpenAI Vision API, Custom classification models |
| Image Processing | Pillow, OpenCV |
| Authentication | JWT with OAuth2 |
| API Documentation | Auto-generated OpenAPI/Swagger |
| Testing | pytest, httpx |
| Deployment | Docker, AWS/GCP |

### iOS App (SwiftUI)
| Component | Technology |
|-----------|------------|
| Framework | SwiftUI (iOS 17+) |
| Architecture | MVVM + Clean Architecture |
| Networking | URLSession + custom networking layer |
| Image Handling | PhotosUI, Kingfisher |
| Local Storage | Core Data / SwiftData |
| Authentication | Sign in with Apple |
| Testing | XCTest, XCUITest |

### Design System
- **Colors**: Earthy, sophisticated palette (Terracotta, Sand, Olive, Cream, Charcoal)
- **Typography**: Lora (serif headings) + Nunito (sans-serif body)
- **Design Language**: Minimalist, editorial, accessible

---

## 📁 Project Structure

```
modaics-v3/
├── README.md                 # This file
├── .gitignore               # Git ignore rules
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── api/            # API routes
│   │   ├── core/           # Config, security
│   │   ├── models/         # SQLAlchemy models
│   │   ├── schemas/        # Pydantic schemas
│   │   ├── services/       # Business logic
│   │   └── main.py         # Application entry
│   ├── tests/
│   ├── requirements.txt
│   └── Dockerfile
├── iOS/                     # SwiftUI iOS app
│   └── Modaics/
│       ├── App/            # App entry, configuration
│       ├── DesignSystem/   # Colors, typography, components
│       ├── Core/           # Utilities, extensions, protocols
│       ├── Presentation/   # Views, ViewModels
│       └── Services/       # API clients, repositories
├── Design/                  # Design documentation
│   ├── ColorPalette.md
│   ├── Typography.md
│   └── Mockups/            # Screen mockups
└── docs/                    # Technical documentation
    ├── API.md
    └── Architecture.md
```

---

## 🚀 Setup Instructions

### Prerequisites
- Python 3.11+
- Node.js 18+ (for future web frontend)
- Xcode 15+ (for iOS development)
- PostgreSQL 14+
- Git

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with your database credentials and API keys

# Run database migrations
alembic upgrade head

# Start development server
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`
Documentation at `http://localhost:8000/docs`

### iOS Setup

```bash
# Open the project in Xcode
open iOS/Modaics/Modaics.xcodeproj

# Or if using Swift Package Manager
open iOS/Modaics/Modaics.xcworkspace
```

1. Select your development team in Signing & Capabilities
2. Choose a simulator or connected device
3. Press Cmd+R to build and run

---

## 🔄 Development Workflow

### Branch Strategy

We use a simplified Git Flow:

- **`main`**: Production-ready code only
- **`develop`**: Integration branch for features
- **`feature/*`**: Individual feature branches
- **`hotfix/*`**: Critical production fixes

### Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clean, documented code
   - Follow existing code style
   - Add tests for new functionality

3. **Commit with clear messages**
   ```bash
   git commit -m "feat: add image upload endpoint"
   ```
   
   Commit message prefixes:
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation changes
   - `style:` Code style (formatting, semicolons, etc)
   - `refactor:` Code refactoring
   - `test:` Adding or updating tests
   - `chore:` Build process, dependencies, etc

4. **Push and create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Code Review**
   - All PRs require at least one review
   - CI checks must pass
   - Address review feedback

6. **Merge**
   - Use "Squash and merge" for feature branches
   - Delete feature branches after merging

### Code Standards

#### Python (Backend)
- Follow PEP 8
- Use type hints
- Maximum line length: 100 characters
- Run `black` and `isort` before committing
- Maintain test coverage >80%

#### Swift (iOS)
- Follow Swift API Design Guidelines
- Use SwiftFormat for consistent formatting
- Prefer `let` over `var`
- Use meaningful variable names
- Document public APIs with Swift DocC

### Testing

**Backend:**
```bash
cd backend
pytest
```

**iOS:**
- Use Cmd+U in Xcode to run tests
- Target 80%+ code coverage for new features

---

## 🤝 Contributing

We welcome contributions! Please:

1. Check existing issues before creating new ones
2. Discuss major changes in an issue first
3. Follow our code standards
4. Write tests for new features
5. Update documentation as needed

---

## 📜 License

Proprietary - All rights reserved.

---

## 🙏 Acknowledgments

Built with care by the Modaics team and contributors.

---

## 📞 Support

- **Issues**: Create a GitHub issue
- **Documentation**: See `/docs` folder
- **Team**: Contact the product team via Slack

---

*Last updated: February 2026*
