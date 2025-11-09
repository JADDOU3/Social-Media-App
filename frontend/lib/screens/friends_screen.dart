// screens/friends_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/friend_response.dart';
import '../models/user_search_result.dart';
import '../routes/app_router.dart';
import '../services/friend_service.dart';
import '../utils/app_color.dart';
import '../utils/theme_provider.dart';

class FriendsScreen extends StatefulWidget {
  final FriendService friendService;

  const FriendsScreen({
    Key? key,
    required this.friendService,
  }) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FriendResponse> _friends = [];
  List<FriendResponse> _receivedRequests = [];
  List<FriendResponse> _sentRequests = [];
  List<UserSearchResult> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFriendsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendsData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        widget.friendService.getAllFriends(),
        widget.friendService.getReceivedFriendRequests(),
        widget.friendService.getSentFriendRequests(),
      ]);

      setState(() {
        _friends = results[0] as List<FriendResponse>;
        _receivedRequests = results[1] as List<FriendResponse>;
        _sentRequests = results[2] as List<FriendResponse>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await widget.friendService.findUsersByName(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendFriendRequest(int userId) async {
    try {
      await widget.friendService.sendFriendRequest(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request sent!')),
        );
        _loadFriendsData();
        _searchController.clear();
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _approveFriendRequest(int friendshipId) async {
    try {
      await widget.friendService.approveFriendRequest(friendshipId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request approved!')),
        );
        _loadFriendsData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _declineFriendRequest(int friendshipId) async {
    try {
      await widget.friendService.declineFriendRequest(friendshipId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request declined')),
        );
        _loadFriendsData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to decline: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _cancelFriendRequest(int friendshipId) async {
    try {
      await widget.friendService.cancelFriendRequest(friendshipId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request cancelled')),
        );
        _loadFriendsData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _removeFriend(int friendshipId, String friendName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove $friendName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.friendService.removeFriend(friendshipId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Friend removed')),
          );
          _loadFriendsData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        title: const Text('Friends'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchUsers,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                        });
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkCardBackground
                        : AppColors.lightCardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (_searchResults.isEmpty)
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  tabs: [
                    Tab(
                      text: 'Friends (${_friends.length})',
                    ),
                    Tab(
                      text: 'Received (${_receivedRequests.length})',
                    ),
                    Tab(
                      text: 'Sent (${_sentRequests.length})',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFriendsData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isNotEmpty || _searchController.text.isNotEmpty) {
      return _buildSearchResults(isDark);
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildFriendsList(isDark),
        _buildReceivedRequestsList(isDark),
        _buildSentRequestsList(isDark),
      ],
    );
  }

  Widget _buildSearchResults(bool isDark) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserCard(user, isDark);
      },
    );
  }

  Widget _buildUserCard(UserSearchResult user, bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color:
      isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            if (user.bio != null && user.bio!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  user.bio!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _sendFriendRequest(user.id),
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList(bool isDark) {
    if (_friends.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        message: 'No friends yet',
        isDark: isDark,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriendsData,
      child: ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return _buildFriendCard(friend, isDark);
        },
      ),
    );
  }

  Widget _buildFriendCard(FriendResponse friend, bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color:
      isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            friend.receiverName.isNotEmpty
                ? friend.receiverName[0].toUpperCase()
                : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          friend.receiverName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        subtitle: Text(
          friend.receiverEmail,
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'remove') {
              _removeFriend(friend.id, friend.receiverName);
            } else if (value == 'block') {
              _blockUser(friend.id, friend.receiverName);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, size: 20, color: Colors.orange),
                  SizedBox(width: 12),
                  Text('Remove Friend'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Block User'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedRequestsList(bool isDark) {
    if (_receivedRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        message: 'No pending requests',
        isDark: isDark,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriendsData,
      child: ListView.builder(
        itemCount: _receivedRequests.length,
        itemBuilder: (context, index) {
          final request = _receivedRequests[index];
          return _buildReceivedRequestCard(request, isDark);
        },
      ),
    );
  }

  Widget _buildReceivedRequestCard(FriendResponse request, bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color:
      isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    request.senderName.isNotEmpty
                        ? request.senderName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.senderName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        request.senderEmail,
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
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveFriendRequest(request.id),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _declineFriendRequest(request.id),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentRequestsList(bool isDark) {
    if (_sentRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send_outlined,
        message: 'No sent requests',
        isDark: isDark,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriendsData,
      child: ListView.builder(
        itemCount: _sentRequests.length,
        itemBuilder: (context, index) {
          final request = _sentRequests[index];
          return _buildSentRequestCard(request, isDark);
        },
      ),
    );
  }

  Widget _buildSentRequestCard(FriendResponse request, bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color:
      isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            request.receiverName.isNotEmpty
                ? request.receiverName[0].toUpperCase()
                : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          request.receiverName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.receiverEmail,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pending',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: TextButton(
          onPressed: () => _cancelFriendRequest(request.id),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required bool isDark,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _blockUser(int friendshipId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.friendService.blockUser(friendshipId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User blocked')),
          );
          _loadFriendsData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to block: ${e.toString()}')),
          );
        }
      }
    }
  }
}