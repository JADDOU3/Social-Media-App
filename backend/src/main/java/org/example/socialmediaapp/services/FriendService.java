package org.example.socialmediaapp.services;


import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.example.socialmediaapp.dto.FriendRequest;
import org.example.socialmediaapp.dto.FriendResponse;
import org.example.socialmediaapp.entities.Friend;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.repositories.FriendRepo;
import org.example.socialmediaapp.repositories.UserRepo;
import org.example.socialmediaapp.utils.SecurityUtils;
import org.example.socialmediaapp.utils.enums.RequestStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional(rollbackOn =  Exception.class)
@RequiredArgsConstructor
public class FriendService {

    @Autowired
    private final FriendRepo friendRepo;

    @Autowired
    private final UserRepo userRepo;

    public FriendResponse sendFriendRequest(User sender , int receiverId) {
        User receiver = userRepo.findById(receiverId).orElseThrow(() -> new RuntimeException("User not found"));

        if(receiverId == sender.getId()){
            throw new IllegalArgumentException();
        }

        Optional<Friend> existingRequest1 = friendRepo.findByUser1AndUser2(sender, receiver);
        Optional<Friend> existingRequest2 = friendRepo.findByUser1AndUser2(receiver, sender);
        if (existingRequest1.isPresent() || existingRequest2.isPresent()) {
            throw new RuntimeException("Friend request already exists");
        }
        Friend friendRequest = new Friend(
                sender,
                receiver,
                false,
                RequestStatus.REQUESTED
        );

        Friend friend = friendRepo.save(friendRequest);
        return convertToResponse(friend);

    }

    public void approveFriendRequest(int id){
        User user = SecurityUtils.getCurrentUser();
        Optional<Friend> friendRequest = friendRepo.findById(id);
        if(friendRequest.isPresent() && friendRequest.get().getRequestStatus().equals(RequestStatus.REQUESTED)){
            if(friendRequest.get().getUser2().getId() == user.getId() ) {// only user 2 ( reveiver )
                friendRequest.get().setRequestStatus(RequestStatus.APPROVED);
                friendRepo.save(friendRequest.get());
            }
            else{
                throw new  RuntimeException("User with id" + user.getId() + " is not part of that request");
            }
        }
        else{
            throw new RuntimeException("Friend request not found or already approved");
        }

    }

    public void declineFriendRequest(int id){
        User user = SecurityUtils.getCurrentUser();
        Optional<Friend> friendRequest = friendRepo.findById(id);
        if(friendRequest.isPresent() && friendRequest.get().getRequestStatus().equals(RequestStatus.REQUESTED)){
            if(friendRequest.get().getUser2().getId() == user.getId() ) { // only user 2 ( reveiver )
                friendRequest.get().setRequestStatus(RequestStatus.DECLINED);
                friendRepo.save(friendRequest.get());
            }
            else{
                throw new  RuntimeException("User with id" + user.getId() + " is not part of that request");
            }
        }
        else{
            throw new RuntimeException("Friend request not found or already declined");
        }
    }

    public List<FriendResponse> getSentFriendRequests(){
        User user = SecurityUtils.getCurrentUser();
        //only find by user1 ( the sender )
        List<Friend> friendRequests = friendRepo.findByUser1AndRequestStatus(user, RequestStatus.REQUESTED);
        return friendRequests.stream()
                .map(this::convertToResponse)
                .toList();
    }

    public List<FriendResponse> getReceiverFriendRequests(){
        User user = SecurityUtils.getCurrentUser();
        //only find by user2 ( the receiver )
        List<Friend> friendRequests = friendRepo.findByUser2AndRequestStatus(user, RequestStatus.REQUESTED);
        return friendRequests.stream()
                .map(this::convertToResponse)
                .toList();
    }

    public List<FriendResponse> getAllFriends(int id){
        User user =  userRepo.findById(id).orElseThrow(() -> new RuntimeException("User not found"));
        List<Friend> friendsAsUser1 = friendRepo.findByUser1AndRequestStatus(user, RequestStatus.APPROVED);
        List<Friend> friendsAsUser2 = friendRepo.findByUser2AndRequestStatus(user, RequestStatus.APPROVED);
        List<Friend> allFriends = new ArrayList<>(friendsAsUser1);
        allFriends.addAll(friendsAsUser2);
        allFriends.removeIf(friend -> friend.isBlocked());
        return allFriends.stream()
                .map(this::convertToResponse)
                .toList();
    }

    public List<FriendResponse> getBlockedUsers(){
        User user =  SecurityUtils.getCurrentUser();
        List<Friend> blockedAsUser1 = friendRepo.findByUser1AndIsBlockedTrue(user);
        List<Friend> blockedAsUser2 = friendRepo.findByUser2AndIsBlockedTrue(user);

        List<Friend> allBlockedUsers = new ArrayList<>(blockedAsUser1);
        allBlockedUsers.addAll(blockedAsUser2);

        return allBlockedUsers.stream()
                .map(this::convertToResponse)
                .toList();
    }

    public FriendResponse blockUser(int id){
        User user = SecurityUtils.getCurrentUser();
        Optional<Friend> friend = friendRepo.findById(id);
        if(friend.isPresent()){
            if(friend.get().getUser1().getId() == user.getId() || friend.get().getUser2().getId() == user.getId() ) {
                friend.get().setBlocked(true);
                Friend blockedFriend = friendRepo.save(friend.get());
                return convertToResponse(blockedFriend);
            }
            else{
                throw new  RuntimeException("User with id" + user.getId() + " is not part of that request");
            }
        }
        else{
            throw new RuntimeException("Friend request not found or already declined");
        }
    }

    public List<User> findUsersByName(String name){
        User user = SecurityUtils.getCurrentUser();
        List<Friend> friendsAsUser1 = friendRepo.findByUser1AndRequestStatus(user, RequestStatus.APPROVED);
        List<Friend> friendsAsUser2 = friendRepo.findByUser2AndRequestStatus(user, RequestStatus.APPROVED);
        List<Friend> allFriends = new ArrayList<>(friendsAsUser1);
        allFriends.addAll(friendsAsUser2);
        allFriends.removeIf(friend -> {
            if(friend.isBlocked()){
                return true;
            }

            User theFriend = friend.getUser1().getId() == user.getId()
                    ? friend.getUser2()
                    : friend.getUser1();

            return theFriend.getName() == null || !theFriend.getName().toLowerCase().contains(name.toLowerCase());
        });

        List<User> users = extractUsers(allFriends);
        users.removeIf(user1 -> user1.getId() == user.getId());
        return users;
    }

    private List<User> extractUsers(List<Friend> friends){
        List<User> users = new ArrayList<>();
        for(Friend friend : friends){
            users.add(friend.getUser1());
            users.add(friend.getUser2());
        }
        return users.stream()
                .distinct()
                .collect(Collectors.toList());
    }

    private FriendResponse convertToResponse(Friend friend) {
        FriendResponse response = new FriendResponse();
        response.setId(friend.getId());
        response.setSenderId(friend.getUser1().getId());
        response.setReceiverId(friend.getUser2().getId());
        response.setBlocked(friend.isBlocked());
        response.setRequestStatus(friend.getRequestStatus());
        return response;
    }


    public void cancelFriendRequest(int id) {
        User user = SecurityUtils.getCurrentUser();
        Optional<Friend> friendRequest = friendRepo.findById(id);
        if(friendRequest.isPresent() && friendRequest.get().getRequestStatus().equals(RequestStatus.REQUESTED)){
            if(friendRequest.get().getUser1().getId() == user.getId() ) { // only user 1 ( sender )
                friendRequest.get().setRequestStatus(RequestStatus.CANCELLED);
                friendRepo.save(friendRequest.get());
            }
            else{
                throw new  RuntimeException("User with id" + user.getId() + " is not part of that request");
            }
        }
        else{
            throw new RuntimeException("Friend request not found or already declined");
        }
    }

    public FriendResponse unblockUser(int id) {
        User user = SecurityUtils.getCurrentUser();
        Optional<Friend> friend = friendRepo.findById(id);
        if(friend.isPresent()){
            if(friend.get().getUser1().getId() == user.getId() || friend.get().getUser2().getId() == user.getId() ) {
                friend.get().setBlocked(false);
                Friend unblockedFriend = friendRepo.save(friend.get());
                return convertToResponse(unblockedFriend);
            }
            else{
                throw new  RuntimeException("User with id" + user.getId() + " is not part of that request");
            }
        }
        else{
            throw new RuntimeException("Friend request not found or already declined");
        }
    }

    public void removeFriend(int id) {
        User user = SecurityUtils.getCurrentUser();
        Optional<Friend> friendRequest = friendRepo.findById(id);
        if(friendRequest.isPresent() && friendRequest.get().getRequestStatus().equals(RequestStatus.APPROVED)){
            if(friendRequest.get().getUser1().getId() == user.getId() ) { // only user 1 ( sender )
                friendRequest.get().setRequestStatus(RequestStatus.REMOVED);
                friendRepo.save(friendRequest.get());
            }
            else{
                throw new  RuntimeException("User with id" + user.getId() + " is not part of that request");
            }
        }
        else{
            throw new RuntimeException("Friend request not found or already declined");
        }
    }
}
