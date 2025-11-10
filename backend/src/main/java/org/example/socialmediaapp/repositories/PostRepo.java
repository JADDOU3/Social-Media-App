package org.example.socialmediaapp.repositories;

import org.example.socialmediaapp.entities.Post;
import org.example.socialmediaapp.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;

public interface PostRepo extends JpaRepository<Post, Integer> {
    List<Post> findAllByAuthor_emailAndDeletedFalse(String email);

    List<Post> findAllByDeletedFalse();

    List<Post> findAllByAuthorInAndDeletedFalse(List<User> authors);

    List<Post> findByAuthor_IdAndDeletedFalse(int userId);
}
