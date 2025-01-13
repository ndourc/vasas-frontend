from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from ollama import chat
from textblob import TextBlob
from .serializers import ChatbotSerializer, EventSerializer
from .models import ChatMessage, Event

class ChatbotView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChatbotSerializer(data=request.data)
        if serializer.is_valid():
            user_message = serializer.validated_data['user_message']
            user = request.user

            # Check if the user is confirming an event
            if user_message.lower() in ["yes", "yeah", "yep"]:
                last_message = ChatMessage.objects.filter(user=user).last()
                if last_message and "Should I set a reminder for this event?" in last_message.bot_response:
                    # Extract event details from the last user message
                    event_details = last_message.user_message
                    # For simplicity, we'll use hardcoded values here
                    event = Event.objects.create(
                        user=user,
                        title="Event",
                        date="2023-01-17",  # Extract the actual date from the message
                        time="09:00:00",    # Extract the actual time from the message
                        description=event_details
                    )
                    bot_response = "Reminder set, find it in your homepage."
                    return Response({'bot_response': bot_response}, status=status.HTTP_200_OK)

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
            if "exam" in user_message.lower() or "event" in user_message.lower():
                bot_response += " Should I set a reminder for this event?"
            
            return Response({'bot_response': bot_response, 'sentiment': sentiment}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)