import os
import json
import uuid
import time
import requests
from pathlib import Path

BASE = "http://65.21.9.14:1212"
DISHES_URL = f"{BASE}/api/get-dishes/"
IMAGES_URL = f"{BASE}/api/images"

TIMEOUT = 60

def _post_dishes(image_path=None, preferences=None, products=None):
    files = {}
    data = {}

    if image_path:
        p = Path(image_path)
        if not p.exists():
            raise FileNotFoundError(f"Image not found: {image_path}")
        files["image"] = (p.name, p.read_bytes(), "image/png")

    if preferences is not None:
        data["preferences"] = json.dumps(preferences)

    if products is not None:
        data["products"] = json.dumps(products)

    resp = requests.post(DISHES_URL, files=files or None, data=data or None, timeout=TIMEOUT)
    try:
        return resp.status_code, resp.json()
    except Exception:
        return resp.status_code, resp.text


def test_image_only():
    print("== test_image_only ==")
    status, body = _post_dishes(image_path="test.jpg")
    assert status == 200, f"Expected 200, got {status}, body={body}"
    assert isinstance(body, dict) and body.get("status") == "ok", f"Bad body: {body}"
    dishes = body.get("dishes") or []
    assert len(dishes) >= 1, "No dishes returned"
    print(f"OK: {len(dishes)} dishes")

    image_id = dishes[0].get("image_id")
    if image_id:
        image_id_str = str(image_id)
        for candidate in (f"{image_id_str}.png", image_id_str):
            url = f"{IMAGES_URL}/{candidate}"
            r = requests.get(url, timeout=TIMEOUT)
            print(f"Fetch image {candidate}: {r.status_code}")
            if r.status_code == 200:
                assert r.headers.get("Content-Type", "").startswith(("image/", "application/octet-stream"))
                break


def test_products_only():
    print("== test_products_only ==")
    status, body = _post_dishes(
        products=["Potatoes (500g)", "Onions (1)", "Garlic (2 cloves)", "Olive oil (2 tbsp)"]
    )
    assert status == 200, f"Expected 200, got {status}, body={body}"
    assert body.get("status") == "ok"
    dishes = body.get("dishes") or []
    assert len(dishes) >= 1
    print(f"OK: {len(dishes)} dishes")


def test_with_preferences_and_image():
    print("== test_with_preferences_and_image ==")
    prefs = {
        "diets": ["vegetarian"],
        "experience": "beginner",
        "favourite": ["soup", "pasta"],
        "time": [10, 30]
    }
    status, body = _post_dishes(image_path="test.jpg", preferences=prefs)
    assert status == 200, f"Expected 200, got {status}, body={body}"
    assert body.get("status") == "ok"
    dishes = body.get("dishes") or []
    assert len(dishes) >= 1
    print(f"OK: {len(dishes)} dishes with preferences")


def test_bad_request_no_image_no_products():
    print("== test_bad_request_no_image_no_products ==")
    status, body = _post_dishes()
    assert status == 400, f"Expected 400, got {status}, body={body}"
    # body can be dict or text; try to inspect message
    msg = body if isinstance(body, str) else body.get("error")
    assert "No image or products provided" in str(msg)
    print("OK: got 400 as expected")


if __name__ == "__main__":
    try:
        test_bad_request_no_image_no_products()
        test_products_only()
        test_with_preferences_and_image()
        test_image_only()
        print("\nAll tests completed.")
    except AssertionError as e:
        print("ASSERTION FAILED:", e)
    except Exception as e:
        print("ERROR:", e)
