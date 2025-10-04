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
from utils.gpt import get_recipes_by_image, get_photo
import uuid

def parse_recipes(recipes):
    blocks = [b.strip() for b in recipes.strip().split("\n----------\n") if b.strip()]
    recipes = []

    for block in blocks:
        lines = [l for l in block.splitlines() if l.strip()]
        if len(lines) < 2:
            continue

        name = lines[0].strip()
        products_line = lines[1].strip()

        products = [p.strip() for p in products_line.split(",") if p.strip()]

        recipe_body = "\n".join(lines[2:]).strip()

        recipes.append({
            "name": name,
            "products": products,
            "recipe": recipe_body
        })

    return recipes
    
class DishesView(APIView):
    parser_classes = (MultiPartParser, FormParser)
    permission_classes = [AllowAny]

    def post(self, request):
        image = request.FILES.get("image")
        if not image:
            return Response({"error": "No image provided."}, status=status.HTTP_400_BAD_REQUEST)

        recipes = get_recipes_by_image(image)
        recipes = parse_recipes(recipes)

        for recipe in recipes:
            image_id = uuid.uuid4()
            current_dir = os.path.dirname(os.path.abspath(__file__))
            download_path = os.path.join(current_dir, 'images', image_id)
            get_photo(recipe['name'], recipe['products'], recipe['recipe'], download_path)
            recipe['image'] = image_id

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
