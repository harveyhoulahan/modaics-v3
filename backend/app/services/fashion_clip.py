"""
FashionCLIP Service

Marqo-FashionCLIP model integration for fashion-specific embeddings.
Replaces generic CLIP with fashion-optimized model (57% better accuracy).
"""

import os
import asyncio
from typing import List, Optional, Dict, Any, Tuple
import logging

import torch
import numpy as np
from PIL import Image
from transformers import CLIPModel, CLIPProcessor

from app.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()


class FashionCLIPService:
    """
    Singleton service for FashionCLIP embeddings.
    
    Uses Marqo-FashionCLIP for fashion-specific visual and text embeddings.
    512-dimensional vectors compatible with existing pgvector schema.
    """
    
    _instance = None
    _lock = asyncio.Lock()
    
    # Zero-shot classification prompt libraries
    CATEGORY_PROMPTS = [
        "a photo of a t-shirt", "a photo of a dress", "a photo of a jacket", "a photo of jeans",
        "a photo of a skirt", "a photo of a sweater", "a photo of a coat", "a photo of a blouse",
        "a photo of shorts", "a photo of a hoodie", "a photo of trousers", "a photo of a suit",
        "a photo of a cardigan", "a photo of sneakers", "a photo of boots", "a photo of high heels",
        "a photo of a handbag", "a photo of a scarf", "a photo of a hat", "a photo of a belt",
        "a photo of a swimsuit", "a photo of a jumpsuit", "a photo of a vest", "a photo of sandals",
        "a photo of an athletic top", "a photo of athletic leggings", "a photo of a denim jacket",
    ]
    
    COLOR_PROMPTS = [
        "black colored clothing", "white colored clothing", "navy blue colored clothing",
        "red colored clothing", "green colored clothing", "grey colored clothing",
        "beige colored clothing", "brown colored clothing", "pink colored clothing",
        "yellow colored clothing", "orange colored clothing", "purple colored clothing",
        "olive colored clothing", "cream colored clothing", "burgundy colored clothing",
        "teal colored clothing", "multicolored clothing with multiple colors",
    ]
    
    MATERIAL_PROMPTS = [
        "clothing made of cotton fabric", "clothing made of denim fabric", "clothing made of leather material",
        "clothing made of wool fabric", "clothing made of silk fabric", "clothing made of polyester fabric",
        "clothing made of linen fabric", "clothing made of cashmere fabric", "clothing made of velvet fabric",
        "clothing made of suede material", "clothing made of nylon fabric", "clothing made of knitted fabric",
        "clothing made of chiffon fabric", "clothing made of corduroy fabric", "clothing made of tweed fabric",
    ]
    
    CONDITION_PROMPTS = [
        "brand new clothing with tags", "like new clothing in excellent condition",
        "gently used clothing in good condition", "visibly worn clothing with signs of use",
        "heavily worn damaged clothing",
    ]
    
    STYLE_PROMPTS = [
        "minimalist style", "vintage retro style", "streetwear style", "bohemian style",
        "classic preppy style", "athleisure style", "avant-garde fashion", "casual everyday wear",
        "formal wear", "workwear professional", "grunge style", "cottagecore style",
    ]
    
    def __new__(cls):
        """Singleton pattern to avoid loading model multiple times."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialized = False
        return cls._instance
    
    def __init__(self):
        if self._initialized:
            return
        
        self.model: Optional[CLIPModel] = None
        self.processor: Optional[CLIPProcessor] = None
        self.device: str = settings.CLIP_DEVICE if hasattr(settings, 'CLIP_DEVICE') else ('cuda' if torch.cuda.is_available() else 'cpu')
        self.model_name: str = "Marqo/marqo-fashionCLIP"
        self.cache_dir: str = getattr(settings, 'MODEL_CACHE_DIR', './model_cache')
        self.embedding_dim: int = 512
        
        os.makedirs(self.cache_dir, exist_ok=True)
        self._initialized = True
    
    async def initialize(self) -> None:
        """Load the FashionCLIP model asynchronously."""
        if self.model is not None:
            return
        
        async with self._lock:
            if self.model is not None:
                return
            
            logger.info(f"Loading FashionCLIP model: {self.model_name}")
            
            try:
                loop = asyncio.get_event_loop()
                self.model, self.processor = await loop.run_in_executor(
                    None, self._load_model_sync
                )
                logger.info("FashionCLIP model loaded successfully")
            except Exception as e:
                logger.error(f"Failed to load FashionCLIP model: {e}")
                raise
    
    def _load_model_sync(self) -> Tuple[CLIPModel, CLIPProcessor]:
        """Synchronous model loading (runs in thread pool)."""
        model = CLIPModel.from_pretrained(
            self.model_name,
            cache_dir=self.cache_dir
        )
        processor = CLIPProcessor.from_pretrained(
            self.model_name,
            cache_dir=self.cache_dir
        )
        
        model.to(self.device)
        model.eval()
        
        return model, processor
    
    async def encode_image(self, image: Image.Image) -> np.ndarray:
        """Generate embedding from PIL Image."""
        await self.initialize()
        
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, self._encode_image_sync, image)
    
    def _encode_image_sync(self, image: Image.Image) -> np.ndarray:
        """Synchronous image encoding."""
        inputs = self.processor(images=image, return_tensors="pt").to(self.device)
        
        with torch.no_grad():
            image_features = self.model.get_image_features(**inputs)
            image_features = image_features / image_features.norm(dim=-1, keepdim=True)
        
        return image_features.cpu().numpy().flatten()
    
    async def encode_text(self, text: str) -> np.ndarray:
        """Generate embedding from text description."""
        await self.initialize()
        
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, self._encode_text_sync, text)
    
    def _encode_text_sync(self, text: str) -> np.ndarray:
        """Synchronous text encoding."""
        inputs = self.processor(
            text=[text],
            return_tensors="pt",
            padding=True,
            truncation=True,
            max_length=77
        ).to(self.device)
        
        with torch.no_grad():
            text_features = self.model.get_text_features(**inputs)
            text_features = text_features / text_features.norm(dim=-1, keepdim=True)
        
        return text_features.cpu().numpy().flatten()
    
    async def classify_image(self, image: Image.Image) -> Dict[str, Any]:
        """Multi-attribute zero-shot classification."""
        await self.initialize()
        
        results = await asyncio.gather(
            self._classify_attribute(image, self.CATEGORY_PROMPTS, n=3),
            self._classify_attribute(image, self.COLOR_PROMPTS, n=3),
            self._classify_attribute(image, self.MATERIAL_PROMPTS, n=2),
            self._classify_attribute(image, self.CONDITION_PROMPTS, n=1),
            self._classify_attribute(image, self.STYLE_PROMPTS, n=2),
        )
        
        return {
            "category": results[0],
            "color": results[1],
            "material": results[2],
            "condition": results[3],
            "style": results[4],
        }
    
    async def _classify_attribute(self, image: Image.Image, prompts: List[str], n: int = 1) -> List[Dict[str, Any]]:
        """Classify image against a set of text prompts."""
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, self._classify_attribute_sync, image, prompts, n)
    
    def _classify_attribute_sync(self, image: Image.Image, prompts: List[str], n: int) -> List[Dict[str, Any]]:
        """Synchronous classification."""
        inputs = self.processor(text=prompts, images=image, return_tensors="pt", padding=True).to(self.device)
        
        with torch.no_grad():
            outputs = self.model(**inputs)
            logits = outputs.logits_per_image.softmax(dim=1)
        
        scores = {prompt: float(logits[0][i]) for i, prompt in enumerate(prompts)}
        sorted_scores = sorted(scores.items(), key=lambda x: x[1], reverse=True)
        
        return [
            {"label": self._clean_label(label), "confidence": round(conf, 3)}
            for label, conf in sorted_scores[:n]
        ]
    
    def _clean_label(self, prompt: str) -> str:
        """Clean prompt text to get readable label."""
        for prefix in ["a pair of ", "a ", "an "]:
            if prompt.startswith(prefix):
                prompt = prompt[len(prefix):]
        return (prompt.replace(" clothing", "").replace(" fabric", "").replace(" material", "").replace(" style", ""))
    
    def calculate_similarity(self, embedding1: np.ndarray, embedding2: np.ndarray) -> float:
        """Calculate cosine similarity between two embeddings."""
        return float(np.dot(embedding1, embedding2))
    
    async def batch_encode_images(self, images: List[Image.Image]) -> np.ndarray:
        """Batch encode multiple images efficiently."""
        await self.initialize()
        
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, self._batch_encode_images_sync, images)
    
    def _batch_encode_images_sync(self, images: List[Image.Image]) -> np.ndarray:
        """Synchronous batch encoding."""
        inputs = self.processor(images=images, return_tensors="pt", padding=True).to(self.device)
        
        with torch.no_grad():
            image_features = self.model.get_image_features(**inputs)
            image_features = image_features / image_features.norm(dim=-1, keepdim=True)
        
        return image_features.cpu().numpy()


# Global singleton instance
_fashion_clip_service: Optional[FashionCLIPService] = None

async def get_fashion_clip_service() -> FashionCLIPService:
    """Get or initialize the FashionCLIP service singleton."""
    global _fashion_clip_service
    if _fashion_clip_service is None:
        _fashion_clip_service = FashionCLIPService()
        await _fashion_clip_service.initialize()
    return _fashion_clip_service
