// services/friend_service.dart
import '../models/friend_request.dart';
import '../models/friend_response.dart';
import '../models/friend_status.dart';
import '../models/user_search_result.dart';
import 'api_service.dart';

class FriendService {
  final ApiService _apiService;

  FriendService(this._apiService);

  Future<FriendResponse> sendFriendRequest(int receiverId) async {
    final response = await _apiService.post(
      '/friends/send',
      data: FriendRequest(receiverId: receiverId).toJson(),
    );
    return FriendResponse.fromJson(response);
  }

  Future<void> approveFriendRequest(int friendshipId) async {
    await _apiService.post('/friends/$friendshipId/approve', data: {});
  }

  Future<void> declineFriendRequest(int friendshipId) async {
    await _apiService.post('/friends/$friendshipId/decline', data: {});
  }

  Future<List<UserSearchResult>> findUsersByName(String name) async {
    final response = await _apiService.get('/friends/$name');
    return (response as List)
        .map((json) => UserSearchResult.fromJson(json))
        .toList();
  }

  Future<List<FriendResponse>> getReceivedFriendRequests() async {
    final response = await _apiService.get('/friends/received-requests');
    return (response as List)
        .map((json) => FriendResponse.fromJson(json))
        .toList();
  }

  Future<List<FriendResponse>> getSentFriendRequests() async {
    final response = await _apiService.get('/friends/sent-requests');
    return (response as List)
        .map((json) => FriendResponse.fromJson(json))
        .toList();
  }

  Future<List<FriendResponse>> getAllFriends() async {
    final response = await _apiService.get('/friends/');
    return (response as List)
        .map((json) => FriendResponse.fromJson(json))
        .toList();
  }

  Future<List<FriendResponse>> getBlockedUsers() async {
    final response = await _apiService.get('/friends/blocked');
    return (response as List)
        .map((json) => FriendResponse.fromJson(json))
        .toList();
  }

  Future<FriendResponse> blockUser(int friendshipId) async {
    final response = await _apiService.post('/friends/$friendshipId/block', data: {});
    return FriendResponse.fromJson(response);
  }

  Future<FriendResponse> unblockUser(int friendshipId) async {
    final response = await _apiService.patch('/friends/$friendshipId/unblock', data: {});
    return FriendResponse.fromJson(response);
  }

  Future<void> removeFriend(int friendshipId) async {
    await _apiService.patch('/friends/$friendshipId/remove', data: {});
  }

  Future<void> cancelFriendRequest(int friendshipId) async {
    await _apiService.patch('/friends/$friendshipId/cancel', data: {});
  }

  Future<FriendStatus> getFriendStatus(int userId) async {
    final response = await _apiService.get('/friends/status/$userId');
    return FriendStatus.fromJson(response);
  }

}