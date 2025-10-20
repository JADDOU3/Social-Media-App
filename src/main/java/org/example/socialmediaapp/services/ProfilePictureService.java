package org.example.socialmediaapp.services;

import org.example.socialmediaapp.entities.ProfilePicture;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.repositories.ProfilePictureRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.example.socialmediaapp.repositories.UserRepo;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Optional;

@Service
public class ProfilePictureService {
    @Autowired
    private ProfilePictureRepo profilePictureRepo;
    @Autowired
    private UserRepo userRepo;

    public ProfilePicture SaveProfilePicture(String email, MultipartFile profilePicture) throws IOException {
        User user=userRepo.findByEmail(email).orElseThrow(()->new RuntimeException("User not found"));

        byte[] imageBytes = profilePicture.getBytes();

        Optional<ProfilePicture> exist=profilePictureRepo.findByEmail(email);
        exist.ifPresent(profilePictureRepo::delete);

        ProfilePicture picture = ProfilePicture.builder()
                .pictureName(profilePicture.getOriginalFilename())
                .pictureType(profilePicture.getContentType())
                .imageData(imageBytes)
                .user(user)
                .build();


        return profilePictureRepo.save(picture);
    }

    public Optional<ProfilePicture> GetProfilePicture(String email) throws IOException {
        Optional<ProfilePicture> profilePicture=profilePictureRepo.findByEmail(email);
        return profilePicture;
    }

    public void deleteProfilePicture(String email) throws IOException {
        profilePictureRepo.findByEmail(email).ifPresent(profilePictureRepo::delete);
    }
}
