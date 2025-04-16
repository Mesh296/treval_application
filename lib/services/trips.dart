import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TripApi {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'BASE_URL';
  static const _storage = FlutterSecureStorage();

  // Helper method to retrieve the authentication token
  Future<String?> _getToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      return token;
    } catch (e) {
      return null;
    }
  }

  // POST: Create a new trip
  Future<String> createTrip({
    required String tripName,
    required String description,
    required String type,
    required double budget,
    required String startDate,
    required String endDate,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/trips'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'trip_name': tripName,
        'description': description,
        'type': type,
        'budget': budget,
        'date_start': startDate,
        'date_end': endDate,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final tripId = responseData['trip']?['id'] as String?;
      print('Extracted tripId: $tripId'); // Debug logging
      if (tripId == null) {
        throw Exception('Trip ID not returned in response: ${response.body}');
      }
      return tripId;
    } else {
      throw Exception('Failed to create trip: ${response.statusCode} - ${response.body}');
    }
  }

  // GET: Retrieve the list of all trips
  Future<List<dynamic>> getTrips() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/trips'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['trips'] as List<dynamic>? ?? [];
    } else {
      throw Exception('Failed to retrieve trips: ${response.statusCode} - ${response.body}');
    }
  }

  // GET: Retrieve trip details by ID
  Future<Map<String, dynamic>> getTripById(String tripId) async {
    if (tripId.isEmpty) {
      throw Exception('Invalid trip ID: tripId cannot be empty');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/trips/$tripId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
   

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
       print(responseData);
      return responseData as Map<String, dynamic>? ?? {};
    } else {
      throw Exception('Failed to retrieve trip: ${response.statusCode} - ${response.body}');
    }
  }

  // PUT: Update trip details
  Future<void> updateTrip({
    required String tripId,
    required String tripName,
    required String description,
    required String type,
    required double budget,
    required String startDate,
    required String endDate,
  }) async {
    if (tripId.isEmpty) {
      throw Exception('Invalid trip ID: tripId cannot be empty');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/trips/$tripId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'trip_name': tripName,
        'description': description,
        'type': type,
        'budget': budget,
        'date_start': startDate,
        'date_end': endDate,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update trip: ${response.statusCode} - ${response.body}');
    }
  }

  // DELETE: Delete a trip
  Future<void> deleteTrip(String tripId) async {
    if (tripId.isEmpty) {
      throw Exception('Invalid trip ID: tripId cannot be empty');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/trips/$tripId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete trip: ${response.statusCode} - ${response.body}');
    }
  }

  // POST: Add a location to a trip (already implemented)
  Future<void> addLocationToTrip({
    required String tripId,
    required String locationId,
  }) async {
    if (tripId.isEmpty) {
      throw Exception('Invalid trip ID: tripId cannot be empty');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/trips/$tripId/locations?id=$locationId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'location_id': locationId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add location to trip: ${response.statusCode} - ${response.body}');
    }
  }

  // DELETE: Remove a location from a trip
  Future<void> removeLocationFromTrip({
    required String locationId,
  }) async {
    if (locationId.isEmpty) {
      throw Exception('Invalid location ID: locationId cannot be empty');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/trips/locations/$locationId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to remove location from trip: ${response.statusCode} - ${response.body}');
    }
  }
}