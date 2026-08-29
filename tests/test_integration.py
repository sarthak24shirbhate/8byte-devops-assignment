def test_create_and_list_items_workflow(client):
    payload = {
        "title": "Provision VPC via Terraform",
        "description": "2 public subnets, 2 private subnets, NAT Gateway, ALB"
    }
    # 1. Create item
    create_res = client.post("/api/v1/items", json=payload)
    assert create_res.status_code == 201
    item_data = create_res.json()
    assert item_data["title"] == payload["title"]
    assert item_data["description"] == payload["description"]
    assert "id" in item_data

    # 2. List items
    list_res = client.get("/api/v1/items")
    assert list_res.status_code == 200
    items = list_res.json()
    assert len(items) >= 1
    assert any(i["id"] == item_data["id"] for i in items)

def test_create_item_invalid_payload(client):
    # Empty title should fail Pydantic validation (422)
    invalid_payload = {"title": ""}
    res = client.post("/api/v1/items", json=invalid_payload)
    assert res.status_code == 422
