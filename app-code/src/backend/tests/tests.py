import json
from app import app


def test_health():
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["status"] == "ok"

