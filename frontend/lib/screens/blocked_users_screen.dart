import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/friend_response.dart';
import '../routes/app_router.dart';
import '../services/friend_service.dart';
import '../utils/app_color.dart';
import '../utils/theme_provider.dart';

class BlockedUsersScreen extends StatefulWidget {
  final FriendService friendService;

  const BlockedUsersScreen({
    Key? key,
    required this.friendService,
  }) : super(key: key);

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<FriendResponse> _blockedUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final blockedUsers = await widget.friendService.getBlockedUsers();
      setState(() {
        _blockedUsers = blockedUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _unblockUser(int friendshipId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User'),
        content: Text('Are you sure you want to unblock $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unblock', style: TextStyle(color: AppColors.success)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.friendService.unblockUser(friendshipId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User unblocked')),
          );
          _loadBlockedUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to unblock: ${e.toString()}')),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('Blocked Users'),
        centerTitle: true,
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading blocked users',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBlockedUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 64,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No blocked users',
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

    return RefreshIndicator(
      onRefresh: _loadBlockedUsers,
      child: ListView.builder(
        itemCount: _blockedUsers.length,
        itemBuilder: (context, index) {
          final blockedUser = _blockedUsers[index];
          return _buildBlockedUserCard(blockedUser, isDark);
        },
      ),
    );
  }

  Widget _buildBlockedUserCard(FriendResponse blockedUser, bool isDark) {
    final userName = blockedUser.receiverName.isNotEmpty
        ? blockedUser.receiverName
        : blockedUser.senderName;
    final userEmail = blockedUser.receiverEmail.isNotEmpty
        ? blockedUser.receiverEmail
        : blockedUser.senderEmail;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark
          ? AppColors.darkCardBackground
          : AppColors.lightCardBackground,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.error.withOpacity(0.2),
          child: Icon(
            Icons.block,
            color: AppColors.error,
          ),
        ),
        title: Text(
          userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        subtitle: Text(
          userEmail,
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () => _unblockUser(blockedUser.id, userName),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
          child: const Text('Unblock'),
        ),
      ),
    );
  }
}