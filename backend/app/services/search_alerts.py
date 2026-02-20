"""
Search Alerts Service

"Keep an eye out" feature - users can ask Moda to watch for specific items
and get notified when matching items are listed.
"""

import uuid
import logging
from typing import List, Dict, Optional
from datetime import datetime, timedelta

from app.database import get_db_pool
from app.services.fashion_clip import get_fashion_clip_service

logger = logging.getLogger(__name__)


class SearchAlert:
    """A search alert/watch request."""
    
    def __init__(
        self,
        id: str,
        user_id: str,
        description: str,
        text_embedding: List[float],
        max_price: Optional[float] = None,
        category: Optional[str] = None,
        similarity_threshold: float = 0.72
    ):
        self.id = id
        self.user_id = user_id
        self.description = description
        self.text_embedding = text_embedding
        self.max_price = max_price
        self.category = category
        self.similarity_threshold = similarity_threshold
        self.is_active = True
        self.matches_found = 0
        self.last_notified_at: Optional[datetime] = None
        self.created_at = datetime.utcnow()


class SearchAlertsService:
    """Service for managing search alerts and matching."""
    
    DEFAULT_SIMILARITY_THRESHOLD = 0.72
    MIN_NOTIFICATION_INTERVAL = timedelta(hours=24)
    
    async def create_alert(
        self,
        user_id: str,
        description: str,
        max_price: Optional[float] = None,
        category: Optional[str] = None,
        image: Optional[bytes] = None
    ) -> SearchAlert:
        """Create a new search alert."""
        
        # Generate embedding from description (and optionally image)
        clip_service = await get_fashion_clip_service()
        
        # Text embedding
        text_embedding = await clip_service.encode_text(description)
        
        # If image provided, average embeddings
        if image:
            from PIL import Image
            import io
            img = Image.open(io.BytesIO(image)).convert("RGB")
            image_embedding = await clip_service.encode_image(img)
            # Average text and image embeddings
            text_embedding = [
                (t + i) / 2 for t, i in zip(text_embedding, image_embedding)
            ]
        
        # Create alert
        alert_id = str(uuid.uuid4())
        alert = SearchAlert(
            id=alert_id,
            user_id=user_id,
            description=description,
            text_embedding=text_embedding.tolist() if hasattr(text_embedding, 'tolist') else list(text_embedding),
            max_price=max_price,
            category=category,
            similarity_threshold=self.DEFAULT_SIMILARITY_THRESHOLD
        )
        
        # Save to database
        pool = await get_db_pool()
        async with pool.acquire() as conn:
            await conn.execute(
                """
                INSERT INTO search_alerts (
                    id, user_id, description, text_embedding, max_price, 
                    category, similarity_threshold, is_active, created_at
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
                """,
                alert.id, alert.user_id, alert.description,
                alert.text_embedding, alert.max_price,
                alert.category, alert.similarity_threshold, alert.is_active
            )
        
        logger.info(f"Created search alert {alert_id} for user {user_id}: {description}")
        return alert
    
    async def get_user_alerts(self, user_id: str) -> List[Dict]:
        """Get all active alerts for a user."""
        pool = await get_db_pool()
        async with pool.acquire() as conn:
            rows = await conn.fetch(
                """
                SELECT 
                    id, description, max_price, category,
                    matches_found, created_at
                FROM search_alerts
                WHERE user_id = $1 AND is_active = true
                ORDER BY created_at DESC
                """,
                user_id
            )
        
        return [
            {
                "id": str(r["id"]),
                "description": r["description"],
                "max_price": float(r["max_price"]) if r["max_price"] else None,
                "category": r["category"],
                "matches_found": r["matches_found"],
                "created_at": r["created_at"].isoformat()
            }
            for r in rows
        ]
    
    async def deactivate_alert(self, alert_id: str, user_id: str) -> bool:
        """Deactivate a search alert."""
        pool = await get_db_pool()
        async with pool.acquire() as conn:
            result = await conn.execute(
                """
                UPDATE search_alerts
                SET is_active = false
                WHERE id = $1 AND user_id = $2
                """,
                alert_id, user_id
            )
        return result == "UPDATE 1"
    
    async def check_new_listings(self) -> List[Dict]:
        """
        Check recently listed items against active alerts.
        Returns list of matches for notification.
        """
        pool = await get_db_pool()
        matches = []
        
        async with pool.acquire() as conn:
            # Get items listed in last 15 minutes
            new_items = await conn.fetch(
                """
                SELECT 
                    i.id, i.title, i.description, i.price, i.category,
                    i.image_embedding, i.seller_id, u.username as seller_name
                FROM items i
                JOIN users u ON i.seller_id = u.id
                WHERE i.created_at > NOW() - INTERVAL '15 minutes'
                AND i.image_embedding IS NOT NULL
                AND i.status = 'active'
                """
            )
            
            for item in new_items:
                # Find matching alerts
                matching_alerts = await conn.fetch(
                    """
                    SELECT 
                        sa.id, sa.user_id, sa.description,
                        1 - (sa.text_embedding <=> $1::vector) AS similarity
                    FROM search_alerts sa
                    WHERE sa.is_active = true
                    AND (sa.max_price IS NULL OR $2 <= sa.max_price)
                    AND (sa.category IS NULL OR sa.category = $3)
                    AND (1 - (sa.text_embedding <=> $1::vector)) > sa.similarity_threshold
                    AND (
                        sa.last_notified_at IS NULL 
                        OR sa.last_notified_at < NOW() - INTERVAL '24 hours'
                    )
                    AND sa.user_id != $4  -- Don't alert for own listings
                    """,
                    item["image_embedding"], item["price"], 
                    item["category"], item["seller_id"]
                )
                
                for alert in matching_alerts:
                    matches.append({
                        "alert_id": str(alert["id"]),
                        "user_id": str(alert["user_id"]),
                        "alert_description": alert["description"],
                        "similarity": float(alert["similarity"]),
                        "item": {
                            "id": str(item["id"]),
                            "title": item["title"],
                            "price": float(item["price"]),
                            "category": item["category"],
                            "seller_name": item["seller_name"]
                        }
                    })
                    
                    # Update alert
                    await conn.execute(
                        """
                        UPDATE search_alerts
                        SET last_notified_at = NOW(),
                            matches_found = matches_found + 1
                        WHERE id = $1
                        """,
                        alert["id"]
                    )
        
        return matches
    
    async def find_matches_for_alert(self, alert_id: str) -> List[Dict]:
        """Find existing items that match a specific alert."""
        pool = await get_db_pool()
        
        async with pool.acquire() as conn:
            # Get alert details
            alert = await conn.fetchrow(
                "SELECT * FROM search_alerts WHERE id = $1",
                alert_id
            )
            
            if not alert:
                return []
            
            # Find matching items
            items = await conn.fetch(
                """
                SELECT 
                    i.id, i.title, i.price, i.category,
                    1 - ($1::vector <=> i.image_embedding) AS similarity,
                    u.username as seller_name
                FROM items i
                JOIN users u ON i.seller_id = u.id
                WHERE i.status = 'active'
                AND i.created_at > NOW() - INTERVAL '30 days'
                AND ($2 IS NULL OR i.price <= $2)
                AND ($3 IS NULL OR i.category = $3)
                AND (1 - ($1::vector <=> i.image_embedding)) > $4
                AND i.seller_id != $5
                ORDER BY similarity DESC
                LIMIT 20
                """,
                alert["text_embedding"], alert["max_price"],
                alert["category"], alert["similarity_threshold"],
                alert["user_id"]
            )
        
        return [
            {
                "id": str(item["id"]),
                "title": item["title"],
                "price": float(item["price"]),
                "category": item["category"],
                "seller_name": item["seller_name"],
                "similarity": float(item["similarity"])
            }
            for item in items
        ]
    
    async def concierge_search(
        self,
        user_id: str,
        query: str,
        occasion: Optional[str] = None,
        budget: Optional[float] = None,
        timeline: Optional[str] = None  # "tonight", "this weekend", "anytime"
    ) -> Dict:
        """
        Concierge-style search for urgent needs.
        Example: "quick tux for tonight under $300"
        """
        clip_service = await get_fashion_clip_service()
        
        # Parse query into searchable terms
        search_embedding = await clip_service.encode_text(query)
        
        pool = await get_db_pool()
        async with pool.acquire() as conn:
            # Search with multiple criteria
            items = await conn.fetch(
                """
                SELECT 
                    i.id, i.title, i.price, i.category, i.condition,
                    i.size, i.brand, i.images,
                    1 - ($1::vector <=> i.image_embedding) AS similarity,
                    u.username as seller_name,
                    u.location as seller_location
                FROM items i
                JOIN users u ON i.seller_id = u.id
                WHERE i.status = 'active'
                AND ($2 IS NULL OR i.price <= $2)
                AND i.seller_id != $3
                ORDER BY similarity DESC
                LIMIT 10
                """,
                search_embedding.tolist() if hasattr(search_embedding, 'tolist') else list(search_embedding),
                budget, user_id
            )
        
        # Build result
        results = []
        for item in items:
            result = {
                "id": str(item["id"]),
                "title": item["title"],
                "price": float(item["price"]),
                "brand": item["brand"],
                "condition": item["condition"],
                "size": item["size"],
                "seller": item["seller_name"],
                "similarity": float(item["similarity"]),
                "images": item["images"] or []
            }
            results.append(result)
        
        # Generate summary
        summary = self._generate_concierge_summary(query, results, occasion, budget, timeline)
        
        return {
            "query": query,
            "results": results,
            "summary": summary,
            "total_found": len(results),
            "budget": budget,
            "timeline": timeline
        }
    
    def _generate_concierge_summary(
        self, 
        query: str, 
        results: List[Dict],
        occasion: Optional[str],
        budget: Optional[float],
        timeline: Optional[str]
    ) -> str:
        """Generate a helpful concierge-style summary."""
        if not results:
            if budget:
                return f"I couldn't find anything matching '{query}' under ${budget:.0f} right now. Want me to keep an eye out?"
            return f"I couldn't find anything matching '{query}' right now. Want me to watch for it?"
        
        count = len(results)
        top_result = results[0]
        
        parts = []
        
        if timeline == "tonight":
            parts.append(f"Found {count} options that could work for tonight!")
        elif timeline == "this weekend":
            parts.append(f"Found {count} great options for the weekend.")
        else:
            parts.append(f"Found {count} pieces matching '{query}'.")
        
        if top_result["similarity"] > 0.85:
            parts.append(f"That {top_result['title']} is a {int(top_result['similarity']*100)}% match — looks perfect!")
        elif top_result["similarity"] > 0.70:
            parts.append(f"The {top_result['title']} at ${top_result['price']:.0f} is your best bet.")
        
        if budget and top_result["price"] <= budget * 0.8:
            parts.append(f"And it's ${budget - top_result['price']:.0f} under budget! 💰")
        
        return " ".join(parts)


# Global instance
_search_alerts_service: Optional[SearchAlertsService] = None


async def get_search_alerts_service() -> SearchAlertsService:
    """Get or initialize the search alerts service."""
    global _search_alerts_service
    if _search_alerts_service is None:
        _search_alerts_service = SearchAlertsService()
    return _search_alerts_service
