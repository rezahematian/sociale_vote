import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/auth_storage.dart';

class HttpClient {
  final String baseUrl;
  final AuthStorage authStorage;

  HttpClient({
    required this.baseUrl,
    required this.authStorage,
  });

  Map<String, String> _headers() {
    final token = authStorage.session?.token.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) {
    return http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
    );
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) {
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
      body: jsonEncode(body),
    );
  }
}
