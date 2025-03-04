// services/user.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserApi {
  static const String baseUrl = 'https://api-jxzcqxilwa-uc.a.run.app';
  static const _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user info: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getRecommendedLocationsAndOffers() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/recommended-locations-and-offers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get recommendations: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUserActivities() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user activities: ${response.body}');
    }
  }

  Future<void> deleteUser() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  Future<void> deleteUserActivity() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/users/activities'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete user activity: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> addUserActivity(
      Map<String, dynamic> activityData) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users/activities'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(activityData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add user activity: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/users/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user by ID: ${response.body}');
    }
  }

  // Fetch all available activities
  Future<List<Map<String, dynamic>>> getActivities() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/activities'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch activities: ${response.body}');
    }
  }

Future<void> addActivities(List<String> activityIds) async {
  final token = await _getToken();
  if (token == null) {
    throw Exception('No token found. Please sign in.');
  }

  final response = await http.post(
    Uri.parse('$baseUrl/users/activities/replace'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'activity_ids': activityIds}), // Gửi danh sách thay vì một ID
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to add liked activities: ${response.body}');
  }
}

  // Remove an activity from user's liked activities
  Future<void> removeLikedActivity(String activityId) async {
    final token = await _getToken();
    print(token);
    print(activityId);
    if (token == null) {
      throw Exception('No token found. Please sign in.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/users/activities'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'activity_id': activityId}),
    );
    print(token);
    if (response.statusCode == 200) {
      print("ok");
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to remove liked activity: ${response.body}');
    }
  }
}
