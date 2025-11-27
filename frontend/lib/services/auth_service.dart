import 'package:jwt_decoder/jwt_decoder.dart'; // ✅ REQUIRED PACKAGE
import 'api_service.dart';
import 'local_storage_service.dart';
import '../models/user_profile.dart'; // ✅ FIX for UserProfile errors

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

      if (response == null || response['access_token'] == null) {
        return false;
      }

      final token = response['access_token'];
      await _localStorage.saveAccessToken(token);

      // Extract userId from token
      final userId = extractUserIdFromToken(token);
      if (userId != null) {
        await _localStorage.saveUserId(userId.toString());
      }

      final expiry = DateTime.now().add(Duration(days: staySignedIn ? 7 : 1));
      await _localStorage.saveExpiry(expiry);

      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  int? extractUserIdFromToken(String token) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['userId'];
    } catch (e) {
      print('Failed to decode token: $e');
      return null;
    }
  }

  Future<int?> getCurrentUserId() async {
    // Try storage first
    final storedId = await _localStorage.getUserId();
    if (storedId != null) {
      return int.tryParse(storedId);
    }

    // Fallback: extract from token
    final token = await _localStorage.getAccessToken();
    if (token != null) {
      return extractUserIdFromToken(token);
    }

    return null;
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _localStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _apiService.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        authRequired: false,
      );

      if (response == null || response['accessToken'] == null) {
        return false;
      }

      final newToken = response['accessToken'];
      await _localStorage.saveAccessToken(newToken);

      final expiry = DateTime.now().add(const Duration(days: 7));
      await _localStorage.saveExpiry(expiry);

      return true;
    } catch (e) {
      print('Refresh token error: $e');
      return false;
    }
  }

  Future<UserProfile> register(Map<String, dynamic> userData) async {
    final response = await _apiService.post(
      '/users/register',
      data: userData,
      authRequired: false,
    );
    if (response == null) throw Exception('Empty register response');

    final profile = UserProfile.fromJson(Map<String, dynamic>.from(response));
    if (profile.id != null) {
      await _localStorage.saveUserId(profile.id.toString());
    }

    return profile;
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout', data: {}, authRequired: true);
    } catch (e) {
      print('Logout API call failed: $e');
    } finally {
      await _localStorage.clearAuth();
      await _localStorage.clearUserId();
    }
  }
}