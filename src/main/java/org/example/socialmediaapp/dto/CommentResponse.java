package org.example.socialmediaapp.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CommentResponse {
    private int id;
    private int postId;
    private String comment;
    private String authorEmail;
    private String authorName;
    private LocalDateTime commentDate;
}
