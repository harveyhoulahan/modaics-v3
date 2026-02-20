"""
Dynamic Greeting API

Personalized home screen messages and search hints.
"""

import logging
from fastapi import APIRouter

from app.services.moda_assistant import get_moda_assistant

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/greeting", tags=["greeting"])


@router.get("")
async def get_greeting():
    """Get a personalized greeting for the home screen."""
    # TODO: Get actual user_id from auth
    user_id = "temp-user-id"
    
    assistant = await get_moda_assistant()
    
    try:
        greeting = await assistant.generate_greeting(user_id)
        return {
            "greeting": greeting,
            "subtitle": "Discover pieces with stories"  # Fallback/secondary text
        }
    except Exception as e:
        logger.error(f"Failed to generate greeting: {e}")
        return {
            "greeting": "Discover pieces with stories",
            "subtitle": "Sustainable fashion marketplace"
        }


@router.get("/search-hint")
async def get_search_hint():
    """Get a personalized search placeholder."""
    # TODO: Get actual user_id from auth
    user_id = "temp-user-id"
    
    assistant = await get_moda_assistant()
    
    try:
        hint = await assistant.generate_search_hint(user_id)
        return {"hint": hint}
    except Exception as e:
        logger.error(f"Failed to generate search hint: {e}")
        return {"hint": "Search for vintage Levi's, silk blouses..."}


@router.get("/daily-fact")
async def get_daily_fact():
    """Get a fun fashion fact or tip."""
    import random
    
    facts = [
        "The average person only wears 20% of their wardrobe regularly 👕",
        "Buying one pre-loved item saves 2,100 litres of water 💧",
        "The term 'vintage' originally referred to wine, not clothes 🍷",
        "Cotton is the world's dirtiest crop — it uses 16% of all insecticides 🌱",
        "The little black dress was popularized by Coco Chanel in 1926 🖤",
        "Denim was originally called 'serge de Nîmes' from France 🇫🇷",
        "The average garment is worn only 7 times before being discarded 😢",
        "Upcycling started during WWII when fabric was rationed ✂️",
        "Cashmere comes from Kashmir goats in Mongolia and China 🐐",
        "The first fashion magazine was published in 1678 📖",
        "Synthetic fabrics like polyester can take 200 years to decompose ⏰",
        "The fashion industry produces 10% of global carbon emissions 🌍",
        "Levi's 501 jeans have been in production since 1873 👖",
        "Silk was once worth its weight in gold in ancient Rome 🏛️",
        "The average Australian buys 27kg of new clothes per year 🇦🇺",
    ]
    
    return {
        "fact": random.choice(facts),
        "type": "sustainability" if random.random() > 0.5 else "fashion_history"
    }
