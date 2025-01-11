# filepath: /c:/the_dev/final_year/vasas/backend/vasas_project/vasas_chatbot/views.py
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from ollama import chat
from .serializers import ChatbotSerializer
from .models import ChatMessage

class ChatbotView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChatbotSerializer(data=request.data)
        if serializer.is_valid():
            user_message = serializer.validated_data['user_message']
            response = chat(model='llama3.2', messages=[{'role': 'user', 'content': user_message}])
            bot_response = response.message.content
            
            # Perform sentiment analysis (dummy example)
            sentiment = "positive" if "happy" in user_message else "negative"
            
            # Save the chat message and sentiment to the database
            chat_message = ChatMessage.objects.create(
                user_message=user_message,
                bot_response=bot_response,
                sentiment=sentiment
            )
            
            return Response({'bot_response': bot_response, 'sentiment': sentiment}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)