from django.urls import path
from .views import DishesView, serve_image

urlpatterns = [
    path("dishes/", DishesView.as_view(), name="dishes"),
    path("images/<str:filename>/", serve_image, name="serve_image"),
]