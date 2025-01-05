# vasas_auth/serializers.py

from rest_framework import serializers
from .models import Profile
from django.contrib.auth import get_user_model

User = get_user_model()

class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = ['bio', 'profile_picture', 'date_of_birth']
        read_only_fields = ['user']
