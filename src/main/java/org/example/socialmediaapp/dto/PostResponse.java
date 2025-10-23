package org.example.socialmediaapp.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;


@Data
public class PostResponse {
    private int id;
    private String text;
    private String authorEmail;
    private String authorName;
    private LocalDateTime createdDate;
    private int imageCount;
    private int commentCount;
    private int likeCount;
    private List<String> imageNames;

}
