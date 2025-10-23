package org.example.socialmediaapp.controllers;

import org.example.socialmediaapp.dto.CommentRequest;
import org.example.socialmediaapp.dto.CommentResponse;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.services.PostCommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/comments/")
public class PostCommentController {
    @Autowired
    private PostCommentService postCommentService;

    @PostMapping("/add")
    public ResponseEntity<CommentResponse> add(
            User author,
            @RequestBody CommentRequest request
    ) {
        String email = author.getUsername();
        return ResponseEntity.ok(postCommentService.addComment(email, request.getPostId(), request.getComment()));
    }

    @GetMapping("/post/{postId}")
    public ResponseEntity<List<CommentResponse>> list(@PathVariable Integer postId) {
        return ResponseEntity.ok(postCommentService.getComments(postId));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            User author,
            @PathVariable int id
    ) {
        String email = author.getUsername();
        postCommentService.deleteComment(email, id);
        return ResponseEntity.noContent().build();
    }



}
