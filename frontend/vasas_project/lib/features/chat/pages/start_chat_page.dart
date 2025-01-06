import 'package:flutter/material.dart';
import 'package:vasas_project/features/chat/pages/chat_screen.dart';

class StartChatPage extends StatefulWidget {
  const StartChatPage({super.key});

  @override
  State<StartChatPage> createState() => _StartChatPageState();
}

class _StartChatPageState extends State<StartChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child:
                  Image.asset('assets/person_animation.png', fit: BoxFit.cover),
            ),
            Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.circle_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Get The Help You Need, Anytime!',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start a conversation with your virtual assistant to get academic support, personalized study plans, or answers to your questions.',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChatbotPage()),
                          ); // Navigate to Chatbot Page
                        },
                        child: const Text(
                          'Start Chat',
                          style: TextStyle(color: Colors.green),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
