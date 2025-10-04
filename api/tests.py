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
    """
    Send POST /api/get-dishes/ with optional image, preferences (dict), products (list).
    Returns (status_code, json_dict or text).
    """
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


def _attach_image_links(body):
    """
    Adds 'image_url' to every dish based on image_id (assumes .png filenames).
    Mutates and returns body.
    """
    if not isinstance(body, dict):
        return body

    dishes = body.get("dishes") or []
    for d in dishes:
        image_id = d.get("image_id")
        if image_id is None:
            continue
        image_id_str = str(image_id)
        d["image_url"] = f"{IMAGES_URL}/{image_id_str}.png"
    return body


def _print_results(label, status, body):
    print(f"\n== {label} ==")
    print("HTTP:", status)

    if isinstance(body, dict):
        body = _attach_image_links(body)
        print(json.dumps(body, ensure_ascii=False, indent=2))
        links = [d.get("image_url") for d in body.get("dishes", []) if d.get("image_url")]
        if links:
            print("\nImage links:")
            for url in links:
                print(" -", url)
    else:
        print(body)


def test_image_only():
    status, body = _post_dishes(image_path=r"A:\global-hackathon-v1\api\test.jpg")
    _print_results("test_image_only", status, body)
    assert status == 200, f"Expected 200, got {status}"
    assert isinstance(body, dict) and body.get("status") == "ok", f"Bad body: {body}"
    assert (body.get("dishes") or []), "No dishes returned"


def test_products_only():
    status, body = _post_dishes(
        products=["Potatoes (500g)", "Onions (1)", "Garlic (2 cloves)", "Olive oil (2 tbsp)"]
    )
    _print_results("test_products_only", status, body)
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
    _print_results("test_with_preferences_and_image", status, body)
    assert status == 200, f"Expected 200, got {status}"
    assert isinstance(body, dict) and body.get("status") == "ok"
    assert (body.get("dishes") or [])


def test_bad_request_no_image_no_products():
    status, body = _post_dishes()
    _print_results("test_bad_request_no_image_no_products", status, body)
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
