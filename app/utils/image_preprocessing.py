# app/utils/image_preprocessing.py

import logging
import numpy as np
from PIL import Image
from io import BytesIO

logger = logging.getLogger(__name__)

# ── Constants ──────────────────────────────────────────────────
IMG_SIZE = (224, 224)  # Standard input size for MobileNet / ResNet
MEAN = [0.485, 0.456, 0.406]  # ImageNet mean values
STD  = [0.229, 0.224, 0.225]  # ImageNet std values


def load_image_from_bytes(image_bytes: bytes) -> Image.Image:
    """
    Converts raw bytes received from Flutter into a PIL Image.
    """
    try:
        image = Image.open(BytesIO(image_bytes))
        logger.info(f"Image loaded successfully | Original size: {image.size} | Mode: {image.mode}")
        return image
    except Exception as e:
        logger.error(f"Failed to load image: {e}")
        raise ValueError(f"Invalid image file: {e}")


def preprocess_image(image: Image.Image) -> np.ndarray:
    """
    Full preprocessing pipeline:
    1. Convert to RGB (handles PNG with alpha channel too)
    2. Resize to 224x224
    3. Normalize using ImageNet mean and std
    4. Return as NumPy array ready for model input
    """
    try:
        # Step 1 — Convert to RGB
        if image.mode != "RGB":
            image = image.convert("RGB")
            logger.info("Image converted to RGB")

        # Step 2 — Resize
        image = image.resize(IMG_SIZE)
        logger.info(f"Image resized to {IMG_SIZE}")

        # Step 3 — Convert to numpy array and scale to [0, 1]
        img_array = np.array(image, dtype=np.float32) / 255.0

        # Step 4 — Normalize using ImageNet mean and std
        img_array = (img_array - np.array(MEAN)) / np.array(STD)

        # Step 5 — Reshape to (1, 3, 224, 224) for PyTorch (batch, channel, H, W)
        img_array = np.transpose(img_array, (2, 0, 1))  # HWC → CHW
        img_array = np.expand_dims(img_array, axis=0)   # Add batch dimension

        logger.info(f"Image preprocessed successfully | Shape: {img_array.shape}")
        return img_array

    except Exception as e:
        logger.error(f"Preprocessing failed: {e}")
        raise ValueError(f"Image preprocessing error: {e}")


def load_and_preprocess(image_bytes: bytes) -> np.ndarray:
    """
    Convenience function that combines both steps.
    This is what the crop route will call directly.
    """
    image = load_image_from_bytes(image_bytes)
    return preprocess_image(image)