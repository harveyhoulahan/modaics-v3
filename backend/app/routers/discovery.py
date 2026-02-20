"""
Discovery Router

AI-powered smart matching for garment discovery.
Uses CLIP embeddings for visual and semantic similarity.
"""

import uuid
from typing import Optional, List

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, func, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db_session
from app.models.garment import Garment
from app.schemas import (
    DiscoveryQuery, DiscoveryResponse, DiscoveryResult,
    GarmentResponse, PaginationParams
)
from app.services.style_matching import style_matching_service

router = APIRouter(prefix="/discovery", tags=["discovery"])


@router.get("", response_model=DiscoveryResponse)
async def discover_garments(
    q: Optional[str] = Query(None, description="Natural language style query"),
    category: Optional[str] = Query(None, description="Filter by category"),
    size: Optional[str] = Query(None, description="Filter by size"),
    condition: Optional[str] = Query(None, description="Filter by condition"),
    exchange_type: Optional[str] = Query(None, description="Filter by exchange type"),
    max_price: Optional[float] = Query(None, ge=0, description="Maximum price"),
    min_sustainability: Optional[float] = Query(None, ge=0, le=100, description="Minimum sustainability score"),
    style_tags: Optional[List[str]] = Query(None, description="Style tags to match"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session)
) -> dict:
    """
    Smart garment discovery with AI-powered matching.
    
    This endpoint uses CLIP embeddings for semantic similarity matching,
    NOT keyword search. Describe what you're looking for in natural language
    (e.g., "vintage denim jacket with a worn-in feel" or "elegant black dress
    for a wedding") and get visually and semantically similar results.
    
    The matching considers:
    - Visual style and aesthetic
    - Semantic meaning of descriptions
    - Style attributes (colors, patterns)
    - Garment stories and narratives
    """
    
    # Generate query embedding from text description
    query_embedding = None
    if q:
        try:
            query_embedding = await style_matching_service.generate_text_embedding(q)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail=f"AI service unavailable: {str(e)}"
            )
    
    # Build base query for active garments
    base_query = select(Garment).where(Garment.status == "active")
    count_query = select(func.count(Garment.id)).where(Garment.status == "active")
    
    # Apply filters
    if category:
        base_query = base_query.where(Garment.category.ilike(f"%{category}%"))
        count_query = count_query.where(Garment.category.ilike(f"%{category}%"))
    
    if size:
        base_query = base_query.where(Garment.size == size)
        count_query = count_query.where(Garment.size == size)
    
    if condition:
        base_query = base_query.where(Garment.condition == condition)
        count_query = count_query.where(Garment.condition == condition)
    
    if exchange_type:
        base_query = base_query.where(Garment.exchange_type == exchange_type)
        count_query = count_query.where(Garment.exchange_type == exchange_type)
    
    if max_price is not None:
        base_query = base_query.where(Garment.price <= max_price)
        count_query = count_query.where(Garment.price <= max_price)
    
    # Execute count query
    count_result = await db.execute(count_query)
    total = count_result.scalar()
    
    if total == 0:
        return {
            "results": [],
            "query_embedding": query_embedding,
            "total": 0,
            "page": page,
            "page_size": page_size,
            "pages": 0
        }
    
    # Get candidate garments
    result = await db.execute(base_query)
    candidates = result.scalars().all()
    
    # Calculate similarity scores if we have a query embedding
    scored_results = []
    
    if query_embedding:
        # Score candidates by embedding similarity
        for garment in candidates:
            if garment.embedding:
                similarity = style_matching_service.calculate_similarity(
                    query_embedding,
                    garment.embedding
                )
            else:
                # Fallback: calculate text-based similarity from story/attributes
                similarity = _calculate_text_similarity(q, garment)
            
            if similarity >= 0.1:  # Minimum threshold
                # Generate match reasons
                reasons = _generate_match_reasons(q, garment)
                
                scored_results.append({
                    "garment": garment,
                    "similarity": similarity,
                    "reasons": reasons
                })
        
        # Sort by similarity score (descending)
        scored_results.sort(key=lambda x: x["similarity"], reverse=True)
    else:
        # No query, return recent items with default scores
        for garment in candidates:
            scored_results.append({
                "garment": garment,
                "similarity": 0.5,  # Neutral score
                "reasons": ["Recently listed"]
            })
        
        # Sort by creation date
        scored_results.sort(
            key=lambda x: x["garment"].created_at,
            reverse=True
        )
    
    # Apply pagination
    total_scored = len(scored_results)
    start_idx = (page - 1) * page_size
    end_idx = start_idx + page_size
    paginated_results = scored_results[start_idx:end_idx]
    
    # Build response
    discovery_results = [
        DiscoveryResult(
            garment=result["garment"],
            similarity_score=round(result["similarity"], 3),
            match_reasons=result["reasons"]
        )
        for result in paginated_results
    ]
    
    return {
        "results": discovery_results,
        "query_embedding": query_embedding,
        "total": total_scored,
        "page": page,
        "page_size": page_size,
        "pages": (total_scored + page_size - 1) // page_size
    }


@router.post("", response_model=DiscoveryResponse)
async def discover_garments_post(
    query: DiscoveryQuery,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session)
) -> dict:
    """
    Smart garment discovery with structured query (POST version).
    
    Same AI-powered matching as GET endpoint, but accepts a JSON body
    for more complex queries.
    """
    # Combine text and style tags for query
    query_parts = []
    if query.text:
        query_parts.append(query.text)
    if query.style_tags:
        query_parts.append(f"Style: {', '.join(query.style_tags)}")
    
    full_query = " ".join(query_parts) if query_parts else None
    
    # Delegate to GET implementation
    return await discover_garments(
        q=full_query,
        category=query.category,
        size=query.size,
        condition=query.condition.value if query.condition else None,
        exchange_type=query.exchange_type.value if query.exchange_type else None,
        max_price=float(query.max_price) if query.max_price else None,
        min_sustainability=query.min_sustainability_score,
        style_tags=query.style_tags,
        page=page,
        page_size=page_size,
        db=db
    )


@router.get("/similar/{garment_id}", response_model=DiscoveryResponse)
async def find_similar_garments(
    garment_id: uuid.UUID,
    exclude_same_owner: bool = Query(True, description="Exclude items from same owner"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session)
) -> dict:
    """
    Find garments similar to a specific item.
    
    Uses the garment's CLIP embedding to find visually and 
    semantically similar items in the catalog.
    """
    # Get source garment
    result = await db.execute(
        select(Garment).where(Garment.id == garment_id)
    )
    source_garment = result.scalar_one_or_none()
    
    if not source_garment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Source garment not found"
        )
    
    if not source_garment.embedding:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Source garment has no embedding for similarity search"
        )
    
    # Build query for candidates
    query = select(Garment).where(
        Garment.id != garment_id,
        Garment.status == "active",
        Garment.embedding.isnot(None)
    )
    
    if exclude_same_owner:
        query = query.where(Garment.owner_id != source_garment.owner_id)
    
    result = await db.execute(query)
    candidates = result.scalars().all()
    
    if not candidates:
        return {
            "results": [],
            "query_embedding": source_garment.embedding,
            "total": 0,
            "page": page,
            "page_size": page_size,
            "pages": 0
        }
    
    # Calculate similarities
    scored_results = []
    for garment in candidates:
        similarity = style_matching_service.calculate_similarity(
            source_garment.embedding,
            garment.embedding
        )
        
        if similarity >= 0.3:  # Higher threshold for similar-item search
            reasons = style_matching_service.generate_match_reasons(
                {
                    "category": source_garment.category,
                    "condition": source_garment.condition,
                    "style_attributes": source_garment.style_attributes
                },
                {
                    "category": garment.category,
                    "condition": garment.condition,
                    "style_attributes": garment.style_attributes
                }
            )
            
            scored_results.append({
                "garment": garment,
                "similarity": similarity,
                "reasons": reasons
            })
    
    # Sort by similarity
    scored_results.sort(key=lambda x: x["similarity"], reverse=True)
    
    # Paginate
    total = len(scored_results)
    start_idx = (page - 1) * page_size
    end_idx = start_idx + page_size
    paginated = scored_results[start_idx:end_idx]
    
    discovery_results = [
        DiscoveryResult(
            garment=r["garment"],
            similarity_score=round(r["similarity"], 3),
            match_reasons=r["reasons"]
        )
        for r in paginated
    ]
    
    return {
        "results": discovery_results,
        "query_embedding": source_garment.embedding,
        "total": total,
        "page": page,
        "page_size": page_size,
        "pages": (total + page_size - 1) // page_size
    }


def _calculate_text_similarity(query: str, garment: Garment) -> float:
    """Fallback text similarity when no embedding available."""
    query_lower = query.lower()
    score = 0.0
    
    # Category match
    if garment.category and garment.category.lower() in query_lower:
        score += 0.3
    
    # Brand match
    if garment.brand and garment.brand.lower() in query_lower:
        score += 0.2
    
    # Story content match
    if garment.story and isinstance(garment.story, dict):
        story_text = garment.get_story_text().lower()
        query_words = set(query_lower.split())
        story_words = set(story_text.split())
        overlap = len(query_words & story_words)
        score += min(overlap * 0.1, 0.4)
    
    # Style attributes match
    if garment.style_attributes and isinstance(garment.style_attributes, dict):
        colors = garment.style_attributes.get("colors", [])
        for color in colors:
            if color.lower() in query_lower:
                score += 0.1
                break
    
    return min(score, 1.0)


def _generate_match_reasons(query: str, garment: Garment) -> List[str]:
    """Generate human-readable reasons for why a garment matches."""
    reasons = []
    query_lower = query.lower()
    
    # Category match
    if garment.category and garment.category.lower() in query_lower:
        reasons.append(f"Matches category: {garment.category}")
    
    # Style tag matches
    if garment.style_attributes and isinstance(garment.style_attributes, dict):
        tags = garment.style_attributes.get("style_tags", [])
        for tag in tags:
            if tag.lower() in query_lower:
                reasons.append(f"{tag} style")
                break
        
        colors = garment.style_attributes.get("colors", [])
        for color in colors:
            if color.lower() in query_lower:
                reasons.append(f"{color} colorway")
                break
    
    # Provenance match
    if garment.provenance and isinstance(garment.provenance, dict):
        source = garment.provenance.get("source", "").lower()
        if source and source in query_lower:
            reasons.append(f"{source} item")
    
    if not reasons:
        reasons.append("Style compatibility")
    
    return reasons[:3]  # Max 3 reasons
