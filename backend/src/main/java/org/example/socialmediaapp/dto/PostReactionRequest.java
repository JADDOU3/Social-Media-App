package org.example.socialmediaapp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.socialmediaapp.utils.enums.ReactionType;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PostReactionRequest {
    private int postId;
    private ReactionType reactionType;
}
