import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LocalStorageService {
  final FlutterSecureStorage _secureStorage;

  LocalStorageService(this._secureStorage);

  static const String _token = "accessToken";
  static const String _themeMode = "isDarkMode";
  static const String _expiryKey = 'auth_expiry';
  static const String _userId = "user_id";
  static const String _refreshToken = "refresh_token";

  Future<void> saveAccessToken(String accessToken) async {
    await _secureStorage.write(key: _token, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _token);
  }

  Future<void> clearAuth() async {
    await _secureStorage.delete(key: _token);
    await _secureStorage.delete(key: _expiryKey);
    await _secureStorage.delete(key: _refreshToken);
    await _secureStorage.delete(key: _userId);
  }

  Future<void> clearTokenAndExpiry() async {
    await _secureStorage.delete(key: _token);
    await _secureStorage.delete(key: _expiryKey);
    await _secureStorage.delete(key: _refreshToken);
  }

  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userId);
  }

  Future<void> clearUserId() async {
    await _secureStorage.delete(key: _userId);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshToken, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshToken);
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    await _secureStorage.write(key: _themeMode, value: isDarkMode.toString());
  }

  Future<bool?> getThemeMode() async {
    final value = await _secureStorage.read(key: _themeMode);
    return value == 'true';
  }

  Future<void> saveExpiry(DateTime expiry) async {
    await _secureStorage.write(key: _expiryKey, value: expiry.toIso8601String());
  }

  Future<DateTime?> getExpiry() async {
    final v = await _secureStorage.read(key: _expiryKey);
    if (v == null) return null;
    try {
      return DateTime.parse(v);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getData(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteData(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  String? extractUserEmailFromToken(String token) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      print("decodedToken $decodedToken");

      return decodedToken['sub'];
    } catch (e) {
      print('Failed to decode token: $e');
      return null;
    }
  }


}