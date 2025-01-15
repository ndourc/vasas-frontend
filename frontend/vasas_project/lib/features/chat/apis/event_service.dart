import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vasas_project/features/auth/apis/auth_service.dart';
import '../models/event_model.dart';

class EventService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<void> scheduleEvent(Event event) async {
    final accessToken = await AuthService.getAccessToken();
    final url = Uri.parse('$baseUrl/api/events/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(event.toJson()),
    );

    if (response.statusCode == 201) {
      print('Event scheduled successfully');
    } else {
      print('Failed to schedule event: ${response.body}');
    }
  }
}
