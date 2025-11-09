import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  final FlutterSecureStorage _secureStorage;

  LocalStorageService(this._secureStorage);

  static const String _token = "accessToken";
  static const String _themeMode = "isDarkMode";

  // Token methods
  Future<void> saveTokens({
    required String accessToken,
  }) async {
    await _secureStorage.write(key: _token, value: accessToken);
  }

  Future<void> saveAccessToken(String accessToken) async {
    await _secureStorage.write(key: _token, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _token);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _token);
  }

  // Theme methods
  Future<void> saveThemeMode(bool isDarkMode) async {
    await _secureStorage.write(key: _themeMode, value: isDarkMode.toString());
  }

  Future<bool?> getThemeMode() async {
    final value = await _secureStorage.read(key: _themeMode);
    if (value == null) return null;
    return value == 'true';
  }

  Future<void> clearThemeMode() async {
    await _secureStorage.delete(key: _themeMode);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}