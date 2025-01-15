import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:vasas_project/features/chat/apis/chat_services.dart';
import 'package:vasas_project/features/chat/apis/event_service.dart';
import '../models/event_model.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user-id');
  final _bot = const types.User(id: 'bot-id');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            headerChat(),
            Expanded(
              child: Chat(
                messages: _messages,
                onSendPressed: _handleSendPressed,
                user: _user,
                theme: const DefaultChatTheme(
                  inputBackgroundColor: Colors.white,
                  inputTextColor: Colors.black,
                  primaryColor: Colors.green,
                  secondaryColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 175, 173, 173),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget headerChat() {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 175, 173, 173),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        children: [
          const Icon(Icons.arrow_back_ios),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.person),
          ),
          const SizedBox(width: 5),
          const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Savannah",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Icon(Icons.check_circle, color: Colors.green, size: 15),
                ],
              ),
              Text("Vasas 1.1"),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) async {
    final preprocessedMessage = preprocessUserInput(message.text);

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: preprocessedMessage,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    final botResponse =
        await ChatbotService.sendMessageToBot(preprocessedMessage);
    final postprocessedResponse = postprocessBotResponse(botResponse);

    final botMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: postprocessedResponse,
    );

    setState(() {
      _messages.insert(0, botMessage);
    });

    // Check for event-related keywords
    if (postprocessedResponse
        .contains("Should I set a reminder for this event?")) {
      _scheduleEventDialog(preprocessedMessage);
    }
  }

  String preprocessUserInput(String input) {
    // Example: Remove or replace certain keywords
    input = input.replaceAll('Meta', 'Your Company');
    return input;
  }

  String postprocessBotResponse(String response) {
    // Example: Remove or replace certain keywords
    response = response.replaceAll('Meta', 'Your Company');
    return response;
  }

  void _scheduleEventDialog(String userMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Schedule Event"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Please provide the following details:"),
              TextField(
                decoration: InputDecoration(labelText: "Date (YYYY-MM-DD)"),
                onChanged: (value) {
                  // Store the date value
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: "Time (HH:MM)"),
                onChanged: (value) {
                  // Store the time value
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: "Description"),
                onChanged: (value) {
                  // Store the description value
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: "Venue"),
                onChanged: (value) {
                  // Store the venue value
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Submit"),
              onPressed: () {
                Navigator.of(context).pop();
                _scheduleEvent(userMessage);
              },
            ),
          ],
        );
      },
    );
  }

  void _scheduleEvent(String userMessage) {
    // Extract event details from userMessage (e.g., date, time, title)
    // For simplicity, we'll use hardcoded values here
    final event = Event(
      title: "Exam",
      date: DateTime(2023, 1, 17),
      time: TimeOfDay(hour: 9, minute: 0),
      description: userMessage,
      venue: "Your Venue",
    );

    EventService.scheduleEvent(event);
  }
}
