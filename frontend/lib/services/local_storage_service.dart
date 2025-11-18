import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  final FlutterSecureStorage _secureStorage;

  LocalStorageService(this._secureStorage);

  static const String _token = "accessToken";
  static const String _themeMode = "isDarkMode";
  static const String _expiryKey='auth_expiry';

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

  Future<void> saveThemeMode(bool isDarkMode) async {
    await _secureStorage.write(key: _themeMode, value: isDarkMode.toString());
  }

  Future<void> saveExpiry(DateTime expiry)async{
    await _secureStorage.write(key: _expiryKey,value: expiry.toIso8601String());
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

  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  Future<bool?> getThemeMode() async {
    final value = await _secureStorage.read(key: _themeMode);
    if (value == null) return null;
    return value == 'true';
  }

  Future<void> clearAuth() async{
    await _secureStorage.delete(key:_token);
    await _secureStorage.delete(key:_expiryKey);
  }

  Future<void> clearThemeMode() async {
    await _secureStorage.delete(key: _themeMode);
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
}