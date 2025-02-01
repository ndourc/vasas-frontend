import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vasas_project/features/chat/apis/chat_services.dart';
// ignore: depend_on_referenced_packages
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:vasas_project/features/chat/models/chat_message_model.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final AutoScrollController _scrollController = AutoScrollController();

  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user-id');
  final _bot = const types.User(id: 'bot-id');
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => _onSpeechStatus(status),
      onError: (error) => _onSpeechError(error),
    );
    if (!mounted) return;
    setState(() {
      _isListening = available;
    });
  }

  void _onSpeechStatus(String status) {
    debugPrint('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    debugPrint('Speech error: $error');
    if (error.permanent) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => setState(() {
            _recognizedText = result.recognizedWords;
            if (result.finalResult) {
              _sendRecognizedTextToBot();
            }
          }),
          listenFor:
              const Duration(minutes: 5), // Adjust the listening duration
          pauseFor: const Duration(seconds: 10), // Adjust the pause duration
        );
        print("Listening for 5 minutes");
      }
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      if (_recognizedText.isNotEmpty) {
        _sendRecognizedTextToBot();
      }
    }
  }

  void _sendRecognizedTextToBot() {
    if (_recognizedText.trim().isNotEmpty) {
      _handleSendPressed(types.PartialText(text: _recognizedText));
      setState(() => _recognizedText = '');
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    final processedText = _preprocessInput(message.text);

    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: UniqueKey().toString(),
      text: processedText,
    );

    setState(() {
      _messages.insert(0, userMessage);
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      final botResponse = await ChatbotService.sendMessageToBot(processedText);
      final botMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: UniqueKey().toString(),
        text: _postprocessResponse(botResponse),
      );

      setState(() {
        _messages.insert(0, botMessage);
      });

      // Serialize and send the data to the backend
      final chatMessage = ChatMessage(
        userMessage: processedText,
        botResponse: botResponse,
        timestamp: DateTime.now(),
      );

      await _sendChatMessageToBackend(chatMessage);
    } catch (e) {
      _showError('Failed to get response from bot');
    }
  }

  Future<void> _sendChatMessageToBackend(ChatMessage chatMessage) async {
    try {
      await ChatbotService.sendMessageToBot(chatMessage.userMessage);
    } catch (e) {
      _showError('Failed to send data to backend');
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Chat(
                messages: _messages,
                onSendPressed: _handleSendPressed,
                user: _user,
                theme: _buildChatTheme(),
                scrollController: _scrollController,
              ),
            ),
            _buildListeningUI(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 175, 173, 173),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Savannah",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                ],
              ),
              Text("Vasas 1.1", style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  DefaultChatTheme _buildChatTheme() {
    return const DefaultChatTheme(
      inputBackgroundColor: Colors.white,
      inputTextColor: Colors.black,
      primaryColor: Colors.green,
      secondaryColor: Colors.white,
      backgroundColor: Color.fromARGB(255, 175, 173, 173),
      inputBorderRadius: BorderRadius.all(Radius.circular(25)),
      sendButtonIcon: Icon(Icons.send, color: Colors.green),
    );
  }

  Widget _buildListeningUI() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                _isListening ? 'Listening...' : 'Tap mic to speak',
                style: TextStyle(
                  color: _isListening ? Colors.green : Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: _isListening ? _stopListening : _startListening,
            backgroundColor: _isListening ? Colors.red : Colors.green,
            child: Icon(_isListening ? Icons.stop : Icons.mic_none),
          ),
        ],
      ),
    );
  }

  String _preprocessInput(String input) {
    return input.replaceAll('Meta', 'Your Company').trim();
  }

  String _postprocessResponse(String response) {
    return response.replaceAll('Meta', 'Your Company').trim();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
