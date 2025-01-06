import 'package:avatars/avatars.dart';
import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 175, 173, 173),
      body: SafeArea(
          child: Column(
        children: [
          headerChat(),
          bodyChat(),
        ],
      )),
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
                          color: Colors.black),
                    ),
                    Icon(Icons.check_circle, color: Colors.green, size: 15),
                  ],
                ),
                Text("Vasas 1.1")
              ])
        ],
      ),
    );
  }

  Widget bodyChat() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            itemChat(
              chat: 1,
              message: "Hello",
              avatar: "Henry Ndou",
              time: "12:00",
            )
          ],
        ),
      ),
    );
  }
}

Widget itemChat({
  required int chat,
  required String message,
  required String avatar,
  required String time,
}) {
  return Row(
    mainAxisAlignment:
        chat == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Avatar(useCache: true, name: avatar, shape: AvatarShape.circle(25)),
      Flexible(
          child: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: chat == 0
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ))
    ],
  );
}
