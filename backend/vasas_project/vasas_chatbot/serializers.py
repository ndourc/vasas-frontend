# filepath: /c:/the_dev/final_year/vasas/backend/vasas_project/vasas_chatbot/serializers.py
from rest_framework import serializers
from .models import ChatMessage

class ChatbotSerializer(serializers.ModelSerializer):
    user_message = serializers.CharField()
    bot_response = serializers.CharField(required=False)
    sentiment = serializers.CharField(required=False)

    class Meta:
        model = ChatMessage
        fields = ['user_message', 'bot_response', 'sentiment', 'timestamp']