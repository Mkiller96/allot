import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String baseUrl = const String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:5000/api',
  );
  static VoidCallback? onUnauthorized;

  final String? _token;
  const ApiService([this._token]);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _parse(res);
  }

  Future<dynamic> get(String path, {Map<String, String>? params}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: params);
    final res = await http.get(uri, headers: _headers);
    return _parse(res);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final res = await http.delete(Uri.parse('$baseUrl$path'), headers: _headers);
    return _parse(res);
  }

  dynamic _parse(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      if (res.statusCode == 401) {
        onUnauthorized?.call();
      }
      final msg = (body is Map ? body['error'] ?? body['message'] : null)
          ?? 'Error ${res.statusCode}';
      throw ApiException(msg as String, res.statusCode);
    }
    return body;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}
