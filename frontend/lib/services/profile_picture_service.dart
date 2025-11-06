import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'api_service.dart';

class ProfilePictureService {
  final ApiService _apiService;

  ProfilePictureService(this._apiService);

  Future<Uint8List?> getProfilePicture() async {
    try {
      final response = await _apiService.getBytes('profilepicture/');
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> uploadProfilePicture(Uint8List imageBytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: filename,
        ),
      });

      await _apiService.postFormData('profilepicture/', formData);
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  Future<void> updateProfilePicture(Uint8List imageBytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: filename,
        ),
      });

      await _apiService.putFormData('profilepicture/', formData);
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