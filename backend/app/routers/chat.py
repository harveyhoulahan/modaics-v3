"""
Chat API Router

Streaming chat endpoint for Moda AI Assistant.
"""

import json
import logging
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field

from app.services.moda_assistant import get_moda_assistant
from app.services.search_alerts import get_search_alerts_service

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/chat", tags=["chat"])


# ============== Request/Response Schemas ==============

class ChatMessage(BaseModel):
    """A single chat message."""
    role: str = Field(..., description="user or assistant")
    content: str = Field(..., description="Message content")
    timestamp: Optional[str] = None


class ChatRequest(BaseModel):
    """Chat request from user."""
    message: str = Field(..., description="User's message")
    conversation_history: list[ChatMessage] = Field(default_factory=list)


class CreateAlertRequest(BaseModel):
    """Request to create a search alert."""
    description: str = Field(..., description="What to watch for")
    max_price: Optional[float] = Field(None, description="Maximum price")
    category: Optional[str] = Field(None, description="Category filter")


class ConciergeRequest(BaseModel):
    """Concierge search request."""
    query: str = Field(..., description="What you're looking for")
    occasion: Optional[str] = Field(None, description="Occasion (e.g., 'wedding', 'interview')")
    budget: Optional[float] = Field(None, description="Maximum budget")
    timeline: Optional[str] = Field(None, description="Urgency: 'tonight', 'this_weekend', 'anytime'")


# ============== Routes ==============

@router.post("/stream")
async def chat_stream(request: ChatRequest):
    """
    SSE streaming chat with Moda AI assistant.
    
    Streams back the AI response word by word for a natural feel.
    """
    # TODO: Get actual user_id from auth
    user_id = "temp-user-id"  # Replace with actual auth
    
    assistant = await get_moda_assistant()
    
    async def generate():
        try:
            async for chunk in assistant.chat_stream(
                user_id=user_id,
                message=request.message,
                conversation_history=[h.model_dump() for h in request.conversation_history]
            ):
                yield f"data: {json.dumps({'type': 'text', 'content': chunk})}\n\n"
            
            yield f"data: {json.dumps({'type': 'done'})}\n\n"
        except Exception as e:
            logger.error(f"Chat stream error: {e}")
            yield f"data: {json.dumps({'type': 'error', 'content': str(e)})}\n\n"
    
    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
        }
    )


@router.post("/alert")
async def create_alert(request: CreateAlertRequest):
    """Create a 'keep an eye out' alert."""
    # TODO: Get actual user_id from auth
    user_id = "temp-user-id"
    
    service = await get_search_alerts_service()
    
    try:
        alert = await service.create_alert(
            user_id=user_id,
            description=request.description,
            max_price=request.max_price,
            category=request.category
        )
        
        return {
            "success": True,
            "alert_id": alert.id,
            "message": f"I'll keep an eye out for '{request.description}' and let you know when something pops up! 👀"
        }
    except Exception as e:
        logger.error(f"Failed to create alert: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create alert"
        )


@router.get("/alerts")
async def get_alerts():
    """Get user's active search alerts."""
    # TODO: Get actual user_id from auth
    user_id = "temp-user-id"
    
    service = await get_search_alerts_service()
    alerts = await service.get_user_alerts(user_id)
    
    return {
        "alerts": alerts,
        "count": len(alerts)
    }


@router.delete("/alert/{alert_id}")
async def delete_alert(alert_id: str):
    """Deactivate a search alert."""
    # TODO: Get actual user_id from auth
    user_id = "temp-user-id"
    
    service = await get_search_alerts_service()
    success = await service.deactivate_alert(alert_id, user_id)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Alert not found"
        )
    
    return {"success": True, "message": "Alert removed"}


@router.post("/concierge")
async def concierge_search(request: ConciergeRequest):
    """
    Concierge-style search for urgent needs.
    
    Example: "I need a tux for tonight under $300"
    """
    # TODO: Get actual user_id from auth
    user_id = "temp-user-id"
    
    service = await get_search_alerts_service()
    
    try:
        result = await service.concierge_search(
            user_id=user_id,
            query=request.query,
            occasion=request.occasion,
            budget=request.budget,
            timeline=request.timeline
        )
        
        return result
    except Exception as e:
        logger.error(f"Concierge search error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Search failed"
        )
