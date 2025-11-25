package org.example.socialmediaapp.services;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.example.socialmediaapp.dto.SuggestedFriendResponse;
import org.example.socialmediaapp.dto.FriendResponse;
import org.example.socialmediaapp.dto.FriendStatusResponse;
import org.example.socialmediaapp.entities.Friend;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.repositories.FriendRepo;
import org.example.socialmediaapp.repositories.UserRepo;
import org.example.socialmediaapp.utils.SecurityUtils;
import org.example.socialmediaapp.utils.enums.RequestStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional(rollbackOn = Exception.class)
@RequiredArgsConstructor
public class FriendService {

    @Autowired
    private final FriendRepo friendRepo;

    @Autowired
    private final UserRepo userRepo;

    public FriendResponse sendFriendRequest(User sender, int receiverId) {
        User receiver = userRepo.findById(receiverId).orElseThrow(() -> new RuntimeException("User not found"));
        if (receiverId == sender.getId()) {
            throw new IllegalArgumentException("Cannot send friend request to yourself");
        }
        Optional<Friend> existingRequest1 = friendRepo.findByUser1AndUser2(sender, receiver);
        Optional<Friend> existingRequest2 = friendRepo.findByUser1AndUser2(receiver, sender);
        if (existingRequest1.isPresent() || existingRequest2.isPresent()) {
            throw new RuntimeException("Friend request already exists");
        }
        Friend friendRequest = new Friend(sender, receiver, false, RequestStatus.REQUESTED);
        Friend friend = friendRepo.save(friendRequest);
        return convertToResponse(friend);
    }

    public void approveFriendRequest(int id) {
        User user = SecurityUtils.getCurrentUser();
        Friend friendRequest = friendRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Friend request not found"));
        if (!friendRequest.getRequestStatus().equals(RequestStatus.REQUESTED)) {
            throw new RuntimeException("Friend request already processed");
        }
        if (friendRequest.getUser2().getId() != user.getId()) {
            throw new RuntimeException("Only the receiver can approve this request");
        }
        friendRequest.setRequestStatus(RequestStatus.APPROVED);
        friendRepo.save(friendRequest);
    }

    public void declineFriendRequest(int id) {
        User user = SecurityUtils.getCurrentUser();
        Friend friendRequest = friendRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Friend request not found"));
        if (!friendRequest.getRequestStatus().equals(RequestStatus.REQUESTED)) {
            throw new RuntimeException("Friend request already processed");
        }
        if (friendRequest.getUser2().getId() != user.getId()) {
            throw new RuntimeException("Only the receiver can decline this request");
        }
        friendRequest.setRequestStatus(RequestStatus.DECLINED);
        friendRepo.save(friendRequest);
    }

    public List<FriendResponse> getSentFriendRequests() {
        User user = SecurityUtils.getCurrentUser();
        List<Friend> friendRequests = friendRepo.findByUser1AndRequestStatusOrderByIdDesc(user, RequestStatus.REQUESTED);
        return friendRequests.stream().map(this::convertToResponse).collect(Collectors.toList());
    }

    public List<FriendResponse> getReceiverFriendRequests() {
        User user = SecurityUtils.getCurrentUser();
        List<Friend> friendRequests = friendRepo.findByUser2AndRequestStatusOrderByIdDesc(user, RequestStatus.REQUESTED);
        return friendRequests.stream().map(this::convertToResponse).collect(Collectors.toList());
    }

    public List<FriendResponse> getAllFriends() {
        User user = SecurityUtils.getCurrentUser();
        List<Friend> allFriends = friendRepo.findAllFriendsByUserAndStatusOrderByIdDesc(user, RequestStatus.APPROVED);
        return allFriends.stream()
                .collect(Collectors.toMap(Friend::getId, f -> f, (f1, f2) -> f1))
                .values().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<FriendResponse> getAllFriends(int id) {
        User user = userRepo.findById(id).orElseThrow(() -> new RuntimeException("User not found"));
        List<Friend> allFriends = friendRepo.findAllFriendsByUserAndStatusOrderByIdDesc(user, RequestStatus.APPROVED);
        return allFriends.stream().distinct().map(this::convertToResponse).collect(Collectors.toList());
    }

    public List<FriendResponse> getBlockedUsers() {
        User user = SecurityUtils.getCurrentUser();
        List<Friend> blockedUsers = friendRepo.findByUser1AndIsBlockedTrueOrderByIdDesc(user);
        return blockedUsers.stream().map(this::convertToResponse).collect(Collectors.toList());
    }

    public FriendResponse blockUser(int friendId) {
        User user = SecurityUtils.getCurrentUser();
        Friend friend = friendRepo.findById(friendId)
                .orElseThrow(() -> new RuntimeException("Friendship not found"));
        if (friend.getUser1().getId() != user.getId() && friend.getUser2().getId() != user.getId()) {
            throw new RuntimeException("User is not part of this friendship");
        }
        if (friend.isBlocked()) {
            throw new RuntimeException("User is already blocked");
        }
        if (friend.getUser2().getId() == user.getId()) {
            User temp = friend.getUser1();
            friend.setUser1(friend.getUser2());
            friend.setUser2(temp);
        }
        friend.setBlocked(true);
        Friend blockedFriend = friendRepo.save(friend);
        return convertToResponse(blockedFriend);
    }

    public FriendResponse unblockUser(int friendId) {
        User user = SecurityUtils.getCurrentUser();
        Friend friend = friendRepo.findById(friendId)
                .orElseThrow(() -> new RuntimeException("Friendship not found"));
        if (friend.getUser1().getId() != user.getId()) {
            throw new RuntimeException("Only the user who blocked can unblock");
        }
        if (!friend.isBlocked()) {
            throw new RuntimeException("User is not blocked");
        }
        friend.setBlocked(false);
        Friend unblockedFriend = friendRepo.save(friend);
        return convertToResponse(unblockedFriend);
    }

    public void cancelFriendRequest(int id) {
        User user = SecurityUtils.getCurrentUser();
        Friend friendRequest = friendRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Friend request not found"));
        if (!friendRequest.getRequestStatus().equals(RequestStatus.REQUESTED)) {
            throw new RuntimeException("Friend request already processed");
        }
        if (friendRequest.getUser1().getId() != user.getId()) {
            throw new RuntimeException("Only the sender can cancel this request");
        }
        friendRequest.setRequestStatus(RequestStatus.CANCELLED);
        friendRepo.save(friendRequest);
    }

    public void removeFriend(int id) {
        User user = SecurityUtils.getCurrentUser();
        Friend friendship = friendRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Friendship not found"));
        if (!friendship.getRequestStatus().equals(RequestStatus.APPROVED)) {
            throw new RuntimeException("This is not an active friendship");
        }
        if (friendship.getUser1().getId() != user.getId() && friendship.getUser2().getId() != user.getId()) {
            throw new RuntimeException("User is not part of this friendship");
        }
        friendship.setRequestStatus(RequestStatus.REMOVED);
        friendRepo.save(friendship);
    }

    public List<SuggestedFriendResponse> getSuggestedFriends() {
        User currentUser = SecurityUtils.getCurrentUser();
        int currentUserId = currentUser.getId();
        Set<Integer> excludedIds = new HashSet<>();
        excludedIds.add(currentUserId);
        excludedIds.addAll(friendRepo.findBlockedUserIds(currentUserId));
        List<Friend> pendingSent = friendRepo.findByUser1AndRequestStatusOrderByIdDesc(currentUser, RequestStatus.REQUESTED);
        List<Friend> pendingReceived = friendRepo.findByUser2AndRequestStatusOrderByIdDesc(currentUser, RequestStatus.REQUESTED);
        List<Friend> approvedFriends = friendRepo.findAllFriendsByUserAndStatusOrderByIdDesc(currentUser, RequestStatus.APPROVED);
        for (Friend f : pendingSent) {
            excludedIds.add(f.getUser2().getId());
        }
        for (Friend f : pendingReceived) {
            excludedIds.add(f.getUser1().getId());
        }
        for (Friend f : approvedFriends) {
            int friendId = f.getUser1().getId() == currentUserId ? f.getUser2().getId() : f.getUser1().getId();
            excludedIds.add(friendId);
        }
        Map<Integer, SuggestedFriendResponse> suggestionsMap = new HashMap<>();
        for (Friend directFriend : approvedFriends) {
            User friendUser = directFriend.getUser1().getId() == currentUserId ? directFriend.getUser2() : directFriend.getUser1();
            List<Friend> friendsOfFriend = friendRepo.findAllFriendsByUserAndStatusOrderByIdDesc(friendUser, RequestStatus.APPROVED);
            for (Friend fof : friendsOfFriend) {
                User suggestedUser = fof.getUser1().getId() == friendUser.getId() ? fof.getUser2() : fof.getUser1();
                int suggestedUserId = suggestedUser.getId();
                if (suggestedUserId == currentUserId || excludedIds.contains(suggestedUserId)) {
                    continue;
                }
                if (suggestionsMap.containsKey(suggestedUserId)) {
                    suggestionsMap.get(suggestedUserId).setMutualFriendsCount(
                            suggestionsMap.get(suggestedUserId).getMutualFriendsCount() + 1
                    );
                } else {
                    SuggestedFriendResponse response = new SuggestedFriendResponse();
                    response.setId(suggestedUserId);
                    response.setName(suggestedUser.getName());
                    response.setMutualFriendsCount(1);
                    suggestionsMap.put(suggestedUserId, response);
                }
            }
        }
        return suggestionsMap.values().stream()
                .sorted((r1, r2) -> Integer.compare(r2.getMutualFriendsCount(), r1.getMutualFriendsCount()))
                .collect(Collectors.toList());
    }

    public List<User> findUsersByName(String name) {
        User user = SecurityUtils.getCurrentUser();
        List<Friend> allRelationships = new ArrayList<>();
        allRelationships.addAll(friendRepo.findByUser1AndRequestStatusOrderByIdDesc(user, RequestStatus.APPROVED));
        allRelationships.addAll(friendRepo.findByUser2AndRequestStatusOrderByIdDesc(user, RequestStatus.APPROVED));
        Set<Integer> excludedIds = new HashSet<>();
        excludedIds.add(user.getId());
        for (Friend rel : allRelationships) {
            excludedIds.add(rel.getUser1().getId());
            excludedIds.add(rel.getUser2().getId());
        }
        return userRepo.findByNameContainingIgnoreCase(name).stream()
                .filter(u -> !excludedIds.contains(u.getId()))
                .filter(u -> u.getId() != user.getId())
                .collect(Collectors.toList());
    }

    public boolean areFriends(int userId1, int userId2) {
        if (userId1 == userId2) return false;
        User user1 = userRepo.findById(userId1).orElse(null);
        User user2 = userRepo.findById(userId2).orElse(null);
        if (user1 == null || user2 == null) return false;
        Optional<Friend> friendship1 = friendRepo.findByUser1AndUser2(user1, user2);
        Optional<Friend> friendship2 = friendRepo.findByUser1AndUser2(user2, user1);
        return friendship1.map(f -> f.getRequestStatus() == RequestStatus.APPROVED && !f.isBlocked())
                .orElseGet(() -> friendship2.map(f -> f.getRequestStatus() == RequestStatus.APPROVED && !f.isBlocked())
                        .orElse(false));
    }

    public FriendStatusResponse getFriendStatus(int currentUserId, int targetUserId) {
        if (currentUserId == targetUserId) return new FriendStatusResponse("SELF", null);
        User currentUser = userRepo.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("Current user not found"));
        User targetUser = userRepo.findById(targetUserId)
                .orElseThrow(() -> new RuntimeException("Target user not found"));
        Optional<Friend> friendship1 = friendRepo.findByUser1AndUser2(currentUser, targetUser);
        Optional<Friend> friendship2 = friendRepo.findByUser1AndUser2(targetUser, currentUser);
        Friend friendship = null;
        boolean currentUserIsSender = false;
        if (friendship1.isPresent()) {
            friendship = friendship1.get();
            currentUserIsSender = true;
        } else if (friendship2.isPresent()) {
            friendship = friendship2.get();
            currentUserIsSender = false;
        }
        if (friendship == null) return new FriendStatusResponse("NONE", null);
        if (friendship.isBlocked()) return new FriendStatusResponse("BLOCKED", friendship.getId());
        switch (friendship.getRequestStatus()) {
            case APPROVED:
                return new FriendStatusResponse("FRIENDS", friendship.getId());
            case REQUESTED:
                return new FriendStatusResponse(
                        currentUserIsSender ? "PENDING_SENT" : "PENDING_RECEIVED",
                        friendship.getId()
                );
            case DECLINED:
            case CANCELLED:
            case REMOVED:
                return new FriendStatusResponse("NONE", null);
            default:
                return new FriendStatusResponse("NONE", null);
        }
    }

    private FriendResponse convertToResponse(Friend friend) {
        FriendResponse response = new FriendResponse();
        response.setId(friend.getId());
        response.setSenderId(friend.getUser1().getId());
        response.setReceiverId(friend.getUser2().getId());
        response.setSenderName(friend.getUser1().getName());
        response.setReceiverName(friend.getUser2().getName());
        response.setBlocked(friend.isBlocked());
        response.setRequestStatus(friend.getRequestStatus());
        return response;
    }
}