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
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;
    private final ProfileService profileService;
    private final JwtService jwtService;

    // ===================== REGISTER =====================
    @PostMapping("/register")
    public ResponseEntity<User> register(@RequestBody RegisterRequest registerRequest) {
        User user = userService.Register(registerRequest);
        return ResponseEntity.ok(user);
    }

    // ===================== VIEW PROFILE =====================
    @GetMapping("/view")
    public ResponseEntity<?> viewProfile(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        String email = jwtService.extractUsername(token);

        User user = profileService.getProfileByEmail(email);
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

    // ===================== UPDATE PROFILE =====================
    @PutMapping("/update")
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

    // ===================== CHANGE PASSWORD =====================
    @PutMapping("/change-password")
    public ResponseEntity<?> changePassword(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody PasswordChangeRequest request) {

        String token = authHeader.substring(7);
        String email = jwtService.extractUsername(token);

        try {
            profileService.changePassword(email, request.getOldPassword(), request.getNewPassword());
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
