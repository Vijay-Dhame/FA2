"""
DevOps Environment Manager — FastAPI Backend
Provides health, info, and status endpoints for the multi-environment dashboard.
"""

import os
from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from prometheus_fastapi_instrumentator import Instrumentator

# ---------------------------------------------------------------------------
# Configuration from environment variables
# ---------------------------------------------------------------------------
APP_NAME = "DevOps Environment Manager"
APP_VERSION = "1.0.0"
ENVIRONMENT = os.getenv("ENVIRONMENT_NAME", "development")
SERVICE_NAME = os.getenv("SERVICE_NAME", "backend")
DESCRIPTION = (
    "Academic demonstration backend for the FA1 multi-environment "
    "container deployment assignment."
)

# ---------------------------------------------------------------------------
# Pydantic response models
# ---------------------------------------------------------------------------

class RootResponse(BaseModel):
    application: str
    version: str
    environment: str
    message: str


class HealthResponse(BaseModel):
    status: str
    environment: str
    timestamp: str


class InfoResponse(BaseModel):
    application: str
    version: str
    environment: str
    service: str
    description: str


class StatusResponse(BaseModel):
    application: str
    version: str
    environment: str
    service: str
    status: str
    uptime_check: str
    timestamp: str
    description: str
    host_info: str


# ---------------------------------------------------------------------------
# FastAPI application
# ---------------------------------------------------------------------------
app = FastAPI(
    title=APP_NAME,
    description=DESCRIPTION,
    version=APP_VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
)
# Prometheus instrumentation
Instrumentator().instrument(app).expose(app)

# CORS — allow the frontend origins for all three environments plus localhost dev
ALLOWED_ORIGINS = [
    "http://localhost:5173",       # Vite dev server
    "http://localhost:8081",       # QA frontend
    "http://localhost:8082",       # UAT frontend
    "http://localhost:8083",       # PROD frontend
    "http://127.0.0.1:5173",
    "http://127.0.0.1:8081",
    "http://127.0.0.1:8082",
    "http://127.0.0.1:8083",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=False,
    allow_methods=["GET"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@app.get("/", response_model=RootResponse)
def root():
    """Return basic application information."""
    return RootResponse(
        application=APP_NAME,
        version=APP_VERSION,
        environment=ENVIRONMENT,
        message=f"{APP_NAME} backend running in {ENVIRONMENT} environment.",
    )


@app.get("/health", response_model=HealthResponse)
def health():
    """Return a health-check response."""
    return HealthResponse(
        status="healthy",
        environment=ENVIRONMENT,
        timestamp=datetime.now(timezone.utc).isoformat(),
    )


@app.get("/api/info", response_model=InfoResponse)
def api_info():
    """Return structured application metadata."""
    return InfoResponse(
        application=APP_NAME,
        version=APP_VERSION,
        environment=ENVIRONMENT,
        service=SERVICE_NAME,
        description=DESCRIPTION,
    )


@app.get("/api/status", response_model=StatusResponse)
def api_status():
    """Return detailed service status for the frontend dashboard."""
    return StatusResponse(
        application=APP_NAME,
        version=APP_VERSION,
        environment=ENVIRONMENT,
        service=SERVICE_NAME,
        status="running",
        uptime_check="passed",
        timestamp=datetime.now(timezone.utc).isoformat(),
        description=DESCRIPTION,
        host_info=os.getenv("HOSTNAME", "unknown"),
    )
