import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/suggested_friend_response.dart';
import '../models/friend_response.dart';
import '../models/friend_status.dart';
import '../routes/app_router.dart';
import '../services/post_service.dart';
import '../services/profile_picture_service.dart';
import '../services/comment_service.dart';
import '../services/user_service.dart';
import '../services/friend_service.dart';
import '../utils/app_color.dart';
import '../utils/theme_provider.dart';
import '../utils/logout_utils.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_dialog.dart';
import '../enums/reaction_type.dart';
import '../models/user_search_result.dart';

class HomeScreen extends StatefulWidget {
  final PostService postService;
  final ProfilePictureService profilePictureService;
  final CommentService commentService;
  final UserService userService;
  final FriendService friendService;

  const HomeScreen({
    Key? key,
    required this.postService,
    required this.profilePictureService,
    required this.commentService,
    required this.userService,
    required this.friendService,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> _posts = [];
  List<SuggestedFriendResponse> _suggestedFriends = [];
  List<FriendResponse> _friends = [];
  Uint8List? _currentUserProfilePicture;
  Map<int, Uint8List?> _avatarCache = {};
  String _currentUserEmail = '';
  int? _currentUserId;
  bool _isLoading = true;
  bool _isLoadingFriends = true;
  String? _error;
  String? _friendsError;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _avatarCache.clear();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _isLoadingFriends = true;
      _error = null;
      _friendsError = null;
    });

    try {
      final profile = await widget.userService.getProfile();
      if (!mounted) return;

      _currentUserId = profile.id;
      _currentUserEmail = profile.email ?? '';

      final results = await Future.wait([
        widget.postService.getFriendsPosts(),
        widget.profilePictureService.getUserProfilePicture(null),
        widget.friendService.getSuggestedFriends(),
        widget.friendService.getAllFriends(),
      ]);

      if (!mounted) return;

      setState(() {
        _posts = results[0] as List<Post>;
        _currentUserProfilePicture = results[1] as Uint8List?;
        _suggestedFriends = results[2] as List<SuggestedFriendResponse>;
        _friends = results[3] as List<FriendResponse>;
        _isLoading = false;
        _isLoadingFriends = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingFriends = false;
      });
    }
  }

  Future<void> _refreshAll() async {
    await _loadAllData();
  }

  Future<Uint8List?> _getAvatar(int userId) async {
    if (_avatarCache.containsKey(userId)) return _avatarCache[userId];

    final bytes = await widget.profilePictureService.getUserProfilePicture(
        userId);

    if (!mounted) return bytes;

    setState(() {
      _avatarCache[userId] = bytes;
    });
    return bytes;
  }

  Widget _buildAvatar(int userId, String name, {double radius = 22}) {
    return FutureBuilder<Uint8List?>(
      future: _getAvatar(userId),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        return CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primary,
          backgroundImage: bytes != null ? MemoryImage(bytes) : null,
          child: bytes == null
              ? Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          )
              : null,
        );
      },
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          CreatePostDialog(
            postService: widget.postService,
            onPostCreated: _loadAllData,
          ),
    );
  }

  Future<void> _handleReaction(Post post, ReactionType reaction) async {
    try {
      if (!mounted) return;

      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = _posts[index].copyWith(
            currentUserReaction: reaction.name.toUpperCase(),
          );
        }
      });

      await widget.postService.reactToPost(post.id, reaction);
    } catch (e) {
      if (mounted) {
        _loadAllData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to react: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendFriendRequest(int userId) async {
    try {
      await widget.friendService.sendFriendRequest(userId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!')),
      );

      setState(() {
        _suggestedFriends.removeWhere((s) => s.id == userId);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: ${e.toString()}')),
      );
    }
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
            'Confirm Logout',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors
                  .lightTextPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors
                  .lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors
                      .lightTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (mounted) {
                  performLogout(context);
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

  Widget _buildUserTile({
    required int userId,
    required String name,
    String? subtitle,
    required bool isDark,
    Widget? trailing,
  }) {
    return ListTile(
      leading: _buildAvatar(userId, name, radius: 22),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors
              .lightTextPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors
              .lightTextSecondary,
          fontSize: 12,
        ),
      )
          : null,
      trailing: trailing,
      onTap: () {
        if (mounted) {
          context.go('${AppRoutes.profile}/$userId');
        }
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSuggestedFriendsSection(bool isDark, {required bool isMobile}) {
    if (_isLoadingFriends) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_suggestedFriends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.person_add,
                size: 20,
                color: isDark ? AppColors.darkTextSecondary : AppColors
                    .lightTextSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Suggested Friends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors
                      .lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
        if (isMobile)
          SizedBox(
            height: 137,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestedFriends.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestedFriends[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAvatar(suggestion.id, suggestion.name,
                              radius: 24),
                          const SizedBox(height: 4),
                          Text(
                            suggestion.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '${suggestion.mutualFriendsCount} mutual',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              fontSize: 8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          IconButton(
                            icon: const Icon(
                                Icons.add_circle_outline, size: 14),
                            color: AppColors.primary,
                            onPressed: () => _sendFriendRequest(suggestion.id),
                            tooltip: 'Send friend request',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 28, minHeight: 28),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _suggestedFriends.length,
            separatorBuilder: (_, __) =>
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkDivider : AppColors
                      .lightDivider,
                ),
            itemBuilder: (context, index) {
              final suggestion = _suggestedFriends[index];
              return _buildUserTile(
                userId: suggestion.id,
                name: suggestion.name,
                subtitle: '${suggestion
                    .mutualFriendsCount} mutual friend${suggestion
                    .mutualFriendsCount != 1 ? 's' : ''}',
                isDark: isDark,
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                  onPressed: () => _sendFriendRequest(suggestion.id),
                  tooltip: 'Send friend request',
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFriendsSection(bool isDark, {required bool isMobile}) {
    if (_isLoadingFriends) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_friends.isEmpty && _suggestedFriends.isEmpty) {
      return _buildEmptyFriendsState(isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.people,
                size: 20,
                color: isDark ? AppColors.darkTextSecondary : AppColors
                    .lightTextSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Friends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors
                      .lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
        if (isMobile)
          SizedBox(
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                final bool iAmSender = _currentUserId == friend.senderId;
                final int friendUserId = iAmSender ? friend.receiverId : friend
                    .senderId;
                final String friendName = iAmSender
                    ? friend.receiverName
                    : friend.senderName;

                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAvatar(friendUserId, friendName, radius: 20),
                          const SizedBox(height: 4),
                          Text(
                            friendName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          if (_friends.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No friends yet',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors
                        .lightTextSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _friends.length,
              separatorBuilder: (_, __) =>
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.darkDivider : AppColors
                        .lightDivider,
                  ),
              itemBuilder: (context, index) {
                final friend = _friends[index];

                final bool iAmSender = _currentUserId == friend.senderId;
                final int friendUserId = iAmSender ? friend.receiverId : friend
                    .senderId;
                final String friendName = iAmSender
                    ? friend.receiverName
                    : friend.senderName;

                return _buildUserTile(
                  userId: friendUserId,
                  name: friendName,
                  isDark: isDark,
                );
              },
            ),
      ],
    );
  }

  Widget _buildEmptyFriendsState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: isDark ? AppColors.darkTextSecondary : AppColors
                  .lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Friends Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors
                    .lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add friends to see their posts here!',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors
                    .lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsSection(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState(isDark);
    }

    if (_posts.isEmpty) {
      return _buildEmptyPostsState(isDark);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(_posts.length, (index) {
          final post = _posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: PostCard(
              post: post,
              isDark: isDark,
              profilePicture: _currentUserProfilePicture,
              currentUserEmail: _currentUserEmail,
              commentService: widget.commentService,
              postService: widget.postService,
              onPostUpdated: _loadAllData,
              onPostDeleted: _loadAllData,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyPostsState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors
                  .lightTextSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Posts Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors
                    .lightTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your friends haven\'t posted anything yet.\nAdd more friends to see their posts here!',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors
                    .lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                if (mounted) {
                  context.go(AppRoutes.friends);
                }
              },
              icon: const Icon(Icons.people),
              label: const Text('Find Friends'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? AppColors.darkTextSecondary : AppColors
                .lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors
                  .lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? _friendsError ?? 'Unknown error',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors
                  .lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final selectedUserId = await showSearch<int?>(
                context: context,
                delegate: UserSearchDelegate(
                  userService: widget.userService,
                  profilePictureService: widget.profilePictureService,
                  isDark: isDark,
                ),
              );
              if (selectedUserId != null && mounted) {
                context.go('${AppRoutes.profile}/$selectedUserId');
              }
            },
            tooltip: 'Search users',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              if (mounted) context.go(AppRoutes.profile);
            },
            tooltip: 'My Profile',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_outlined),
            color: isDark ? AppColors.darkCardBackground : AppColors
                .lightCardBackground,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (!mounted) return;

              switch (value) {
                case 'theme':
                  themeProvider.toggleTheme();
                  break;
                case 'friends':
                  context.go(AppRoutes.friends);
                  break;
                case 'blocked':
                  context.go(AppRoutes.blocked);
                  break;
                case 'logout':
                  _showLogoutConfirmation(isDark);
                  break;
              }
            },
            itemBuilder: (context) =>
            [
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      size: 20,
                      color: isDark ? AppColors.darkTextPrimary : AppColors
                          .lightTextPrimary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isDark ? 'Light Mode' : 'Dark Mode',
                      style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors
                              .lightTextPrimary),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'friends',
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 20,
                      color: isDark ? AppColors.darkTextPrimary : AppColors
                          .lightTextPrimary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Friends',
                      style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors
                              .lightTextPrimary),
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
                      color: isDark ? AppColors.darkTextPrimary : AppColors
                          .lightTextPrimary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Blocked List',
                      style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors
                              .lightTextPrimary),
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
                    const Text(
                        'Logout', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: _buildBody(isDark),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading && _isLoadingFriends) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSuggestedFriendsSection(isDark, isMobile: true),
                const SizedBox(height: 16),
                _buildFriendsSection(isDark, isMobile: true),
                const SizedBox(height: 16),
                _buildPostsSection(isDark),
              ],
            ),
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: isDark ? AppColors.darkDivider : AppColors
                            .lightDivider,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListView(
                    children: [
                      _buildSuggestedFriendsSection(isDark, isMobile: false),
                      _buildFriendsSection(isDark, isMobile: false),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: _buildPostsSection(isDark),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class UserSearchDelegate extends SearchDelegate<int?> {
  final UserService userService;
  final ProfilePictureService profilePictureService;
  final bool isDark;

  UserSearchDelegate({
    required this.userService,
    required this.profilePictureService,
    required this.isDark,
  });

  @override
  String? get searchFieldLabel => 'Search users by name';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults(context);

  Widget _buildResults(BuildContext context) {
    if (query
        .trim()
        .isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors
                  .lightTextSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Type a name to search',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors
                    .lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<UserSearchResult>>(
      future: userService.findUsersByName(query.trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Search failed: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors
                      .lightTextSecondary,
                ),
              ),
            ),
          );
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_search,
                  size: 64,
                  color: isDark ? AppColors.darkTextSecondary : AppColors
                      .lightTextSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No users found',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors
                        .lightTextSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) =>
              Divider(
                height: 1,
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
          itemBuilder: (context, index) {
            final user = results[index];
            return ListTile(
              onTap: () => close(context, user.id),
              leading: FutureBuilder<Uint8List?>(
                future: profilePictureService.getUserProfilePicture(user.id),
                builder: (context, snap) {
                  final bytes = snap.data;
                  return CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    backgroundImage: bytes != null ? MemoryImage(bytes) : null,
                    child: bytes == null
                        ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )
                        : null,
                  );
                },
              ),
              title: Text(
                user.name,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors
                      .lightTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                user.email,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors
                      .lightTextSecondary,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            );
          },
        );
      },
    );
  }
}
