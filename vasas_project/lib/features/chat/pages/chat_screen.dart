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

  // void _handleSendPressed(types.PartialText message) async {
  //   final processedText = _preprocessInput(message.text);

  //   final userMessage = types.TextMessage(
  //     author: _user,
  //     createdAt: DateTime.now().millisecondsSinceEpoch,
  //     id: UniqueKey().toString(),
  //     text: processedText,
  //   );

  //   setState(() {
  //     _messages.insert(0, userMessage);
  //     // _scrollController.animateTo(
  //     //   0,
  //     //   duration: const Duration(milliseconds: 300),
  //     //   curve: Curves.easeOut,
  //     // );
  //   });

  //   try {
  //     // Send message to bot and get response
  //     final Map<String, dynamic> response =
  //         await ChatbotService.sendMessageToBot(processedText);

  //     // Extract bot response and event details
  //     final String botResponseText = response['bot_response'] as String;
  //     final bool hasEvent = response['has_event'] ?? false;
  //     final Map<String, dynamic>? eventDetails = response['event_details'];

  //     // Add bot message to chat
  //     final botMessage = types.TextMessage(
  //       author: _bot,
  //       createdAt: DateTime.now().millisecondsSinceEpoch,
  //       id: UniqueKey().toString(),
  //       text: _postprocessResponse(botResponseText),
  //     );

  //     setState(() {
  //       _messages.insert(0, botMessage);
  //     });

  //     // Save chat message
  //     final chatMessage = ChatMessage(
  //       userMessage: processedText,
  //       botResponse: botResponseText,
  //       timestamp: DateTime.now(),
  //     );
  //     await _sendChatMessageToBackend(chatMessage);

  //     // Show event dialog if event detected
  //     if (hasEvent && eventDetails != null) {
  //       Future.delayed(const Duration(milliseconds: 500), () {
  //         if (mounted) {
  //           _showEventConfirmationDialog(eventDetails);
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     print('Error in _handleSendPressed: $e'); // Debug log
  //     _showError('Failed to get response from bot: ${e.toString()}');
  //   }
  // }
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
    });

    try {
      final Map<String, dynamic> chatResponse =
          await ChatbotService.sendMessageToBot(processedText);
      //final eventResponse = await EventService.detectEvent(processedText);
      //final bool hasEvent = response['has_event'] ?? false;
      //final Map<String, dynamic>? eventDetails = chatResponse['event_details'];
      final eventResponse = await EventService.detectEvent(processedText);
      if (eventResponse['event_details'] != null) {
        //_showQuickEventForm(eventResponse['event_details']);
        _showEventDetailsDialog(eventResponse['event_details']);
      }
      // If event detected, show form directly
      // if (hasEvent && eventDetails != null) {
      //   _showEventDetailsDialog(eventDetails);
      // }

      // Add bot confirmation message
      final botMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: UniqueKey().toString(),
        text: chatResponse['bot_response'],
      );

      setState(() {
        _messages.insert(0, botMessage);
      });
    } catch (e) {
      print('Error: $e');
      _showError('Failed to process message');
    }
  }

// New streamlined event form
  void _showQuickEventForm(Map<String, dynamic> eventDetails) {
    final title = eventDetails['type'] ?? '';
    final location = eventDetails['location'] ?? '';
    final startTime =
        DateTime.tryParse(eventDetails['time'] ?? '') ?? DateTime.now();
    final endTime = startTime.add(const Duration(hours: 1));
    final eventType = eventDetails['type']?.toUpperCase() ?? 'OTHER';
    String description = eventDetails['description'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quick Event Setup'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Type: $eventType'),
                subtitle: Text('Location: $location'),
              ),
              ListTile(
                title: Text('Start: ${startTime.toString()}'),
                subtitle: Text('End: ${endTime.toString()}'),
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Add Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ChatbotPage()),
              );
              _createEvent(Event(
                id: 0,
                title: title,
                description: description,
                eventType: eventType,
                startTime: startTime,
                endTime: endTime,
                location: location,
              ).toJson());
              print(Event);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  // Navigate to Chatbot Page

// Add this method for initial confirmation
  // void _showEventConfirmationDialog(Map<String, dynamic> eventDetails) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) => AlertDialog(
  //       title: const Text('Event Detected'),
  //       content: Text('Would you like to schedule a ${eventDetails['type']} '
  //           'at ${eventDetails['time']} in ${eventDetails['location']}?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('No'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _showEventDetailsDialog(eventDetails);
  //           },
  //           child: const Text('Yes'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // void _handleSendPressed(types.PartialText message) async {
  //   final processedText = _preprocessInput(message.text);

  //   final userMessage = types.TextMessage(
  //     author: _user,
  //     createdAt: DateTime.now().millisecondsSinceEpoch,
  //     id: UniqueKey().toString(),
  //     text: processedText,
  //   );

  //   setState(() {
  //     _messages.insert(0, userMessage);
  //   });

  //   try {
  //     final response = await ChatbotService.sendMessageToBot(processedText);

  //     // Check for event intent
  //     if (response['has_event'] == true) {
  //       _showEventDialog(response['event_details']);
  //     }

  //     final botMessage = types.TextMessage(
  //       author: _bot,
  //       createdAt: DateTime.now().millisecondsSinceEpoch,
  //       id: UniqueKey().toString(),
  //       text: response['bot_response'],
  //     );

  //     setState(() {
  //       _messages.insert(0, botMessage);
  //     });
  //   } catch (e) {
  //     _showError('Failed to get response from bot');
  //   }
  // }

  void _showEventDetailsDialog(Map<String, dynamic> eventDetails) {
    String title = eventDetails['type'] ?? '';
    String description = '';
    String location = eventDetails['location'] ?? '';
    DateTime startTime =
        DateTime.tryParse(eventDetails['time'] ?? '') ?? DateTime.now();
    DateTime endTime = startTime.add(const Duration(hours: 1));
    String eventType = eventDetails['type']?.toUpperCase() ?? 'OTHER';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Schedule Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: title),
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
                ),
                value: eventType,
                items: const [
                  DropdownMenuItem(
                      value: 'APPOINTMENT', child: Text('Appointment')),
                  DropdownMenuItem(value: 'EXAM', child: Text('Exam')),
                  DropdownMenuItem(value: 'MEETING', child: Text('Meeting')),
                  DropdownMenuItem(value: 'DATE', child: Text('Date')),
                  DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                ],
                onChanged: (value) => eventType = value ?? 'OTHER',
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: location),
                onChanged: (value) => location = value,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDateTimePicker(
                    context: context,
                    initialDate: startTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    startTime = picked;
                    endTime = picked.add(const Duration(hours: 1));
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(startTime.toString()),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDateTimePicker(
                    context: context,
                    initialDate: endTime,
                    firstDate: startTime,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    endTime = picked;
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(endTime.toString()),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ChatbotPage()));

              final event = Event(
                id: 0,
                title: title,
                description: description,
                eventType: eventType,
                startTime: startTime,
                endTime: endTime,
                location: location,
              );
              _createEvent(event.toJson());
            },
            child: const Text('Save'),
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

  // void _createEvent(Map<String, dynamic> eventDetails) async {
  //   try {
  //     final event = Event(
  //       id: 0, // Will be set by backend
  //       title: eventDetails['type'],
  //       description: eventDetails['description'] ?? '',
  //       eventType: eventDetails['type'].toUpperCase(),
  //       startTime: DateTime.parse(eventDetails['time']),
  //       endTime:
  //           DateTime.parse(eventDetails['time']).add(const Duration(hours: 1)),
  //       location: eventDetails['location'],
  //     );

  //     await EventService.createEvent(event.toJson());

  //     if (mounted) {
  //       Navigator.pop(context); // Close dialog
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Event created successfully')),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       Navigator.pop(context);
  //       _showError('Failed to create event: $e');
  //     }
  //   }
  // }
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
}
