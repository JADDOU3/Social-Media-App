package org.example.socialmediaapp.repositories;

import org.example.socialmediaapp.entities.ProfilePicture;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ProfilePictureRepo extends JpaRepository<ProfilePicture,Long> {

    Optional<ProfilePicture> findByEmail(String email);

}
