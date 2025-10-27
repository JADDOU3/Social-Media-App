package org.example.socialmediaapp.controllers;

import org.example.socialmediaapp.dto.PostReactionRequest;
import org.example.socialmediaapp.dto.PostReactionResponse;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.services.PostReactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/posts/reactions")
public class PostReactionController {

    @Autowired
    private PostReactionService postReactionService;

    @PostMapping
    public ResponseEntity<PostReactionResponse> reactToPost(
            @RequestBody PostReactionRequest request,
            @AuthenticationPrincipal User user) {

        PostReactionResponse response = postReactionService.reactToPost(
                request.getPostId(),
                user,
                request.getReactionType()
        );
        return ResponseEntity.ok(response);
    }
}
