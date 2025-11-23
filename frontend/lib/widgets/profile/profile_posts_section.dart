import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../services/comment_service.dart';
import '../../services/post_service.dart';
import '../post_card.dart';
import '../../enums/reaction_type.dart';
import '../../utils/app_color.dart';

class ProfilePostsSection extends StatelessWidget {
  final List<Post> posts;
  final bool isDark;
  final bool canViewPosts;
  final Uint8List? profilePicture;
  final String currentUserEmail;
  final CommentService commentService;
  final PostService postService;
  final Function(Post, ReactionType) onReactionSelected;
  final VoidCallback onPostUpdated;
  final VoidCallback onPostDeleted;

  const ProfilePostsSection({
    Key? key,
    required this.posts,
    required this.isDark,
    required this.canViewPosts,
    required this.profilePicture,
    required this.currentUserEmail,
    required this.commentService,
    required this.postService,
    required this.onReactionSelected,
    required this.onPostUpdated,
    required this.onPostDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!canViewPosts)
          _buildPrivateProfileMessage()
        else if (posts.isEmpty)
          _buildEmptyState()
        else
          _buildPostsList(),
      ],
    );
  }

  Widget _buildPrivateProfileMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'This profile is private',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add them as a friend to see their posts',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.post_add,
              size: 64,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          post: post,
          isDark: isDark,
          profilePicture: profilePicture,
          currentUserEmail: currentUserEmail,
          commentService: commentService,
          postService: postService,
          onReactionSelected: (reaction) => onReactionSelected(post, reaction),
          onPostUpdated: onPostUpdated,
          onPostDeleted: onPostDeleted,
        );
      },
    );
  }
}