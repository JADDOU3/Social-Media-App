import 'package:dio/dio.dart';
import '../models/post.dart';
import 'api_service.dart';
import 'dart:typed_data';

class PostService {
  final ApiService _apiService;

  PostService(this._apiService);

  Future<List<Post>> getAllPosts() async {
    try {
      final response = await _apiService.get('posts');
      List<dynamic> postsJson = response;
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<List<Post>> getMyPosts() async {
    try {
      final response = await _apiService.get('posts/my');
      List<dynamic> postsJson = response;
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load my posts: $e');
    }
  }

  Future<Post> createPost({
    required String text,
    List<Uint8List>? images,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'text': text,
        if (images != null && images.isNotEmpty)
          'images': images
              .asMap()
              .entries
              .map((entry) => MultipartFile.fromBytes(
            entry.value,
            filename: 'image_${entry.key}.jpg',
          ))
              .toList(),
      });

      final response = await _apiService._dio.post(
        'posts/',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          extra: {'auth_required': true},
        ),
      );

      return Post.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Future<Post> updatePost({
    required int postId,
    required String text,
    List<Uint8List>? newImages,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'text': text,
        if (newImages != null && newImages.isNotEmpty)
          'images': newImages
              .asMap()
              .entries
              .map((entry) => MultipartFile.fromBytes(
            entry.value,
            filename: 'image_${entry.key}.jpg',
          ))
              .toList(),
      });

      final response = await _apiService._dio.put(
        'posts/$postId/update',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          extra: {'auth_required': true},
        ),
      );

      return Post.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await _apiService.delete('posts/$postId');
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  Future<void> reactToPost(int postId, String reactionType) async {
    try {
      await _apiService.post(
        'posts/$postId/react',
        data: {'reactionType': reactionType},
      );
    } catch (e) {
      throw Exception('Failed to react to post: $e');
    }
  }
}

