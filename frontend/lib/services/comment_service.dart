import 'dart:convert';
import '../models/comment.dart';
import 'api_service.dart';

class CommentService {
  final ApiService _apiService;

  CommentService(this._apiService);

  Future<Comment> addComment(int postId, String commentText) async {
    try {
      final data = {
        'postId': postId,
        'comment': commentText,
      };

      final response = await _apiService.post(
        'comments/add',
        data: jsonEncode(data),
      );

      return Comment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<List<Comment>> getComments(int postId) async {
    try {
      final response = await _apiService.get('comments/post/$postId');
      final List<dynamic> jsonList = response as List<dynamic>;
      return jsonList.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      await _apiService.delete('comments/$commentId');
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }
}
