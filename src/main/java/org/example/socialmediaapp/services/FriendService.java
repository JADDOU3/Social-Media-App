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
            if(friendRequest.get().getUser1().getId() == user.getId() || friendRequest.get().getUser2().getId() == user.getId() ) {
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
            if(friendRequest.get().getUser1().getId() == user.getId() || friendRequest.get().getUser2().getId() == user.getId() ) {
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

    public List<FriendResponse> getAllFriends(int id){
        User user =  userRepo.findById(id).orElseThrow(() -> new RuntimeException("User not found"));
        List<Friend> friendsAsUser1 = friendRepo.findByUser1AndRequestStatus(user, RequestStatus.APPROVED);
        List<Friend> friendsAsUser2 = friendRepo.findByUser2AndRequestStatus(user, RequestStatus.APPROVED);
        List<Friend> allFriends = new ArrayList<>(friendsAsUser1);
        allFriends.addAll(friendsAsUser2);
        return allFriends.stream()
                .map(this::convertToResponse)
                .toList();
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
}
