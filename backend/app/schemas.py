"""
Pydantic Schemas for API Request/Response Validation

Defines all data models for API input/output.
"""

import uuid
from datetime import datetime
from decimal import Decimal
from typing import List, Optional, Dict, Any
from enum import Enum

from pydantic import BaseModel, Field, EmailStr, HttpUrl, ConfigDict


# ============== Enums ==============

class ExchangeType(str, Enum):
    BUY = "buy"
    SELL = "sell"
    TRADE = "trade"
    GIFT = "gift"


class ExchangeStatus(str, Enum):
    PENDING = "pending"
    ACCEPTED = "accepted"
    REJECTED = "rejected"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class GarmentStatus(str, Enum):
    ACTIVE = "active"
    RESERVED = "reserved"
    SOLD = "sold"
    HIDDEN = "hidden"


class GarmentCondition(str, Enum):
    NEW = "new"
    EXCELLENT = "excellent"
    GOOD = "good"
    FAIR = "fair"


# ============== Common ==============

class PaginationParams(BaseModel):
    page: int = Field(default=1, ge=1)
    page_size: int = Field(default=20, ge=1, le=100)


class PaginatedResponse(BaseModel):
    total: int
    page: int
    page_size: int
    pages: int


# ============== Story Schemas ==============

class GarmentStory(BaseModel):
    """Story/narrative about a garment."""
    text: Optional[str] = Field(None, description="The garment's story")
    mood: Optional[str] = Field(None, description="Emotional tone")
    occasion: Optional[str] = Field(None, description="Where/when it was worn")
    memories: Optional[List[str]] = Field(default_factory=list, description="Related memories")


class GarmentProvenance(BaseModel):
    """Provenance/sustainability information."""
    source: Optional[str] = Field(None, description="Origin: new, secondhand, vintage")
    materials: Optional[List[str]] = Field(default_factory=list, description="Material composition")
    made_in: Optional[str] = Field(None, description="Country/region of manufacture")
    certifications: Optional[List[str]] = Field(default_factory=list, description="Sustainability certs")


class GarmentStyleAttributes(BaseModel):
    """Style classification attributes."""
    colors: Optional[List[str]] = Field(default_factory=list)
    patterns: Optional[List[str]] = Field(default_factory=list)
    style_tags: Optional[List[str]] = Field(default_factory=list)
    season: Optional[str] = Field(None)


class WardrobeStory(BaseModel):
    """Story about a wardrobe collection."""
    theme: Optional[str] = Field(None, description="Collection theme")
    description: Optional[str] = Field(None, description="Narrative description")
    inspiration: Optional[str] = Field(None, description="What inspired this wardrobe")
    journey: Optional[List[str]] = Field(default_factory=list, description="Style evolution notes")


# ============== User Schemas ==============

class UserBase(BaseModel):
    email: EmailStr
    display_name: str = Field(..., min_length=1, max_length=100)


class UserCreate(UserBase):
    pass


class UserUpdate(BaseModel):
    display_name: Optional[str] = Field(None, min_length=1, max_length=100)
    avatar_url: Optional[HttpUrl] = None
    bio: Optional[str] = None
    location: Optional[str] = None


class UserResponse(UserBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    location: Optional[str] = None
    sustainability_score: float
    created_at: datetime


class UserDetailResponse(UserResponse):
    garment_count: int = 0
    wardrobe_count: int = 0
    exchange_count: int = 0


# ============== Garment Schemas ==============

class GarmentBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    category: str = Field(..., min_length=1, max_length=50)
    condition: GarmentCondition
    size: str = Field(..., min_length=1, max_length=20)
    brand: Optional[str] = Field(None, max_length=100)


class GarmentCreate(GarmentBase):
    story: Optional[GarmentStory] = None
    provenance: Optional[GarmentProvenance] = None
    style_attributes: Optional[GarmentStyleAttributes] = None
    exchange_type: ExchangeType
    price: Optional[Decimal] = Field(None, ge=0, decimal_places=2)


class GarmentUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    category: Optional[str] = Field(None, min_length=1, max_length=50)
    condition: Optional[GarmentCondition] = None
    size: Optional[str] = Field(None, min_length=1, max_length=20)
    brand: Optional[str] = Field(None, max_length=100)
    story: Optional[GarmentStory] = None
    provenance: Optional[GarmentProvenance] = None
    style_attributes: Optional[GarmentStyleAttributes] = None
    exchange_type: Optional[ExchangeType] = None
    price: Optional[Decimal] = Field(None, ge=0, decimal_places=2)
    status: Optional[GarmentStatus] = None


class GarmentResponse(GarmentBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID
    owner_id: uuid.UUID
    story: Optional[Dict[str, Any]] = None
    provenance: Optional[Dict[str, Any]] = None
    style_attributes: Optional[Dict[str, Any]] = None
    exchange_type: str
    price: Optional[Decimal] = None
    view_count: int
    save_count: int
    status: str
    created_at: datetime
    updated_at: datetime
    owner: Optional[UserResponse] = None


class GarmentListResponse(PaginatedResponse):
    items: List[GarmentResponse]


class GarmentDetailResponse(GarmentResponse):
    embedding: Optional[List[float]] = None
    similar_garments: List[GarmentResponse] = []


# ============== Exchange Schemas ==============

class ExchangeBase(BaseModel):
    garment_id: uuid.UUID
    type: ExchangeType
    amount: Optional[Decimal] = Field(None, ge=0, decimal_places=2)
    message: Optional[str] = None


class ExchangeCreate(ExchangeBase):
    seller_id: uuid.UUID


class ExchangeUpdate(BaseModel):
    status: Optional[ExchangeStatus] = None
    message: Optional[str] = None


class ExchangeResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID
    garment_id: uuid.UUID
    buyer_id: uuid.UUID
    seller_id: uuid.UUID
    type: str
    status: str
    amount: Optional[Decimal] = None
    message: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    garment: Optional[GarmentResponse] = None
    buyer: Optional[UserResponse] = None
    seller: Optional[UserResponse] = None


class ExchangeListResponse(PaginatedResponse):
    items: List[ExchangeResponse]


# ============== Wardrobe Schemas ==============

class WardrobeBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)


class WardrobeCreate(WardrobeBase):
    story: Optional[WardrobeStory] = None
    is_public: bool = False


class WardrobeUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    story: Optional[WardrobeStory] = None
    is_public: Optional[bool] = None


class WardrobeAddGarment(BaseModel):
    garment_id: uuid.UUID
    notes: Optional[str] = None


class WardrobeResponse(WardrobeBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID
    owner_id: uuid.UUID
    story: Optional[Dict[str, Any]] = None
    sustainability_score: float
    is_public: bool
    created_at: datetime
    updated_at: datetime
    garment_count: int = 0
    owner: Optional[UserResponse] = None


class WardrobeDetailResponse(WardrobeResponse):
    garments: List[GarmentResponse] = []
    category_breakdown: Dict[str, int] = {}
    total_value: float = 0.0


class WardrobeListResponse(PaginatedResponse):
    items: List[WardrobeResponse]


# ============== Discovery Schemas ==============

class DiscoveryQuery(BaseModel):
    """Query for smart garment discovery."""
    text: Optional[str] = Field(None, description="Natural language description")
    image_url: Optional[HttpUrl] = Field(None, description="Reference image URL")
    category: Optional[str] = Field(None, description="Filter by category")
    size: Optional[str] = Field(None, description="Filter by size")
    condition: Optional[GarmentCondition] = None
    exchange_type: Optional[ExchangeType] = None
    max_price: Optional[Decimal] = Field(None, ge=0)
    min_sustainability_score: Optional[float] = Field(None, ge=0, le=100)
    style_tags: Optional[List[str]] = Field(default_factory=list)


class DiscoveryResult(BaseModel):
    """Discovery result with match score."""
    garment: GarmentResponse
    similarity_score: float = Field(..., ge=0, le=1, description="AI match score")
    match_reasons: List[str] = Field(default_factory=list, description="Why it matched")


class DiscoveryResponse(PaginatedResponse):
    query_embedding: Optional[List[float]] = None
    results: List[DiscoveryResult]


# ============== Health Check ==============

class HealthCheck(BaseModel):
    status: str
    version: str
    database: bool
    redis: bool
    timestamp: datetime
