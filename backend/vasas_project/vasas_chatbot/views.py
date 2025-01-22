import os
import wave
import json
import pyttsx3

from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from ollama import chat
from textblob import TextBlob
from .serializers import ChatbotSerializer
from .models import ChatMessage, Event, EventState
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from vosk import Model, KaldiRecognizer

class ChatbotView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChatbotSerializer(data=request.data)
        if serializer.is_valid():
            user_message = serializer.validated_data['user_message']
            user = request.user

            # Check if there is an ongoing event scheduling process
            event_state = EventState.objects.filter(user=user).last()
            if event_state and event_state.state != 'completed':
                return self.handle_event_scheduling(event_state, user_message)

            response = chat(model='llama3.2', messages=[{'role': 'user', 'content': user_message}])
            bot_response = response.message.content
            
            # Perform sentiment analysis
            sentiment_analysis = TextBlob(user_message)
            sentiment = "positive" if sentiment_analysis.sentiment.polarity > 0 else "negative"
            
            # Save the chat message and sentiment to the database
            chat_message = ChatMessage.objects.create(
                user=user,
                user_message=user_message,
                bot_response=bot_response,
                sentiment=sentiment
            )
            
            # Check for event-related keywords
            if "exam" in user_message.lower() or "meeting" in user_message.lower() or "date" in user_message.lower() or "event" in user_message.lower():
                bot_response += " Should I set a reminder for this event?"
                EventState.objects.create(user=user, state='awaiting_confirmation', description=user_message)
            
            return Response({'bot_response': bot_response, 'sentiment': sentiment}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def handle_event_scheduling(self, event_state, user_message):
        user = event_state.user
        if event_state.state == 'awaiting_confirmation':
            if user_message.lower() in ["yes", "yeah", "yep"]:
                event_state.state = 'awaiting_date'
                event_state.save()
                bot_response = "Please provide the date of the event."
            else:
                event_state.delete()
                bot_response = "Event scheduling cancelled."
        elif event_state.state == 'awaiting_date':
            try:
                event_state.date = self.extract_date(user_message)
                event_state.state = 'awaiting_time'
                event_state.save()
                bot_response = "Please provide the time of the event."
            except ValueError:
                bot_response = "I couldn't understand the date. Please provide the date in the format YYYY-MM-DD."
        elif event_state.state == 'awaiting_time':
            try:
                event_state.time = self.extract_time(user_message)
                event_state.state = 'awaiting_venue'
                event_state.save()
                bot_response = "Please provide the venue of the event."
            except ValueError:
                bot_response = "I couldn't understand the time. Please provide the time in the format HH:MM."
        elif event_state.state == 'awaiting_venue':
            event_state.venue = user_message
            event_state.state = 'completed'
            event_state.save()
            Event.objects.create(
                user=user,
                title="Event",
                date=event_state.date,
                time=event_state.time,
                description=event_state.description,
                venue=event_state.venue
            )
            bot_response = "Reminder set, find it in your homepage."
            event_state.delete()
        return Response({'bot_response': bot_response}, status=status.HTTP_200_OK)

    def extract_date(self, user_message):
        # Implement date extraction logic here
        from datetime import datetime
        return datetime.strptime(user_message, '%Y-%m-%d').date()

    def extract_time(self, user_message):
        # Implement time extraction logic here
        from datetime import datetime
        return datetime.strptime(user_message, '%H:%M').time()


class SpeechRecognitionView(APIView):
    def post(self, request):
        audio_file = request.FILES.get('audio')
        if not audio_file:
            return Response({'error': 'No audio file provided'}, status=status.HTTP_400_BAD_REQUEST)

        # Save the audio file temporarily
        audio_path = os.path.join(settings.MEDIA_ROOT, 'temp_audio.wav')
        with open(audio_path, 'wb') as f:
            for chunk in audio_file.chunks():
                f.write(chunk)

        # Perform speech recognition
        model_path = os.path.join(settings.BASE_DIR, 'vasas_chatbot', 'vosk_model', 'vosk-model-small-en-us-0.15')  # Update this path to your Vosk model
        recognized_text = recognize_speech(audio_path, model_path)

        # Clean up the temporary audio file
        os.remove(audio_path)

        # Generate a response using the Ollama model
        response_text = generate_response(recognized_text)

        # Convert the response text to speech
        response_audio_path = os.path.join(settings.MEDIA_ROOT, 'response_audio.wav')
        text_to_speech(response_text, response_audio_path)

        return Response({'recognized_text': recognized_text, 'response_text': response_text, 'response_audio_path': response_audio_path}, status=status.HTTP_200_OK)

def recognize_speech(audio_path, model_path):
    # Load the Vosk model
    model = Model(model_path)

    # Open the audio file
    wf = wave.open(audio_path, "rb")

    # Initialize the recognizer with the model and sample rate
    rec = KaldiRecognizer(model, wf.getframerate())

    recognized_text = ""
    while True:
        data = wf.readframes(4000)
        if len(data) == 0:
            break
        if rec.AcceptWaveform(data):
            result = json.loads(rec.Result())
            recognized_text += result.get('text', '')

    result = json.loads(rec.FinalResult())
    recognized_text += result.get('text', '')

    return recognized_text

def generate_response(user_message):
    # Interact with the Ollama model to generate a response
    response = chat(model='llama3.2', messages=[{'role': 'user', 'content': user_message}])
    return response.message.content

def text_to_speech(text, output_path):
    engine = pyttsx3.init()
    engine.save_to_file(text, output_path)
    engine.runAndWait()