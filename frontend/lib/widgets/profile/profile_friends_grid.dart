import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/friend_response.dart';
import '../../services/profile_picture_service.dart';
import '../../services/user_service.dart';
import '../../routes/app_router.dart';
import '../../utils/app_color.dart';

class ProfileFriendsGrid extends StatelessWidget {
  final List<FriendResponse> friends;
  final bool isDark;
  final UserService userService;
  final ProfilePictureService profilePictureService;

  const ProfileFriendsGrid({
    Key? key,
    required this.friends,
    required this.isDark,
    required this.userService,
    required this.profilePictureService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayFriends = friends.take(6).toList();

    return Card(
      color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.go(AppRoutes.friends),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Friends',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    '${friends.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (friends.isEmpty)
                _buildNoFriendsMessage()
              else
                FutureBuilder<int>(
                  future: userService.getCurrentUserId(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final currentUserId = snapshot.data!;

                    return Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: displayFriends.length,
                          itemBuilder: (context, index) {
                            final friend = displayFriends[index];
                            return _buildFriendGridItem(
                                context, friend, currentUserId);
                          },
                        ),
                        if (friends.length > 6)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Center(
                              child: Text(
                                'View all friends',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoFriendsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'No friends yet',
              style: TextStyle(
                fontSize: 14,
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

  Widget _buildFriendGridItem(
      BuildContext context, FriendResponse friend, int currentUserId) {
    final isCurrentUserSender = currentUserId == friend.senderId;
    final friendUserId =
    isCurrentUserSender ? friend.receiverId : friend.senderId;
    final friendName =
    isCurrentUserSender ? friend.receiverName : friend.senderName;

    return GestureDetector(
      onTap: () {
        context.go('${AppRoutes.profile}/$friendUserId');
      },
      child: Column(
        children: [
          FutureBuilder<Uint8List?>(
            future: profilePictureService.getUserProfilePicture(friendUserId),
            builder: (context, snapshot) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: snapshot.hasData && snapshot.data != null
                      ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                      : Container(
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
                    child: Icon(
                      Icons.person,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      size: 30,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            friendName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}