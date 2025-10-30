package org.example.socialmediaapp.controllers;

import org.example.socialmediaapp.entities.ProfilePicture;
import org.example.socialmediaapp.services.ProfilePictureService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/api/profilepicture/")
public class ProfilePictureController {
    @Autowired
    private ProfilePictureService profilePictureService;

    @PostMapping("/{email}")
    public ResponseEntity<ProfilePicture> uploadProfilePicture(@PathVariable String email,@RequestParam("file") MultipartFile file) throws IOException {
    ProfilePicture picture = profilePictureService.saveProfilePicture(email,file);
    return ResponseEntity.ok().body(picture);
    }

    @GetMapping("/{email}")
    public ResponseEntity<byte[]> getProfilePicture(@PathVariable String email) throws IOException {
        return profilePictureService.getProfilePicture(email)
                .map(picture -> ResponseEntity.ok()
                        .contentType(MediaType.valueOf(picture.getPictureType()))
                        .body(picture.getImageData()))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{email}")
    public ResponseEntity<ProfilePicture> updateProfilePicture(
            @PathVariable String email,
            @RequestParam("file") MultipartFile file
    ) throws IOException {
        ProfilePicture updated = profilePictureService.updateProfilePicture(email, file);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{email}")
    public ResponseEntity<String> deleteProfilePicture(@PathVariable String email) throws IOException {
        profilePictureService.deleteProfilePicture(email);
        return ResponseEntity.ok("Profile picture deleted successfully");
    }
}
