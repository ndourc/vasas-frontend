import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Registration function
  static Future<void> registerUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/users/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        're_password': password,
      }),
    );

    if (response.statusCode == 201) {
      print('Registration successful');
    } else {
      print('Registration failed: ${response.body}');
    }
  }

  // Login function
  static Future<void> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/jwt/create/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      String accessToken = responseData['access'];
      String refreshToken = responseData['refresh'];

      // Save the tokens in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('refreshToken', refreshToken);
      print('Login successful, tokens stored: $accessToken');
    } else {
      print('Login failed: ${response.body}');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('accessToken');
  }

  // Logout function
  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    print('Logout successful');
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
}
