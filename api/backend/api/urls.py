from django.urls import path
from .views import DishesView

urlpatterns = [
    path("dishes/", DishesView.as_view(), name="dishes"),
]