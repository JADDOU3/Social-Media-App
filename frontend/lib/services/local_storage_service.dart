import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService{
  final FlutterSecureStorage _secureStorage;

  LocalStorageService(this._secureStorage);

  static const String _token = "accessToken";

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
}