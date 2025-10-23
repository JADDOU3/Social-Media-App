package org.example.socialmediaapp.controllers;

import org.example.socialmediaapp.dto.PostRequest;
import org.example.socialmediaapp.dto.PostResponse;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.services.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/posts/")
public class PostsController {
    @Autowired
    private PostService postService;
    @PostMapping(value = "/create")
    public ResponseEntity<PostResponse> createPost(
            User Author,
            @RequestPart(value = "text", required = false) String text,
            @RequestPart(value = "images", required = false) List<MultipartFile> images
    ) throws IOException {
        String email = Author.getUsername();
        PostRequest req = new PostRequest();
        req.setText(text);
        req.setImages(images);
        return ResponseEntity.ok(postService.createPost(email,req));
    }

    @GetMapping("/my")
    public ResponseEntity<List<PostResponse>> myPosts( User author) {
        String email = author.getUsername();
        return ResponseEntity.ok(postService.getMyPosts(email));
    }

    @PostMapping("/{postId}/like")
    public ResponseEntity<String> toggleLike(
            @PathVariable int postId,
            User author
    ) {
        String email = author.getEmail();
        return ResponseEntity.ok(postService.toggleLike(postId, email));
    }

    @GetMapping
    public ResponseEntity<List<PostResponse>> getAllPosts() {
        return ResponseEntity.ok(postService.getAllPosts());
    }
}
