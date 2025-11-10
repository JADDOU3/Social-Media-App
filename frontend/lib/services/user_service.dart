  import 'package:dio/dio.dart';
  import '../models/user_profile.dart';
  import 'api_service.dart';

  class UserService {
    final ApiService _apiService;

    UserService(this._apiService);

    Future<UserProfile> getProfile() async {
      try {
        final response = await _apiService.get('users/view');
        return UserProfile.fromJson(response);
      } catch (e) {
        throw Exception('Failed to load profile: $e');
      }
    }

    Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
      try {
        final response = await _apiService.put('users/update', data: data);
        return UserProfile.fromJson(response);
      } catch (e) {
        throw Exception('Failed to update profile: $e');
      }
    }

    Future<void> changePassword({
      required String oldPassword,
      required String newPassword,
    }) async {
      try {
        await _apiService.put(
          'users/change-password',
          data: {
            'oldPassword': oldPassword,
            'newPassword': newPassword,
          },
        );
      } catch (e) {
        throw Exception('Failed to change password: $e');
      }
    }

    Future<UserProfile> getUserProfile(int userId) async {
      try {
        final response = await _apiService.get('users/profile/$userId');
        return UserProfile.fromJson(response);
      } catch (e) {
        throw Exception('Failed to load user profile: $e');
      }
    }
  }