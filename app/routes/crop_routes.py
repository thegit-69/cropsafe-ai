# app/routes/crop_routes.py

import logging
from fastapi import APIRouter, UploadFile, File, HTTPException
from app.models.crop_model import predict_crop_disease
from app.services.recommendation_service import get_crop_recommendation
from app.utils.image_preprocessing import load_and_preprocess

logger = logging.getLogger(__name__)

# ── Router Setup ───────────────────────────────────────────────
router = APIRouter()


@router.post("/predict_crop")
async def predict_crop(file: UploadFile = File(...)):
    """
    Endpoint: POST /crop/predict_crop

    Accepts a crop leaf image from Flutter.
    Returns disease name, confidence, and treatment recommendation.

    Example Response:
    {
        "disease": "Leaf Blight",
        "confidence": 0.91,
        "recommendation": "Apply copper fungicide and remove infected leaves."
    }
    """

    # ── Step 1: Validate file type ─────────────────────────────
    ALLOWED_TYPES = [
        "image/jpeg", "image/png", "image/jpg",
        "image/webp", "application/octet-stream"
    ]

    # Check by file extension if content type is octet-stream
    if file.content_type not in ALLOWED_TYPES:
        logger.warning(f"Invalid file type received: {file.content_type}")
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type: {file.content_type}. Only JPEG and PNG allowed."
        )

    # If octet-stream check file extension
    if file.content_type == "application/octet-stream":
        ext = file.filename.lower().split(".")[-1] if file.filename else ""
        if ext not in ["jpg", "jpeg", "png", "webp"]:
            logger.warning(f"Invalid file extension: {ext}")
            raise HTTPException(
                status_code=400,
                detail="Invalid file type. Only JPEG and PNG allowed."
            )

    # ── Step 2: Read image bytes ───────────────────────────────
    try:
        image_bytes = await file.read()
        logger.info(f"Image received | Filename: {file.filename} | Size: {len(image_bytes)} bytes")
    except Exception as e:
        logger.error(f"Failed to read uploaded file: {e}")
        raise HTTPException(
            status_code=500,
            detail="Failed to read uploaded image."
        )

    # ── Step 3: Preprocess image ───────────────────────────────
    try:
        img_array = load_and_preprocess(image_bytes)
        logger.info("Image preprocessed successfully")
    except ValueError as e:
        logger.error(f"Preprocessing error: {e}")
        raise HTTPException(
            status_code=422,
            detail=f"Image preprocessing failed: {str(e)}"
        )

    # ── Step 4: Run prediction ─────────────────────────────────
    try:
        prediction = predict_crop_disease(img_array)
        disease = prediction["disease"]
        confidence = prediction["confidence"]
        logger.info(f"Prediction complete → Disease: {disease} | Confidence: {confidence}")
    except ValueError as e:
        logger.error(f"Prediction error: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Model prediction failed: {str(e)}"
        )

    # ── Step 5: Get recommendation ─────────────────────────────
    recommendation = get_crop_recommendation(disease)

    # ── Step 6: Return structured response ────────────────────
    return {
        "disease": disease,
        "confidence": confidence,
        "recommendation": recommendation
    }