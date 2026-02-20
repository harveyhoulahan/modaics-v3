"""
Moda AI Assistant Service

The personality-driven AI wardrobe companion for Modaics.
- Makes witty remarks about user's collection
- "Keep an eye out" alerts for wanted items
- Concierge service for finding items
- Dynamic personalized content
"""

import os
import json
import asyncio
from typing import List, Dict, Any, Optional, AsyncGenerator
from datetime import datetime, timedelta
import logging

from anthropic import AsyncAnthropic
import openai

from app.config import get_settings
from app.database import AsyncSessionLocal

logger = logging.getLogger(__name__)
settings = get_settings()


# Moda's personality - warm, witty, slightly cheeky fashion-savvy best friend
MODA_SYSTEM_PROMPT = """You are Moda, the AI style companion for Modaics — a circular fashion marketplace.

PERSONALITY:
- Warm, witty, slightly cheeky — like a fashion-savvy best friend who cares about the planet
- You celebrate personal style over trends
- Passionate about circular fashion but NEVER preachy
- Body-positive, encouraging, specific
- Say "pre-loved" not "used". Say "piece" not "item" when it sounds natural.
- Keep responses concise (2-3 sentences for quick queries, longer for styling advice)
- Use emojis sparingly (1-2 per message max)
- Reference specific items from the user's wardrobe by name when relevant
- Be observant - notice patterns in what they search, buy, save

CAPABILITIES:
- Search the user's wardrobe for outfit combinations
- Search the marketplace for items matching descriptions
- Create alerts for specific items the user is looking for
- Suggest outfits based on weather, occasion, or mood
- Provide styling advice rooted in the user's actual wardrobe
- Track sustainability impact and celebrate milestones

BOUNDARIES:
- Never shame users for fast fashion purchases — gently suggest pre-loved alternatives
- Never give body-negative advice
- If asked about non-fashion topics, briefly engage then redirect
- Never recommend items outside the user's stated budget
- Always disclose when suggesting marketplace items (could be seen as advertising)

TONE EXAMPLES:
- Instead of "I'd recommend..." → "That Everlane blazer you saved would be 🤌 with those black jeans"
- Instead of "You should consider..." → "Have you thought about..."
- Instead of "Based on your data..." → just reference the item naturally
- When they buy something: "Another piece with a story! Your wardrobe just got more interesting ✨"
- When they search repeatedly: "I see you're vibing with [style] lately..."
"""


class ModaContext:
    """Context about the user for personalization."""
    
    def __init__(self, user_id: str):
        self.user_id = user_id
        self.wardrobe_count = 0
        self.recent_searches: List[str] = []
        self.recent_purchases: List[Dict] = []
        self.saved_items: List[Dict] = []
        self.style_preferences: List[str] = []
        self.sustainability_score = 0
        self.total_carbon_saved = 0.0
        self.favorite_categories: List[str] = []
        self.favorite_colors: List[str] = []
        self.budget_range = {"min": 0, "max": 1000}
        self.location = ""
        
    async def load(self):
        """Load user context from database."""
        from sqlalchemy import text
        
        async with AsyncSessionLocal() as session:
            # Wardrobe stats
            result = await session.execute(
                text("""
                    SELECT 
                        COUNT(*) as wardrobe_count,
                        COALESCE(SUM(carbon_savings_kg), 0) as total_carbon
                    FROM wardrobe_items 
                    WHERE user_id = :user_id
                """),
                {"user_id": self.user_id}
            )
            row = result.fetchone()
            if row:
                self.wardrobe_count = row.wardrobe_count
                self.total_carbon_saved = float(row.total_carbon)
            
            # Recent searches (last 30 days)
            result = await session.execute(
                text("""
                    SELECT search_query, created_at
                    FROM search_history
                    WHERE user_id = :user_id AND created_at > NOW() - INTERVAL '30 days'
                    ORDER BY created_at DESC
                    LIMIT 20
                """),
                {"user_id": self.user_id}
            )
            searches = result.fetchall()
            self.recent_searches = [s.search_query for s in searches]
            
            # Recent purchases
            result = await session.execute(
                text("""
                    SELECT i.title, i.category, i.brand, t.created_at
                    FROM transactions t
                    JOIN items i ON t.item_id = i.id
                    WHERE t.buyer_id = :user_id
                    ORDER BY t.created_at DESC
                    LIMIT 10
                """),
                {"user_id": self.user_id}
            )
            purchases = result.fetchall()
            self.recent_purchases = [
                {"title": p.title, "category": p.category, "brand": p.brand}
                for p in purchases
            ]
            
            # Saved items (wishlist)
            result = await session.execute(
                text("""
                    SELECT i.title, i.category, i.brand
                    FROM wishlist w
                    JOIN items i ON w.item_id = i.id
                    WHERE w.user_id = :user_id
                    ORDER BY w.created_at DESC
                    LIMIT 10
                """),
                {"user_id": self.user_id}
            )
            saved = result.fetchall()
            self.saved_items = [
                {"title": s.title, "category": s.category, "brand": s.brand}
                for s in saved
            ]
            
            # Style preferences from profile
            result = await session.execute(
                text("SELECT style_preferences, favorite_colors, location FROM users WHERE id = :user_id"),
                {"user_id": self.user_id}
            )
            profile = result.fetchone()
            if profile:
                self.style_preferences = profile.style_preferences or []
                self.favorite_colors = profile.favorite_colors or []
                self.location = profile.location or ""
            
            # Extract favorite categories from wardrobe
            result = await session.execute(
                text("""
                    SELECT category, COUNT(*) as count
                    FROM wardrobe_items
                    WHERE user_id = :user_id
                    GROUP BY category
                    ORDER BY count DESC
                    LIMIT 5
                """),
                {"user_id": self.user_id}
            )
            categories = result.fetchall()
            self.favorite_categories = [c.category for c in categories]


class ModaAssistant:
    """Main AI assistant service."""
    
    def __init__(self):
        self.client = None
        self.model = "claude-3-5-haiku-20241022"  # Fast, cost-effective
        
    async def initialize(self):
        """Initialize the AI client."""
        if settings.ANTHROPIC_API_KEY:
            self.client = AsyncAnthropic(api_key=settings.ANTHROPIC_API_KEY)
        elif settings.OPENAI_API_KEY:
            openai.api_key = settings.OPENAI_API_KEY
            self.model = "gpt-4o-mini"
            
    async def chat_stream(
        self, 
        user_id: str, 
        message: str, 
        conversation_history: List[Dict] = None
    ) -> AsyncGenerator[str, None]:
        """Stream chat response with full context."""
        
        # Load user context
        context = ModaContext(user_id)
        await context.load()
        
        # Build context-rich messages
        messages = self._build_messages(message, context, conversation_history or [])
        
        # Stream response
        if settings.ANTHROPIC_API_KEY and self.client:
            async for chunk in self._stream_claude(messages):
                yield chunk
        else:
            async for chunk in self._stream_openai(messages):
                yield chunk
    
    def _build_messages(
        self, 
        message: str, 
        context: ModaContext,
        history: List[Dict]
    ) -> List[Dict]:
        """Build messages with user context."""
        
        # Build context summary
        context_parts = []
        
        if context.wardrobe_count > 0:
            context_parts.append(f"User has {context.wardrobe_count} items in their wardrobe")
        
        if context.recent_searches:
            recent = ", ".join(context.recent_searches[:5])
            context_parts.append(f"Recent searches: {recent}")
        
        if context.recent_purchases:
            recent_purchase = context.recent_purchases[0]
            context_parts.append(f"Most recent purchase: {recent_purchase['title']} ({recent_purchase['category']})")
        
        if context.saved_items:
            saved = ", ".join([s['title'] for s in context.saved_items[:3]])
            context_parts.append(f"Saved items: {saved}")
        
        if context.favorite_categories:
            context_parts.append(f"Favorite categories: {', '.join(context.favorite_categories[:3])}")
        
        if context.total_carbon_saved > 0:
            context_parts.append(f"Total carbon saved: {context.total_carbon_saved:.1f}kg")
        
        context_str = "\n".join(context_parts)
        
        # Build messages
        messages = []
        
        # Add context as first system message
        if context_str:
            messages.append({
                "role": "system",
                "content": f"User context:\n{context_str}"
            })
        
        # Add conversation history
        for h in history[-10:]:  # Last 10 messages
            messages.append({
                "role": "user" if h.get("is_user") else "assistant",
                "content": h.get("content", "")
            })
        
        # Add current message
        messages.append({"role": "user", "content": message})
        
        return messages
    
    async def _stream_claude(self, messages: List[Dict]) -> AsyncGenerator[str, None]:
        """Stream response using Claude."""
        try:
            async with self.client.messages.stream(
                model=self.model,
                max_tokens=1024,
                system=MODA_SYSTEM_PROMPT,
                messages=messages
            ) as stream:
                async for text in stream.text_stream:
                    yield text
        except Exception as e:
            logger.error(f"Claude streaming error: {e}")
            yield "Sorry, I'm having trouble thinking right now. Mind trying again?"
    
    async def _stream_openai(self, messages: List[Dict]) -> AsyncGenerator[str, None]:
        """Stream response using OpenAI."""
        try:
            # Combine system prompt
            full_messages = [{"role": "system", "content": MODA_SYSTEM_PROMPT}]
            full_messages.extend(messages)
            
            response = await openai.ChatCompletion.acreate(
                model=self.model,
                messages=full_messages,
                stream=True,
                max_tokens=1024
            )
            
            async for chunk in response:
                if chunk.choices[0].delta.get("content"):
                    yield chunk.choices[0].delta.content
        except Exception as e:
            logger.error(f"OpenAI streaming error: {e}")
            yield "Sorry, I'm having trouble thinking right now. Mind trying again?"
    
    async def generate_greeting(self, user_id: str) -> str:
        """Generate a dynamic greeting for the home screen."""
        context = ModaContext(user_id)
        await context.load()
        
        # Select from personalized greetings based on context
        greetings = self._generate_greeting_options(context)
        
        # Use AI to pick/create the best one
        if self.client:
            prompt = f"""Pick or create a short, punchy greeting (max 10 words) for a fashion app home screen.
            
Context:
- User has {context.wardrobe_count} wardrobe items
- Recent searches: {', '.join(context.recent_searches[:3]) if context.recent_searches else 'None'}
- Saved items: {len(context.saved_items)}
- Carbon saved: {context.total_carbon_saved:.0f}kg

Options to consider:
{chr(10).join(greetings[:5])}

Return just the greeting text, no quotes."""
            
            try:
                response = await self.client.messages.create(
                    model=self.model,
                    max_tokens=50,
                    system="You are a witty fashion copywriter. Be brief and punchy.",
                    messages=[{"role": "user", "content": prompt}]
                )
                return response.content[0].text.strip().strip('"')
            except:
                pass
        
        # Fallback to random selection
        import random
        return random.choice(greetings) if greetings else "Discover pieces with stories"
    
    def _generate_greeting_options(self, context: ModaContext) -> List[str]:
        """Generate personalized greeting options."""
        options = []
        
        # Wardrobe-based
        if context.wardrobe_count == 0:
            options.append("Ready to start your sustainable wardrobe?")
        elif context.wardrobe_count < 5:
            options.append(f"Your {context.wardrobe_count} pieces are just the beginning ✨")
        elif context.wardrobe_count < 20:
            options.append(f"Your wardrobe has {context.wardrobe_count} stories and counting")
        else:
            options.append(f"{context.wardrobe_count} pieces — your collection is legendary 🏆")
        
        # Sustainability-based
        if context.total_carbon_saved > 50:
            options.append(f"Your wardrobe saved {context.total_carbon_saved:.0f}kg of CO₂ 🌱")
        
        # Search-based
        if context.recent_searches:
            search_terms = context.recent_searches[:2]
            options.append(f"Still thinking about that {search_terms[0]}?")
            if len(search_terms) > 1:
                options.append(f"I see you're vibing with {search_terms[0]} lately...")
        
        # Saved items
        if context.saved_items:
            item = context.saved_items[0]
            options.append(f"That {item['title']} you saved? Still available 👀")
        
        # Recent purchase
        if context.recent_purchases:
            purchase = context.recent_purchases[0]
            options.append(f"How's that {purchase['title']} working out?")
            options.append("Another piece with a story! Love to see it ✨")
        
        # Time-based
        hour = datetime.now().hour
        if hour < 12:
            options.append("Good morning! Find something pre-loved today ☀️")
        elif hour < 17:
            options.append("Afternoon shopping? Your wardrobe approves 👗")
        else:
            options.append("Late night browsing? I won't tell 😉")
        
        # General
        options.extend([
            "Someone in your area just listed something perfect",
            "3 new pieces matching your style dropped today",
            "Ready to discover your next favourite piece?",
            "Your next obsession is waiting...",
            "Fashion that doesn't cost the Earth 🌍",
        ])
        
        return options
    
    async def generate_search_hint(self, user_id: str) -> str:
        """Generate a personalized search placeholder."""
        context = ModaContext(user_id)
        await context.load()
        
        hints = [
            "Search for vintage Levi's...",
            "Find a blazer for tonight...",
            "Look for silk blouses...",
            "Search sustainable denim...",
            "Find party dresses under $100...",
        ]
        
        # Personalize based on history
        if context.recent_searches:
            # Extract common terms
            common = context.recent_searches[0].split()[0]
            hints.append(f"More like '{common}...'")
        
        if context.favorite_categories:
            cat = context.favorite_categories[0]
            hints.append(f"Find {cat}...")
        
        import random
        return random.choice(hints)


# Global instance
_moda_assistant: Optional[ModaAssistant] = None


async def get_moda_assistant() -> ModaAssistant:
    """Get or initialize the Moda assistant."""
    global _moda_assistant
    if _moda_assistant is None:
        _moda_assistant = ModaAssistant()
        await _moda_assistant.initialize()
    return _moda_assistant
