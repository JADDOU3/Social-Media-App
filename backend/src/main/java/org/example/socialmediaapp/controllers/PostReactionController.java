package org.example.socialmediaapp.controllers;

import org.example.socialmediaapp.dto.PostReactionRequest;
import org.example.socialmediaapp.dto.PostReactionResponse;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.services.PostReactionService;
import org.example.socialmediaapp.utils.SecurityUtils;
import org.example.socialmediaapp.utils.enums.ReactionType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/reactions")
public class PostReactionController {

    @Autowired
    private PostReactionService postReactionService;

    @PostMapping()
    public ResponseEntity<PostReactionResponse> reactToPost(@RequestBody PostReactionRequest request) {
        User user = SecurityUtils.getCurrentUser();
        PostReactionResponse response = postReactionService.reactToPost(
                request.getPostId(),
                user,
                request.getReactionType()
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/post/{postId}")
    public ResponseEntity<Map<ReactionType, Integer>> getReactionsByPost(@PathVariable int postId) {
        User user = SecurityUtils.getCurrentUser();
        System.out.println("Incoming reaction request: postId=" + user.getEmail()) ;
        Map<ReactionType, Integer> counts = postReactionService.getReactionsByPost(postId, user);
        return ResponseEntity.ok(counts);
    }
}
