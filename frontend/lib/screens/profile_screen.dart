import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/user_profile.dart';
import '../routes/app_router.dart';
import '../services/post_service.dart';
import '../services/profile_picture_service.dart';
import '../services/user_service.dart';
import '../services/comment_service.dart';
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

  const ProfileScreen({
    Key? key,
    required this.userService,
    required this.profilePictureService,
    required this.postService,
    required this.commentService,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  List<Post> _posts = [];
  Uint8List? _profilePicture;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        widget.userService.getProfile(),
        widget.postService.getMyPosts(),
        widget.profilePictureService.getProfilePicture(),
      ]);

      setState(() {
        _profile = results[0] as UserProfile;
        _posts = results[1] as List<Post>;
        _profilePicture = results[2] as Uint8List?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
    // TODO: Call your API to add reaction
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
            icon: const Icon(Icons.home_outlined),
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
            icon: const Icon(Icons.home_outlined),
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
          icon: const Icon(Icons.home_outlined),
          onPressed: () {
            context.go(AppRoutes.home);
          },
        ),
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
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
        ],
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
                onEditProfile: () {
                  // TODO: Navigate to edit profile screen
                },
                onCreatePost: _showCreatePostDialog,
                onChangeProfilePicture: () {
                  // TODO: Implement profile picture change
                },
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
    // TODO: Navigate to blocked list screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Blocked list coming soon...'),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

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

                // TODO: Clear tokens - uncomment when you have access to localStorage
                // await localStorage.clearTokens();

                if (context.mounted) {
                  // TODO: Navigate to login screen when you have that route
                  // context.go('/login');
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
          _posts.isEmpty
              ? _buildEmptyState(isDark)
              : _buildPostsList(isDark),
        ],
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