import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vasas_project/features/auth/apis/auth_service.dart';
import 'package:vasas_project/features/event_scheduling/models/event_model.dart';

class EventService {
  static const String eventBaseUrl = 'http://10.0.2.2:8000/api/events';

  static Future<Map<String, dynamic>> detectEvent(String text) async {
    final accessToken = await AuthService.getAccessToken();
    final url = Uri.parse('$eventBaseUrl/detect/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to detect event');
    }
  }

  static Future<Event> createEvent(Map<String, dynamic> eventData) async {
    final accessToken = await AuthService.getAccessToken();
    final url = Uri.parse('$eventBaseUrl/events/create/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(eventData),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return Event.fromJson(responseData);
    } else {
      throw Exception('Failed to create event: ${response.body}');
    }
  }

  static Future<List<Event>> fetchEvents() async {
    final accessToken = await AuthService.getAccessToken();
    final url = Uri.parse('$eventBaseUrl/get-events/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = jsonDecode(response.body);
      return eventList.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to fetch events: ${response.body}');
    }
  }
}
