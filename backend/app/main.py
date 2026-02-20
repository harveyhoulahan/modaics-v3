"""
Modaics FastAPI Application

Main entry point for the Modaics backend API.
"""

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.config import get_settings
from app.database import check_db_connection, close_db_connections, init_extensions
from app.routers import garments, discovery, exchange, wardrobes
from app.routers.analysis import router as analysis_router
from app.schemas import HealthCheck
from app.services.style_matching import style_matching_service
from app.services.fashion_clip import get_fashion_clip_service

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager.
    
    Handles startup and shutdown events.
    """
    # Startup
    logger.info("Starting up Modaics API v%s", settings.APP_VERSION)
    
    # Initialize database extensions
    try:
        await init_extensions()
        logger.info("Database extensions initialized")
    except Exception as e:
        logger.error("Failed to initialize database extensions: %s", e)
    
    # Initialize AI services
    try:
        await style_matching_service.initialize()
        logger.info("Style matching service initialized")
    except Exception as e:
        logger.warning("Could not initialize style matching service: %s", e)
    
    # Initialize FashionCLIP service (new AI pipeline)
    try:
        fashion_clip = await get_fashion_clip_service()
        logger.info("FashionCLIP service initialized")
    except Exception as e:
        logger.warning("Could not initialize FashionCLIP service: %s", e)
    
    # Health check
    db_healthy = await check_db_connection()
    logger.info("Database connection: %s", "healthy" if db_healthy else "unhealthy")
    
    yield
    
    # Shutdown
    logger.info("Shutting down Modaics API")
    await close_db_connections()


# Create FastAPI application
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="""
    Modaics v3.0 API - Sustainable Fashion Platform
    
    ## Features
    
    - **Garments** - Create and manage fashion items with rich stories
    - **Discovery** - AI-powered style matching using CLIP embeddings
    - **Exchange** - Buy, sell, and trade garments
    - **Wardrobes** - Curated collections ("The Mosaic")
    
    ## AI Features
    
    - FashionCLIP garment analysis (/api/analyze)
    - Multi-attribute classification (category, color, material, condition, style)
    - Color extraction with pixel-level analysis
    - Condition grading for donation routing
    - CLIP-based visual and semantic similarity
    - Vector search for style matching
    - Smart recommendations
    """,
    docs_url="/docs" if not settings.is_production else None,
    redoc_url="/redoc" if not settings.is_production else None,
    lifespan=lifespan
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Exception handlers
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Handle uncaught exceptions."""
    logger.exception("Unhandled exception")
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "detail": "Internal server error",
            "type": "internal_error"
        }
    )


# Include routers
app.include_router(garments.router)
app.include_router(discovery.router)
app.include_router(exchange.router)
app.include_router(wardrobes.router)
app.include_router(analysis_router)  # AI-powered /api/analyze endpoint


@app.get("/", response_model=HealthCheck)
async def root():
    """Root endpoint with API information."""
    from datetime import datetime
    return {
        "status": "operational",
        "version": settings.APP_VERSION,
        "database": await check_db_connection(),
        "redis": True,  # Placeholder - implement actual check
        "timestamp": datetime.utcnow()
    }


@app.get("/health", response_model=HealthCheck)
async def health_check():
    """Health check endpoint for monitoring."""
    from datetime import datetime
    
    db_healthy = await check_db_connection()
    
    return {
        "status": "healthy" if db_healthy else "unhealthy",
        "version": settings.APP_VERSION,
        "database": db_healthy,
        "redis": True,  # Placeholder
        "timestamp": datetime.utcnow()
    }


@app.get("/ready")
async def readiness_check():
    """Kubernetes-style readiness probe."""
    db_healthy = await check_db_connection()
    
    if not db_healthy:
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={"ready": False, "reason": "database_unavailable"}
        )
    
    return {"ready": True}


@app.get("/live")
async def liveness_check():
    """Kubernetes-style liveness probe."""
    return {"alive": True}


# Development entry point
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.is_development
    )
