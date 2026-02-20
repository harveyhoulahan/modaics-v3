"""
Story AI Service

AI-powered story generation and enhancement for garments.
Helps users craft compelling narratives about their clothes.
"""

import random
from typing import Optional, Dict, Any, List
import logging

logger = logging.getLogger(__name__)


class StoryAIService:
    """
    Service for generating and enhancing garment stories.
    
    Uses templates and natural language generation to help users
    create compelling narratives about their garments.
    """
    
    # Story templates by category
    STORY_TEMPLATES = {
        "dress": [
            "This {adjective} dress has been my go-to for {occasion}. "
            "I remember wearing it when {memory}. "
            "The {fabric} fabric feels {texture_desc} against the skin.",
            
            "I found this {adjective} piece {discovery_story}. "
            "It's perfect for {occasion} and always makes me feel {feeling}."
        ],
        "shirt": [
            "This {adjective} shirt has seen me through {life_event}. "
            "The {fabric} has softened beautifully over time.",
            
            "A wardrobe staple that works for {occasion}. "
            "I love how the {color} {pattern} {pattern_desc}."
        ],
        "jacket": [
            "My trusted companion for {season} adventures. "
            "This {adjective} jacket has been with me to {places}.",
            
            "The perfect layer for {occasion}. "
            "I've received countless compliments on its {feature}."
        ],
        "sweater": [
            "Cozy comfort in {fabric} knit. "
            "This {adjective} sweater wraps you in warmth like {metaphor}.",
            
            "My favorite for {season} days. "
            "The {color} shade reminds me of {memory}."
        ],
        "default": [
            "This {adjective} piece has been part of my journey. "
            "{memory_or_use}",
            
            "A {adjective} addition to any wardrobe. "
            "Perfect for {occasion} and always reliable."
        ]
    }
    
    # Vocabulary banks
    ADJECTIVES = [
        "beautiful", "stunning", "elegant", "charming", "unique",
        "versatile", "timeless", "classic", "trendy", "vibrant",
        "sophisticated", "playful", "refined", "bold", "subtle",
        "cherished", "beloved", "treasured", "favorite", "special"
    ]
    
    OCCASIONS = [
        "special occasions", "casual outings", "date nights",
        "weekend brunches", "work presentations", "weddings",
        "gallery openings", "dinner parties", "travel adventures",
        "cozy nights in", "summer festivals", "holiday gatherings"
    ]
    
    MEMORIES = [
        "I received an unexpected compliment from a stranger",
        "it helped me land my dream job",
        "I danced the night away without a care",
        "I felt completely like myself",
        "it became part of my signature look",
        "I celebrated a milestone",
        "I made memories that will last forever"
    ]
    
    FABRICS = [
        "silk", "cotton", "linen", "wool", "cashmere",
        "velvet", "denim", "leather", "suede", "knit",
        "organic cotton", "recycled polyester", "hemp blend"
    ]
    
    FEELINGS = [
        "confident", "elegant", "comfortable", "powerful",
        "creative", "authentic", "radiant", "at ease",
        "like my best self", "ready for anything"
    ]
    
    SEASONS = [
        "spring", "summer", "fall", "winter",
        "transitional weather", "crisp autumn", "sunny summer"
    ]
    
    def generate_story_prompt(
        self,
        category: str,
        brand: Optional[str] = None,
        color: Optional[str] = None,
        style_tags: Optional[List[str]] = None
    ) -> str:
        """
        Generate a prompt to help users write their garment story.
        
        Args:
            category: Garment category
            brand: Brand name
            color: Primary color
            style_tags: Style descriptors
            
        Returns:
            A creative writing prompt
        """
        prompts = []
        
        # Category-specific opening
        prompts.append(f"Tell us about your {category}...")
        
        # Context questions
        questions = [
            f"Where did you get this {category}?",
            "What memories does it hold?",
            "When do you love wearing it most?",
            "How does it make you feel?"
        ]
        
        if brand:
            questions.insert(1, f"What drew you to {brand}?")
        
        if style_tags:
            style_str = ", ".join(style_tags[:3])
            prompts.append(f"This piece has a {style_str} vibe. ")
        
        prompt_text = "\n".join(prompts)
        prompt_text += "\n\nConsider these questions:\n"
        prompt_text += "\n".join(f"• {q}" for q in questions[:4])
        
        return prompt_text
    
    def enhance_story(
        self,
        user_text: str,
        category: str,
        style_attributes: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Enhance a user's story with AI suggestions.
        
        Args:
            user_text: Original user story
            category: Garment category
            style_attributes: Style data for context
            
        Returns:
            Enhanced story with suggestions
        """
        # Analyze existing content
        word_count = len(user_text.split())
        
        suggestions = []
        
        # Length-based suggestions
        if word_count < 20:
            suggestions.append("Consider adding more detail about when you wear this piece")
        
        if "feel" not in user_text.lower() and "feeling" not in user_text.lower():
            suggestions.append("How does this garment make you feel when you wear it?")
        
        if "remember" not in user_text.lower() and "memory" not in user_text.lower():
            suggestions.append("Any special memories associated with this piece?")
        
        # Extract mood
        mood = self._detect_mood(user_text)
        
        # Generate enhanced version
        enhanced = self._generate_enhanced_version(
            user_text, category, style_attributes, mood
        )
        
        return {
            "original": user_text,
            "enhanced": enhanced,
            "mood": mood,
            "suggestions": suggestions,
            "word_count": word_count,
            "readability_score": self._calculate_readability(user_text)
        }
    
    def generate_story_from_attributes(
        self,
        category: str,
        style_attributes: Dict[str, Any],
        provenance: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        Generate a starter story from garment attributes.
        
        Args:
            category: Garment category
            style_attributes: Style data
            provenance: Provenance information
            
        Returns:
            Generated story text
        """
        # Get appropriate templates
        templates = self.STORY_TEMPLATES.get(category, self.STORY_TEMPLATES["default"])
        template = random.choice(templates)
        
        # Build substitution dictionary
        subs = {
            "adjective": random.choice(self.ADJECTIVES),
            "occasion": random.choice(self.OCCASIONS),
            "memory": random.choice(self.MEMORIES),
            "fabric": random.choice(self.FABRICS),
            "feeling": random.choice(self.FEELINGS),
            "season": random.choice(self.SEASONS),
            "texture_desc": "luxuriously soft" if category in ["sweater", "dress"] else "wonderfully comfortable",
            "discovery_story": "at a vintage market" if provenance and provenance.get("source") == "vintage" else "during a memorable trip",
            "places": "so many places" if category in ["jacket", "coat"] else "work and weekend adventures",
            "pattern": "texture" if category in ["sweater", "knit"] else "pattern",
            "pattern_desc": "adds such depth" if category in ["sweater", "knit"] else "catches the light beautifully",
            "color": random.choice(["deep navy", "warm burgundy", "soft cream", "classic black"]),
            "feature": "unique details" if category in ["jacket", "coat"] else "perfect fit",
            "metaphor": "a warm hug from an old friend",
            "memory_or_use": "I've worn it to countless memorable occasions."
        }
        
        # Override with actual attributes if available
        if style_attributes:
            if colors := style_attributes.get("colors"):
                subs["color"] = colors[0] if colors else subs["color"]
        
        if provenance:
            if materials := provenance.get("materials"):
                subs["fabric"] = materials[0] if materials else subs["fabric"]
        
        try:
            story = template.format(**subs)
        except KeyError:
            # Fallback if template has missing keys
            story = f"A {subs['adjective']} {category} perfect for {subs['occasion']}."
        
        return story
    
    def _detect_mood(self, text: str) -> str:
        """Detect the emotional mood of a story."""
        positive_words = ["love", "favorite", "beautiful", "perfect", "amazing", "wonderful"]
        nostalgic_words = ["remember", "memories", "used to", "when I", "back then"]
        excited_words = ["excited", "can't wait", "looking forward", "new"]
        
        text_lower = text.lower()
        
        scores = {
            "nostalgic": sum(1 for w in nostalgic_words if w in text_lower),
            "excited": sum(1 for w in excited_words if w in text_lower),
            "appreciative": sum(1 for w in positive_words if w in text_lower)
        }
        
        if not any(scores.values()):
            return "neutral"
        
        return max(scores, key=scores.get)
    
    def _generate_enhanced_version(
        self,
        original: str,
        category: str,
        style_attributes: Optional[Dict[str, Any]],
        mood: str
    ) -> str:
        """Generate an AI-enhanced version of the story."""
        # For now, return original with a creative closing
        closings = {
            "nostalgic": f" This {category} holds a special place in my wardrobe and my heart.",
            "excited": f" I can't wait to create more memories with this {category}!",
            "appreciative": f" I'm grateful to have found such a perfect {category}.",
            "neutral": f" It's become an essential part of my collection."
        }
        
        enhanced = original.strip()
        if not enhanced.endswith("."):
            enhanced += "."
        
        # Only add closing if story is short
        if len(original.split()) < 50:
            enhanced += closings.get(mood, closings["neutral"])
        
        return enhanced
    
    def _calculate_readability(self, text: str) -> Dict[str, Any]:
        """Calculate basic readability metrics."""
        sentences = max(1, text.count(".") + text.count("!") + text.count("?"))
        words = len(text.split())
        
        # Very basic metric
        avg_words_per_sentence = words / sentences
        
        if avg_words_per_sentence < 10:
            level = "easy"
        elif avg_words_per_sentence < 20:
            level = "standard"
        else:
            level = "complex"
        
        return {
            "average_words_per_sentence": round(avg_words_per_sentence, 1),
            "total_words": words,
            "total_sentences": sentences,
            "reading_level": level
        }
    
    def suggest_story_elements(
        self,
        category: str,
        current_story: Optional[str] = None
    ) -> List[Dict[str, str]]:
        """
        Suggest story elements the user might want to add.
        
        Args:
            category: Garment category
            current_story: Existing story text
            
        Returns:
            List of suggested elements with prompts
        """
        suggestions = []
        
        # Category-specific suggestions
        category_suggestions = {
            "dress": [
                {"type": "occasion", "prompt": "What special events have you worn this to?"},
                {"type": "feeling", "prompt": "How do you feel when you put it on?"},
            ],
            "jacket": [
                {"type": "adventure", "prompt": "Where has this jacket traveled with you?"},
                {"type": "weather", "prompt": "What kind of days do you reach for it?"},
            ],
            "shoes": [
                {"type": "comfort", "prompt": "How do they feel after a long day?"},
                {"type": "journeys", "prompt": "What places have these shoes taken you?"},
            ]
        }
        
        suggestions.extend(category_suggestions.get(category, [
            {"type": "memory", "prompt": "What memories do you have while wearing this?"},
            {"type": "style", "prompt": "How do you like to style this piece?"},
        ]))
        
        # Filter out already covered topics
        if current_story:
            current_lower = current_story.lower()
            suggestions = [
                s for s in suggestions 
                if s["type"] not in current_lower
            ]
        
        return suggestions[:3]  # Return top 3


# Global service instance
story_ai_service = StoryAIService()
