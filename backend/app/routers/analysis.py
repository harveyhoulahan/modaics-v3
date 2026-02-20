"""
Garment Analysis Router

AI-powered image analysis endpoint for Smart Create flow.
Analyzes garment images to extract: category, color, material, condition, style.
"""

import uuid
import io
from typing import Optional, List
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession
from PIL import Image

from app.database import get_db_session
from app.models.user import User
from app.services.fashion_clip import get_fashion_clip_service
from app.services.color_extractor import color_extractor
from app.services.condition_grader import condition_grader

router = APIRouter(prefix="/api/analyze", tags=["analysis"])


# ============== Response Schemas ==============

class AttributePrediction(BaseModel):
    """Single attribute prediction with confidence."""
    label: str = Field(..., description="Predicted label")
    confidence: float = Field(..., ge=0, le=1, description="Confidence score")


class ConditionGradeResult(BaseModel):
    """Condition grading result."""
    grade: str = Field(..., description="A-F grade")
    label: str = Field(..., description="Human-readable label")
    confidence: float = Field(..., ge=0, le=1)
    description: str
    sell_multiplier: float
    recommendation: str
    defects_detected: List[dict]


class ExtractedColor(BaseModel):
    """Extracted color from image."""
    name: str
    hex: str
    rgb: List[int]
    percentage: float
    is_dominant: bool


class EstimatedPrice(BaseModel):
    """Price estimation result."""
    min: Decimal
    max: Decimal
    currency: str = "AUD"
    confidence: str


class GarmentAnalysisResponse(BaseModel):
    """Full garment analysis response."""
    category: List[AttributePrediction]
    color: List[AttributePrediction]
    material: List[AttributePrediction]
    condition: List[AttributePrediction]
    style: List[AttributePrediction]
    detected_colors: List[ExtractedColor]
    condition_grade: ConditionGradeResult
    embedding: List[float] = Field(..., description="512-dimensional FashionCLIP embedding")
    estimated_price: EstimatedPrice
    sustainability_score: int = Field(..., ge=0, le=100)
    suggestions: List[str]


class BatchAnalysisResponse(BaseModel):
    """Batch analysis response for multiple images."""
    individual_results: List[dict]
    aggregated: dict
    image_count: int


# ============== Helper Functions ==============

def estimate_price(category: str, condition: str, materials: List[str]) -> EstimatedPrice:
    """Estimate price range based on garment attributes."""
    base_prices = {
        "dress": 85, "jacket": 120, "coat": 150, "sweater": 65,
        "shirt": 45, "jeans": 55, "shoes": 75, "bag": 95,
        "t-shirt": 35, "blouse": 55, "skirt": 50, "trousers": 60,
        "shorts": 35, "hoodie": 50, "cardigan": 55, "suit": 200,
        "vest": 45, "swimsuit": 40, "jumpsuit": 75, "scarf": 30,
        "hat": 25, "belt": 30, "handbag": 85
    }
    
    condition_multipliers = {"A": 1.0, "B": 0.75, "C": 0.5, "D": 0.25, "F": 0.0}
    
    base = base_prices.get(category.lower().replace("a ", "").replace("an ", ""), 50)
    multiplier = condition_multipliers.get(condition, 0.5)
    
    # Material premium
    sustainable_materials = ["silk", "cashmere", "organic cotton", "linen", "wool"]
    material_bonus = 1.0
    for material in materials:
        if any(sm in material.lower() for sm in sustainable_materials):
            material_bonus = 1.15
            break
    
    estimated = base * multiplier * material_bonus
    
    return EstimatedPrice(
        min=Decimal(str(round(estimated * 0.7, 2))),
        max=Decimal(str(round(estimated * 1.3, 2))),
        currency="AUD",
        confidence="medium" if condition in ("B", "C") else "high"
    )


def calculate_sustainability_score(materials: List[dict], condition: str) -> int:
    """Calculate sustainability score (0-100)."""
    score = 50  # Base score
    
    # Material points (max 30)
    sustainable_materials = ["organic cotton", "hemp", "linen", "tencel", 
                            "recycled polyester", "bamboo", "wool", "silk", "cashmere"]
    for material in materials:
        if any(sm in material.get("label", "").lower() for sm in sustainable_materials):
            score += 10
    score = min(score, 80)
    
    # Condition bonus
    condition_points = {"A": 15, "B": 10, "C": 5, "D": 3, "F": 0}
    score += condition_points.get(condition, 0)
    
    return min(score, 100)


def generate_suggestions(classification: dict, condition: dict) -> List[str]:
    """Generate AI suggestions for listing optimization."""
    suggestions = []
    
    category = classification.get("category", [{}])[0].get("label", "") if classification.get("category") else ""
    
    if category in ["dress", "jacket", "coat"]:
        suggestions.append(f"Consider mentioning the {category}'s versatility for different occasions")
    
    grade = condition.get("grade", "C")
    if grade in ["D", "F"]:
        suggestions.append("Be transparent about wear and include detailed photos of any imperfections")
    elif grade == "A":
        suggestions.append("Highlight the excellent condition in your title for faster sales")
    
    materials = [m.get("label", "") for m in classification.get("material", [])]
    if any("wool" in m.lower() or "cashmere" in m.lower() for m in materials):
        suggestions.append("Premium materials like wool/cashmere should be highlighted - mention care instructions")
    
    return suggestions


def aggregate_predictions(results: List[dict]) -> dict:
    """Aggregate predictions from multiple images using weighted voting."""
    from collections import defaultdict
    
    category_votes = defaultdict(float)
    for result in results:
        for cat in result.get("category", []):
            category_votes[cat["label"]] += cat.get("confidence", 0)
    
    total_confidence = sum(category_votes.values())
    if total_confidence > 0:
        aggregated_category = [
            {"label": label, "confidence": round(conf / total_confidence, 3)}
            for label, conf in sorted(category_votes.items(), key=lambda x: x[1], reverse=True)[:3]
        ]
    else:
        aggregated_category = []
    
    return {"category": aggregated_category}


# ============== Endpoints ==============

@router.post("", response_model=GarmentAnalysisResponse)
async def analyze_garment_image(
    file: UploadFile = File(..., description="Garment image to analyze"),
    db: AsyncSession = Depends(get_db_session)
) -> GarmentAnalysisResponse:
    """
    Analyze a garment image using AI.
    
    Returns comprehensive analysis including category, colors, materials, condition,
    style, embedding, price estimate, and sustainability score.
    """
    # Validate file type
    allowed_types = ["image/jpeg", "image/png", "image/webp"]
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid file type. Allowed: {', '.join(allowed_types)}"
        )
    
    # Read and validate image
    image_data = await file.read()
    if len(image_data) > 10 * 1024 * 1024:  # 10MB limit
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image too large. Maximum size: 10MB"
        )
    
    try:
        image = Image.open(io.BytesIO(image_data)).convert("RGB")
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid image file"
        )
    
    # Get services
    clip_service = await get_fashion_clip_service()
    
    # Run AI analysis pipelines in parallel
    classification, colors, condition_result, embedding = await asyncio.gather(
        clip_service.classify_image(image),
        asyncio.to_thread(color_extractor.extract_with_metadata, image),
        condition_grader.grade(image),
        clip_service.encode_image(image)
    )
    
    # Calculate derived values
    category_label = classification["category"][0]["label"] if classification["category"] else "unknown"
    condition_grade = condition_result["grade"]
    materials = [m["label"] for m in classification.get("material", [])]
    
    estimated_price = estimate_price(category_label, condition_grade, materials)
    sustainability_score = calculate_sustainability_score(classification.get("material", []), condition_grade)
    suggestions = generate_suggestions(classification, condition_result)
    
    # Build response
    return GarmentAnalysisResponse(
        category=[AttributePrediction(**item) for item in classification["category"]],
        color=[AttributePrediction(**item) for item in classification["color"]],
        material=[AttributePrediction(**item) for item in classification["material"]],
        condition=[AttributePrediction(**item) for item in classification["condition"]],
        style=[AttributePrediction(**item) for item in classification["style"]],
        detected_colors=[ExtractedColor(**item) for item in colors["colors"]],
        condition_grade=ConditionGradeResult(**condition_result),
        embedding=embedding.tolist(),
        estimated_price=estimated_price,
        sustainability_score=sustainability_score,
        suggestions=suggestions
    )


@router.post("/batch", response_model=BatchAnalysisResponse)
async def analyze_multiple_images(
    files: List[UploadFile] = File(..., description="Multiple garment images"),
    db: AsyncSession = Depends(get_db_session)
) -> BatchAnalysisResponse:
    """
    Analyze multiple images of the same garment for improved accuracy.
    
    Aggregates predictions across all images and returns consensus results
    with confidence-weighted voting.
    """
    if len(files) > 8:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum 8 images allowed per analysis"
        )
    
    clip_service = await get_fashion_clip_service()
    
    results = []
    for file in files:
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data)).convert("RGB")
        classification = await clip_service.classify_image(image)
        results.append(classification)
    
    # Aggregate results
    aggregated = aggregate_predictions(results)
    
    return BatchAnalysisResponse(
        individual_results=results,
        aggregated=aggregated,
        image_count=len(files)
    )


import asyncio
