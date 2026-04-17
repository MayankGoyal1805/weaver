from fastapi.testclient import TestClient

from app.main import app


def test_tool_catalog_non_empty() -> None:
    client = TestClient(app)
    response = client.get("/api/v1/tools/catalog")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert any(item["tool_id"] == "filesystem.list_directory" for item in data)
