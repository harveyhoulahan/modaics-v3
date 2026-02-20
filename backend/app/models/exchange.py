"""
Exchange Model

Represents transactions between users for garments.
Supports buy, sell, trade, and gift exchange types.
"""

import uuid
from datetime import datetime
from decimal import Decimal
from typing import TYPE_CHECKING, Optional

from sqlalchemy import String, Text, Numeric, DateTime, func, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.garment import Garment


class Exchange(Base):
    """
    Exchange model representing a transaction between users.
    
    Exchange Types:
        - buy: Buyer purchases from seller
        - sell: Alias for buy (from seller perspective)
        - trade: Direct garment swap
        - gift: No monetary exchange
    
    Status Flow:
        pending -> accepted -> completed
               -> rejected
               -> cancelled
    
    Attributes:
        id: Unique identifier
        garment_id: The garment being exchanged
        buyer_id: User acquiring the garment
        seller_id: User providing the garment
        type: Exchange type (buy, sell, trade, gift)
        status: Transaction status
        amount: Monetary amount (null for trade/gift)
        message: Optional message between parties
    """
    
    __tablename__ = "exchanges"
    
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )
    garment_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("garments.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    buyer_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    seller_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    type: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        comment="buy, sell, trade, gift"
    )
    status: Mapped[str] = mapped_column(
        String(20),
        default="pending",
        nullable=False,
        index=True,
        comment="pending, accepted, rejected, completed, cancelled"
    )
    amount: Mapped[Optional[Decimal]] = mapped_column(
        Numeric(precision=10, scale=2),
        nullable=True
    )
    message: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
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
    garment: Mapped["Garment"] = relationship(
        "Garment",
        back_populates="exchanges",
        lazy="selectin"
    )
    
    buyer: Mapped["User"] = relationship(
        "User",
        foreign_keys=[buyer_id],
        back_populates="buying_exchanges",
        lazy="selectin"
    )
    
    seller: Mapped["User"] = relationship(
        "User",
        foreign_keys=[seller_id],
        back_populates="selling_exchanges",
        lazy="selectin"
    )
    
    def __repr__(self) -> str:
        return f"<Exchange(id={self.id}, type={self.type}, status={self.status})>"
    
    def accept(self) -> None:
        """Accept the exchange offer."""
        if self.status != "pending":
            raise ValueError(f"Cannot accept exchange with status: {self.status}")
        self.status = "accepted"
    
    def reject(self) -> None:
        """Reject the exchange offer."""
        if self.status != "pending":
            raise ValueError(f"Cannot reject exchange with status: {self.status}")
        self.status = "rejected"
    
    def complete(self) -> None:
        """Mark exchange as completed."""
        if self.status != "accepted":
            raise ValueError(f"Cannot complete exchange with status: {self.status}")
        self.status = "completed"
        # Update garment status
        if self.garment:
            self.garment.status = "sold"
    
    def cancel(self) -> None:
        """Cancel the exchange."""
        if self.status in ["completed", "cancelled"]:
            raise ValueError(f"Cannot cancel exchange with status: {self.status}")
        self.status = "cancelled"
    
    def is_pending(self) -> bool:
        """Check if exchange is pending."""
        return self.status == "pending"
    
    def is_active(self) -> bool:
        """Check if exchange is active (pending or accepted)."""
        return self.status in ["pending", "accepted"]
    
    def requires_payment(self) -> bool:
        """Check if this exchange requires monetary payment."""
        return self.type in ["buy", "sell"] and self.amount is not None and self.amount > 0
