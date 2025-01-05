from django.urls import path
from .views import ProfileDetail

urlpatterns = [
    path('profile/', ProfileDetail.as_view(), name='profile-detail'),
]
