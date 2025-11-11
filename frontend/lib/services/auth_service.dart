import '../models/user_profile.dart';
import 'api_service.dart';
import 'local_storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final LocalStorageService _localStorage;

  AuthService(this._apiService, this._localStorage);

  Future<String> login(String email, String password) async {
    final payload = {'email': email, 'password': password};
    final response = await _apiService.post('/auth/login', data: payload, authRequired: false);

    if (response == null || response['access_token'] == null) {
      throw Exception('Login failed: missing access_token');
    }

    final token = response['access_token'];
    await _localStorage.saveAccessToken(token);
    return token;
  }

  Future<UserProfile> register(Map<String, dynamic> userData) async {
    final response = await _apiService.post('/users/register', data: userData, authRequired: false);
    if (response == null) throw Exception('Empty register response');
    return UserProfile.fromJson(Map<String, dynamic>.from(response));
  }

  Future<void> logout() async {
    try {
      await _localStorage.saveAccessToken('');
    } catch (_) {}
  }
}
