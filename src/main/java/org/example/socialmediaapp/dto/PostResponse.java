package org.example.socialmediaapp.dto;

import lombok.Data;
import org.example.socialmediaapp.utils.PostType;

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
    private List<String> imageNames;
    private PostType postType;
}
