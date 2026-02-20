"""
Wardrobe Model ("The Mosaic")

Represents a user's curated collection of garments.
Each wardrobe tells a story about the owner's style journey.
"""

import uuid
from datetime import datetime
from typing import TYPE_CHECKING, List, Optional, Dict, Any

from sqlalchemy import String, Text, Float, Boolean, DateTime, func, ForeignKey, Table, Column
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.garment import Garment


# Association table for wardrobe-garment relationship
wardrobe_garments = Table(
    "wardrobe_garments",
    Base.metadata,
    Column("wardrobe_id", UUID(as_uuid=True), ForeignKey("wardrobes.id", ondelete="CASCADE"), primary_key=True),
    Column("garment_id", UUID(as_uuid=True), ForeignKey("garments.id", ondelete="CASCADE"), primary_key=True),
    Column("added_at", DateTime(timezone=True), server_default=func.now(), nullable=False),
    Column("notes", Text, nullable=True),
)


class Wardrobe(Base):
    """
    Wardrobe model representing a user's curated collection.
    
    "The Mosaic" - Each wardrobe is a visual story of the owner's
    fashion journey, sustainability choices, and personal style evolution.
    
    Attributes:
        id: Unique identifier
        owner_id: Reference to owning user
        name: Wardrobe name/title
        story: JSONB with narrative about the wardrobe
        sustainability_score: Calculated eco-score for this collection
        is_public: Visibility setting
        garments: List of garments in this wardrobe
    """
    
    __tablename__ = "wardrobes"
    
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )
    owner_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )
    story: Mapped[Optional[Dict[str, Any]]] = mapped_column(
        JSONB,
        nullable=True,
        comment="Story: {theme: str, description: str, inspiration: str, journey: [...]}"
    )
    sustainability_score: Mapped[float] = mapped_column(
        Float,
        default=0.0,
        nullable=False
    )
    is_public: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
        index=True
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
    owner: Mapped["User"] = relationship(
        "User",
        back_populates="wardrobes",
        lazy="selectin"
    )
    
    garments: Mapped[List["Garment"]] = relationship(
        "Garment",
        secondary=wardrobe_garments,
        back_populates="wardrobes",
        lazy="selectin"
    )
    
    def __repr__(self) -> str:
        return f"<Wardrobe(id={self.id}, name={self.name}, owner={self.owner_id})>"
    
    def add_garment(self, garment: "Garment", notes: Optional[str] = None) -> None:
        """Add a garment to this wardrobe."""
        if garment not in self.garments:
            self.garments.append(garment)
            self.calculate_sustainability_score()
    
    def remove_garment(self, garment: "Garment") -> None:
        """Remove a garment from this wardrobe."""
        if garment in self.garments:
            self.garments.remove(garment)
            self.calculate_sustainability_score()
    
    def calculate_sustainability_score(self) -> float:
        """
        Calculate wardrobe sustainability score based on:
        - Secondhand/pre-owned ratio
        - Sustainable materials
        - Local production
        - Certifications
        """
        if not self.garments:
            self.sustainability_score = 0.0
            return 0.0
        
        total_score = 0.0
        
        for garment in self.garments:
            score = 0.0
            
            # Check provenance for sustainability indicators
            if garment.provenance and isinstance(garment.provenance, dict):
                prov = garment.provenance
                
                # Points for secondhand/vintage
                if prov.get("source") in ["secondhand", "vintage", "thrift", "resale"]:
                    score += 40
                
                # Points for sustainable materials
                materials = prov.get("materials", [])
                sustainable_materials = ["organic cotton", "hemp", "linen", "tencel", 
                                        "recycled polyester", "bamboo", "wool"]
                if any(mat.lower() in sustainable_materials for mat in materials):
                    score += 30
                
                # Points for local production
                if prov.get("made_in") in ["local", "domestic", "artisan"]:
                    score += 15
                
                # Points for certifications
                certs = prov.get("certifications", [])
                if certs:
                    score += min(len(certs) * 5, 15)
            
            # Points for condition (better condition = longer lifecycle)
            condition_points = {
                "new": 5,
                "excellent": 5,
                "good": 3,
                "fair": 1
            }
            score += condition_points.get(garment.condition.lower(), 0)
            
            total_score += min(score, 100)  # Cap per garment
        
        # Average score across wardrobe
        self.sustainability_score = round(total_score / len(self.garments), 2)
        return self.sustainability_score
    
    def get_story_summary(self) -> str:
        """Extract story summary from JSONB."""
        if not self.story:
            return ""
        if isinstance(self.story, dict):
            parts = []
            if theme := self.story.get("theme"):
                parts.append(f"Theme: {theme}")
            if description := self.story.get("description"):
                parts.append(description)
            return " - ".join(parts)
        return ""
    
    def get_garment_count(self) -> int:
        """Get the number of garments in this wardrobe."""
        return len(self.garments)
    
    def get_total_value(self) -> float:
        """Calculate total monetary value of wardrobe."""
        total = 0.0
        for garment in self.garments:
            if garment.price:
                total += float(garment.price)
        return total
    
    def get_category_breakdown(self) -> Dict[str, int]:
        """Get count of garments by category."""
        breakdown = {}
        for garment in self.garments:
            cat = garment.category
            breakdown[cat] = breakdown.get(cat, 0) + 1
        return breakdown
