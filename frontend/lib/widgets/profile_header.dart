import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/friend_status.dart';
import '../utils/app_color.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile? profile;
  final Uint8List? profilePicture;
  final int postCount;
  final bool isDark;
  final bool isOwnProfile;
  final FriendStatus? friendStatus;
  final VoidCallback? onEditProfile;
  final VoidCallback? onCreatePost;
  final VoidCallback? onChangeProfilePicture;
  final VoidCallback? onSendFriendRequest;
  final VoidCallback? onCancelFriendRequest;

  const ProfileHeader({
    Key? key,
    required this.profile,
    required this.profilePicture,
    required this.postCount,
    required this.isDark,
    required this.isOwnProfile,
    this.friendStatus,
    this.onEditProfile,
    this.onCreatePost,
    this.onChangeProfilePicture,
    this.onSendFriendRequest,
    this.onCancelFriendRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
         GestureDetector(
            onTap: isOwnProfile ? onChangeProfilePicture : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  backgroundImage:
                  profilePicture != null ? MemoryImage(profilePicture!) : null,
                  child: profilePicture == null
                      ? Icon(
                    Icons.person,
                    size: 50,
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                  )
                      : null,
                ),
                if (isOwnProfile)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            profile?.name ?? 'Unknown',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),

          if (profile?.email != null) ...[
            const SizedBox(height: 4),
            Text(
              profile!.email!,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],

          if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              profile!.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Posts', postCount.toString(), isDark),
            ],
          ),
          const SizedBox(height: 16),
          if (isOwnProfile) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEditProfile,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCreatePost,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildFriendActionButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFriendActionButton() {
    if (friendStatus == null) {
      return const SizedBox.shrink();
    }

    if (friendStatus!.isFriends) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Friends'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    if (friendStatus!.isPendingSent) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onCancelFriendRequest,
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Cancel Request'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    if (friendStatus!.isPendingReceived) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.mail, size: 18),
          label: const Text('Respond to Request'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onSendFriendRequest,
        icon: const Icon(Icons.person_add, size: 18),
        label: const Text('Add Friend'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}