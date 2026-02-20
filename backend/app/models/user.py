"""
User Model

Represents a Modaics platform user with profile information
and sustainability metrics.
"""

import uuid
from datetime import datetime
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import String, Text, Float, Boolean, DateTime, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

if TYPE_CHECKING:
    from app.models.garment import Garment
    from app.models.exchange import Exchange
    from app.models.wardrobe import Wardrobe


class User(Base):
    """
    User model representing a Modaics platform member.
    
    Attributes:
        id: Unique identifier (UUID)
        email: User's email address (unique)
        display_name: Public display name
        avatar_url: Profile image URL
        bio: User biography
        location: Geographic location
        sustainability_score: Calculated eco-friendly score
        is_active: Account status
        created_at: Account creation timestamp
        updated_at: Last update timestamp
    """
    
    __tablename__ = "users"
    
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )
    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        nullable=False,
        index=True
    )
    display_name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )
    avatar_url: Mapped[Optional[str]] = mapped_column(
        String(500),
        nullable=True
    )
    bio: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )
    location: Mapped[Optional[str]] = mapped_column(
        String(200),
        nullable=True
    )
    sustainability_score: Mapped[float] = mapped_column(
        Float,
        default=0.0,
        nullable=False,
        index=True
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False
    )
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )
    
    # Relationships
    garments: Mapped[List["Garment"]] = relationship(
        "Garment",
        back_populates="owner",
        cascade="all, delete-orphan",
        lazy="selectin"
    )
    
    buying_exchanges: Mapped[List["Exchange"]] = relationship(
        "Exchange",
        foreign_keys="Exchange.buyer_id",
        back_populates="buyer",
        cascade="all, delete-orphan",
        lazy="selectin"
    )
    
    selling_exchanges: Mapped[List["Exchange"]] = relationship(
        "Exchange",
        foreign_keys="Exchange.seller_id",
        back_populates="seller",
        cascade="all, delete-orphan",
        lazy="selectin"
    )
    
    wardrobes: Mapped[List["Wardrobe"]] = relationship(
        "Wardrobe",
        back_populates="owner",
        cascade="all, delete-orphan",
        lazy="selectin"
    )
    
    def __repr__(self) -> str:
        return f"<User(id={self.id}, email={self.email}, name={self.display_name})>"
    
    def update_sustainability_score(self) -> None:
        """
        Calculate and update the user's sustainability score.
        Based on exchange activity, garment provenance, and wardrobe size.
        """
        # Base score
        score = 0.0
        
        # Points for active exchanges (buying/selling secondhand)
        active_exchanges = len([e for e in self.buying_exchanges if e.status == "completed"])
        active_exchanges += len([e for e in self.selling_exchanges if e.status == "completed"])
        score += min(active_exchanges * 10, 100)  # Cap at 100 points
        
        # Points for wardrobe size (circular fashion participation)
        wardrobe_garments = sum(len(w.garments) for w in self.wardrobes)
        score += min(wardrobe_garments * 5, 50)
        
        # Normalize to 0-100 scale
        self.sustainability_score = min(score, 100.0)
