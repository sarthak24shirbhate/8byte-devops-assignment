def test_read_root(client):
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "version" in data
    assert data["status"] == "healthy"
    assert "environment" in data
    assert "x-request-id" in response.headers
    assert "x-response-time-ms" in response.headers


def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "uptime_seconds" in data
    assert "database" in data
    assert "timestamp" in data


def test_metrics_endpoint(client):
    # Make a few calls first
    client.get("/")
    client.get("/health")

    response = client.get("/api/v1/metrics")
    assert response.status_code == 200
    data = response.json()
    assert data["total_requests"] >= 2
    assert "average_latency_ms" in data
    assert "status_breakdown" in data
    assert data["status_breakdown"]["2xx"] >= 2


def test_nonexistent_endpoint_404(client):
    response = client.get("/api/v1/does-not-exist")
    assert response.status_code == 404
