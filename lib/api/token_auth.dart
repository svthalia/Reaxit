import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthResponse {
  bool success;
  String message;
  String token;

  AuthResponse(this.success, {this.message, this.token});
}

class TokenAuth {
  static Map<String,String> _headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  static Future<AuthResponse> authenticate(String username, String password) async {
    String body = jsonEncode({
      'username': username,
      'password': password
    });

    try {
      http.Response response = await http.post('https://thalia.nu/api/v1/token-auth/', headers: _headers, body: body);

      if (response.statusCode == 200)
        return AuthResponse(true, message: 'Logged in.', token: jsonDecode(response.body)['token']);
      else
        return AuthResponse(false, message: 'Login failed.');
    } catch(e) {
      return AuthResponse(false, message: 'No internet.');
    }
  }
}