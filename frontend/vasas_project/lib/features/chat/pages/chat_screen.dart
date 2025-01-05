import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savannah - Your Virtual Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ChatBubble(
                    isUser: true,
                    text:
                        "Hi Savannah, I’m feeling overwhelmed with my studies. Can you help me create a study plan?"),
                ChatBubble(
                    isUser: false,
                    text:
                        "Hello! I’m here to help. Let’s break it down together. Could you tell me which subjects or topics you’re working on and how much time you can dedicate each day?"),
                ChatBubble(
                    isUser: true,
                    text:
                        "I have exams in Math, Biology, and History. I can spend about 4 hours daily on studying."),
                ChatBubble(
                    isUser: false,
                    text:
                        "Got it! Based on your subjects and available time, here’s a suggested study plan:\n\nMath: 1.5 hours – Focus on problem-solving and past papers.\nBiology: 1 hour – Review notes and diagrams.\nHistory: 1.5 hours – Study timelines and key events."),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Add send message logic here
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String text;

  ChatBubble({super.key, required this.isUser, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
