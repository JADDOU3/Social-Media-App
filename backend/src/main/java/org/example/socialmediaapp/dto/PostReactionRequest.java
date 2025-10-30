package org.example.socialmediaapp.dto;

import lombok.Data;
import org.example.socialmediaapp.utils.ReactionType;

@Data
public class PostReactionRequest {
    private int postId;
    private ReactionType reactionType;
}
