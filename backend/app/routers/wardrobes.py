"""
Wardrobes Router ("The Mosaic")

API endpoints for wardrobe management and "Mosaic" views.
"""

import uuid
from typing import Optional, List

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db_session
from app.models.wardrobe import Wardrobe, wardrobe_garments
from app.models.garment import Garment
from app.schemas import (
    WardrobeCreate, WardrobeUpdate, WardrobeResponse, WardrobeDetailResponse,
    WardrobeListResponse, WardrobeAddGarment
)

router = APIRouter(prefix="/wardrobes", tags=["wardrobes"])


@router.post("", response_model=WardrobeResponse, status_code=status.HTTP_201_CREATED)
async def create_wardrobe(
    wardrobe_data: WardrobeCreate,
    db: AsyncSession = Depends(get_db_session)
) -> Wardrobe:
    """
    Create a new wardrobe ("Mosaic").
    
    A wardrobe is a curated collection with its own story and theme.
    """
    # In production, get owner_id from authenticated user
    owner_id = uuid.uuid4()  # Should come from auth
    
    wardrobe = Wardrobe(
        owner_id=owner_id,
        name=wardrobe_data.name,
        story=wardrobe_data.story.model_dump() if wardrobe_data.story else None,
        is_public=wardrobe_data.is_public
    )
    
    db.add(wardrobe)
    await db.commit()
    await db.refresh(wardrobe)
    
    return wardrobe


@router.get("", response_model=WardrobeListResponse)
async def list_wardrobes(
    public_only: bool = Query(False, description="Show only public wardrobes"),
    owner_id: Optional[uuid.UUID] = Query(None, description="Filter by owner"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session)
) -> dict:
    """
    List wardrobes.
    
    Users can browse public wardrobes or view their own collections.
    """
    query = select(Wardrobe)
    count_query = select(func.count(Wardrobe.id))
    
    # Filter by visibility
    if public_only:
        query = query.where(Wardrobe.is_public == True)
        count_query = count_query.where(Wardrobe.is_public == True)
    
    # Filter by owner
    if owner_id:
        query = query.where(Wardrobe.owner_id == owner_id)
        count_query = count_query.where(Wardrobe.owner_id == owner_id)
    
    # Order by newest first
    query = query.order_by(desc(Wardrobe.created_at))
    
    # Pagination
    offset = (page - 1) * page_size
    query = query.offset(offset).limit(page_size)
    
    # Execute
    result = await db.execute(query)
    wardrobes = result.scalars().all()
    
    count_result = await db.execute(count_query)
    total = count_result.scalar()
    
    # Add garment counts
    items = []
    for wardrobe in wardrobes:
        item_data = {
            **{k: getattr(wardrobe, k) for k in wardrobe.__dict__ if not k.startswith('_')},
            "garment_count": len(wardrobe.garments)
        }
        items.append(item_data)
    
    return {
        "items": items,
        "total": total,
        "page": page,
        "page_size": page_size,
        "pages": (total + page_size - 1) // page_size
    }


@router.get("/{wardrobe_id}", response_model=WardrobeDetailResponse)
async def get_wardrobe(
    wardrobe_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session)
) -> Wardrobe:
    """
    Get detailed wardrobe view ("The Mosaic").
    
    Returns the complete wardrobe with:
    - All garments in the collection
    - Category breakdown
    - Total value calculation
    - Sustainability metrics
    """
    result = await db.execute(
        select(Wardrobe).where(Wardrobe.id == wardrobe_id)
    )
    wardrobe = result.scalar_one_or_none()
    
    if not wardrobe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Wardrobe not found"
        )
    
    # Check visibility (public or owned by current user)
    # In production, verify against authenticated user
    current_user_id = uuid.uuid4()  # Should come from auth
    
    if not wardrobe.is_public and wardrobe.owner_id != current_user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This wardrobe is private"
        )
    
    # Calculate metrics
    garment_count = len(wardrobe.garments)
    category_breakdown = wardrobe.get_category_breakdown()
    total_value = wardrobe.get_total_value()
    
    # Recalculate sustainability score
    wardrobe.calculate_sustainability_score()
    await db.commit()
    
    return {
        **{k: getattr(wardrobe, k) for k in wardrobe.__dict__ if not k.startswith('_')},
        "garment_count": garment_count,
        "category_breakdown": category_breakdown,
        "total_value": total_value
    }


@router.patch("/{wardrobe_id}", response_model=WardrobeResponse)
async def update_wardrobe(
    wardrobe_id: uuid.UUID,
    wardrobe_data: WardrobeUpdate,
    db: AsyncSession = Depends(get_db_session)
) -> Wardrobe:
    """
    Update wardrobe information.
    """
    result = await db.execute(
        select(Wardrobe).where(Wardrobe.id == wardrobe_id)
    )
    wardrobe = result.scalar_one_or_none()
    
    if not wardrobe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Wardrobe not found"
        )
    
    # In production, verify current user is the owner
    
    # Update fields
    update_data = wardrobe_data.model_dump(exclude_unset=True)
    
    for field, value in update_data.items():
        if field == "story" and value:
            value = value.model_dump() if hasattr(value, 'model_dump') else value
        setattr(wardrobe, field, value)
    
    await db.commit()
    await db.refresh(wardrobe)
    
    return {
        **{k: getattr(wardrobe, k) for k in wardrobe.__dict__ if not k.startswith('_')},
        "garment_count": len(wardrobe.garments)
    }


@router.delete("/{wardrobe_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_wardrobe(
    wardrobe_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session)
) -> None:
    """
    Delete a wardrobe.
    
    Note: This only deletes the wardrobe collection, not the garments.
    """
    result = await db.execute(
        select(Wardrobe).where(Wardrobe.id == wardrobe_id)
    )
    wardrobe = result.scalar_one_or_none()
    
    if not wardrobe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Wardrobe not found"
        )
    
    # In production, verify current user is the owner
    
    await db.delete(wardrobe)
    await db.commit()


@router.post("/{wardrobe_id}/garments", response_model=WardrobeDetailResponse)
async def add_garment_to_wardrobe(
    wardrobe_id: uuid.UUID,
    add_data: WardrobeAddGarment,
    db: AsyncSession = Depends(get_db_session)
) -> Wardrobe:
    """
    Add a garment to a wardrobe.
    """
    # Get wardrobe
    wardrobe_result = await db.execute(
        select(Wardrobe).where(Wardrobe.id == wardrobe_id)
    )
    wardrobe = wardrobe_result.scalar_one_or_none()
    
    if not wardrobe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Wardrobe not found"
        )
    
    # In production, verify current user owns the wardrobe
    
    # Get garment
    garment_result = await db.execute(
        select(Garment).where(Garment.id == add_data.garment_id)
    )
    garment = garment_result.scalar_one_or_none()
    
    if not garment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Garment not found"
        )
    
    # Add to wardrobe
    wardrobe.add_garment(garment, notes=add_data.notes)
    await db.commit()
    await db.refresh(wardrobe)
    
    return {
        **{k: getattr(wardrobe, k) for k in wardrobe.__dict__ if not k.startswith('_')},
        "garment_count": len(wardrobe.garments),
        "category_breakdown": wardrobe.get_category_breakdown(),
        "total_value": wardrobe.get_total_value()
    }


@router.delete("/{wardrobe_id}/garments/{garment_id}", response_model=WardrobeDetailResponse)
async def remove_garment_from_wardrobe(
    wardrobe_id: uuid.UUID,
    garment_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session)
) -> Wardrobe:
    """
    Remove a garment from a wardrobe.
    """
    # Get wardrobe
    wardrobe_result = await db.execute(
        select(Wardrobe).where(Wardrobe.id == wardrobe_id)
    )
    wardrobe = wardrobe_result.scalar_one_or_none()
    
    if not wardrobe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Wardrobe not found"
        )
    
    # In production, verify current user owns the wardrobe
    
    # Get garment
    garment_result = await db.execute(
        select(Garment).where(Garment.id == garment_id)
    )
    garment = garment_result.scalar_one_or_none()
    
    if not garment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Garment not found"
        )
    
    # Remove from wardrobe
    wardrobe.remove_garment(garment)
    await db.commit()
    await db.refresh(wardrobe)
    
    return {
        **{k: getattr(wardrobe, k) for k in wardrobe.__dict__ if not k.startswith('_')},
        "garment_count": len(wardrobe.garments),
        "category_breakdown": wardrobe.get_category_breakdown(),
        "total_value": wardrobe.get_total_value()
    }


@router.get("/{wardrobe_id}/stats")
async def get_wardrobe_stats(
    wardrobe_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session)
) -> dict:
    """
    Get detailed statistics for a wardrobe.
    """
    result = await db.execute(
        select(Wardrobe).where(Wardrobe.id == wardrobe_id)
    )
    wardrobe = result.scalar_one_or_none()
    
    if not wardrobe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Wardrobe not found"
        )
    
    # Check visibility
    current_user_id = uuid.uuid4()  # Should come from auth
    if not wardrobe.is_public and wardrobe.owner_id != current_user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This wardrobe is private"
        )
    
    garments = wardrobe.garments
    
    # Calculate stats
    total_garments = len(garments)
    
    # Exchange type breakdown
    exchange_types = {}
    for g in garments:
        et = g.exchange_type
        exchange_types[et] = exchange_types.get(et, 0) + 1
    
    # Condition breakdown
    conditions = {}
    for g in garments:
        cond = g.condition
        conditions[cond] = conditions.get(cond, 0) + 1
    
    # Average price
    prices = [float(g.price) for g in garments if g.price]
    avg_price = sum(prices) / len(prices) if prices else 0
    
    # Brand count
    brands = set(g.brand for g in garments if g.brand)
    
    return {
        "wardrobe_id": str(wardrobe_id),
        "name": wardrobe.name,
        "total_garments": total_garments,
        "sustainability_score": wardrobe.sustainability_score,
        "total_value": wardrobe.get_total_value(),
        "category_breakdown": wardrobe.get_category_breakdown(),
        "exchange_type_breakdown": exchange_types,
        "condition_breakdown": conditions,
        "average_price": round(avg_price, 2),
        "unique_brands": len(brands),
        "brand_list": sorted(list(brands))[:10]  # Top 10 brands
    }
