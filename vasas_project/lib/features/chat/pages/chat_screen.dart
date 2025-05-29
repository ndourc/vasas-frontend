// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vasas_project/features/chat/apis/chat_services.dart';
// ignore: depend_on_referenced_packages
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:vasas_project/features/chat/models/chat_message_model.dart';
import 'package:vasas_project/features/home/pages/workspace.dart';
import 'package:vasas_project/features/event_scheduling/apis/event_service.dart';
import 'package:vasas_project/features/event_scheduling/models/event_model.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
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
    try {
      // Check microphone permission first
      var status = await Permission.microphone.status;
      if (status.isDenied) {
        status = await Permission.microphone.request();
        if (status.isDenied) {
          _showError('Microphone permission is required');
          return;
        }
      }

      // Initialize speech recognition
      bool available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: true,
        finalTimeout: const Duration(milliseconds: 2000),
      );

      debugPrint('Speech recognition available: $available');
      if (!available) {
        _showError('Speech recognition not available on this device');
      }
    } catch (e) {
      debugPrint('Speech initialization error: $e');
      _showError('Failed to initialize speech recognition');
    }
  }

  void _onSpeechStatus(String status) {
    debugPrint('Speech status: $status');
    if (!mounted) return;

    if (status == 'done' || status == 'notListening') {
      setState(() {
        _isListening = false;
        // Ensure final text is in TextField
        if (_recognizedText.isNotEmpty) {
          _textController.value = TextEditingValue(
            text: _recognizedText,
            selection: TextSelection.collapsed(offset: _recognizedText.length),
          );
        }
      });
    }
  }

  // void _onSpeechError(SpeechRecognitionError error) {
  //   debugPrint('Speech error: ${error.errorMsg}');
  //   if (!mounted) return;
  //   if (error.errorMsg == 'error_speech_timeout') {
  //     _speech.stop();
  //     setState(() {
  //       _isListening = false;
  //       // If we have recognized text, send it to input
  //       if (_recognizedText.isNotEmpty) {
  //         _sendRecognizedTextToInput();
  //       }
  //     });
  //     return;
  //   }

  //   if (error.permanent) {
  //     setState(() {
  //       _isListening = false;
  //     });

  //     // Show error message only if widget is still mounted
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Speech recognition error: ${error.errorMsg}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }
  void _onSpeechError(SpeechRecognitionError error) {
    debugPrint('Speech error: ${error.errorMsg}');
    if (!mounted) return;

    // Stop listening and reset state
    _speech.stop();
    setState(() => _isListening = false);

    // Handle specific error cases
    String errorMessage;
    switch (error.errorMsg) {
      case 'error_no_match':
        errorMessage = 'No speech was detected. Please try again.';
        break;
      case 'error_speech_timeout':
        errorMessage = 'No speech detected for a while.';
        break;
      case 'error_network':
        errorMessage = 'Network error occurred. Check your connection.';
        break;
      default:
        errorMessage = 'Speech recognition error: ${error.errorMsg}';
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _startListening() async {
    if (!_isListening) {
      try {
        // Check if speech recognition is available
        bool available = await _speech.initialize(
          onStatus: _onSpeechStatus,
          onError: _onSpeechError,
        );

        if (!available) {
          _showError('Speech recognition not available');
          return;
        }

        // Set state before starting
        setState(() {
          _isListening = true;
          _recognizedText = '';
          // _textController.clear();
        });

        await _speech.listen(
          onResult: (result) {
            debugPrint('Speech result received: ${result.recognizedWords}');
            if (!mounted) return;

            // setState(() {
            //   _recognizedText = result.recognizedWords;
            //   // Update text controller even with partial results
            //   if (result.recognizedWords.isNotEmpty) {
            //     _textController.text = result.recognizedWords;
            //     debugPrint('Updated text controller: ${_textController.text}');
            //   }
            // });
            setState(() {
              // _recognizedText = result.recognizedWords;
              // Update text controller and force TextField rebuild
              if (result.recognizedWords.isNotEmpty) {
                _textController.value = TextEditingValue(
                  text: result.recognizedWords,
                  selection: TextSelection.collapsed(
                      offset: result.recognizedWords.length),
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {});
                  }
                });
              }
            });
          },
          listenFor: const Duration(seconds: 30), // Increased listen time
          pauseFor: const Duration(seconds: 3), // Reduced pause time
          partialResults: true,
          onDevice: false, // Changed to on-device
          listenMode: stt.ListenMode.deviceDefault, // Changed listen mode
          cancelOnError: false, // Don't cancel on error
        );

        debugPrint("Speech recognition started");
      } catch (e) {
        debugPrint("Speech recognition error: $e");
        setState(() => _isListening = false);
        _showError("Failed to start speech recognition");
      }
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      try {
        await _speech.stop();
        setState(() {
          _isListening = false;
          // Ensure the recognized text is in the chat input field
          if (_recognizedText.isNotEmpty) {
            _textController.value = TextEditingValue(
              text: _recognizedText,
              selection:
                  TextSelection.collapsed(offset: _recognizedText.length),
            );
          }
        });

        // Optional: Trigger message send if needed
        if (_recognizedText.isNotEmpty) {
          _handleSendPressed(types.PartialText(text: _recognizedText));
          _recognizedText = '';
        }
      } catch (e) {
        debugPrint("Error stopping speech recognition: $e");
        _showError("Failed to stop listening");
      }
    }
  }

  void _sendRecognizedTextToInput() {
    if (_recognizedText.trim().isNotEmpty) {
      _textController.text = _recognizedText.trim();
      _recognizedText = '';
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    final inputText =
        _recognizedText.isNotEmpty ? _recognizedText : message.text;
    final processedText = _preprocessInput(inputText);

    _textController.clear();

    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: UniqueKey().toString(),
      text: processedText,
    );

    setState(() {
      _messages.insert(0, userMessage);
    });

    try {
      final Map<String, dynamic> chatResponse =
          await ChatbotService.sendMessageToBot(processedText);

      final Map<String, dynamic> eventResponse =
          await EventService.detectEvent(processedText);
      final bool hasEvent = eventResponse['has_event'] ?? false;
      final eventDetails = eventResponse['event_details'];

      final botMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: UniqueKey().toString(),
        text: chatResponse['bot_response'] ?? "I couldn't understand that.",
      );

      setState(() {
        _messages.insert(0, botMessage);
      });
      if (mounted && hasEvent && eventDetails != null) {
        Future.delayed(Duration.zero, () {
          _showEventDetailsDialog(eventDetails);
        });
      }
    } catch (e) {
      print('Error: $e');
      _showError('Failed to process message');
    }
  }

  void _detectEvent(String text) async {
    try {
      final Map<String, dynamic> eventResponse =
          await EventService.detectEvent(text);
      if (eventResponse['event_details'] != null) {
        _showEventDialog(eventResponse['event_details']);
      }
    } catch (e) {
      print('Event detection failed silently.');
    }
  }

  void _showEventDialog(Map<String, dynamic> eventDetails) {
    String title = eventDetails['type'] ?? '';
    String location = eventDetails['location'] ?? '';
    String description = eventDetails['description'] ?? '';
    DateTime startTime =
        DateTime.tryParse(eventDetails['time'] ?? '') ?? DateTime.now();
    DateTime endTime = startTime.add(const Duration(hours: 1));
    String eventType = eventDetails['type']?.toUpperCase() ?? 'OTHER';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Event'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                    labelText: 'Title', border: OutlineInputBorder()),
                controller: TextEditingController(text: title),
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                    labelText: 'Location', border: OutlineInputBorder()),
                controller: TextEditingController(text: location),
                onChanged: (value) => location = value,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                    labelText: 'Description', border: OutlineInputBorder()),
                controller: TextEditingController(text: description),
                onChanged: (value) => description = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _createEvent(Event(
                title: title,
                description: description,
                eventType: eventType,
                startTime: startTime,
                endTime: endTime,
                location: location,
              ).toJson());
            },
            child: const Text('Save Event'),
          ),
        ],
      ),
    );
  }

// New streamlined event form
  // void _showQuickEventForm(Map<String, dynamic> eventDetails) {
  //   final title = eventDetails['type'] ?? '';
  //   final location = eventDetails['location'] ?? '';
  //   final startTime =
  //       DateTime.tryParse(eventDetails['time'] ?? '') ?? DateTime.now();
  //   final endTime = startTime.add(const Duration(hours: 1));
  //   final eventType = eventDetails['type']?.toUpperCase() ?? 'OTHER';
  //   String description = eventDetails['description'] ?? '';

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Quick Event Setup'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               title: Text('Type: $eventType'),
  //               subtitle: Text('Location: $location'),
  //             ),
  //             ListTile(
  //               title: Text('Start: ${startTime.toString()}'),
  //               subtitle: Text('End: ${endTime.toString()}'),
  //             ),
  //             TextField(
  //               decoration: const InputDecoration(
  //                 labelText: 'Add Notes (Optional)',
  //                 border: OutlineInputBorder(),
  //               ),
  //               maxLines: 2,
  //               onChanged: (value) => description = value,
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pushReplacement(
  //               context,
  //               MaterialPageRoute(builder: (context) => const ChatbotPage()),
  //             );
  //             _createEvent(Event(
  //               id: 0,
  //               title: title,
  //               description: description,
  //               eventType: eventType,
  //               startTime: startTime,
  //               endTime: endTime,
  //               location: location,
  //             ).toJson());
  //             print(Event);
  //           },
  //           child: const Text('Save'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showEventDetailsDialog(Map<String, dynamic> eventDetails) {
    String title = eventDetails['type'] ?? '';
    String location = eventDetails['location'] ?? '';
    String description = eventDetails['description'] ?? '';
    DateTime startTime =
        DateTime.tryParse(eventDetails['date'] ?? '') ?? DateTime.now();
    DateTime endTime = startTime.add(const Duration(hours: 1));
    String eventType = eventDetails['type']?.toUpperCase() ?? 'OTHER';

    showDialog(
      context: context,
      barrierDismissible: true, // <- user can dismiss if they want
      builder: (context) => AlertDialog(
        title: const Text('Schedule Event'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: title),
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: location),
                onChanged: (value) => location = value,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: description),
                onChanged: (value) => description = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _createEvent(Event(
                title: title,
                description: description,
                eventType: eventType,
                startTime: startTime,
                endTime: endTime,
                location: location,
              ).toJson());
            },
            child: const Text('Save Event'),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _createEvent(Map<String, dynamic> eventDetails) async {
    try {
      final event = Event(
        title: eventDetails['title'] ?? 'Unknown Event',
        description: eventDetails['description'] ?? '',
        eventType: eventDetails['event_type']?.toUpperCase() ?? 'OTHER',
        startTime: DateTime.parse(eventDetails['start_time']),
        endTime: DateTime.parse(eventDetails['end_time'])
            .add(const Duration(hours: 1)),
        location: eventDetails['location'] ?? 'Not Specified',
      );

      final createdEvent = await EventService.createEvent(event.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event Created: ${createdEvent.title}')),
      );
    } catch (e) {
      _showError('Failed to create event: $e');
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
    _speech.cancel();
    _scrollController.dispose();
    _textController.dispose();
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
                customBottomWidget: _buildInputField(),
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
              onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WorkSpacePage()),
                  )),
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

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  _handleSendPressed(types.PartialText(text: text));
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_textController.text.trim().isNotEmpty) {
                _handleSendPressed(
                    types.PartialText(text: _textController.text));
                _textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
