import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TripsApi {
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

  Future<Map<String, dynamic>> createTrip({
    required String tripName,
    required String description,
    required String type,
    required double budget,
    required String dateStart,
    required String dateEnd,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/trips'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'trip_name': tripName,
        'description': description,
        'type': type,
        'budget': budget,
        'date_start': dateStart,
        'date_end': dateEnd,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create trip: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getTrips() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/trips'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch trips: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getTripById(String tripId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/trips/$tripId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch trip: ${response.body}');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/trips/$tripId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete trip: ${response.body}');
    }
  }
}