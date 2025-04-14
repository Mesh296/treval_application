import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationsApi {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'BASE_URL';
  static const _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/locations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch locations: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getLocationById(String locationId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/locations/$locationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch location: ${response.body}');
    }
  }
}