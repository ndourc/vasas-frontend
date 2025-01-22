from django.urls import path
from .views import ChatbotView, SpeechRecognitionView

urlpatterns = [
    path('chat/', ChatbotView.as_view(), name='chatbot'),
    path('speech-recognition/', SpeechRecognitionView.as_view(), name='speech_recognition'),
]