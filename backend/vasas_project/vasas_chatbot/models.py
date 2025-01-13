from django.db import models
from django.contrib.auth import get_user_model

class ChatMessage(models.Model):
    user = models.ForeignKey(get_user_model(), null=True, blank=True, on_delete=models.CASCADE)
    user_message = models.TextField()
    bot_response = models.TextField()
    sentiment = models.CharField(max_length=10, default="neutral")
    timestamp = models.DateTimeField(auto_now_add=True)

class Event(models.Model):
    user = models.ForeignKey(get_user_model(), null=True, blank=True, on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    date = models.DateField()
    time = models.TimeField()
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)