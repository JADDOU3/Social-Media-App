package org.example.socialmediaapp.services;

import org.springframework.transaction.annotation.Transactional;
import org.example.socialmediaapp.dto.CommentRequest;
import org.example.socialmediaapp.dto.CommentResponse;
import org.example.socialmediaapp.entities.Post;
import org.example.socialmediaapp.entities.PostComment;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.repositories.PostCommentRepo;
import org.example.socialmediaapp.repositories.PostRepo;
import org.example.socialmediaapp.repositories.UserRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;


@Service
public class PostCommentService {
    @Autowired
    private PostRepo postRepo;
    @Autowired
    private UserRepo userRepo;
    @Autowired
    private PostCommentRepo postCommentRepo;

    @Transactional
    public CommentResponse addComment(String email, int postId, String commentText) {
        User user = userRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Post post = postRepo.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        PostComment postComment = new PostComment();
        postComment.setPost(post);
        postComment.setComment(commentText);
        postComment.setAuthor(user);
        postComment.setCreatedDate(LocalDateTime.now());

        PostComment saved = postCommentRepo.save(postComment);
        postRepo.save(post);

        return toResponse(saved);
    }


    public CommentResponse toResponse(PostComment postComment) {
        CommentResponse commentResponse = new CommentResponse();
        commentResponse.setPostId(postComment.getPost().getId());
        commentResponse.setCommentDate(postComment.getCreatedDate());
        commentResponse.setComment(postComment.getComment());
        commentResponse.setAuthorEmail(postComment.getAuthor().getEmail());
        commentResponse.setAuthorName(postComment.getAuthor().getName());
        return commentResponse;
    }

    public List<CommentResponse> getComments(int postId) {
        List<PostComment> postComments= postCommentRepo.findByPost_Id(postId);
        return postComments.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public void  deleteComment(String userEmail,int commentId) {
        PostComment commentToDelete=postCommentRepo.findById(commentId).orElseThrow(()->new RuntimeException("Comment not found"));
        if(!commentToDelete.getAuthor().getEmail().equals(userEmail)){
            throw new RuntimeException("Not Authorized to delete this comment");
        }
        Post post=commentToDelete.getPost();
        postCommentRepo.delete(commentToDelete);
        postRepo.save(post);
    }

    @Transactional
    public CommentResponse updateComment(String email, int commentId, CommentRequest request) {
        User user = userRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        PostComment comment = postCommentRepo.findById(commentId)
                .orElseThrow(() -> new RuntimeException("Comment not found"));

        if (!(comment.getAuthor().getId()==user.getId())) {
            throw new RuntimeException("You can only edit your own comments.");
        }

        if (request.getComment() == null || request.getComment().trim().isEmpty()) {
            throw new RuntimeException("Comment text cannot be empty.");
        }

        comment.setComment(request.getComment());
        comment.setCreatedDate(LocalDateTime.now());

        PostComment updated = postCommentRepo.save(comment);
        return toResponse(updated);
    }


}

