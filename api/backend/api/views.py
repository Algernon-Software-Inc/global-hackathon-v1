from django.shortcuts import render
import os
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import AllowAny
from rest_framework import status
from rest_framework.decorators import api_view
import mimetypes
from django.http import FileResponse
from .utils.gpt import get_recipes_by_image, get_photo
import uuid

def parse_recipes(recipes_text: str):
    blocks = [b.strip() for b in recipes_text.strip().split("\n----------\n") if b.strip()]
    results = []

    for block in blocks:
        lines = [l for l in block.splitlines() if l.strip()]
        if len(lines) < 2 + 6:
            if len(lines) >= 2:
                name = lines[0].strip()
                products_line = lines[1].strip()
                products = [p.strip() for p in products_line.split(",") if p.strip()]
                recipe_body = "\n".join(lines[2:]).strip()
                results.append({
                    "name": name,
                    "products": products,
                    "recipe": recipe_body,
                    "time_min": None,
                    "difficulty": None,
                    "energy_kcal": None,
                    "proteins_g": None,
                    "fats_g": None,
                    "carbs_g": None,
                })
            continue

        name = lines[0].strip()
        products_line = lines[1].strip()
        products = [p.strip() for p in products_line.split(",") if p.strip()]

        tail = lines[-6:]
        recipe_body_lines = lines[2:-6]
        recipe_body = "\n".join(recipe_body_lines).strip()

        def to_num(s, as_int=False):
            s = s.strip()
            s = s.replace(",", ".")
            try:
                return int(float(s)) if as_int else float(s)
            except ValueError:
                return None

        time_min = to_num(tail[0], as_int=True)
        difficulty = to_num(tail[1], as_int=True)
        energy_kcal = to_num(tail[2], as_int=False)
        proteins_g = to_num(tail[3], as_int=False)
        fats_g = to_num(tail[4], as_int=False)
        carbs_g = to_num(tail[5], as_int=False)

        results.append({
            "name": name,
            "products": products,
            "recipe": recipe_body,
            "time_min": time_min,
            "difficulty": difficulty,
            "energy_kcal": energy_kcal,
            "proteins_g": proteins_g,
            "fats_g": fats_g,
            "carbs_g": carbs_g,
        })

    return results
    
class DishesView(APIView):
    parser_classes = (MultiPartParser, FormParser)
    permission_classes = [AllowAny]

    def post(self, request):
        image = request.FILES.get("image")
        preferences = request.data.get("preferences", "None")

        if not image:
            return Response({"error": "No image provided."}, status=status.HTTP_400_BAD_REQUEST)

        recipes = get_recipes_by_image(image, preferences)
        recipes = parse_recipes(recipes)

        for recipe in recipes:
            image_id = uuid.uuid4()
            current_dir = os.path.dirname(os.path.abspath(__file__))
            download_path = os.path.join(current_dir, 'images', image_id)
            get_photo(recipe['name'], recipe['products'], recipe['recipe'], download_path)
            recipe['image_id'] = image_id

        return Response({"status": "ok", "dishes": recipes}, status=status.HTTP_200_OK)
    
@api_view(['GET'])
def serve_image(request, filename):
    current_dir = os.path.dirname(os.path.abspath(__file__))
    image_path = os.path.join(current_dir, 'images', filename)
    
    if not os.path.exists(image_path):
        response_data = {"status": "failed"}
        return Response(response_data, status=status.HTTP_404_NOT_FOUND)
    
    content_type, _ = mimetypes.guess_type(image_path)
    if not content_type:
        content_type = 'application/octet-stream'
    
    response = FileResponse(open(image_path, 'rb'), content_type=content_type)
    return response
