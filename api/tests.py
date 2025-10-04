import os
import json
import requests
from pathlib import Path

BASE = "http://65.21.9.14:1212"
DISHES_URL = f"{BASE}/api/get-dishes/"
IMAGES_URL = f"{BASE}/api/images"
TIMEOUT = 120


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


def _print_name_products_link(label, status, body):
    print(f"\n== {label} ==")
    print("HTTP:", status)

    if not isinstance(body, dict):
        print(body)
        return

    # Pretty lines: name - products - link
    dishes = body.get("dishes") or []
    if not dishes:
        print("(no dishes)")
        return

    for d in dishes:
        name = d.get("name", "")
        products_list = d.get("products") or []
        products_str = ", ".join(products_list)
        image_id = d.get("image_id")
        link = f"{IMAGES_URL}/{image_id}.png" if image_id else ""
        print(f"{name} - {products_str} - {link}")


def test_image_only():
    status, body = _post_dishes(image_path=r"A:\global-hackathon-v1\api\test.jpg")
    _print_name_products_link("test_image_only", status, body)
    assert status == 200, f"Expected 200, got {status}"
    assert isinstance(body, dict) and body.get("status") == "ok", f"Bad body: {body}"
    assert (body.get("dishes") or []), "No dishes returned"


def test_products_only():
    status, body = _post_dishes(
        products=["Potatoes (500g)", "Onions (1)", "Garlic (2 cloves)", "Olive oil (2 tbsp)"]
    )
    _print_name_products_link("test_products_only", status, body)
    assert status == 200, f"Expected 200, got {status}"
    assert isinstance(body, dict) and body.get("status") == "ok"
    assert (body.get("dishes") or [])


def test_with_preferences_and_image():
    prefs = {
        "diets": ["vegetarian"],
        "experience": "beginner",
        "favourite": ["soup", "pasta"],
        "time": [10, 30]
    }
    status, body = _post_dishes(image_path=r"A:\global-hackathon-v1\api\test.jpg", preferences=prefs)
    _print_name_products_link("test_with_preferences_and_image", status, body)
    assert status == 200, f"Expected 200, got {status}"
    assert isinstance(body, dict) and body.get("status") == "ok"
    assert (body.get("dishes") or [])


def test_bad_request_no_image_no_products():
    status, body = _post_dishes()
    _print_name_products_link("test_bad_request_no_image_no_products", status, body)
    assert status == 400, f"Expected 400, got {status}"
    msg = body if isinstance(body, str) else body.get("error")
    assert "No image or products provided" in str(msg)


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
