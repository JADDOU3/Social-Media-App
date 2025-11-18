import '../models/user_profile.dart';
import 'api_service.dart';
import 'local_storage_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final ApiService _apiService;
  final LocalStorageService _localStorage;

  AuthService(this._apiService, this._localStorage);

  Future<bool> login(String email, String password, {required bool staySignedIn}) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'email': email, 'password': password},
        authRequired: false,
      );

      if (response == null) return false;

      final token = response['access_token'];
      if (token == null) return false;

      await _localStorage.saveAccessToken(token);

      final expiry = DateTime.now().add(Duration(days: staySignedIn ? 7 : 1));
      await _localStorage.saveExpiry(expiry);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _localStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _apiService.post('/auth/refresh',
        data: {'refreshToken': refreshToken},
        authRequired: false,
      );

      if (response == null) return false;

      final newToken = response['accessToken'];
      await _localStorage.saveAccessToken(newToken);

      final expiry = DateTime.now().add(Duration(days: 7));
      await _localStorage.saveExpiry(expiry);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserProfile> register(Map<String, dynamic> userData) async {
    final response = await _apiService.post('/users/register', data: userData, authRequired: false);
    if (response == null) throw Exception('Empty register response');
    return UserProfile.fromJson(Map<String, dynamic>.from(response));
  }

  Future<void> logout() async {
    await _localStorage.clearAuth();
  }
}
