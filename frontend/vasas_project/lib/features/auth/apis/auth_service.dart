import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';

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
    final url = Uri.parse('$baseUrl/auth/token/login/');
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
      String authToken = responseData['auth_token'];

      // Save the token in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', authToken);
      print('Login successful, token stored: $authToken');
    } else {
      print('Login failed: ${response.body}');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('authToken');
  }

  // Logout function
  static Future<void> logoutUser() async {
    final url = Uri.parse('$baseUrl/auth/token/logout/');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $authToken',
      },
    );

    if (response.statusCode == 204) {
      await prefs.remove('authToken');
      print('Logout successful');
    } else {
      print('Logout failed: ${response.body}');
    }
  }
}
