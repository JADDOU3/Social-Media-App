package org.example.socialmediaapp.dto;

import lombok.Data;

@Data
public class CommentRequest {
    private int postId;
    private String comment;
}
