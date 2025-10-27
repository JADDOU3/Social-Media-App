package org.example.socialmediaapp.controllers;

import lombok.RequiredArgsConstructor;
import org.example.socialmediaapp.dto.PasswordChangeRequest;
import org.example.socialmediaapp.dto.ProfileResponse;
import org.example.socialmediaapp.dto.ProfileUpdateRequest;
import org.example.socialmediaapp.dto.RegisterRequest;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.services.JwtService;
import org.example.socialmediaapp.services.ProfileService;
import org.example.socialmediaapp.services.UserService;
import org.example.socialmediaapp.utils.SecurityUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;
    private final ProfileService profileService;

    @PostMapping("/register")
    public ResponseEntity<User> register(@RequestBody RegisterRequest registerRequest) {
        User user = userService.Register(registerRequest);
        return ResponseEntity.ok(user);
    }

    @GetMapping("/view")
    public ResponseEntity<?> viewProfile() {
        User user = SecurityUtils.getCurrentUser();
        if (user == null) return ResponseEntity.status(404).body("{\"error\":\"User not found\"}");

        ProfileResponse response = new ProfileResponse(
                user.getName(),
                user.getEmail(),
                user.getJob(),
                user.getLocation(),
                user.getGender(),
                user.getPhoneNumber(),
                user.getDateOfBirth(),
                user.getSocialSituation(),
                user.getBio()
        );
        return ResponseEntity.ok(response);
    }

    @PutMapping("/update")
    public ResponseEntity<?> updateProfile(@RequestBody ProfileUpdateRequest request) {
        User currentUser = SecurityUtils.getCurrentUser();
        if (currentUser == null) {
            return ResponseEntity.status(401)
                    .body("{\"error\":\"Unauthorized: Invalid or missing token\"}");
        }
        User updatedUser = profileService.updateProfile(currentUser.getEmail(), request);
        if (updatedUser == null) {
            return ResponseEntity.status(404).body("{\"error\":\"User not found\"}");
        }
        ProfileResponse response = new ProfileResponse(
                updatedUser.getName(),
                updatedUser.getEmail(),
                updatedUser.getJob(),
                updatedUser.getLocation(),
                updatedUser.getGender(),
                updatedUser.getPhoneNumber(),
                updatedUser.getDateOfBirth(),
                updatedUser.getSocialSituation(),
                updatedUser.getBio()
        );

        return ResponseEntity.ok(response);
    }

    @PutMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody PasswordChangeRequest request) {
        User currentUser = SecurityUtils.getCurrentUser();
        if (currentUser == null) {
            return ResponseEntity.status(401)
                    .body("{\"error\":\"Unauthorized: Invalid or missing token\"}");
        }

        try {
            profileService.changePassword(
                    currentUser.getEmail(),
                    request.getOldPassword(),
                    request.getNewPassword()
            );
            return ResponseEntity.ok("Password changed successfully");
        } catch (RuntimeException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        }
    }

    @GetMapping("/{name}")
    public ResponseEntity<List<User>> findUsersByName(@PathVariable String name) {
        List<User> users = userService.findUsersByName(name);
        return ResponseEntity.ok(users);
    }


}
