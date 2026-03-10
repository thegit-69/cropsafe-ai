# app/models/soil_model.py

import logging
import numpy as np
import joblib

logger = logging.getLogger(__name__)

# ── Paths ──────────────────────────────────────────────────────
MODEL_PATH   = "trained_models/soil_model.pkl"
ENCODER_PATH = "trained_models/fertilizer_encoder.pkl"

# ── Model State ────────────────────────────────────────────────
soil_model       = None
soil_encoder     = None

# ── Ideal Ranges for Scoring ───────────────────────────────────
IDEAL_RANGES = {
    "nitrogen":   {"min": 80,  "max": 120, "unit": "kg/ha", "label": "Nitrogen (N)"},
    "phosphorus": {"min": 50,  "max": 80,  "unit": "kg/ha", "label": "Phosphorus (P)"},
    "potassium":  {"min": 80,  "max": 120, "unit": "kg/ha", "label": "Potassium (K)"},
    "ph":         {"min": 6.0, "max": 7.5, "unit": "",      "label": "pH Level"},
    "moisture":   {"min": 25,  "max": 45,  "unit": "%",     "label": "Soil Moisture"},
}

# ── Health Labels ──────────────────────────────────────────────
HEALTH_LABELS = [
    (85, 100, "Excellent Soil Health"),
    (70, 84,  "Good Soil Health"),
    (50, 69,  "Moderate Soil Health"),
    (30, 49,  "Poor Soil Health"),
    (0,  29,  "Critical Soil Health"),
]


def load_soil_model():
    """
    Loads the trained RandomForest model and label encoder.
    Called once when the server starts.
    Falls back to mock mode if files not found.
    """
    global soil_model, soil_encoder

    try:
        soil_model   = joblib.load(MODEL_PATH)
        soil_encoder = joblib.load(ENCODER_PATH)
        logger.info("Real soil model loaded successfully")

    except FileNotFoundError:
        logger.warning("soil_model.pkl not found — running in MOCK mode")
        soil_model   = None
        soil_encoder = None

    except Exception as e:
        logger.error(f"Failed to load soil model: {e}")
        soil_model   = None
        soil_encoder = None


def _score_parameter(value: float, min_val: float, max_val: float) -> float:
    """
    Scores a single parameter out of 20 based on
    how close it is to the ideal range.

    Inside range     -> 20 points
    Slightly outside -> proportional deduction
    Far outside      -> minimum 0 points
    """
    if min_val <= value <= max_val:
        return 20.0

    # How far outside the range as a ratio
    range_size = max_val - min_val

    if value < min_val:
        gap = min_val - value
    else:
        gap = value - max_val

    # Deduct proportionally — lose all 20 pts if gap >= range_size
    deduction = min(20.0, (gap / range_size) * 20.0)
    return round(max(0.0, 20.0 - deduction), 2)


def _get_status(value: float, min_val: float, max_val: float) -> str:
    """
    Returns status tag for a parameter value.
    """
    if min_val <= value <= max_val:
        return "OK"

    deviation = 0.3 * (max_val - min_val)

    if value < min_val:
        return "Low" if (min_val - value) <= deviation else "Critical Low"
    else:
        return "High" if (value - max_val) <= deviation else "Critical High"


def _get_health_label(score: int) -> str:
    """
    Maps numeric score to a health label string.
    """
    for low, high, label in HEALTH_LABELS:
        if low <= score <= high:
            return label
    return "Unknown"


def _predict_fertilizer(
    nitrogen: float,
    phosphorus: float,
    potassium: float,
    moisture: float
) -> str:
    """
    Uses the trained ML model to predict the best fertilizer.
    Falls back to rule-based prediction in mock mode.
    """
    global soil_model, soil_encoder

    # ── Real model ─────────────────────────────────────────────
    if soil_model is not None and soil_encoder is not None:
        try:
            input_array = np.array([[nitrogen, phosphorus, potassium, moisture]])
            prediction  = soil_model.predict(input_array)
            fertilizer  = soil_encoder.inverse_transform(prediction)[0]
            logger.info(f"ML fertilizer prediction: {fertilizer}")
            return fertilizer
        except Exception as e:
            logger.error(f"ML prediction failed: {e} — falling back to rules")

    # ── Mock / fallback rule-based ─────────────────────────────
    if nitrogen < 20:
        return "Urea"
    if phosphorus < 20:
        return "DAP"
    if potassium < 20:
        return "10-26-26"
    return "17-17-17"


def analyze_soil(
    nitrogen: float,
    phosphorus: float,
    potassium: float,
    ph: float,
    moisture: float
) -> dict:
    """
    Main function called by the soil route.
    Returns full soil health report including:
    - Score (0-100)
    - Health label
    - Per-parameter breakdown with status
    - ML-based fertilizer recommendation
    """

    # ── Score each parameter ───────────────────────────────────
    params = {
        "nitrogen":   nitrogen,
        "phosphorus": phosphorus,
        "potassium":  potassium,
        "ph":         ph,
        "moisture":   moisture,
    }

    breakdown     = []
    total_score   = 0
    deficiencies  = 0

    for key, value in params.items():
        ideal    = IDEAL_RANGES[key]
        score    = _score_parameter(value, ideal["min"], ideal["max"])
        status   = _get_status(value, ideal["min"], ideal["max"])
        total_score += score

        if status != "OK":
            deficiencies += 1

        breakdown.append({
            "parameter": ideal["label"],
            "value":     value,
            "unit":      ideal["unit"],
            "status":    status,
            "ideal":     f"{ideal['min']}-{ideal['max']}",
            "score":     score
        })

    # ── Final score ────────────────────────────────────────────
    final_score  = round(total_score)
    health_label = _get_health_label(final_score)

    # ── ML fertilizer prediction ───────────────────────────────
    fertilizer = _predict_fertilizer(
        nitrogen, phosphorus, potassium, moisture
    )

    logger.info(
        f"Soil analysis complete — "
        f"Score: {final_score} | Label: {health_label} | "
        f"Deficiencies: {deficiencies} | Fertilizer: {fertilizer}"
    )

    return {
        "score":              final_score,
        "label":              health_label,
        "deficiencies_count": deficiencies,
        "fertilizer":         fertilizer,
        "breakdown":          breakdown,
    }