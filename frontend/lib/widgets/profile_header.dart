import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../utils/app_color.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile? profile;
  final Uint8List? profilePicture;
  final int postCount;
  final bool isDark;
  final VoidCallback? onEditProfile;
  final VoidCallback? onCreatePost;
  final VoidCallback? onChangeProfilePicture;

  const ProfileHeader({
    Key? key,
    this.profile,
    this.profilePicture,
    required this.postCount,
    required this.isDark,
    this.onEditProfile,
    this.onCreatePost,
    this.onChangeProfilePicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark
          ? AppColors.darkCardBackground
          : AppColors.lightCardBackground,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfilePicture(),
          const SizedBox(height: 16),
          _buildNameAndEmail(),
          if (profile?.bio != null) ...[
            const SizedBox(height: 12),
            _buildBio(),
          ],
          const SizedBox(height: 20),
          _buildStats(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: profilePicture != null
                ? MemoryImage(profilePicture!)
                : const NetworkImage('https://i.pravatar.cc/300?img=12')
            as ImageProvider,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onChangeProfilePicture,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkCardBackground
                      : AppColors.lightCardBackground,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameAndEmail() {
    return Column(
      children: [
        Text(
          profile?.name ?? 'Loading...',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile?.email ?? '',
          style: TextStyle(
            fontSize: 16,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBio() {
    return Text(
      profile!.bio!,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Posts', postCount.toString()),
        _buildDivider(),
        _buildStatItem('Friends', '0'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
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

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: onEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onCreatePost,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}