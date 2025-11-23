import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/user_profile.dart';
import '../models/friend_status.dart';
import '../models/friend_response.dart';
import '../routes/app_router.dart';
import '../services/post_service.dart';
import '../services/profile_picture_service.dart';
import '../services/user_service.dart';
import '../services/comment_service.dart';
import '../services/friend_service.dart';
import '../utils/app_color.dart';
import '../utils/theme_provider.dart';
import '../utils/logout_utils.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/create_post_dialog.dart';
import '../widgets/profile/profile_details_card.dart';
import '../widgets/profile/profile_friends_grid.dart';
import '../widgets/profile/profile_posts_section.dart';
import '../enums/reaction_type.dart';
import 'edit_profile_page.dart';

class ProfileScreen extends StatefulWidget {
  final UserService userService;
  final ProfilePictureService profilePictureService;
  final PostService postService;
  final CommentService commentService;
  final FriendService friendService;
  final int? userId;

  const ProfileScreen({
    Key? key,
    required this.userService,
    required this.profilePictureService,
    required this.postService,
    required this.commentService,
    required this.friendService,
    this.userId,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  List<Post> _posts = [];
  Uint8List? _profilePicture;
  FriendStatus? _friendStatus;
  List<FriendResponse> _friends = [];
  bool _isLoading = true;
  String? _error;
  bool _isOwnProfile = false;

  @override
  void initState() {
    super.initState();
    _isOwnProfile = widget.userId == null;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Future> futures = [
        widget.userId != null
            ? widget.userService.getUserProfile(widget.userId!)
            : widget.userService.getProfile(),
        widget.userId != null
            ? widget.postService.getUserPosts(widget.userId!)
            : widget.postService.getMyPosts(),
        widget.profilePictureService.getUserProfilePicture(widget.userId),
      ];

      if (widget.userId != null) {
        futures.add(widget.friendService.getFriendStatus(widget.userId!));
        futures.add(widget.friendService.getUserFriends(widget.userId!));
      } else {
        futures.add(widget.friendService.getAllFriends());
      }

      final results = await Future.wait(futures);

      setState(() {
        _profile = results[0] as UserProfile;
        _posts = results[1] as List<Post>;
        _profilePicture = results[2] as Uint8List?;

        int resultIndex = 3;
        if (widget.userId != null) {
          _friendStatus = results[resultIndex] as FriendStatus;
          resultIndex++;
          _friends = results[resultIndex] as List<FriendResponse>;
        } else {
          _friends = results[resultIndex] as List<FriendResponse>;
        }

        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFriendRequest() async {
    try {
      await widget.friendService.sendFriendRequest(widget.userId!);
      _loadProfileData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send friend request: $e')),
        );
      }
    }
  }

  Future<void> _cancelFriendRequest() async {
    if (_friendStatus?.requestId == null) return;

    try {
      await widget.friendService.cancelFriendRequest(_friendStatus!.requestId!);
      _loadProfileData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request cancelled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel request: $e')),
        );
      }
    }
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => CreatePostDialog(
        postService: widget.postService,
        onPostCreated: _loadProfileData,
      ),
    );
  }

  Future<void> _handleReaction(Post post, ReactionType reaction) async {
    try {
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = _posts[index].copyWith(
            currentUserReaction: reaction.name.toUpperCase(),
          );
        }
      });
      await widget.postService.reactToPost(post.id, reaction.toString());
    } catch (e) {
      _loadProfileData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to react: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          user: _profile!,
          userService: widget.userService,
          profilePictureService: widget.profilePictureService,
        ),
      ),
    ).then((_) => _loadProfileData());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.home),
          ),
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.home),
          ),
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfileData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('Profile'),
        centerTitle: true,
        actions: _isOwnProfile ? [_buildSettingsMenu(isDark, themeProvider)] : null,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ProfileHeader(
                profile: _profile,
                profilePicture: _profilePicture,
                postCount: _posts.length,
                friendsCount: _friends.length,
                isDark: isDark,
                isOwnProfile: _isOwnProfile,
                friendStatus: _friendStatus,
                onEditProfile: _isOwnProfile ? _navigateToEditProfile : null,
                onCreatePost: _isOwnProfile ? _showCreatePostDialog : null,
                onSendFriendRequest:
                !_isOwnProfile && _friendStatus?.isNone == true
                    ? _sendFriendRequest
                    : null,
                onCancelFriendRequest:
                !_isOwnProfile && _friendStatus?.isPendingSent == true
                    ? _cancelFriendRequest
                    : null,
              ),
              const SizedBox(height: 12),
              _buildContentSection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsMenu(bool isDark, ThemeProvider themeProvider) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings_outlined),
      color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'theme') {
          themeProvider.toggleTheme();
        } else if (value == 'blocked') {
          context.go(AppRoutes.blocked);
        } else if (value == 'logout') {
          _showLogoutConfirmation(isDark);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'theme',
          child: Row(
            children: [
              Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                size: 20,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                isDark ? 'Light Mode' : 'Dark Mode',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'blocked',
          child: Row(
            children: [
              Icon(
                Icons.block,
                size: 20,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                'Blocked List',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 20, color: AppColors.error),
              const SizedBox(width: 12),
              const Text('Logout', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          title: Text(
            'Logout',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await performLogout(context);
              },
              child: const Text('Logout', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContentSection(bool isDark) {
    bool canViewPosts = _isOwnProfile || _friendStatus?.isFriends == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ProfileDetailsCard(
                  profile: _profile,
                  isDark: isDark,
                  isOwnProfile: _isOwnProfile,
                  onEditProfile: _navigateToEditProfile,
                ),
                const SizedBox(height: 16),
                ProfileFriendsGrid(
                  friends: _friends,
                  isDark: isDark,
                  userService: widget.userService,
                  profilePictureService: widget.profilePictureService,
                  friendService: widget.friendService,
                  viewingUserId: widget.userId,
                ),
                const SizedBox(height: 16),
                ProfilePostsSection(
                  posts: _posts,
                  isDark: isDark,
                  canViewPosts: canViewPosts,
                  profilePicture: _profilePicture,
                  currentUserEmail: _profile?.email ?? '',
                  commentService: widget.commentService,
                  postService: widget.postService,
                  onReactionSelected: _handleReaction,
                  onPostUpdated: _loadProfileData,
                  onPostDeleted: _loadProfileData,
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      ProfileDetailsCard(
                        profile: _profile,
                        isDark: isDark,
                        isOwnProfile: _isOwnProfile,
                        onEditProfile: _navigateToEditProfile,
                      ),
                      const SizedBox(height: 16),
                      ProfileFriendsGrid(
                        friends: _friends,
                        isDark: isDark,
                        userService: widget.userService,
                        profilePictureService: widget.profilePictureService,
                        friendService: widget.friendService,
                        viewingUserId: widget.userId,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ProfilePostsSection(
                    posts: _posts,
                    isDark: isDark,
                    canViewPosts: canViewPosts,
                    profilePicture: _profilePicture,
                    currentUserEmail: _profile?.email ?? '',
                    commentService: widget.commentService,
                    postService: widget.postService,
                    onReactionSelected: _handleReaction,
                    onPostUpdated: _loadProfileData,
                    onPostDeleted: _loadProfileData,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

}