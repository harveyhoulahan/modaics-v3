"""
Modaics Configuration Module

Centralized settings management using Pydantic Settings.
Supports environment variables and .env files.
"""

import os
from functools import lru_cache
from typing import Optional, List

from pydantic_settings import BaseSettings
from pydantic import Field, PostgresDsn, RedisDsn


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Application
    APP_NAME: str = Field(default="Modaics API", description="Application name")
    APP_VERSION: str = Field(default="3.0.0", description="Application version")
    DEBUG: bool = Field(default=False, description="Debug mode")
    ENVIRONMENT: str = Field(default="development", description="Environment (development/staging/production)")
    LOG_LEVEL: str = Field(default="info", description="Logging level")
    
    # Security
    SECRET_KEY: str = Field(default="change-me-in-production", description="Secret key for JWT signing")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=60 * 24 * 7, description="JWT token expiration in minutes (7 days)")
    ALGORITHM: str = Field(default="HS256", description="JWT algorithm")
    
    # Database
    DATABASE_URL: PostgresDsn = Field(
        default="postgresql+asyncpg://modaics:modaics@localhost:5432/modaics",
        description="PostgreSQL connection URL"
    )
    DATABASE_POOL_SIZE: int = Field(default=10, description="Database connection pool size")
    DATABASE_MAX_OVERFLOW: int = Field(default=20, description="Database max overflow connections")
    
    # Redis
    REDIS_URL: RedisDsn = Field(
        default="redis://localhost:6379/0",
        description="Redis connection URL"
    )
    REDIS_CACHE_TTL: int = Field(default=3600, description="Default cache TTL in seconds")
    
    # AI/ML Models
    CLIP_MODEL_NAME: str = Field(
        default="openai/clip-vit-base-patch32",
        description="CLIP model for image/text embeddings"
    )
    CLIP_DEVICE: str = Field(default="cpu", description="Device for CLIP inference (cpu/cuda)")
    EMBEDDING_DIMENSION: int = Field(default=512, description="Embedding vector dimension")
    MODEL_CACHE_DIR: str = Field(default="./model_cache", description="Directory for cached models")
    
    # File Upload
    MAX_UPLOAD_SIZE_MB: int = Field(default=10, description="Maximum upload size in MB")
    UPLOAD_ALLOWED_TYPES: List[str] = Field(
        default=["image/jpeg", "image/png", "image/webp"],
        description="Allowed upload MIME types"
    )
    
    # Pagination
    DEFAULT_PAGE_SIZE: int = Field(default=20, description="Default page size for paginated responses")
    MAX_PAGE_SIZE: int = Field(default=100, description="Maximum page size")
    
    # Rate Limiting
    RATE_LIMIT_REQUESTS: int = Field(default=100, description="Rate limit requests per window")
    RATE_LIMIT_WINDOW_SECONDS: int = Field(default=60, description="Rate limit window in seconds")
    
    # CORS
    CORS_ORIGINS: List[str] = Field(
        default=["*"],
        description="Allowed CORS origins"
    )
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True
    
    @property
    def is_production(self) -> bool:
        """Check if running in production environment."""
        return self.ENVIRONMENT.lower() == "production"
    
    @property
    def is_development(self) -> bool:
        """Check if running in development environment."""
        return self.ENVIRONMENT.lower() == "development"
    
    @property
    def sync_database_url(self) -> str:
        """Get synchronous database URL for migrations."""
        url = str(self.DATABASE_URL)
        return url.replace("+asyncpg", "")


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()
