package org.example.socialmediaapp.services;

import lombok.RequiredArgsConstructor;
import org.example.socialmediaapp.dto.ProfileUpdateRequest;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.repositories.UserRepo;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class ProfileService {

    private final UserRepo userRepository;

    public User getProfileByEmail(String email) {
        return userRepository.findByEmail(email).orElse(null);
    }

    public User updateProfile(String email, ProfileUpdateRequest request) {
        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null) return null;

        if (request.getName() != null && !request.getName().isBlank()) user.setName(request.getName());
        if (request.getBio() != null && !request.getBio().isBlank()) user.setBio(request.getBio());


        return userRepository.save(user);
    }
}
