package org.example.socialmediaapp.controllers;

import org.example.socialmediaapp.dto.PostRequest;
import org.example.socialmediaapp.dto.PostResponse;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.services.PostService;
import org.example.socialmediaapp.services.PostReactionService;
import org.example.socialmediaapp.services.UserService;
import org.example.socialmediaapp.utils.ReactionType;
import org.example.socialmediaapp.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.security.core.userdetails.UserDetails;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/posts")
public class PostsController {

    @Autowired
    private PostService postService;

    @Autowired
    private UserService userService;

    @Autowired
    private PostReactionService postReactionService;




    @GetMapping
    public ResponseEntity<List<PostResponse>> getAllPosts() {
        return ResponseEntity.ok(postService.getAllPosts());
    }

    @PostMapping("/")
    public ResponseEntity<PostResponse> createPost(
            @RequestBody(required = false) String text,
            @RequestBody(required = false) List<MultipartFile> images
    ) throws IOException {
        User user = SecurityUtils.getCurrentUser();
        PostRequest request = new PostRequest();
        request.setText(text);
        request.setImages(images);
        return ResponseEntity.ok(postService.createPost(user, request));
    }

    @GetMapping("/my")
    public ResponseEntity<List<PostResponse>> getMyPosts() {
        User user = SecurityUtils.getCurrentUser();
        return ResponseEntity.ok(postService.getMyPosts(user.getEmail()));
    }

    @PutMapping("/{postId}/update")
    public ResponseEntity<PostResponse> updatePost(
            @PathVariable int postId,
            @RequestPart(value = "text", required = false) String text,
            @RequestPart(value = "images", required = false) List<MultipartFile> newImages
    ) throws IOException {
        User user = SecurityUtils.getCurrentUser();

        PostRequest request = new PostRequest();
        request.setText(text);
        request.setImages(newImages);

        return ResponseEntity.ok(postService.updatePost(postId, user.getEmail(), request));
    }

    @DeleteMapping("/{postId}")
    public ResponseEntity<String> deletePost(@PathVariable int postId) {
        User user = SecurityUtils.getCurrentUser();
        postService.deletePost(postId, user.getEmail());
        return ResponseEntity.ok("Post deleted successfully.");
    }

    @PostMapping("/{postId}/react")
    public ResponseEntity<String> reactToPost(
            @PathVariable int postId,
            @RequestParam ReactionType reactionType
    ) {
        User user = SecurityUtils.getCurrentUser();
        postReactionService.reactToPost(postId, user, reactionType);
        return ResponseEntity.ok("Reaction updated.");
    }
}
