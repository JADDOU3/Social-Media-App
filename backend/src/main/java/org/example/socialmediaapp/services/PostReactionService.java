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

import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class PostReactionService {

    @Autowired
    private PostReactionRepo postReactionRepo;

    @Autowired
    private PostRepo postRepo;

    @Autowired
    private FriendService friendService;

    public Map<ReactionType, Integer> getReactionsByPost(int postId, User user) {
        Post post = postRepo.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        if (!canInteractWithPost(user, post)) {
            throw new RuntimeException("You can only view reactions on your friends' posts or your own posts.");
        }

        List<PostReaction> reactions = postReactionRepo.findByPost(post);

        Map<ReactionType, Integer> counts = new EnumMap<>(ReactionType.class);
        for (ReactionType type : ReactionType.values()) {
            counts.put(type, 0);
        }

        for (PostReaction r : reactions) {
            counts.put(r.getType(), counts.get(r.getType()) + 1);
        }

        return counts;
    }

    public PostReactionResponse reactToPost(int postId, User user, ReactionType reactionType) {
        Post post = postRepo.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        if (!canInteractWithPost(user, post)) {
            throw new RuntimeException("You can only react to your friends' posts or your own posts.");
        }

        Optional<PostReaction> existingReactionOpt = postReactionRepo.findByPostAndUser(post, user);

        existingReactionOpt.ifPresentOrElse(
                existing -> {
                    if (existing.getType() == reactionType) {
                        postReactionRepo.delete(existing);
                    } else {
                        existing.setType(reactionType);
                        postReactionRepo.save(existing);
                    }
                },
                () -> {
                    PostReaction newReaction = new PostReaction();
                    newReaction.setPost(post);
                    newReaction.setUser(user);
                    newReaction.setType(reactionType);
                    postReactionRepo.save(newReaction);
                }
        );

        int totalReactions = postReactionRepo.countByPost(post);
        return new PostReactionResponse(post.getId(), reactionType, totalReactions);
    }

    private boolean canInteractWithPost(User user, Post post) {
        if (user.getId() == post.getAuthor().getId()) {
            return true;
        }
        return friendService.getAllFriends(user.getId()).stream()
                .anyMatch(f -> f.getSenderId() == post.getAuthor().getId() ||
                        f.getReceiverId() == post.getAuthor().getId());
    }
}
