import 'package:http/http.dart' as http;
import 'dart:convert';

class MongoDBService {
  // Update this to your local MongoDB API endpoint
  // For Web/Chrome: use localhost
  // For Android Emulator: use 10.0.2.2
  // For Physical Device: use your machine IP
  static const String baseUrl = 'http://localhost:3000/api';

  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // AUTH ENDPOINTS
  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': 'organizer',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Signup successful',
        };
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // EVENT ENDPOINTS
  static Future<Map<String, dynamic>> createEvent({
    required String name,
    required DateTime dateTime,
    required int maxCapacity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'dateTime': dateTime.toIso8601String(),
          'maxCapacity': maxCapacity,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Event created successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create event',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Events fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch events',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getEvent(String eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Event fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch event',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteEvent(String eventId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Event deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete event',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // PARTICIPANT ENDPOINTS
  static Future<Map<String, dynamic>> addParticipants({
    required String eventId,
    required List<Map<String, dynamic>> participants,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/participants'),
        headers: _getHeaders(),
        body: jsonEncode({
          'participants': participants,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Participants added successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to add participants',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getParticipants(String eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/participants'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Participants fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch participants',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // CHECK-IN ENDPOINTS
  static Future<Map<String, dynamic>> checkInParticipant({
    required String eventId,
    required String participantId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/checkin'),
        headers: _getHeaders(),
        body: jsonEncode({
          'participantId': participantId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Check-in successful',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Check-in failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getCheckIns(String eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/checkins'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Check-ins fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch check-ins',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> syncCheckIns({
    required String eventId,
    required List<Map<String, dynamic>> checkIns,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/sync-checkins'),
        headers: _getHeaders(),
        body: jsonEncode({
          'checkIns': checkIns,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Sync successful',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to sync',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getStats(String eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/stats'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Stats fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch stats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
