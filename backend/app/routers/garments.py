"""
Garments Router

API endpoints for garment CRUD operations and management.
"""

import uuid
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db_session
from app.models.garment import Garment
from app.models.user import User
from app.schemas import (
    GarmentCreate, GarmentUpdate, GarmentResponse, 
    GarmentDetailResponse, GarmentListResponse
)
from app.services.style_matching import style_matching_service

router = APIRouter(prefix="/garments", tags=["garments"])


@router.post("", response_model=GarmentResponse, status_code=status.HTTP_201_CREATED)
async def create_garment(
    garment_data: GarmentCreate,
    db: AsyncSession = Depends(get_db_session)
) -> Garment:
    """
    Create a new garment with story and provenance.
    
    Automatically generates CLIP embedding for style matching.
    """
    # In production, get owner_id from authenticated user
    # For now, create or get a default user
    
    # Create garment object
    garment = Garment(
        owner_id=garment_data.owner_id if hasattr(garment_data, 'owner_id') else uuid.uuid4(),
        title=garment_data.title,
        category=garment_data.category,
        condition=garment_data.condition.value,
        size=garment_data.size,
        brand=garment_data.brand,
        story=garment_data.story.model_dump() if garment_data.story else None,
        provenance=garment_data.provenance.model_dump() if garment_data.provenance else None,
        style_attributes=garment_data.style_attributes.model_dump() if garment_data.style_attributes else None,
        exchange_type=garment_data.exchange_type.value,
        price=garment_data.price
    )
    
    # Generate embedding
    try:
        story_text = ""
        if garment_data.story and garment_data.story.text:
            story_text = garment_data.story.text
        
        embedding = await style_matching_service.generate_garment_embedding(
            text=story_text,
            style_attributes=garment_data.style_attributes.model_dump() if garment_data.style_attributes else None
        )
        garment.embedding = embedding
    except Exception as e:
        # Log but don't fail - embedding can be generated later
        print(f"Warning: Could not generate embedding: {e}")
    
    db.add(garment)
    await db.commit()
    await db.refresh(garment)
    
    return garment


@router.get("", response_model=GarmentListResponse)
async def list_garments(
    category: Optional[str] = Query(None, description="Filter by category"),
    condition: Optional[str] = Query(None, description="Filter by condition"),
    exchange_type: Optional[str] = Query(None, description="Filter by exchange type"),
    min_price: Optional[float] = Query(None, ge=0, description="Minimum price"),
    max_price: Optional[float] = Query(None, ge=0, description="Maximum price"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session)
) -> dict:
    """
    List garments with filtering and pagination.
    """
    # Build query
    query = select(Garment).where(Garment.status == "active")
    count_query = select(func.count(Garment.id)).where(Garment.status == "active")
    
    # Apply filters
    if category:
        query = query.where(Garment.category.ilike(f"%{category}%"))
        count_query = count_query.where(Garment.category.ilike(f"%{category}%"))
    
    if condition:
        query = query.where(Garment.condition == condition)
        count_query = count_query.where(Garment.condition == condition)
    
    if exchange_type:
        query = query.where(Garment.exchange_type == exchange_type)
        count_query = count_query.where(Garment.exchange_type == exchange_type)
    
    if min_price is not None:
        query = query.where(Garment.price >= min_price)
        count_query = count_query.where(Garment.price >= min_price)
    
    if max_price is not None:
        query = query.where(Garment.price <= max_price)
        count_query = count_query.where(Garment.price <= max_price)
    
    # Order by newest first
    query = query.order_by(desc(Garment.created_at))
    
    # Pagination
    offset = (page - 1) * page_size
    query = query.offset(offset).limit(page_size)
    
    # Execute queries
    result = await db.execute(query)
    garments = result.scalars().all()
    
    count_result = await db.execute(count_query)
    total = count_result.scalar()
    
    return {
        "items": garments,
        "total": total,
        "page": page,
        "page_size": page_size,
        "pages": (total + page_size - 1) // page_size
    }


@router.get("/search", response_model=GarmentListResponse)
async def search_garments(
    q: str = Query(..., min_length=2, description="Search query"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session)
) -> dict:
    """
    Search garments using full-text search on stories and titles.
    """
    # Build search query using PostgreSQL full-text search
    # This is a simplified version - in production use proper tsvector
    
    query = select(Garment).where(
        Garment.status == "active"
    ).where(
        (Garment.title.ilike(f"%{q}%")) |
        (Garment.brand.ilike(f"%{q}%")) |
        (Garment.category.ilike(f"%{q}%"))
    )
    
    count_query = select(func.count(Garment.id)).where(
        Garment.status == "active"
    ).where(
        (Garment.title.ilike(f"%{q}%")) |
        (Garment.brand.ilike(f"%{q}%")) |
        (Garment.category.ilike(f"%{q}%"))
    )
    
    # Pagination
    offset = (page - 1) * page_size
    query = query.offset(offset).limit(page_size)
    
    result = await db.execute(query)
    garments = result.scalars().all()
    
    count_result = await db.execute(count_query)
    total = count_result.scalar()
    
    return {
        "items": garments,
        "total": total,
        "page": page,
        "page_size": page_size,
        "pages": (total + page_size - 1) // page_size
    }


@router.get("/{garment_id}", response_model=GarmentDetailResponse)
async def get_garment(
    garment_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session)
) -> Garment:
    """
    Get detailed information about a specific garment.
    
    Includes similar garment recommendations based on embedding similarity.
    """
    result = await db.execute(
        select(Garment).where(Garment.id == garment_id)
    )
    garment = result.scalar_one_or_none()
    
    if not garment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Garment not found"
        )
    
    # Increment view count
    garment.increment_views()
    await db.commit()
    
    # Find similar garments if embedding exists
    similar = []
    if garment.embedding:
        # Query for similar embeddings
        similar_query = select(Garment).where(
            Garment.id != garment_id,
            Garment.status == "active",
            Garment.embedding.isnot(None)
        ).limit(5)
        
        similar_result = await db.execute(similar_query)
        candidates = similar_result.scalars().all()
        
        # Calculate similarity scores
        if candidates:
            candidate_embs = [(c.id, c.embedding) for c in candidates if c.embedding]
            similar_ids = style_matching_service.find_similar_items(
                garment.embedding,
                candidate_embs,
                top_k=5,
                threshold=0.3
            )
            
            # Fetch full garment objects for similar items
            if similar_ids:
                similar_id_list = [sid for sid, _ in similar_ids]
                similar_query = select(Garment).where(Garment.id.in_(similar_id_list))
                similar_result = await db.execute(similar_query)
                similar = similar_result.scalars().all()
    
    return {
        **{k: getattr(garment, k) for k in garment.__dict__ if not k.startswith('_')},
        "similar_garments": similar
    }


@router.patch("/{garment_id}", response_model=GarmentResponse)
async def update_garment(
    garment_id: uuid.UUID,
    garment_data: GarmentUpdate,
    db: AsyncSession = Depends(get_db_session)
) -> Garment:
    """
    Update garment information.
    """
    result = await db.execute(
        select(Garment).where(Garment.id == garment_id)
    )
    garment = result.scalar_one_or_none()
    
    if not garment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Garment not found"
        )
    
    # Update fields
    update_data = garment_data.model_dump(exclude_unset=True)
    
    for field, value in update_data.items():
        if field in ["condition", "exchange_type", "status"] and value:
            value = value.value if hasattr(value, 'value') else value
        elif field in ["story", "provenance", "style_attributes"] and value:
            value = value.model_dump() if hasattr(value, 'model_dump') else value
        setattr(garment, field, value)
    
    # Regenerate embedding if relevant fields changed
    if any(f in update_data for f in ["story", "style_attributes"]):
        try:
            story_text = ""
            if garment.story and isinstance(garment.story, dict):
                story_text = garment.story.get("text", "")
            
            embedding = await style_matching_service.generate_garment_embedding(
                text=story_text,
                style_attributes=garment.style_attributes
            )
            garment.embedding = embedding
        except Exception as e:
            print(f"Warning: Could not regenerate embedding: {e}")
    
    await db.commit()
    await db.refresh(garment)
    
    return garment


@router.delete("/{garment_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_garment(
    garment_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session)
) -> None:
    """
    Delete a garment.
    """
    result = await db.execute(
        select(Garment).where(Garment.id == garment_id)
    )
    garment = result.scalar_one_or_none()
    
    if not garment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Garment not found"
        )
    
    await db.delete(garment)
    await db.commit()
