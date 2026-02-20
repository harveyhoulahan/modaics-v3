"""
Color Extraction Service

Extracts dominant colors from garment images using K-Means clustering.
Complements CLIP's semantic color classification with pixel-level analysis.
"""

from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass
from collections import Counter

import numpy as np
from PIL import Image
from sklearn.cluster import KMeans


@dataclass
class ExtractedColor:
    """Represents a single extracted color with metadata."""
    name: str
    hex: str
    rgb: Tuple[int, int, int]
    percentage: float
    is_dominant: bool = False


# Fashion color palette with RGB values
FASHION_COLOR_PALETTE = {
    "Black": (0, 0, 0), "Charcoal": (54, 69, 79), "White": (255, 255, 255),
    "Off-White": (250, 249, 246), "Cream": (255, 253, 208), "Navy": (0, 0, 128),
    "Royal Blue": (65, 105, 225), "Sky Blue": (135, 206, 235),
    "Denim Blue": (21, 96, 189), "Light Blue": (173, 216, 230),
    "Red": (220, 20, 60), "Burgundy": (128, 0, 32), "Coral": (255, 127, 80),
    "Pink": (255, 192, 203), "Hot Pink": (255, 105, 180), "Blush": (222, 93, 131),
    "Forest Green": (34, 139, 34), "Olive": (128, 128, 0), "Sage": (138, 154, 140),
    "Mint": (189, 252, 201), "Emerald": (80, 200, 120), "Teal": (0, 128, 128),
    "Turquoise": (64, 224, 208), "Yellow": (255, 255, 0), "Mustard": (255, 173, 1),
    "Gold": (255, 215, 0), "Orange": (255, 165, 0), "Rust": (183, 65, 14),
    "Terracotta": (226, 114, 91), "Purple": (128, 0, 128), "Lavender": (230, 230, 250),
    "Mauve": (224, 176, 255), "Grey": (128, 128, 128), "Silver": (192, 192, 192),
    "Taupe": (188, 152, 126), "Beige": (245, 245, 220), "Tan": (210, 180, 140),
    "Brown": (139, 69, 19), "Chocolate": (123, 63, 0), "Camel": (193, 154, 107),
}


def rgb_to_hex(rgb: Tuple[int, int, int]) -> str:
    """Convert RGB tuple to hex string."""
    return "#{:02x}{:02x}{:02x}".format(*rgb)


def color_distance(rgb1: Tuple[int, ...], rgb2: Tuple[int, ...]) -> float:
    """
    Calculate weighted color distance accounting for human perception.
    Uses CIE76 color difference formula (simplified).
    """
    r1, g1, b1 = rgb1
    r2, g2, b2 = rgb2
    
    r_mean = (r1 + r2) / 2
    r_diff = r1 - r2
    g_diff = g1 - g2
    b_diff = b1 - b2
    
    return np.sqrt(
        (2 + r_mean / 256) * r_diff ** 2 +
        4 * g_diff ** 2 +
        (2 + (255 - r_mean) / 256) * b_diff ** 2
    )


def find_nearest_fashion_color(rgb: Tuple[int, int, int]) -> Tuple[str, Tuple[int, int, int]]:
    """Find the closest fashion color name for an RGB value."""
    min_distance = float('inf')
    nearest_name = "Unknown"
    nearest_rgb = rgb
    
    for name, ref_rgb in FASHION_COLOR_PALETTE.items():
        dist = color_distance(rgb, ref_rgb)
        if dist < min_distance:
            min_distance = dist
            nearest_name = name
            nearest_rgb = ref_rgb
    
    return nearest_name, nearest_rgb


def is_background_color(rgb: Tuple[int, int, int]) -> bool:
    """Detect if a color is likely background rather than garment."""
    r, g, b = rgb
    brightness = (r + g + b) / 3
    
    if brightness < 20:  # Too dark (shadows)
        return True
    if brightness > 245:  # Too bright (blown out)
        return True
    
    max_val = max(r, g, b)
    min_val = min(r, g, b)
    saturation = (max_val - min_val) / max_val if max_val > 0 else 0
    
    if saturation < 0.05 and brightness > 200:  # Low saturation grayscale
        return True
    
    return False


class ColorExtractor:
    """
    Extract dominant colors from garment images using K-Means clustering.
    """
    
    def __init__(self, n_colors: int = 5, resize_dim: int = 150, min_pixel_threshold: int = 100):
        self.n_colors = n_colors
        self.resize_dim = resize_dim
        self.min_pixel_threshold = min_pixel_threshold
    
    def extract_colors(self, image: Image.Image, remove_background: bool = True) -> List[ExtractedColor]:
        """Extract dominant colors from an image."""
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        image_resized = image.resize((self.resize_dim, self.resize_dim), Image.Resampling.LANCZOS)
        pixels = np.array(image_resized)
        pixels = pixels.reshape(-1, 3)
        
        if remove_background:
            mask = ~np.apply_along_axis(is_background_color, 1, pixels)
            pixels = pixels[mask]
        
        if len(pixels) < self.min_pixel_threshold:
            return [ExtractedColor(
                name="Unknown", hex="#808080", rgb=(128, 128, 128),
                percentage=1.0, is_dominant=True
            )]
        
        n_clusters = min(self.n_colors, len(pixels) // 20)
        n_clusters = max(2, n_clusters)
        
        kmeans = KMeans(n_clusters=n_clusters, n_init=10, max_iter=300, random_state=42, algorithm='lloyd')
        kmeans.fit(pixels)
        
        colors = kmeans.cluster_centers_.astype(int)
        labels = kmeans.labels_
        counts = Counter(labels)
        total_pixels = sum(counts.values())
        
        results = []
        for i, color in enumerate(colors):
            rgb = tuple(int(c) for c in color)
            percentage = counts[i] / total_pixels
            fashion_name, _ = find_nearest_fashion_color(rgb)
            
            results.append(ExtractedColor(
                name=fashion_name,
                hex=rgb_to_hex(rgb),
                rgb=rgb,
                percentage=round(percentage, 3),
                is_dominant=False
            ))
        
        results.sort(key=lambda x: x.percentage, reverse=True)
        if results:
            results[0].is_dominant = True
        
        return results
    
    def extract_with_metadata(self, image: Image.Image) -> Dict:
        """Extract colors with additional metadata for API response."""
        colors = self.extract_colors(image)
        
        diversity = len([c for c in colors if c.percentage > 0.1])
        is_multicolored = diversity >= 2 and colors[0].percentage < 0.6
        
        return {
            "colors": [
                {
                    "name": c.name,
                    "hex": c.hex,
                    "rgb": list(c.rgb),
                    "percentage": c.percentage,
                    "is_dominant": c.is_dominant
                }
                for c in colors
            ],
            "dominant_color": {
                "name": colors[0].name,
                "hex": colors[0].hex,
                "rgb": list(colors[0].rgb)
            } if colors else None,
            "color_count": len(colors),
            "is_multicolored": is_multicolored,
            "color_diversity_score": diversity,
        }


# Convenience function
def extract_dominant_colors(image: Image.Image, n_colors: int = 3) -> List[Dict]:
    """Quick color extraction with default settings."""
    extractor = ColorExtractor(n_colors=n_colors)
    result = extractor.extract_with_metadata(image)
    return result["colors"][:n_colors]


# Global instance
color_extractor = ColorExtractor()
