import 'package:flutter/material.dart';
import 'package:vasas_project/features/app/pages/settings.dart';
import 'package:vasas_project/features/chat/pages/chat_screen.dart';
import 'package:vasas_project/features/event_scheduling/apis/event_service.dart';
import 'package:vasas_project/features/event_scheduling/models/event_model.dart';
import 'package:vasas_project/features/home/apis/sentiment_analysis_services.dart';
import 'package:vasas_project/features/notifications/pages/notifications.dart';

class WorkSpacePage extends StatefulWidget {
  const WorkSpacePage({super.key});

  @override
  State<WorkSpacePage> createState() => _WorkSpacePageState();
}

class _WorkSpacePageState extends State<WorkSpacePage> {
  String sentimentMessage = "Loading sentiment analysis...";
  String level = "";
  String state = "";

  List<Event> _events = [];
  bool _isLoading = true;
  String _errorMessage = '';

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchSentiment();
    fetchEvents();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatbotPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    }
  }

  Future<void> fetchSentiment() async {
    try {
      final data = await ApiService.fetchSentimentAnalysis();
      setState(() {
        sentimentMessage = data['overall_well_being'];
        level = data['level'];
        state = data['state'];
      });
    } catch (e) {
      setState(() {
        sentimentMessage = "Failed to load sentiment analysis.";
      });
    }
  }

  Future<void> fetchEvents() async {
    try {
      List<Event> events = await EventService.fetchEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching events: $e';
        _isLoading = false;
      });
    }
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Type: ${event.eventType}"),
            Text("Location: ${event.location}"),
            Text("Start Time: ${event.startTime}"),
            Text("End Time: ${event.endTime}"),
            Text("Description: ${event.description}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/person_animation.png'),
            ),
            SizedBox(width: 10),
            Text(
              "My WorkSpace",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Spacer(),
            Icon(Icons.settings, color: Colors.black),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current user's sentiment",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sentimentMessage,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Level: $level",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "State: $state",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Pending Events",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : ListView.builder(
                          itemCount: _events.length,
                          itemBuilder: (context, index) {
                            final event = _events[index];
                            return GestureDetector(
                              onTap: () => _showEventDetails(event),
                              child: eventCard(
                                event.title,
                                event.description,
                                //event.startTime.toString(),
                                event.location,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  Widget eventCard(
      String title,
      String subtitle,
      //String date,
      String location) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.event, color: Colors.black),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text(
                //   date,
                //   style: const TextStyle(
                //       fontSize: 14, fontWeight: FontWeight.bold),
                // ),
                Text(
                  location,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
