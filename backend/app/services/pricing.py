"""
Pricing Service

Intelligent pricing recommendations for garments based on:
- Market data and comparable items
- Condition and provenance
- Brand value and rarity
- Sustainability factors
"""

from decimal import Decimal, ROUND_HALF_UP
from typing import Optional, Dict, Any, List
from dataclasses import dataclass
import logging

logger = logging.getLogger(__name__)


@dataclass
class PricingFactors:
    """Factors influencing garment pricing."""
    base_value: Decimal
    condition_multiplier: Decimal
    brand_multiplier: Decimal
    sustainability_bonus: Decimal
    rarity_multiplier: Decimal
    demand_adjustment: Decimal


class PricingService:
    """
    Service for calculating and recommending garment prices.
    
    Uses a multi-factor algorithm to estimate fair market value
    for secondhand fashion items.
    """
    
    # Condition multipliers (percentage of original value)
    CONDITION_MULTIPLIERS = {
        "new": Decimal("0.85"),
        "excellent": Decimal("0.70"),
        "good": Decimal("0.50"),
        "fair": Decimal("0.30"),
    }
    
    # Brand tier multipliers (relative to generic pricing)
    BRAND_TIERS = {
        # Luxury tier
        "gucci": Decimal("2.5"),
        "prada": Decimal("2.5"),
        "chanel": Decimal("3.0"),
        "hermes": Decimal("3.5"),
        "louis vuitton": Decimal("2.5"),
        
        # Premium tier
        "theory": Decimal("1.5"),
        "cos": Decimal("1.3"),
        "everlane": Decimal("1.2"),
        "reformation": Decimal("1.4"),
        "patagonia": Decimal("1.4"),
        "eileen fisher": Decimal("1.4"),
        
        # Mid-tier
        "j.crew": Decimal("1.1"),
        "banana republic": Decimal("1.0"),
        "zara": Decimal("0.8"),
        "h&m": Decimal("0.6"),
        "uniqlo": Decimal("0.9"),
        "madewell": Decimal("1.2"),
        
        # Sustainable/ethical brands get a boost
        "organic basics": Decimal("1.3"),
        "tentree": Decimal("1.3"),
        "kotn": Decimal("1.3"),
        "pact": Decimal("1.2"),
        "kuyichi": Decimal("1.2"),
    }
    
    # Category base prices (estimated original retail)
    CATEGORY_BASE_PRICES = {
        "dress": Decimal("120.00"),
        "shirt": Decimal("60.00"),
        "blouse": Decimal("70.00"),
        "t-shirt": Decimal("35.00"),
        "pants": Decimal("80.00"),
        "jeans": Decimal("90.00"),
        "skirt": Decimal("65.00"),
        "jacket": Decimal("150.00"),
        "coat": Decimal("200.00"),
        "sweater": Decimal("85.00"),
        "cardigan": Decimal("75.00"),
        "shorts": Decimal("45.00"),
        "activewear": Decimal("70.00"),
        "swimwear": Decimal("60.00"),
        "accessory": Decimal("50.00"),
        "shoes": Decimal("100.00"),
        "bag": Decimal("150.00"),
    }
    
    @classmethod
    def estimate_price(
        cls,
        category: str,
        condition: str,
        brand: Optional[str] = None,
        provenance: Optional[Dict[str, Any]] = None,
        original_price: Optional[Decimal] = None
    ) -> Dict[str, Any]:
        """
        Estimate recommended price for a garment.
        
        Args:
            category: Garment category
            condition: Physical condition
            brand: Brand name
            provenance: Provenance data for sustainability bonuses
            original_price: Known original retail price
            
        Returns:
            Dict with recommended price and breakdown
        """
        # Determine base value
        if original_price:
            base_value = original_price
        else:
            base_value = cls.CATEGORY_BASE_PRICES.get(
                category.lower(),
                Decimal("75.00")  # Default fallback
            )
        
        # Apply condition multiplier
        condition_mult = cls.CONDITION_MULTIPLIERS.get(
            condition.lower(),
            Decimal("0.40")  # Default for unknown conditions
        )
        
        # Apply brand multiplier
        brand_mult = Decimal("1.0")
        if brand:
            brand_key = brand.lower().strip()
            brand_mult = cls.BRAND_TIERS.get(brand_key, Decimal("1.0"))
        
        # Calculate sustainability bonus
        sustainability_bonus = cls._calculate_sustainability_bonus(provenance)
        
        # Rarity adjustment (placeholder for future ML model)
        rarity_mult = Decimal("1.0")
        
        # Calculate final price
        adjusted_base = base_value * condition_mult * brand_mult * rarity_mult
        final_price = adjusted_base + sustainability_bonus
        
        # Round to nearest dollar
        final_price = final_price.quantize(Decimal("1.00"), rounding=ROUND_HALF_UP)
        
        # Ensure minimum price
        final_price = max(final_price, Decimal("5.00"))
        
        # Calculate price range (±20%)
        min_price = (final_price * Decimal("0.8")).quantize(Decimal("1.00"))
        max_price = (final_price * Decimal("1.2")).quantize(Decimal("1.00"))
        
        return {
            "recommended_price": final_price,
            "price_range": {
                "min": min_price,
                "max": max_price
            },
            "factors": {
                "base_value": base_value,
                "condition_multiplier": condition_mult,
                "brand_multiplier": brand_mult,
                "sustainability_bonus": sustainability_bonus,
                "rarity_multiplier": rarity_mult
            },
            "confidence": cls._calculate_confidence(category, brand, original_price),
            "explanation": cls._generate_explanation(
                category, condition, brand, provenance, final_price
            )
        }
    
    @classmethod
    def _calculate_sustainability_bonus(
        cls,
        provenance: Optional[Dict[str, Any]]
    ) -> Decimal:
        """Calculate price bonus for sustainable attributes."""
        if not provenance:
            return Decimal("0.00")
        
        bonus = Decimal("0.00")
        
        # Secondhand/vintage premium (people pay more for unique items)
        source = provenance.get("source", "").lower()
        if source in ["vintage", "antique", "designer archive"]:
            bonus += Decimal("15.00")
        elif source in ["secondhand", "consignment"]:
            bonus += Decimal("5.00")
        
        # Sustainable materials bonus
        materials = provenance.get("materials", [])
        sustainable_materials = [
            "organic cotton", "hemp", "linen", "tencel", "lyocell",
            "recycled polyester", "recycled nylon", "bamboo",
            "peace silk", "alpaca", "merino wool"
        ]
        
        for material in materials:
            if any(sus in material.lower() for sus in sustainable_materials):
                bonus += Decimal("5.00")
                break  # Only count once
        
        # Certifications bonus
        certs = provenance.get("certifications", [])
        cert_bonus_map = {
            "gots": Decimal("10.00"),      # Global Organic Textile Standard
            "fair trade": Decimal("10.00"),
            "b corp": Decimal("8.00"),
            "bluesign": Decimal("8.00"),
            "oeko-tex": Decimal("5.00"),
            "cradle to cradle": Decimal("10.00"),
        }
        
        for cert in certs:
            cert_lower = cert.lower()
            for cert_name, cert_value in cert_bonus_map.items():
                if cert_name in cert_lower:
                    bonus += cert_value
                    break
        
        return min(bonus, Decimal("50.00"))  # Cap at $50 bonus
    
    @classmethod
    def _calculate_confidence(
        cls,
        category: str,
        brand: Optional[str],
        original_price: Optional[Decimal]
    ) -> str:
        """Calculate confidence level in price estimate."""
        score = 0
        
        # Known category
        if category.lower() in cls.CATEGORY_BASE_PRICES:
            score += 1
        
        # Known brand
        if brand and brand.lower() in cls.BRAND_TIERS:
            score += 2
        
        # Known original price
        if original_price:
            score += 2
        
        if score >= 4:
            return "high"
        elif score >= 2:
            return "medium"
        else:
            return "low"
    
    @classmethod
    def _generate_explanation(
        cls,
        category: str,
        condition: str,
        brand: Optional[str],
        provenance: Optional[Dict[str, Any]],
        final_price: Decimal
    ) -> str:
        """Generate human-readable pricing explanation."""
        parts = []
        
        parts.append(f"Based on {category} category pricing")
        
        if brand:
            parts.append(f"with {brand} brand value")
        
        parts.append(f"adjusted for {condition} condition")
        
        if provenance:
            source = provenance.get("source")
            if source:
                parts.append(f"as a {source} item")
            
            certs = provenance.get("certifications", [])
            if certs:
                parts.append(f"with {', '.join(certs[:2])} certification")
        
        return " ".join(parts) + f". Estimated fair value: ${final_price}"
    
    @classmethod
    def get_comparable_listings(
        cls,
        category: str,
        brand: Optional[str] = None,
        condition: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Get comparable market listings (placeholder for future integration).
        
        In production, this would query external marketplaces
        like TheRealReal, Poshmark, ThredUp for actual comps.
        """
        # Placeholder implementation
        base_price = cls.CATEGORY_BASE_PRICES.get(category.lower(), Decimal("75.00"))
        
        return [
            {
                "platform": "Example Marketplace",
                "price": float(base_price * Decimal("0.8")),
                "condition": condition or "good",
                "url": "#"
            }
        ]


# Global service instance
pricing_service = PricingService()
