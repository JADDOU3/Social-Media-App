package org.example.socialmediaapp.controllers;

import org.example.socialmediaapp.dto.CommentRequest;
import org.example.socialmediaapp.dto.CommentResponse;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.services.PostCommentService;
import org.example.socialmediaapp.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/comments")
public class PostCommentController {

    @Autowired
    private PostCommentService postCommentService;

    @PostMapping("/add")
    public ResponseEntity<CommentResponse> add(@RequestBody CommentRequest request) {
        User author = SecurityUtils.getCurrentUser(); // authenticated user
        String email = author.getEmail();
        CommentResponse response =
                postCommentService.addComment(email, request.getPostId(), request.getComment());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/post/{postId}")
    public ResponseEntity<List<CommentResponse>> list(@PathVariable Integer postId) {
        return ResponseEntity.ok(postCommentService.getComments(postId));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable int id) {
        User author = SecurityUtils.getCurrentUser();
        String email = author.getEmail();
        postCommentService.deleteComment(email, id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<CommentResponse> updateComment(
            @PathVariable int id,
            @RequestBody CommentRequest request
    ) {
        User currentUser = SecurityUtils.getCurrentUser();
        String email = currentUser.getEmail();
        CommentResponse updated = postCommentService.updateComment(email, id, request);
        return ResponseEntity.ok(updated);
    }


}
