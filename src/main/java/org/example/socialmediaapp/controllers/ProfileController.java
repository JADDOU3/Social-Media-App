package org.example.socialmediaapp.controllers;

import lombok.RequiredArgsConstructor;
import org.example.socialmediaapp.dto.ProfileResponse;
import org.example.socialmediaapp.dto.ProfileUpdateRequest;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.services.JwtService;
import org.example.socialmediaapp.services.ProfileService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;
    private final JwtService jwtService;

    @GetMapping
    public ResponseEntity<?> getProfile(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        String email = jwtService.extractUsername(token);

        User user = profileService.getProfileByEmail(email);
        if (user == null) return ResponseEntity.status(404).body("User not found");

        ProfileResponse response = new ProfileResponse(
                user.getName(),
                user.getEmail(),
                user.getBio()
        );
        return ResponseEntity.ok(response);
    }

    @PutMapping
    public ResponseEntity<?> updateProfile(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody ProfileUpdateRequest request) {

        String token = authHeader.substring(7);
        String email = jwtService.extractUsername(token);

        User updatedUser = profileService.updateProfile(email, request);
        if (updatedUser == null) return ResponseEntity.status(404).body("User not found");

        ProfileResponse response = new ProfileResponse(
                updatedUser.getName(),
                updatedUser.getEmail(),
                updatedUser.getBio()
        );

        return ResponseEntity.ok(response);
    }
}
