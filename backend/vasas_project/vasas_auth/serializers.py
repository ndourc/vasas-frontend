# vasas_auth/serializers.py

from djoser.serializers import UserCreateSerializer as BaseUserCreateSerializer
from django.contrib.auth import get_user_model

User = get_user_model()

class UserCreateSerializer(BaseUserCreateSerializer):
    class Meta(BaseUserCreateSerializer.Meta):
        model = User
        fields = ('id', 'email', 'password', 're_password', 'username')  # Remove 'username' field

    def create(self, validated_data):
        if 'username' not in validated_data or not validated_data['username']:
            validated_data['username'] = validated_data['email']  # Assign email as username
        return super().create(validated_data)