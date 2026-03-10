# app/services/recommendation_service.py

import logging

logger = logging.getLogger(__name__)

# ── Fertilizer Descriptions ────────────────────────────────────
FERTILIZER_INFO = {
    "Urea": {
        "title": "Apply Urea Fertilizer",
        "detail": "Add 40 kg/ha urea to fix nitrogen deficiency before next irrigation cycle."
    },
    "DAP": {
        "title": "Apply DAP Fertilizer",
        "detail": "Apply 50 kg/ha DAP (Di-Ammonium Phosphate) to improve phosphorus and nitrogen levels."
    },
    "14-35-14": {
        "title": "Apply 14-35-14 Fertilizer",
        "detail": "Use 14-35-14 NPK mix at 60 kg/ha to boost phosphorus while maintaining nitrogen and potassium."
    },
    "28-28": {
        "title": "Apply 28-28 Fertilizer",
        "detail": "Apply 28-28 NPK blend at 50 kg/ha to equally raise nitrogen and phosphorus levels."
    },
    "17-17-17": {
        "title": "Apply 17-17-17 Balanced Fertilizer",
        "detail": "Use balanced 17-17-17 NPK at 55 kg/ha to improve overall nutrient levels evenly."
    },
    "20-20": {
        "title": "Apply 20-20 Fertilizer",
        "detail": "Apply 20-20 NPK blend at 50 kg/ha to raise nitrogen and phosphorus together."
    },
    "10-26-26": {
        "title": "Apply 10-26-26 Fertilizer",
        "detail": "Use 10-26-26 NPK at 60 kg/ha to significantly boost phosphorus and potassium levels."
    },
}

# ── Parameter Specific Recommendations ────────────────────────
PARAMETER_RECOMMENDATIONS = {
    "Nitrogen (N)": {
        "Low": {
            "title": "Low Nitrogen Detected",
            "detail": "Apply nitrogen-rich fertilizer. Consider split application — half before sowing, half after 30 days."
        },
        "Critical Low": {
            "title": "Critical Nitrogen Deficiency",
            "detail": "Immediate action required. Apply urea at 60 kg/ha and foliar spray with 2% urea solution."
        },
        "High": {
            "title": "Excess Nitrogen Detected",
            "detail": "Reduce nitrogen inputs. Excess nitrogen causes leaf burn and reduces fruit quality."
        },
        "Critical High": {
            "title": "Critical Nitrogen Excess",
            "detail": "Stop all nitrogen fertilization immediately. Flush soil with irrigation to dilute concentration."
        },
    },
    "Phosphorus (P)": {
        "Low": {
            "title": "Low Phosphorus Detected",
            "detail": "Apply phosphate fertilizer such as DAP or SSP. Best applied before planting season."
        },
        "Critical Low": {
            "title": "Critical Phosphorus Deficiency",
            "detail": "Apply superphosphate at 80 kg/ha immediately. Phosphorus deficiency stunts root development."
        },
        "High": {
            "title": "Excess Phosphorus Detected",
            "detail": "Avoid phosphate fertilizers this season. High phosphorus blocks zinc and iron absorption."
        },
        "Critical High": {
            "title": "Critical Phosphorus Excess",
            "detail": "Do not apply any phosphate. Test soil again after 60 days and consider soil flushing."
        },
    },
    "Potassium (K)": {
        "Low": {
            "title": "Low Potassium Detected",
            "detail": "Apply potash fertilizer such as MOP (Muriate of Potash) at 40 kg/ha."
        },
        "Critical Low": {
            "title": "Critical Potassium Deficiency",
            "detail": "Apply MOP at 60 kg/ha urgently. Potassium deficiency causes weak stems and poor grain fill."
        },
        "High": {
            "title": "Excess Potassium Detected",
            "detail": "Skip potassium fertilizers this season. High K interferes with magnesium uptake."
        },
        "Critical High": {
            "title": "Critical Potassium Excess",
            "detail": "Avoid all potassium inputs. Conduct a full micronutrient panel to check secondary effects."
        },
    },
    "pH Level": {
        "Low": {
            "title": "Acidic Soil Detected",
            "detail": "Apply agricultural lime at 2 tonnes/ha to raise pH. Retest after 4 weeks."
        },
        "Critical Low": {
            "title": "Highly Acidic Soil",
            "detail": "Apply dolomitic limestone at 3 tonnes/ha. Acidic soil severely limits nutrient availability."
        },
        "High": {
            "title": "Alkaline Soil Detected",
            "detail": "Apply elemental sulfur at 200 kg/ha to lower pH gradually over 6-8 weeks."
        },
        "Critical High": {
            "title": "Highly Alkaline Soil",
            "detail": "Apply sulfur and acidifying fertilizers. Alkaline soil locks out phosphorus and micronutrients."
        },
    },
    "Soil Moisture": {
        "Low": {
            "title": "Low Soil Moisture",
            "detail": "Irrigate within 24 hours. Apply mulch to retain moisture and reduce evaporation."
        },
        "Critical Low": {
            "title": "Critical Moisture Deficiency",
            "detail": "Immediate irrigation required. Crops are at wilting point. Apply 50mm water as soon as possible."
        },
        "High": {
            "title": "Excess Soil Moisture",
            "detail": "Improve field drainage. Waterlogged soil causes root rot and nutrient leaching."
        },
        "Critical High": {
            "title": "Critical Waterlogging",
            "detail": "Create drainage channels immediately. Standing water destroys root systems within 48 hours."
        },
    },
}

# ── General Recommendations ────────────────────────────────────
GENERAL_RECOMMENDATIONS = {
    "irrigation": {
        "title": "Irrigation Timing",
        "detail": "Irrigate within 48 hrs of applying fertilizer for better nutrient absorption."
    },
    "organic": {
        "title": "Add Organic Matter",
        "detail": "Mix vermicompost or farmyard manure at 5 tonnes/ha to improve soil structure and microbial activity."
    },
    "testing": {
        "title": "Schedule Soil Retest",
        "detail": "Retest soil after 30 days of treatment to track improvement and adjust inputs accordingly."
    },
}


def get_crop_recommendation(disease: str) -> str:
    """
    Returns treatment recommendation for a detected crop disease.
    """
    CROP_RECOMMENDATIONS = {
        "Healthy":        "No treatment needed. Keep monitoring your crops regularly.",
        "Leaf Spot":      "Apply copper-based fungicide. Remove and destroy infected leaves. Avoid overhead watering.",
        "Blight":         "Use fungicide spray immediately. Remove infected plants. Ensure proper drainage.",
        "Rust":           "Apply sulfur-based fungicide. Remove infected leaves. Improve air circulation around plants.",
        "Powdery Mildew": "Apply neem oil or potassium bicarbonate spray. Avoid excess humidity.",
    }

    recommendation = CROP_RECOMMENDATIONS.get(disease)

    if recommendation:
        logger.info(f"Crop recommendation found for: {disease}")
    else:
        logger.warning(f"No recommendation found for: {disease}")
        recommendation = "Consult a local agricultural expert for further analysis."

    return recommendation


def get_soil_recommendations(breakdown: list, fertilizer: str) -> list:
    """
    Builds a prioritized list of recommendations based on:
    1. ML predicted fertilizer
    2. Status of each parameter in the breakdown
    3. General best practice advice

    Returns a list of recommendation objects with title and detail.
    """
    recommendations = []

    # ── 1. Fertilizer recommendation from ML model ─────────────
    if fertilizer and fertilizer in FERTILIZER_INFO:
        recommendations.append(FERTILIZER_INFO[fertilizer])
        logger.info(f"Fertilizer recommendation added: {fertilizer}")

    # ── 2. Parameter specific recommendations ──────────────────
    for item in breakdown:
        param  = item["parameter"]
        status = item["status"]

        if status == "OK":
            continue

        if param in PARAMETER_RECOMMENDATIONS:
            if status in PARAMETER_RECOMMENDATIONS[param]:
                rec = PARAMETER_RECOMMENDATIONS[param][status]
                recommendations.append(rec)
                logger.info(f"Parameter recommendation added: {param} - {status}")

    # ── 3. Always add irrigation tip if any deficiency exists ──
    deficient_params = [i for i in breakdown if i["status"] != "OK"]

    if deficient_params:
        recommendations.append(GENERAL_RECOMMENDATIONS["irrigation"])

    # ── 4. Always suggest organic matter improvement ───────────
    recommendations.append(GENERAL_RECOMMENDATIONS["organic"])

    # ── 5. Always suggest retesting ───────────────────────────
    recommendations.append(GENERAL_RECOMMENDATIONS["testing"])

    logger.info(f"Total recommendations generated: {len(recommendations)}")
    return recommendations