import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:vasas_project/core/constants/urls.dart';
import 'package:vasas_project/features/auth/apis/auth_service.dart';

class ChatbotService {
  static Future<Map<String, dynamic>> sendMessageToBot(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getAccessToken()}',
        },
        body: jsonEncode({
          'user_message': message,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          return responseData;
        } catch (e) {
          throw Exception('Invalid JSON response: ${response.body}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('ChatbotService error: $e');
      throw Exception('Failed to communicate with bot: $e');
    }
  }

  // Send audio to chatbot for speech recognition
  static Future<String> sendAudioToBot(File audioFile) async {
    final accessToken = await AuthService.getAccessToken();
    final url = Uri.parse('$baseUrl/api/speech-recognition/');
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
