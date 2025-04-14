import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ReviewApi {
  // Base URL for the API (adjust this to your actual API endpoint)
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

  // GET: Fetch reviews for a specific location
  Future<List<dynamic>> getReviewsByLocation(String locationId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/location/$locationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      // Handle "No reviews found for this location"
      return [];
    } else {
      // For other errors, return an empty list instead of throwing
      return [];
    }
  }

  // POST: Submit a new review
  Future<void> postReview({
    required String userId,
    required String locationId,
    required int rating,
    required String content,
  }) async {
    final token = await _getToken();
    print("called");
    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'user_id': userId,
        'location_id': locationId,
        'rating': rating,
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to submit review: ${response.statusCode}');
    }
  }

  // PUT: Update an existing review
  Future<void> updateReview({
    required String reviewId,
    required String userId,
    required String locationId,
    required int rating,
    required String content,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/reviews/$reviewId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'location_id': locationId,
        'rating': rating,
        'content': content,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update review: ${response.statusCode}');
    }
  }

  // DELETE: Delete a review
  Future<void> deleteReview(String reviewId) async {
    final token = await _getToken();
    print("delteeeeeeeeeee");
    print(reviewId);
    final response = await http.delete(
      Uri.parse('$baseUrl/reviews/$reviewId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete review: ${response.statusCode}');
    }
  }
}
