from django.urls import path
from .views import get_dishes, serve_image

urlpatterns = [
    path("get-dishes/", get_dishes, name="dishes"),
    path("images/<str:filename>/", serve_image, name="serve_image"),
]