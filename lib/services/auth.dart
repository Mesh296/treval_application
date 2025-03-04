// services/auth.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthApi {
  static const String baseUrl =;
  static const String firebaseApiKey = ;
  static const _storage = FlutterSecureStorage();

  Future<void> _saveToken(String token) async {
    try {
      await _storage.write(key: 'auth_token', value: token);
    } catch (e) {
      print('Error saving token: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'auth_token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<void> removeToken() async {
    try {
      await _storage.delete(key: 'auth_token');
    } catch (e) {
      print('Error removing token: $e');
      throw Exception('Failed to remove token: $e');
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sign up: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final Uri uri = Uri.https(
      'identitytoolkit.googleapis.com',
      '/v1/accounts:signInWithPassword',
      {
        'key': firebaseApiKey,
        'email': email,
        'password': password,
        'returnSecureToken': 'true',
      },
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['idToken']);
      return data;
    } else {
      throw Exception('Failed to sign in: ${response.body}');
    }
  }
}
