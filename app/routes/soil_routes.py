# app/routes/soil_routes.py

import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field, validator
from app.models.soil_model import analyze_soil
from app.services.recommendation_service import get_soil_recommendations

logger = logging.getLogger(__name__)

router = APIRouter()


# ── Input Schema ───────────────────────────────────────────────
class SoilInput(BaseModel):
    """
    Exactly matches the Flutter input form fields.
    All values validated against realistic ranges.
    """
    nitrogen:   float = Field(..., ge=0, le=200, description="Nitrogen in kg/ha")
    phosphorus: float = Field(..., ge=0, le=200, description="Phosphorus in kg/ha")
    potassium:  float = Field(..., ge=0, le=200, description="Potassium in kg/ha")
    ph:         float = Field(..., ge=0, le=14,  description="Soil pH level")
    moisture:   float = Field(..., ge=0, le=100, description="Soil moisture in %")

    @validator("ph")
    def validate_ph(cls, v):
        if v < 0 or v > 14:
            raise ValueError("pH must be between 0 and 14")
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "nitrogen":   42,
                "phosphorus": 68,
                "potassium":  85,
                "ph":         6.8,
                "moisture":   45
            }
        }


@router.post("/predict_soil")
async def predict_soil(soil_data: SoilInput):
    """
    Endpoint: POST /soil/predict_soil

    Accepts 5 soil parameters from Flutter.
    Returns full soil health report with score,
    parameter breakdown, and recommendations.

    Example Response:
    {
        "score": 62,
        "label": "Moderate Soil Health",
        "deficiencies_count": 2,
        "breakdown": [...],
        "recommendations": [...]
    }
    """

    logger.info(
        f"Soil input received — "
        f"N:{soil_data.nitrogen} P:{soil_data.phosphorus} "
        f"K:{soil_data.potassium} pH:{soil_data.ph} "
        f"Moisture:{soil_data.moisture}"
    )

    # ── Step 1: Run soil analysis + ML prediction ──────────────
    try:
        analysis = analyze_soil(
            nitrogen=soil_data.nitrogen,
            phosphorus=soil_data.phosphorus,
            potassium=soil_data.potassium,
            ph=soil_data.ph,
            moisture=soil_data.moisture
        )
    except Exception as e:
        logger.error(f"Soil analysis failed: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Soil analysis failed: {str(e)}"
        )

    # ── Step 2: Get recommendations ────────────────────────────
    try:
        recommendations = get_soil_recommendations(
            breakdown=analysis["breakdown"],
            fertilizer=analysis["fertilizer"]
        )
    except Exception as e:
        logger.error(f"Recommendation generation failed: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Recommendation generation failed: {str(e)}"
        )

    # ── Step 3: Build and return full response ─────────────────
    return {
        "score":              analysis["score"],
        "label":              analysis["label"],
        "deficiencies_count": analysis["deficiencies_count"],
        "breakdown":          analysis["breakdown"],
        "recommendations":    recommendations
    }