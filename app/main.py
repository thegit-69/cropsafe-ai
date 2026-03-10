# app/main.py

import logging
from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.routes.crop_routes import router as crop_router
from app.routes.soil_routes import router as soil_router
from app.models.crop_model import load_crop_model
from app.models.soil_model import load_soil_model

# ── Logging Setup ──────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)
logger = logging.getLogger(__name__)


# ── Startup & Shutdown Events ──────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Runs when server starts
    logger.info("🚀 Starting Agro AI Backend...")
    load_crop_model()
    load_soil_model()
    logger.info("✅ All models loaded — server ready!")
    yield
    # Runs when server shuts down
    logger.info("🛑 Shutting down Agro AI Backend...")


# ── Create FastAPI App ─────────────────────────────────────────
app = FastAPI(
    title="Agro AI Backend",
    description="AI-Based Crop Health and Soil Analysis System",
    version="1.0.0",
    lifespan=lifespan
)

# ── Register Routers ───────────────────────────────────────────
app.include_router(crop_router, prefix="/crop", tags=["Crop Analysis"])
app.include_router(soil_router, prefix="/soil", tags=["Soil Analysis"])


# ── Root Health Check ──────────────────────────────────────────
@app.get("/", tags=["Health"])
def root():
    logger.info("Health check hit")
    return {
        "status":  "running",
        "message": "Agro AI Backend is live!",
        "docs":    "Visit /docs to test the APIs"
    }