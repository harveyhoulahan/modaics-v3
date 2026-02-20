"""
Exchange Router

API endpoints for garment transactions: buy, sell, trade.
"""

import uuid
from typing import Optional, List

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db_session
from app.models.exchange import Exchange
from app.models.garment import Garment
from app.models.user import User
from app.schemas import (
    ExchangeCreate, ExchangeUpdate, ExchangeResponse, ExchangeListResponse,
    ExchangeType, ExchangeStatus
)

router = APIRouter(prefix="/exchange", tags=["exchange"])


@router.post("", response_model=ExchangeResponse, status_code=status.HTTP_201_CREATED)
async def create_exchange(
    exchange_data: ExchangeCreate,
    db: AsyncSession = Depends(get_db_session)
) -> Exchange:
    """
    Create a new exchange (buy, sell, trade offer).
    
    The buyer initiates the exchange by selecting a garment and
    specifying the type (buy, trade, gift).
    """
    # Verify garment exists and is available
    garment_result = await db.execute(
        select(Garment).where(Garment.id == exchange_data.garment_id)
    )
    garment = garment_result.scalar_one_or_none()
    
    if not garment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Garment not found"
        )
    
    if not garment.is_available():
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Garment is not available for exchange (status: {garment.status})"
        )
    
    # In production, get buyer_id from authenticated user
    # For now, generate a buyer UUID
    buyer_id = uuid.uuid4()  # Should come from auth
    
    # Cannot buy your own garment
    if garment.owner_id == buyer_id:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Cannot exchange your own garment"
        )
    
    # Validate exchange type matches garment configuration
    garment_exchange_type = garment.exchange_type
    requested_type = exchange_data.type.value
    
    # Map types
    if garment_exchange_type == "sell" and requested_type == "buy":
        pass  # Valid
    elif garment_exchange_type == "buy" and requested_type == "sell":
        pass  # Valid (seller perspective)
    elif garment_exchange_type == requested_type:
        pass  # Valid (trade, gift)
    elif requested_type not in ["buy", "sell", "trade", "gift"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid exchange type: {requested_type}"
        )
    
    # Check for existing pending exchange
    existing_result = await db.execute(
        select(Exchange).where(
            Exchange.garment_id == exchange_data.garment_id,
            Exchange.buyer_id == buyer_id,
            Exchange.status.in_(["pending", "accepted"])
        )
    )
    if existing_result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="You already have an active exchange for this garment"
        )
    
    # Create exchange
    exchange = Exchange(
        garment_id=exchange_data.garment_id,
        buyer_id=buyer_id,
        seller_id=garment.owner_id,
        type=requested_type,
        amount=exchange_data.amount or garment.price,
        message=exchange_data.message,
        status="pending"
    )
    
    db.add(exchange)
    
    # Reserve garment
    garment.status = "reserved"
    
    await db.commit()
    await db.refresh(exchange)
    
    return exchange


@router.get("", response_model=ExchangeListResponse)
async def list_exchanges(
    status: Optional[str] = Query(None, description="Filter by status"),
    type: Optional[str] = Query(None, description="Filter by exchange type"),
    as_buyer: Optional[bool] = Query(None, description="Filter exchanges where user is buyer"),
    as_seller: Optional[bool] = Query(None, description="Filter exchanges where user is seller"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session)
) -> dict:
    """
    List exchanges with filtering.
    
    Users can view exchanges they're involved in as buyer or seller.
    """
    # In production, get from authenticated user
    user_id = uuid.uuid4()  # Should come from auth
    
    query = select(Exchange)
    count_query = select(func.count(Exchange.id))
    
    # Filter by user role
    if as_buyer is True:
        query = query.where(Exchange.buyer_id == user_id)
        count_query = count_query.where(Exchange.buyer_id == user_id)
    elif as_seller is True:
        query = query.where(Exchange.seller_id == user_id)
        count_query = count_query.where(Exchange.seller_id == user_id)
    else:
        # Show all exchanges user is part of
        query = query.where(
            (Exchange.buyer_id == user_id) | (Exchange.seller_id == user_id)
        )
        count_query = count_query.where(
            (Exchange.buyer_id == user_id) | (Exchange.seller_id == user_id)
        )
    
    # Apply filters
    if status:
        query = query.where(Exchange.status == status)
        count_query = count_query.where(Exchange.status == status)
    
    if type:
        query = query.where(Exchange.type == type)
        count_query = count_query.where(Exchange.type == type)
    
    # Order by newest first
    query = query.order_by(desc(Exchange.created_at))
    
    # Pagination
    offset = (page - 1) * page_size
    query = query.offset(offset).limit(page_size)
    
    # Execute
    result = await db.execute(query)
    exchanges = result.scalars().all()
    
    count_result = await db.execute(count_query)
    total = count_result.scalar()
    
    return {
        "items": exchanges,
        "total": total,
        "page": page,
        "page_size": page_size,
        "pages": (total + page_size - 1) // page_size
    }


@router.get("/{exchange_id}", response_model=ExchangeResponse)
async def get_exchange(
    exchange_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session)
) -> Exchange:
    """
    Get detailed information about a specific exchange.
    """
    result = await db.execute(
        select(Exchange).where(Exchange.id == exchange_id)
    )
    exchange = result.scalar_one_or_none()
    
    if not exchange:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Exchange not found"
        )
    
    # In production, verify user has permission to view
    # (is buyer, seller, or admin)
    
    return exchange


@router.patch("/{exchange_id}/accept", response_model=ExchangeResponse)
async def accept_exchange(
    exchange_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session)
) -> Exchange:
    """
    Accept a pending exchange offer.
    
    Only the seller can accept an exchange.
    """
    result = await db.execute(
        select(Exchange).where(Exchange.id == exchange_id)
    )
    exchange = result.scalar_one_or_none()
    
    if not exchange:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Exchange not found"
        )
    
    # In production, verify current user is the seller
    
    try:
        exchange.accept()
        await db.commit()
        await db.refresh(exchange)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(e)
        )
    
    return exchange


@router.patch("/{exchange_id}/reject", response_model=ExchangeResponse)
async def reject_exchange(
    exchange_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session)
) -> Exchange:
    """
    Reject a pending exchange offer.
    
    Only the seller can reject an exchange.
    """
    result = await db.execute(
        select(Exchange).where(Exchange.id == exchange_id)
    )
    exchange = result.scalar_one_or_none()
    
    if not exchange:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Exchange not found"
        )
    
    # In production, verify current user is the seller
    
    try:
        exchange.reject()
        # Release garment reservation
        if exchange.garment:
            exchange.garment.status = "active"
        await db.commit()
        await db.refresh(exchange)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(e)
        )
    
    return exchange


@router.patch("/{exchange_id}/complete", response_model=ExchangeResponse)
async def complete_exchange(
    exchange_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session)
) -> Exchange:
    """
    Mark an exchange as completed.
    
    Both buyer and seller can confirm completion after
    the physical exchange has occurred.
    """
    result = await db.execute(
        select(Exchange).where(Exchange.id == exchange_id)
    )
    exchange = result.scalar_one_or_none()
    
    if not exchange:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Exchange not found"
        )
    
    # In production, verify current user is buyer or seller
    
    try:
        exchange.complete()
        # Update user sustainability scores
        if exchange.buyer:
            exchange.buyer.update_sustainability_score()
        if exchange.seller:
            exchange.seller.update_sustainability_score()
        
        await db.commit()
        await db.refresh(exchange)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(e)
        )
    
    return exchange


@router.patch("/{exchange_id}/cancel", response_model=ExchangeResponse)
async def cancel_exchange(
    exchange_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session)
) -> Exchange:
    """
    Cancel an exchange.
    
    Either party can cancel a pending or accepted exchange.
    """
    result = await db.execute(
        select(Exchange).where(Exchange.id == exchange_id)
    )
    exchange = result.scalar_one_or_none()
    
    if not exchange:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Exchange not found"
        )
    
    # In production, verify current user is buyer or seller
    
    try:
        exchange.cancel()
        # Release garment reservation if not already sold
        if exchange.garment and exchange.garment.status == "reserved":
            exchange.garment.status = "active"
        await db.commit()
        await db.refresh(exchange)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(e)
        )
    
    return exchange


@router.get("/stats/overview")
async def get_exchange_stats(
    db: AsyncSession = Depends(get_db_session)
) -> dict:
    """
    Get exchange statistics.
    """
    # Total exchanges by status
    status_counts = await db.execute(
        select(Exchange.status, func.count(Exchange.id))
        .group_by(Exchange.status)
    )
    by_status = {row[0]: row[1] for row in status_counts.all()}
    
    # Total exchanges by type
    type_counts = await db.execute(
        select(Exchange.type, func.count(Exchange.id))
        .group_by(Exchange.type)
    )
    by_type = {row[0]: row[1] for row in type_counts.all()}
    
    # Total value exchanged
    value_result = await db.execute(
        select(func.sum(Exchange.amount))
        .where(Exchange.status == "completed")
    )
    total_value = value_result.scalar() or 0
    
    return {
        "by_status": by_status,
        "by_type": by_type,
        "total_completed_value": float(total_value),
        "total_exchanges": sum(by_status.values())
    }
