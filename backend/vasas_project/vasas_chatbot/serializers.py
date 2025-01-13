# filepath: /c:/the_dev/final_year/vasas/backend/vasas_project/vasas_chatbot/serializers.py
from rest_framework import serializers
from .models import ChatMessage, Event

class ChatbotSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatMessage
        fields = ['user_message']

class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = ['title', 'date', 'time', 'description']