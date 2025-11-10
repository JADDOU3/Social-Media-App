package org.example.socialmediaapp.controllers;

import org.example.socialmediaapp.entities.ProfilePicture;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.services.ProfilePictureService;
import org.example.socialmediaapp.services.UserService;
import org.example.socialmediaapp.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/api/profilepicture")
public class ProfilePictureController {
    @Autowired
    private ProfilePictureService profilePictureService;

    @Autowired
    private UserService userService;

    @PostMapping("/")
    public ResponseEntity<ProfilePicture> uploadProfilePicture(@RequestParam("file") MultipartFile file) throws IOException {
        User user = SecurityUtils.getCurrentUser();
        ProfilePicture picture = profilePictureService.saveProfilePicture(user,file);
        return ResponseEntity.ok().body(picture);
    }

    @GetMapping("/")
    public ResponseEntity<byte[]> getProfilePicture() throws IOException {
        User user = SecurityUtils.getCurrentUser();
        return profilePictureService.getProfilePicture(user.getEmail())
                .map(picture -> ResponseEntity.ok()
                        .contentType(MediaType.valueOf(picture.getPictureType()))
                        .body(picture.getImageData()))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/")
    public ResponseEntity<ProfilePicture> updateProfilePicture(
            @RequestParam("file") MultipartFile file
    ) throws IOException {
        User user = SecurityUtils.getCurrentUser();
        ProfilePicture updated = profilePictureService.updateProfilePicture(user.getEmail(), file);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/")
    public ResponseEntity<String> deleteProfilePicture() throws IOException {
        User user = SecurityUtils.getCurrentUser();
        profilePictureService.deleteProfilePicture(user.getEmail());
        return ResponseEntity.ok("Profile picture deleted successfully");
    }
    @GetMapping("/{userId}")
    public ResponseEntity<byte[]> getUserProfilePicture(@PathVariable int userId) {
        User user = userService.findById(userId);
        if (user == null) return ResponseEntity.notFound().build();
        try {
            return profilePictureService.getProfilePicture(user.getEmail())
                    .map(picture -> ResponseEntity.ok()
                            .contentType(MediaType.valueOf(picture.getPictureType()))
                            .body(picture.getImageData()))
                    .orElse(ResponseEntity.notFound().build());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
