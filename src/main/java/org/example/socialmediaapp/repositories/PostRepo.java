package org.example.socialmediaapp.repositories;

import org.example.socialmediaapp.entities.Post;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface PostRepo extends JpaRepository<Post, Integer> {
    List<Post> findAllByAuthor_emailAndDeletedFalse(String email);

    List<Post> findAllByDeletedFalse();
}
