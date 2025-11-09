import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../utils/app_color.dart';
import 'comment_item.dart';

class CommentSection extends StatefulWidget {
  final int postId;
  final CommentService commentService;
  final bool isDark;
  final String currentUserEmail;
  final Uint8List? currentUserProfilePicture;
  final int initialCommentCount;

  const CommentSection({
    Key? key,
    required this.postId,
    required this.commentService,
    required this.isDark,
    required this.currentUserEmail,
    this.currentUserProfilePicture,
    this.initialCommentCount = 0,
  }) : super(key: key);

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isPosting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final comments = await widget.commentService.getComments(widget.postId);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Error loading comments: $e');
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final newComment = await widget.commentService.addComment(
        widget.postId,
        _commentController.text.trim(),
      );

      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
        _isPosting = false;
      });
    } catch (e) {
      setState(() => _isPosting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        title: Text(
          'Delete Comment',
          style: TextStyle(
            color: widget.isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this comment?',
          style: TextStyle(
            color: widget.isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.commentService.deleteComment(comment.id);
        setState(() {
          _comments.removeWhere((c) => c.id == comment.id);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete comment: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: widget.isDark
                ? AppColors.darkDivider
                : AppColors.lightDivider,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Input Field
          _buildCommentInput(),

          // Comments List
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Error loading comments: $_error',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loadComments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_comments.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No comments yet. Be the first to comment!',
                  style: TextStyle(
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  final isOwnComment =
                      comment.authorEmail == widget.currentUserEmail;

                  return CommentItem(
                    comment: comment,
                    isDark: widget.isDark,
                    isOwnComment: isOwnComment,
                    profilePicture:
                    isOwnComment ? widget.currentUserProfilePicture : null,
                    onDelete: isOwnComment ? () => _deleteComment(comment) : null,
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: widget.currentUserProfilePicture != null
                ? MemoryImage(widget.currentUserProfilePicture!)
                : const NetworkImage('https://i.pravatar.cc/300?img=12')
            as ImageProvider,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _focusNode,
              maxLines: null,
              style: TextStyle(
                color: widget.isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                hintStyle: TextStyle(
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: widget.isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1,
                  ),
                ),
              ),
              onSubmitted: (_) => _addComment(),
            ),
          ),
          const SizedBox(width: 8),
          _isPosting
              ? const SizedBox(
            width: 32,
            height: 32,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          )
              : IconButton(
            onPressed: _addComment,
            icon: const Icon(
              Icons.send,
              color: AppColors.primary,
            ),
            iconSize: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}