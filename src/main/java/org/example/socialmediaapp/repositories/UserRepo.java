package org.example.socialmediaapp.repositories;

import org.example.socialmediaapp.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepo extends JpaRepository<User, Integer> {
    Optional<User> findByEmail(String email);
    List<User> findByNameContainingIgnoreCase(String name);
    boolean existsByEmail(String email);

}
