class ChatMessage {
  final String userMessage;
  final String botResponse;
  final String sentiment;
  final DateTime timestamp;

  ChatMessage({
    required this.userMessage,
    required this.botResponse,
    this.sentiment = "neutral",
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_message': userMessage,
      'bot_response': botResponse,
      'sentiment': sentiment,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
