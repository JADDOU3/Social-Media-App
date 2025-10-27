package org.example.socialmediaapp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import org.example.socialmediaapp.utils.ReactionType;

@Data
@AllArgsConstructor
public class PostReactionResponse {
    private int postId;
    private ReactionType reactionType;
    private int totalReactions;
}

