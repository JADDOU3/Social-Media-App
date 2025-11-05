import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'api_service.dart';

class ProfilePictureService {
  final ApiService _apiService;

  ProfilePictureService(this._apiService);

  Future<Uint8List?> getProfilePicture() async {
    try {
      final response = await _apiService._dio.get(
        'profilepicture/',
        options: Options(
          responseType: ResponseType.bytes,
          extra: {'auth_required': true},
        ),
      );
      return response.data as Uint8List;
    } catch (e) {
      return null;
    }
  }

  Future<void> uploadProfilePicture(Uint8List imageBytes, String filename) async {
    try {
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: filename,
        ),
      });

      await _apiService._dio.post(
        'profilepicture/',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          extra: {'auth_required': true},
        ),
      );
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  Future<void> updateProfilePicture(Uint8List imageBytes, String filename) async {
    try {
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: filename,
        ),
      });

      await _apiService._dio.put(
        'profilepicture/',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          extra: {'auth_required': true},
        ),
      );
    } catch (e) {
      throw Exception('Failed to update profile picture: $e');
    }
  }

  Future<void> deleteProfilePicture() async {
    try {
      await _apiService.delete('profilepicture/');
    } catch (e) {
      throw Exception('Failed to delete profile picture: $e');
    }
  }
}