import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/comment_service.dart';
import '../utils/app_color.dart';
import '../utils/date_formatter.dart';
import '../enums/reaction_type.dart';
import 'reaction_button.dart';
import 'post_image_grid.dart';
import 'comment_section.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isDark;
  final Uint8List? profilePicture;
  final String currentUserEmail;
  final CommentService? commentService;
  final Function(ReactionType)? onReactionSelected;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onMorePressed;

  const PostCard({
    Key? key,
    required this.post,
    required this.isDark,
    this.profilePicture,
    required this.currentUserEmail,
    this.commentService,
    this.onReactionSelected,
    this.onCommentPressed,
    this.onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (post.text != null && post.text!.isNotEmpty) _buildText(),
          if (post.imageUrls.isNotEmpty) _buildImages(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: profilePicture != null
                ? MemoryImage(profilePicture!)
                : const NetworkImage('https://i.pravatar.cc/300?img=12')
            as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName ?? post.authorEmail ?? 'Unknown User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  DateFormatter.formatDate(post.createdDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: isDark
                  ? AppColors.darkIconGray
                  : AppColors.lightIconGray,
            ),
            onPressed: onMorePressed ?? () {},
          ),
        ],
      ),
    );
  }

  Widget _buildText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        post.text!,
        style: TextStyle(
          fontSize: 15,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  Widget _buildImages() {
    if (post.imageUrls.length == 1) {
      return Image.network(
        post.imageUrls[0],
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: isDark ? AppColors.darkShimmer : AppColors.lightShimmer,
            child: Icon(
              Icons.broken_image,
              size: 50,
              color: isDark
                  ? AppColors.darkTextLight
                  : AppColors.lightTextLight,
            ),
          );
        },
      );
    }
    return PostImageGrid(imageUrls: post.imageUrls, isDark: isDark);
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ReactionButton(
            currentReaction: null,
            onReactionSelected: onReactionSelected ?? (reaction) {},
            isDark: isDark,
          ),
          _buildActionButton(
            Icons.comment_outlined,
            'Comment',
            onCommentPressed ?? () {},
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
              color: isDark
                  ? AppColors.darkIconGray
                  : AppColors.lightIconGray,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
}
