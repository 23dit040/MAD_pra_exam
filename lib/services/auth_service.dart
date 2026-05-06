import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/mongodb_service.dart';
import 'package:flutter_application_1/services/local_storage_service.dart';

class AuthService {
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final result = await MongoDBService.signup(
      email: email,
      password: password,
      name: name,
    );

    if (result['success']) {
      final data = result['data'];
      final token = data['token'];
      final user = User.fromJson(data['user'] ?? {});

      await _saveToken(token);
      await LocalStorageService.saveUser(user);
      MongoDBService.setAuthToken(token);

      return {
        'success': true,
        'user': user,
        'message': 'Signup successful',
      };
    }

    return result;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await MongoDBService.login(
      email: email,
      password: password,
    );

    if (result['success']) {
      final data = result['data'];
      final token = data['token'];
      final user = User.fromJson(data['user'] ?? {});

      await _saveToken(token);
      await LocalStorageService.saveUser(user);
      MongoDBService.setAuthToken(token);

      return {
        'success': true,
        'user': user,
        'message': 'Login successful',
      };
    }

    return result;
  }

  static Future<void> logout() async {
    await _clearToken();
    await LocalStorageService.clearUser();
    MongoDBService.setAuthToken('');
  }

  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<User?> getCurrentUser() async {
    final user = LocalStorageService.getUser();
    if (user != null) {
      return user;
    }
    return null;
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  static Future<void> restoreSession() async {
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      MongoDBService.setAuthToken(token);
    }
  }
}
