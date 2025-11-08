package org.example.socialmediaapp.services;

import org.example.socialmediaapp.dto.PostReactionResponse;
import org.example.socialmediaapp.entities.Post;
import org.example.socialmediaapp.entities.PostReaction;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.repositories.PostReactionRepo;
import org.example.socialmediaapp.repositories.PostRepo;
import org.example.socialmediaapp.utils.enums.ReactionType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class PostReactionService {

    @Autowired
    private PostReactionRepo postReactionRepo;

    @Autowired
    private PostRepo postRepo;

    public PostReactionResponse reactToPost(int postId, User user, ReactionType reactionType) {
        Post post = postRepo.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        Optional<PostReaction> existingReactionOpt = postReactionRepo.findByPostAndUser(post, user);

        if (existingReactionOpt.isPresent()) {
            PostReaction existingReaction = existingReactionOpt.get();

            if (existingReaction.getType() == reactionType) {
                postReactionRepo.delete(existingReaction);
            } else {
                existingReaction.setType(reactionType);
                postReactionRepo.save(existingReaction);
            }
        } else {
            PostReaction newReaction = new PostReaction();
            newReaction.setPost(post);
            newReaction.setUser(user);
            newReaction.setType(reactionType);
            postReactionRepo.save(newReaction);
        }
        int totalReactions = postReactionRepo.countByPost(post);
        postRepo.save(post);

        return new PostReactionResponse(post.getId(), reactionType, totalReactions);
    }
}

