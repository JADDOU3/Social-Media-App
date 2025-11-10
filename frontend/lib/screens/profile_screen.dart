import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/user_profile.dart';
import '../models/friend_status.dart';
import '../routes/app_router.dart';
import '../services/post_service.dart';
import '../services/profile_picture_service.dart';
import '../services/user_service.dart';
import '../services/comment_service.dart';
import '../services/friend_service.dart';
import '../utils/app_color.dart';
import '../utils/theme_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_dialog.dart';
import '../enums/reaction_type.dart';

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
      }

      final results = await Future.wait(futures);

      setState(() {
        _profile = results[0] as UserProfile;
        _posts = results[1] as List<Post>;
        _profilePicture = results[2] as Uint8List?;
        if (widget.userId != null) {
          _friendStatus = results[3] as FriendStatus;
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

  void _handleReaction(Post post, ReactionType reaction) {
    print('Post ${post.id}: Selected reaction: ${reaction.name}');
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
            onPressed: () {
              context.go(AppRoutes.home);
            },
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
            onPressed: () {
              context.go(AppRoutes.home);
            },
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
          onPressed: () {
            context.go(AppRoutes.home);
          },
        ),
        title: const Text('Profile'),
        centerTitle: true,
        actions: _isOwnProfile
            ? [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_outlined),
            color: isDark
                ? AppColors.darkCardBackground
                : AppColors.lightCardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'theme') {
                themeProvider.toggleTheme();
              } else if (value == 'blocked') {
                _navigateToBlockedList();
              } else if (value == 'logout') {
                _showLogoutConfirmation();
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
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isDark ? 'Light Mode' : 'Dark Mode',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
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
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Blocked List',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
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
                    const Icon(
                      Icons.logout,
                      size: 20,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Logout',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]
            : null,
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
                isDark: isDark,
                isOwnProfile: _isOwnProfile,
                friendStatus: _friendStatus,
                onEditProfile: _isOwnProfile
                    ? () {
                  // TODO: Navigate to edit profile screen
                }
                    : null,
                onCreatePost: _isOwnProfile ? _showCreatePostDialog : null,
                onChangeProfilePicture: _isOwnProfile
                    ? () {
                  // TODO: Implement profile picture change
                }
                    : null,
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
              _buildPostsSection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBlockedList() {
    context.go(AppRoutes.blocked);
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark =
            Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

        return AlertDialog(
          backgroundColor: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          title: Text(
            'Logout',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                    ),
                  );
                }
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostsSection(bool isDark) {
    bool canViewPosts = _isOwnProfile || _friendStatus?.isFriends == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Posts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
          if (!canViewPosts)
            _buildPrivateProfileMessage(isDark)
          else if (_posts.isEmpty)
            _buildEmptyState(isDark)
          else
            _buildPostsList(isDark),
        ],
      ),
    );
  }

  Widget _buildPrivateProfileMessage(bool isDark) {
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

  Widget _buildEmptyState(bool isDark) {
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

  Widget _buildPostsList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return PostCard(
          post: post,
          isDark: isDark,
          profilePicture: _profilePicture,
          currentUserEmail: _profile?.email ?? '',
          commentService: widget.commentService,
          postService: widget.postService,
          onReactionSelected: (reaction) => _handleReaction(post, reaction),
          onPostUpdated: _loadProfileData,
          onPostDeleted: _loadProfileData,
        );
      },
    );
  }
}