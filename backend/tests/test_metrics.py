import pytest
from fastapi.testclient import TestClient
import sys
import pathlib
sys.path.append(str(pathlib.Path(__file__).resolve().parents[2]))

from backend.app.main import app

client = TestClient(app)

def test_metrics_endpoint():
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "# HELP" in response.text
