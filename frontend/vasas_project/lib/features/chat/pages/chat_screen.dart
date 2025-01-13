import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vasas_project/features/auth/apis/auth_service.dart';

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
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    final botResponse = await _sendMessageToBot(message.text);

    final botMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: botResponse,
    );

    setState(() {
      _messages.insert(0, botMessage);
    });
  }

  Future<String> _sendMessageToBot(String message) async {
    final accessToken = await AuthService.getAccessToken();
    final url = Uri.parse('http://127.0.0.1:8000/api/chat/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'user_message': message}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['bot_response'];
    } else {
      print('Failed to get response from bot: ${response.body}');
      return 'Error: Unable to get response from bot';
    }
  }
}
