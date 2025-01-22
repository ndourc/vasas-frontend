import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:vasas_project/features/auth/apis/auth_service.dart';

class ChatbotService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Send message to chatbot
  static Future<String> sendMessageToBot(String message) async {
    final accessToken = await AuthService.getAccessToken();
    final url = Uri.parse('$baseUrl/api/chat/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'user_message': message}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['bot_response'];
    } else {
      print('Failed to get response from bot: ${response.body}');
      return 'Error: Unable to get response from bot. Contact administrator or developers.';
    }
  }

  // Send audio to chatbot for speech recognition
  static Future<String> sendAudioToBot(File audioFile) async {
    final accessToken = await AuthService.getAccessToken();
    final url = Uri.parse('$baseUrl/speech-recognition/');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..files.add(await http.MultipartFile.fromPath('audio', audioFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final responseJson = json.decode(responseData.body);
      return responseJson['recognized_text'];
    } else {
      print('Failed to get response from bot: ${response.reasonPhrase}');
      return 'Error: Unable to get response from bot. Contact administrator or developers.';
    }
  }
}
