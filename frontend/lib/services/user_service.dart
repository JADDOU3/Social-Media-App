  import 'dart:convert';
  import 'package:dio/dio.dart';
  import '../models/user_profile.dart';
  import '../models/user_search_result.dart';
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

    Future<int> getCurrentUserId() async {
      try {
        final response = await _apiService.get('users/current-user-id');
        print('this is the response => $response');

        if (response != null && response['id'] != null) {
          return response['id'];
        } else {
          throw Exception('User ID not found in response');
        }
      } catch (e) {
        throw Exception('Failed to fetch user id: $e');
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

    Future<List<UserSearchResult>> findUsersByName(String name) async {
      final query = name.trim();
      if (query.length < 2) {
        return <UserSearchResult>[];
      }


      try {
        final response = await _apiService.get('users/$query');
        final data = response;

        List<dynamic> rawList;
        if (data == null) {
          return <UserSearchResult>[];
        } else if (data is List) {
          rawList = data;
        } else if (data is String) {
          final trimmed = data.trim();
          if (trimmed.isEmpty) return <UserSearchResult>[];
          if (trimmed.startsWith('[')) {
            rawList = jsonDecode(trimmed) as List<dynamic>;
          } else {
            throw FormatException('Unexpected response format for users search');
          }
        } else {
          throw FormatException('Unsupported response type: ${data.runtimeType}');
        }

        return rawList
            .map<UserSearchResult>((e) => UserSearchResult.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        final body = e.response?.data;
        final bodySnippet = body is String
            ? (body.length > 500 ? body.substring(0, 500) : body)
            : body?.toString();
        throw Exception('Failed to search users: HTTP $status, type=${e.type}, body=$bodySnippet');
      } catch (e) {
        throw Exception('Failed to search users: $e');
      }
    }
  }