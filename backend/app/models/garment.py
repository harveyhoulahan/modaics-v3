"""
Garment Model

The core model representing fashion items on the Modaics platform.
Supports stories, provenance tracking, and vector embeddings for AI matching.
"""

import uuid
from datetime import datetime
from decimal import Decimal
from typing import TYPE_CHECKING, List, Optional, Dict, Any

from sqlalchemy import String, Text, Numeric, Integer, DateTime, func, Index
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from pgvector.sqlalchemy import Vector

from app.database import Base
from app.config import get_settings

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.exchange import Exchange
    from app.models.wardrobe import Wardrobe

settings = get_settings()


class Garment(Base):
    """
    Garment model representing a fashion item.
    
    Supports:
    - Rich storytelling via JSONB story field
    - Provenance tracking for sustainability
    - Vector embeddings for AI-powered style matching
    - Multiple exchange types (buy, sell, trade)
    
    Attributes:
        id: Unique identifier
        owner_id: Reference to owning user
        title: Garment name/title
        category: Type (dress, shirt, pants, etc.)
        condition: Physical condition (new, excellent, good, fair)
        size: Size label
        brand: Brand/manufacturer
        story: JSONB with narrative, emotions, memories
        provenance: JSONB with origin, materials, sustainability info
        exchange_type: buy, sell, trade, gift
        price: Price for sale (null for trade/gift)
        style_attributes: JSONB with color, style tags
        embedding: Vector for similarity search
        view_count: Popularity metric
        save_count: User saves/likes
        status: active, reserved, sold, hidden
    """
    
    __tablename__ = "garments"
    
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )
    owner_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        nullable=False,
        index=True
    )
    title: Mapped[str] = mapped_column(
        String(200),
        nullable=False
    )
    category: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        index=True
    )
    condition: Mapped[str] = mapped_column(
        String(20),
        nullable=False
    )
    size: Mapped[str] = mapped_column(
        String(20),
        nullable=False
    )
    brand: Mapped[Optional[str]] = mapped_column(
        String(100),
        nullable=True
    )
    
    # JSONB fields for flexible data
    story: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSONB,
        nullable=True,
        comment="Narrative: {text: str, mood: str, occasion: str, memories: [...]}"
    )
    provenance: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSONB,
        nullable=True,
        comment="Origin: {source: str, materials: [...], made_in: str, certifications: [...]}"
    )
    style_attributes: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSONB,
        nullable=True,
        comment="Style: {colors: [...], patterns: [...], style_tags: [...], season: str}"
    )
    
    # Exchange configuration
    exchange_type: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        index=True,
        comment="buy, sell, trade, gift"
    )
    price: Mapped[Optional[Decimal]] = mapped_column(
        Numeric(precision=10, scale=2),
        nullable=True,
        index=True
    )
    
    # AI/ML fields
    embedding: Mapped[Optional[List[float]]] = mapped_column(
        Vector(settings.EMBEDDING_DIMENSION),
        nullable=True
    )
    
    # Engagement metrics
    view_count: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False
    )
    save_count: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False
    )
    
    # Status
    status: Mapped[str] = mapped_column(
        String(20),
        default="active",
        nullable=False,
        index=True
    )
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        index=True
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )
    
    # Relationships
    owner: Mapped["User"] = relationship(
        "User",
        back_populates="garments",
        lazy="selectin"
    )
    
    exchanges: Mapped[List["Exchange"]] = relationship(
        "Exchange",
        back_populates="garment",
        cascade="all, delete-orphan",
        lazy="selectin"
    )
    
    wardrobes: Mapped[List["Wardrobe"]] = relationship(
        "Wardrobe",
        secondary="wardrobe_garments",
        back_populates="garments",
        lazy="selectin"
    )
    
    # Table configuration for pgvector
    __table_args__ = (
        Index('idx_garments_embedding', 'embedding', postgresql_using='ivfflat', 
              postgresql_with={'lists': 100}),
    )
    
    def __repr__(self) -> str:
        return f"<Garment(id={self.id}, title={self.title}, category={self.category})>"
    
    def increment_views(self) -> None:
        """Increment the view counter."""
        self.view_count += 1
    
    def increment_saves(self) -> None:
        """Increment the save counter."""
        self.save_count += 1
    
    def is_available(self) -> bool:
        """Check if garment is available for exchange."""
        return self.status == "active"
    
    def get_story_text(self) -> str:
        """Extract searchable story text from JSONB."""
        if not self.story:
            return ""
        parts = []
        if isinstance(self.story, dict):
            if text := self.story.get("text"):
                parts.append(text)
            if mood := self.story.get("mood"):
                parts.append(mood)
            if occasion := self.story.get("occasion"):
                parts.append(occasion)
        return " ".join(parts)
    
    def get_provenance_summary(self) -> str:
        """Extract provenance summary for display."""
        if not self.provenance:
            return ""
        parts = []
        if isinstance(self.provenance, dict):
            if source := self.provenance.get("source"):
                parts.append(f"Source: {source}")
            if made_in := self.provenance.get("made_in"):
                parts.append(f"Made in: {made_in}")
            if materials := self.provenance.get("materials"):
                parts.append(f"Materials: {', '.join(materials)}")
        return " | ".join(parts)
