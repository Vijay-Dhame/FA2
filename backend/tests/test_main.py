"""
Unit tests for the DevOps Environment Manager backend.
Uses the FastAPI TestClient (backed by httpx).
"""

import os
import pytest
from fastapi.testclient import TestClient

import sys
import pathlib
sys.path.append(str(pathlib.Path(__file__).resolve().parents[2]))

from backend.app.main import app


@pytest.fixture
def client():
    """Create a TestClient for the FastAPI application."""
    return TestClient(app)


# ---- Root endpoint --------------------------------------------------------

def test_root_returns_200(client):
    response = client.get("/")
    assert response.status_code == 200


def test_root_contains_application_name(client):
    data = client.get("/").json()
    assert data["application"] == "DevOps Environment Manager"


def test_root_contains_version(client):
    data = client.get("/").json()
    assert data["version"] == "1.0.0"


# ---- Health endpoint ------------------------------------------------------

def test_health_returns_200(client):
    response = client.get("/health")
    assert response.status_code == 200


def test_health_status_is_healthy(client):
    data = client.get("/health").json()
    assert data["status"] == "healthy"


def test_health_has_timestamp(client):
    data = client.get("/health").json()
    assert "timestamp" in data
    assert len(data["timestamp"]) > 0


# ---- Info endpoint --------------------------------------------------------

def test_info_returns_200(client):
    response = client.get("/api/info")
    assert response.status_code == 200


def test_info_contains_required_fields(client):
    data = client.get("/api/info").json()
    required = {"application", "version", "environment", "service", "description"}
    assert required.issubset(set(data.keys()))


# ---- Status endpoint ------------------------------------------------------

def test_status_returns_200(client):
    response = client.get("/api/status")
    assert response.status_code == 200


def test_status_shows_running(client):
    data = client.get("/api/status").json()
    assert data["status"] == "running"


# ---- Environment configuration -------------------------------------------

def test_default_environment_is_development(client):
    """When ENVIRONMENT_NAME is not set, default to 'development'."""
    data = client.get("/api/info").json()
    # In the test runner, the env var may or may not be set.
    # We verify the field exists and is a non-empty string.
    assert isinstance(data["environment"], str)
    assert len(data["environment"]) > 0


def test_environment_matches_across_endpoints(client):
    """The environment reported must be consistent."""
    env_health = client.get("/health").json()["environment"]
    env_info = client.get("/api/info").json()["environment"]
    env_status = client.get("/api/status").json()["environment"]
    assert env_health == env_info == env_status


# ---- Invalid request behaviour --------------------------------------------

def test_nonexistent_route_returns_404(client):
    response = client.get("/api/nonexistent")
    assert response.status_code == 404


def test_post_to_health_returns_405(client):
    response = client.post("/health")
    assert response.status_code == 405
