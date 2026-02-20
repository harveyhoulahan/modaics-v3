"""
Style Matching Service

AI-powered style matching using CLIP embeddings for visual and text similarity.
Supports image-to-image, text-to-image, and hybrid search.
"""

import os
import asyncio
from typing import List, Optional, Dict, Any, Tuple
from functools import lru_cache
import logging

import torch
import numpy as np
from PIL import Image
from transformers import CLIPProcessor, CLIPModel

from app.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()


class StyleMatchingService:
    """
    Service for generating and comparing style embeddings.
    
    Uses OpenAI's CLIP model to create 512-dimensional embeddings
    that capture both visual and semantic garment characteristics.
    """
    
    _instance = None
    _lock = asyncio.Lock()
    
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
        self.device: str = settings.CLIP_DEVICE
        self.model_name: str = settings.CLIP_MODEL_NAME
        self.cache_dir: str = settings.MODEL_CACHE_DIR
        
        # Ensure cache directory exists
        os.makedirs(self.cache_dir, exist_ok=True)
        
        self._initialized = True
    
    async def initialize(self) -> None:
        """Load the CLIP model asynchronously."""
        if self.model is not None:
            return
        
        async with self._lock:
            if self.model is not None:
                return
            
            logger.info(f"Loading CLIP model: {self.model_name}")
            
            try:
                # Run model loading in thread pool to avoid blocking
                loop = asyncio.get_event_loop()
                self.model, self.processor = await loop.run_in_executor(
                    None, self._load_model_sync
                )
                logger.info("CLIP model loaded successfully")
            except Exception as e:
                logger.error(f"Failed to load CLIP model: {e}")
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
    
    async def generate_text_embedding(self, text: str) -> List[float]:
        """
        Generate embedding from text description.
        
        Args:
            text: Text description of style/garment
            
        Returns:
            512-dimensional embedding vector
        """
        await self.initialize()
        
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(
            None, self._generate_text_embedding_sync, text
        )
    
    def _generate_text_embedding_sync(self, text: str) -> List[float]:
        """Synchronous text embedding generation."""
        inputs = self.processor(
            text=[text],
            return_tensors="pt",
            padding=True,
            truncation=True,
            max_length=77
        ).to(self.device)
        
        with torch.no_grad():
            text_features = self.model.get_text_features(**inputs)
            # Normalize embeddings for cosine similarity
            text_features = text_features / text_features.norm(dim=-1, keepdim=True)
        
        return text_features.cpu().numpy()[0].tolist()
    
    async def generate_image_embedding(self, image_path: str) -> List[float]:
        """
        Generate embedding from image file.
        
        Args:
            image_path: Path to image file
            
        Returns:
            512-dimensional embedding vector
        """
        await self.initialize()
        
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(
            None, self._generate_image_embedding_sync, image_path
        )
    
    def _generate_image_embedding_sync(self, image_path: str) -> List[float]:
        """Synchronous image embedding generation."""
        image = Image.open(image_path).convert("RGB")
        
        inputs = self.processor(
            images=image,
            return_tensors="pt"
        ).to(self.device)
        
        with torch.no_grad():
            image_features = self.model.get_image_features(**inputs)
            # Normalize embeddings
            image_features = image_features / image_features.norm(dim=-1, keepdim=True)
        
        return image_features.cpu().numpy()[0].tolist()
    
    async def generate_garment_embedding(
        self,
        text: Optional[str] = None,
        image_path: Optional[str] = None,
        style_attributes: Optional[Dict[str, Any]] = None
    ) -> List[float]:
        """
        Generate comprehensive embedding for a garment.
        
        Combines text description, image, and structured attributes
        into a single embedding vector.
        
        Args:
            text: Description/story text
            image_path: Path to garment image
            style_attributes: Structured style data (colors, patterns, etc.)
            
        Returns:
            512-dimensional embedding vector
        """
        await self.initialize()
        
        # Build rich text description from all sources
        descriptions = []
        
        if text:
            descriptions.append(text)
        
        if style_attributes:
            attr_parts = []
            if colors := style_attributes.get("colors"):
                attr_parts.append(f"colors: {', '.join(colors)}")
            if patterns := style_attributes.get("patterns"):
                attr_parts.append(f"patterns: {', '.join(patterns)}")
            if tags := style_attributes.get("style_tags"):
                attr_parts.append(f"style: {', '.join(tags)}")
            if season := style_attributes.get("season"):
                attr_parts.append(f"season: {season}")
            
            if attr_parts:
                descriptions.append("A garment with " + ", ".join(attr_parts))
        
        combined_text = " ".join(descriptions) if descriptions else "a garment"
        
        # If we have an image, combine text and image embeddings
        if image_path:
            text_emb = await self.generate_text_embedding(combined_text)
            img_emb = await self.generate_image_embedding(image_path)
            
            # Average the embeddings
            combined = np.array([(text_emb[i] + img_emb[i]) / 2 for i in range(len(text_emb))])
            # Re-normalize
            combined = combined / np.linalg.norm(combined)
            return combined.tolist()
        
        # Text-only embedding
        return await self.generate_text_embedding(combined_text)
    
    def calculate_similarity(self, embedding1: List[float], embedding2: List[float]) -> float:
        """
        Calculate cosine similarity between two embeddings.
        
        Args:
            embedding1: First embedding vector
            embedding2: Second embedding vector
            
        Returns:
            Similarity score between 0 and 1
        """
        vec1 = np.array(embedding1)
        vec2 = np.array(embedding2)
        
        # Cosine similarity
        similarity = np.dot(vec1, vec2) / (np.linalg.norm(vec1) * np.linalg.norm(vec2))
        
        # Convert to 0-1 range (CLIP embeddings are already normalized, so this is safe)
        return float(max(0.0, min(1.0, similarity)))
    
    def find_similar_items(
        self,
        query_embedding: List[float],
        candidate_embeddings: List[Tuple[str, List[float]]],
        top_k: int = 10,
        threshold: float = 0.5
    ) -> List[Tuple[str, float]]:
        """
        Find most similar items from candidates.
        
        Args:
            query_embedding: Query vector
            candidate_embeddings: List of (id, embedding) tuples
            top_k: Number of results to return
            threshold: Minimum similarity threshold
            
        Returns:
            List of (id, similarity_score) tuples, sorted by similarity
        """
        similarities = []
        
        for item_id, emb in candidate_embeddings:
            sim = self.calculate_similarity(query_embedding, emb)
            if sim >= threshold:
                similarities.append((item_id, sim))
        
        # Sort by similarity (descending) and return top_k
        similarities.sort(key=lambda x: x[1], reverse=True)
        return similarities[:top_k]
    
    def generate_match_reasons(
        self,
        query_attrs: Dict[str, Any],
        match_attrs: Dict[str, Any]
    ) -> List[str]:
        """
        Generate human-readable reasons for why items match.
        
        Args:
            query_attrs: Query garment attributes
            match_attrs: Matched garment attributes
            
        Returns:
            List of match reason strings
        """
        reasons = []
        
        query_style = query_attrs.get("style_attributes", {}) or {}
        match_style = match_attrs.get("style_attributes", {}) or {}
        
        # Check color overlap
        query_colors = set(query_style.get("colors", []))
        match_colors = set(match_style.get("colors", []))
        if color_overlap := query_colors & match_colors:
            reasons.append(f"Shared colors: {', '.join(color_overlap)}")
        
        # Check style tag overlap
        query_tags = set(query_style.get("style_tags", []))
        match_tags = set(match_style.get("style_tags", []))
        if tag_overlap := query_tags & match_tags:
            reasons.append(f"Similar style: {', '.join(tag_overlap)}")
        
        # Check category match
        if query_attrs.get("category") == match_attrs.get("category"):
            reasons.append(f"Same category: {match_attrs.get('category')}")
        
        # Check condition
        query_condition = query_attrs.get("condition")
        match_condition = match_attrs.get("condition")
        if query_condition and match_condition:
            condition_rank = {"new": 4, "excellent": 3, "good": 2, "fair": 1}
            if condition_rank.get(match_condition, 0) >= condition_rank.get(query_condition, 0):
                reasons.append(f"Great condition: {match_condition}")
        
        return reasons if reasons else ["Style compatibility match"]


# Global service instance
style_matching_service = StyleMatchingService()
