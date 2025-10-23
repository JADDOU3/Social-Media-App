package org.example.socialmediaapp.repositories;

import org.example.socialmediaapp.entities.Post;
import org.example.socialmediaapp.entities.PostLike;
import org.example.socialmediaapp.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PostLikeRepo extends JpaRepository<PostLike, Integer> {
    Optional<PostLike> findByPostAndUser(Post post, User user);
    int countByPost(Post post);
}
