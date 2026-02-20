"""
Condition Grading Service

Assesses garment condition using CLIP-based zero-shot classification.
Provides A-F grading scale with confidence scores for donation routing.
"""

from typing import Dict, Any, List, Optional
from dataclasses import dataclass

from PIL import Image

from app.services.fashion_clip import FashionCLIPService, get_fashion_clip_service


@dataclass
class ConditionGrade:
    """Represents a condition grade with metadata."""
    grade: str  # A, B, C, D, F
    label: str  # Human-readable label
    confidence: float
    description: str


# Condition grade definitions
CONDITION_GRADES = {
    "A": {
        "label": "Like New",
        "description": "No visible wear, pristine condition",
        "sell_multiplier": 1.0,
        "recommendation": "sell"
    },
    "B": {
        "label": "Excellent",
        "description": "Minor signs of wear, barely noticeable",
        "sell_multiplier": 0.75,
        "recommendation": "sell"
    },
    "C": {
        "label": "Good",
        "description": "Gentle wear visible but overall good condition",
        "sell_multiplier": 0.5,
        "recommendation": "sell"
    },
    "D": {
        "label": "Fair",
        "description": "Visible wear and signs of use",
        "sell_multiplier": 0.25,
        "recommendation": "donate"
    },
    "F": {
        "label": "Worn/Damaged",
        "description": "Significant wear, stains, or damage",
        "sell_multiplier": 0.0,
        "recommendation": "recycle"
    }
}

# Defect detection prompts
DEFECT_PROMPTS = [
    "clothing with visible stains",
    "clothing with holes or tears",
    "clothing with pilling or fuzz",
    "clothing with fading or discoloration",
    "clothing with loose threads",
    "clothing with missing buttons",
    "clothing with zipper problems",
    "clothing in perfect condition",
]


class ConditionGrader:
    """
    Grades garment condition using FashionCLIP zero-shot classification.
    """
    
    def __init__(self, clip_service: Optional[FashionCLIPService] = None):
        self.clip = clip_service
        self.grade_prompts = [
            "brand new clothing with tags",
            "like new clothing in excellent condition",
            "gently used clothing in good condition",
            "visibly worn clothing with signs of use",
            "heavily worn damaged clothing",
        ]
    
    async def initialize(self):
        """Initialize the CLIP service if not already done."""
        if self.clip is None:
            self.clip = await get_fashion_clip_service()
    
    async def grade(self, image: Image.Image) -> Dict[str, Any]:
        """
        Grade garment condition from image.
        
        Returns:
            Dictionary with grade, confidence, defects detected, and recommendations
        """
        await self.initialize()
        
        # Grade classification
        grade_result = await self._classify_grade(image)
        
        # Defect detection
        defects = await self._detect_defects(image)
        
        # Build response
        grade_info = CONDITION_GRADES.get(grade_result["grade"], CONDITION_GRADES["C"])
        
        return {
            "grade": grade_result["grade"],
            "label": grade_info["label"],
            "confidence": grade_result["confidence"],
            "description": grade_info["description"],
            "sell_multiplier": grade_info["sell_multiplier"],
            "recommendation": grade_info["recommendation"],
            "defects_detected": defects,
            "all_grades": grade_result["all_scores"]
        }
    
    async def _classify_grade(self, image: Image.Image) -> Dict[str, Any]:
        """Classify the overall condition grade."""
        # Use FashionCLIP to score each grade prompt
        scores = await self.clip._classify_attribute(image, self.grade_prompts, n=5)
        
        # Map prompts to grades
        grade_map = {
            "brand new": "A",
            "like new": "B",
            "gently used": "C",
            "visibly worn": "D",
            "heavily worn": "F"
        }
        
        # Aggregate scores by grade
        grade_scores = {"A": 0, "B": 0, "C": 0, "D": 0, "F": 0}
        for item in scores:
            for key, grade in grade_map.items():
                if key in item["label"].lower():
                    grade_scores[grade] += item["confidence"]
                    break
        
        # Normalize
        total = sum(grade_scores.values())
        if total > 0:
            grade_scores = {k: round(v / total, 3) for k, v in grade_scores.items()}
        
        # Select best grade
        best_grade = max(grade_scores, key=grade_scores.get)
        
        return {
            "grade": best_grade,
            "confidence": grade_scores[best_grade],
            "all_scores": grade_scores
        }
    
    async def _detect_defects(self, image: Image.Image) -> List[Dict[str, Any]]:
        """Detect specific defects in the garment."""
        scores = await self.clip._classify_attribute(image, DEFECT_PROMPTS, n=len(DEFECT_PROMPTS))
        
        # Filter out "perfect condition" and low-confidence detections
        defects = []
        for item in scores:
            if "perfect" not in item["label"].lower() and item["confidence"] > 0.15:
                defect_type = item["label"].replace("clothing with ", "").replace("visible ", "")
                defects.append({
                    "type": defect_type,
                    "confidence": item["confidence"]
                })
        
        return sorted(defects, key=lambda x: x["confidence"], reverse=True)
    
    def get_routing_recommendation(
        self,
        grade: str,
        brand_tier: Optional[int] = None,
        estimated_price: Optional[float] = None
    ) -> Dict[str, Any]:
        """
        Get sell vs donate vs recycle recommendation.
        
        Args:
            grade: Condition grade (A-F)
            brand_tier: Brand tier (1-5, where 5 is luxury)
            estimated_price: Estimated resale price
            
        Returns:
            Routing recommendation with reasoning
        """
        grade_info = CONDITION_GRADES.get(grade, CONDITION_GRADES["C"])
        
        # Always sell luxury regardless of condition
        if brand_tier == 5:
            return {
                "action": "sell",
                "reason": "premium_brand",
                "message": None,
                "confidence": "high"
            }
        
        # Ultra fast fashion - suggest donation
        if brand_tier == 1:
            return {
                "action": "donate",
                "reason": "ultra_fast_fashion",
                "message": "Items from this brand typically sell for less than shipping costs. Want to give it a second life through donation instead?",
                "confidence": "high"
            }
        
        # Damaged items - recycle
        if grade == "F":
            return {
                "action": "recycle",
                "reason": "damaged",
                "message": "This piece might be past its wearing days — we can help you find textile recycling nearby.",
                "confidence": "high"
            }
        
        # Worn + low brand tier - donate
        if grade == "D" and brand_tier <= 2:
            return {
                "action": "donate",
                "reason": "worn_fast_fashion",
                "message": "This piece could make someone's day! Based on similar items, donating would create more impact than selling.",
                "confidence": "medium"
            }
        
        # Low estimated price - offer choice
        if estimated_price and estimated_price < 15:
            return {
                "action": "choice",
                "reason": "low_value",
                "message": f"Similar items typically sell for ${estimated_price:.0f} AUD. You could list it or donate — either way it stays out of landfill!",
                "confidence": "medium"
            }
        
        # Good condition - sell
        if grade in ("A", "B"):
            return {
                "action": "sell",
                "reason": "good_condition",
                "message": None,
                "confidence": "high"
            }
        
        # Default - sell with discount suggestion
        return {
            "action": "sell_discount",
            "reason": "moderate_condition",
            "message": "This piece shows some wear — consider pricing it competitively for a quick sale.",
            "confidence": "medium"
        }


# Global instance
_condition_grader: Optional[ConditionGrader] = None

async def get_condition_grader() -> ConditionGrader:
    """Get or initialize the condition grader."""
    global _condition_grader
    if _condition_grader is None:
        _condition_grader = ConditionGrader()
        await _condition_grader.initialize()
    return _condition_grader


# Convenience function
condition_grader = ConditionGrader()
