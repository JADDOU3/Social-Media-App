package org.example.socialmediaapp.controllers;


import lombok.RequiredArgsConstructor;
import org.example.socialmediaapp.dto.FriendRequest;
import org.example.socialmediaapp.dto.FriendResponse;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.services.FriendService;
import org.example.socialmediaapp.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/friends")
@RequiredArgsConstructor
public class FriendController {
    @Autowired
    private final FriendService friendService;

      @PostMapping("/send")
      public ResponseEntity<FriendResponse> sendFriend(@RequestBody FriendRequest friendRequest) {
          User sender = SecurityUtils.getCurrentUser();
          FriendResponse response = friendService.sendFriendRequest(sender , friendRequest.getReceiverId());
          return ResponseEntity.ok(response);
      }

      @PostMapping("/{id}/approve")
      public ResponseEntity<String> approveFriend(@PathVariable int id){
          friendService.approveFriendRequest(id);
          return ResponseEntity.ok("Friend request approved.");
      }

      @PostMapping("/{id}/decline")
      public ResponseEntity<String> declineFriend(@PathVariable int id) {
          friendService.declineFriendRequest(id);
          return ResponseEntity.ok("Friend request declined.");
      }

      @GetMapping("/{name}")
      public ResponseEntity<List<User>> findUsersByName(@PathVariable String name){
          List<User> users = friendService.findUsersByName(name);
          return ResponseEntity.ok(users);
      }

      @GetMapping("/received-requests")
      public ResponseEntity<List<FriendResponse>> getReceivedFriendRequests(){
          User user = SecurityUtils.getCurrentUser();
          List<FriendResponse> friendRequests = friendService.getReceiverFriendRequests();
          return ResponseEntity.ok(friendRequests);
      }

    @GetMapping("/sent-requests")
    public ResponseEntity<List<FriendResponse>> getSentFriendRequests(){
        User user = SecurityUtils.getCurrentUser();
        List<FriendResponse> friendRequests = friendService.getSentFriendRequests();
        return ResponseEntity.ok(friendRequests);
    }

     @GetMapping("/")
        public ResponseEntity<List<FriendResponse>> getAllFriends(){
            User user = SecurityUtils.getCurrentUser();
            List<FriendResponse> friends = friendService.getAllFriends(user.getId());
            return ResponseEntity.ok(friends);
        }

     @GetMapping("/blocked")
    public ResponseEntity<List<FriendResponse>> getBlockedUsers(){
          List<FriendResponse> blockedUsers = friendService.getBlockedUsers();
          return ResponseEntity.ok(blockedUsers);
     }

     @PostMapping("/{id}/block")
    public ResponseEntity<FriendResponse> blockUser(@PathVariable int id){
          FriendResponse blocked = friendService.blockUser(id);
          return ResponseEntity.ok(blocked);
     }
}
