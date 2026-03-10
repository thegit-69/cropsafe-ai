# app/models/crop_model.py

import logging
import numpy as np
import random

logger = logging.getLogger(__name__)

# ── Disease Classes ────────────────────────────────────────────
DISEASE_CLASSES = [
    "Healthy",
    "Leaf Spot",
    "Blight",
    "Rust",
    "Powdery Mildew"
]

# ── Model State ────────────────────────────────────────────────
# This will hold the real model later when we swap to Phase 2
crop_model = None
MODEL_PATH = "trained_models/crop_model.pth"


def load_crop_model():
    """
    Tries to load real model from disk.
    Falls back to mock mode if model file not found.
    Called once when the server starts.
    """
    global crop_model

    try:
        import torch
        import torchvision.models as models

        # Load MobileNetV2 architecture
        model = models.mobilenet_v2(pretrained=False)

        # Adjust final layer to match our 5 disease classes
        model.classifier[1] = torch.nn.Linear(
            model.last_channel, 
            len(DISEASE_CLASSES)
        )

        # Load saved weights
        model.load_state_dict(
            torch.load(MODEL_PATH, map_location=torch.device("cpu"))
        )
        model.eval()
        crop_model = model
        logger.info("✅ Real crop model loaded successfully")

    except FileNotFoundError:
        logger.warning("⚠️  crop_model.pth not found — running in MOCK mode")
        crop_model = None

    except Exception as e:
        logger.error(f"❌ Failed to load crop model: {e} — running in MOCK mode")
        crop_model = None


def predict_crop_disease(img_array: np.ndarray) -> dict:
    """
    Takes preprocessed image array and returns prediction.
    Uses real model if loaded, otherwise returns mock prediction.
    """
    global crop_model

    # ── MOCK MODE ──────────────────────────────────────────────
    if crop_model is None:
        logger.info("Running crop prediction in MOCK mode")

        disease = random.choice(DISEASE_CLASSES)
        confidence = round(random.uniform(0.75, 0.99), 2)

        logger.info(f"Mock prediction → Disease: {disease} | Confidence: {confidence}")
        return {
            "disease": disease,
            "confidence": confidence
        }

    # ── REAL MODEL MODE ────────────────────────────────────────
    try:
        import torch

        # Convert numpy array to torch tensor
        tensor = torch.FloatTensor(img_array)

        with torch.no_grad():
            outputs = crop_model(tensor)
            probabilities = torch.softmax(outputs, dim=1)
            confidence, predicted_idx = torch.max(probabilities, dim=1)

        disease = DISEASE_CLASSES[predicted_idx.item()]
        confidence = round(confidence.item(), 2)

        logger.info(f"Real prediction → Disease: {disease} | Confidence: {confidence}")
        return {
            "disease": disease,
            "confidence": confidence
        }

    except Exception as e:
        logger.error(f"Crop prediction failed: {e}")
        raise ValueError(f"Prediction error: {e}")