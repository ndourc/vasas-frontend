from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('auth/', include('djoser.urls')),  # Authentication endpoints
    path('auth/', include('djoser.urls.authtoken')),
    path('api/', include('vasas_userprofile.urls')),  # Profile endpoint
]
