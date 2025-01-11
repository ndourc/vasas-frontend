from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('auth/', include('djoser.urls')),  # Authentication endpoints
    path('auth/', include('djoser.urls.jwt')),
    path('api/', include('vasas_userprofile.urls')),  # Profile endpoint
    path('api/', include('vasas_chatbot.urls')),  # Chatbot endpoint
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]