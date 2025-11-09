import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/comment_service.dart';
import '../services/post_service.dart';
import '../utils/app_color.dart';
import '../utils/date_formatter.dart';
import '../enums/reaction_type.dart';
import 'reaction_button.dart';
import 'post_image_grid.dart';
import 'comment_section.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool isDark;
  final Uint8List? profilePicture;
  final String currentUserEmail;
  final CommentService? commentService;
  final PostService? postService;
  final Function(ReactionType)? onReactionSelected;
  final VoidCallback? onPostUpdated;
  final VoidCallback? onPostDeleted;

  const PostCard({
    Key? key,
    required this.post,
    required this.isDark,
    this.profilePicture,
    required this.currentUserEmail,
    this.commentService,
    this.postService,
    this.onReactionSelected,
    this.onPostUpdated,
    this.onPostDeleted,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showComments = false;

  @override
  Widget build(BuildContext context) {
    final isOwnPost = widget.post.authorEmail == widget.currentUserEmail;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isOwnPost),
          if (widget.post.text != null && widget.post.text!.isNotEmpty)
            _buildText(),
          if (widget.post.imageUrls.isNotEmpty) _buildImages(),
          _buildActions(),
          if (_showComments && widget.commentService != null)
            CommentSection(
              postId: widget.post.id,
              commentService: widget.commentService!,
              isDark: widget.isDark,
              currentUserEmail: widget.currentUserEmail,
              currentUserProfilePicture: widget.profilePicture,
              initialCommentCount: 0,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isOwnPost) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: widget.profilePicture != null
                ? MemoryImage(widget.profilePicture!)
                : const NetworkImage('https://i.pravatar.cc/300?img=12')
            as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.authorName ??
                      widget.post.authorEmail ??
                      'Unknown User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: widget.isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  DateFormatter.formatDate(widget.post.createdDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isOwnPost)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_horiz,
                color: widget.isDark
                    ? AppColors.darkIconGray
                    : AppColors.lightIconGray,
              ),
              color: widget.isDark
                  ? AppColors.darkCardBackground
                  : AppColors.lightCardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog();
                } else if (value == 'delete') {
                  _showDeleteConfirmation();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: widget.isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Edit Post',
                        style: TextStyle(
                          color: widget.isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Delete Post',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final TextEditingController textController = TextEditingController(
      text: widget.post.text ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        title: Text(
          'Edit Post',
          style: TextStyle(
            color: widget.isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        content: TextField(
          controller: textController,
          maxLines: 5,
          style: TextStyle(
            color: widget.isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'What\'s on your mind?',
            hintStyle: TextStyle(
              color: widget.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            filled: true,
            fillColor: widget.isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            onPressed: () async {
              if (textController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post text cannot be empty'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                if (widget.postService != null) {
                  await widget.postService!.updatePost(
                    postId: widget.post.id,
                    text: textController.text.trim(),
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Post updated successfully'),
                        backgroundColor: widget.isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    );
                    widget.onPostUpdated?.call();
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update post: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        title: Text(
          'Delete Post',
          style: TextStyle(
            color: widget.isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(
            color: widget.isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            onPressed: () async {
              try {
                if (widget.postService != null) {
                  await widget.postService!.deletePost(widget.post.id);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Post deleted successfully'),
                        backgroundColor: widget.isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    );
                    widget.onPostDeleted?.call();
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete post: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        widget.post.text!,
        style: TextStyle(
          fontSize: 15,
          color: widget.isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  Widget _buildImages() {
    if (widget.post.imageUrls.length == 1) {
      return Image.network(
        widget.post.imageUrls[0],
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: widget.isDark
                ? AppColors.darkShimmer
                : AppColors.lightShimmer,
            child: Icon(
              Icons.broken_image,
              size: 50,
              color: widget.isDark
                  ? AppColors.darkTextLight
                  : AppColors.lightTextLight,
            ),
          );
        },
      );
    }
    return PostImageGrid(imageUrls: widget.post.imageUrls, isDark: widget.isDark);
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ReactionButton(
            currentReaction: null,
            onReactionSelected: widget.onReactionSelected ?? (reaction) {},
            isDark: widget.isDark,
          ),
          _buildActionButton(
            Icons.comment_outlined,
            'Comment',
                () {
              setState(() {
                _showComments = !_showComments;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: widget.isDark
                  ? AppColors.darkIconGray
                  : AppColors.lightIconGray,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}