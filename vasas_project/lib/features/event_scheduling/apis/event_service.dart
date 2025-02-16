import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vasas_project/features/auth/apis/auth_service.dart';
import 'package:vasas_project/features/event_scheduling/models/event_model.dart';

class EventService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/events';

  // Detect event in message
  static Future<Map<String, dynamic>> detectEvent(String text) async {
    final accessToken = await AuthService.getAccessToken();
    final url = Uri.parse('$baseUrl/detect/');

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

  // Create event after confirmation
  static Future<Event> createEvent(Map<String, dynamic> eventData) async {
    final accessToken = await AuthService.getAccessToken();
    final url = Uri.parse('$baseUrl/create/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(eventData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create event: ${response.body}');
    }
  }
}
