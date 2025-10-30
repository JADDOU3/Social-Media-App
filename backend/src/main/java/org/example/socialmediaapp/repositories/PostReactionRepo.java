package org.example.socialmediaapp.repositories;

import org.example.socialmediaapp.entities.*;
import org.example.socialmediaapp.utils.ReactionType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PostReactionRepo extends JpaRepository<PostReaction, Integer> {

    Optional<PostReaction> findByPostAndUser(Post post, User user);

    List<PostReaction> findByPost(Post post);

    int countByPostAndType(Post post, ReactionType type);

    int countByPost(Post post);
}

