from django.shortcuts import render
import os
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import AllowAny
from rest_framework import status
from utils.gpt import get_recipes_by_image

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

        return Response({"status": "ok", "dishes": recipes}, status=status.HTTP_200_OK)
