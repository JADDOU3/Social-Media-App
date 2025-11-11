import 'package:dio/dio.dart';
import 'dart:typed_data';
import '../models/post.dart';
import 'api_service.dart';

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

  Future<List<Post>> getFriendsPosts() async {
    try {
      final response = await _apiService.get('posts/friends');
      List<dynamic> postsJson = response;
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load friends posts: $e');
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
    String? text,
    List<Uint8List>? images,
  }) async {
    try {
      Map<String, dynamic> formDataMap = {};

      if (text != null && text.isNotEmpty) {
        formDataMap['text'] = text;
      }

      if (images != null && images.isNotEmpty) {
        formDataMap['images'] = images
            .asMap()
            .entries
            .map((entry) => MultipartFile.fromBytes(
          entry.value as List<int>,
          filename: 'image_${entry.key}.jpg',
        ))
            .toList();
      }

      FormData formData = FormData.fromMap(formDataMap);

      final response = await _apiService.postFormData('posts/', formData);
      return Post.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Future<Post> updatePost({
    required int postId,
    String? text,
    List<Uint8List>? newImages,
  }) async {
    try {
      Map<String, dynamic> formDataMap = {};

      if (text != null && text.isNotEmpty) {
        formDataMap['text'] = text;
      }

      if (newImages != null && newImages.isNotEmpty) {
        formDataMap['images'] = newImages
            .asMap()
            .entries
            .map((entry) => MultipartFile.fromBytes(
          entry.value as List<int>,
          filename: 'image_${entry.key}.jpg',
        ))
            .toList();
      }

      FormData formData = FormData.fromMap(formDataMap);

      final response = await _apiService.putFormData('posts/$postId/update', formData);
      return Post.fromJson(response);
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

  Future<List<Post>> getUserPosts(int userId) async {
    try {
      final response = await _apiService.get('posts/user/$userId');
      List<dynamic> postsJson = response;
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load user posts: $e');
    }
  }
}