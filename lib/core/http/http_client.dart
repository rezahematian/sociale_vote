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

  Future<Map<String, String>> _headers() async {
    final session = await authStorage.load();
    final token = session?.token.value;

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) async {
    return http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
  }
}