package org.example.socialmediaapp.dto;

import lombok.Data;
import org.example.socialmediaapp.utils.enums.ReactionType;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
public class PostResponse {
    private int id;
    private String text;
    private String authorEmail;
    private String authorName;
    private LocalDateTime createdDate;
    private int imageCount;
    private List<String> imageUrls;
    private ReactionType currentUserReaction;
    private Map<ReactionType, Integer> reactionCounts;
    private int commentCount;
}