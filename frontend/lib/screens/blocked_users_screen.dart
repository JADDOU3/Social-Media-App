import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/friend_response.dart';
import '../services/friend_service.dart';
import '../utils/app_color.dart';

class BlockedUsersScreen extends StatefulWidget {
  final FriendService friendService;
  const BlockedUsersScreen({Key? key, required this.friendService}) : super(key: key);
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Unblock', style: TextStyle(color: AppColors.success))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await widget.friendService.unblockUser(friendshipId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User unblocked')));
          _loadBlockedUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to unblock: ${e.toString()}')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/home')),
        title: const Text('Blocked Users'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text('Error loading blocked users', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadBlockedUsers, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_blockedUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No blocked users', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
          return _buildBlockedUserCard(blockedUser);
        },
      ),
    );
  }

  Widget _buildBlockedUserCard(FriendResponse blockedUser) {
    final userName = blockedUser.receiverName;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.error.withOpacity(0.2), child: Icon(Icons.block, color: AppColors.error)),
        title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Friendship ID: ${blockedUser.id}'),
        trailing: ElevatedButton(
          onPressed: () => _unblockUser(blockedUser.id, userName),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
          child: const Text('Unblock'),
        ),
      ),
    );
  }
}