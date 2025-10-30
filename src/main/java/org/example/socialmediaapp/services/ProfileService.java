package org.example.socialmediaapp.services;

import lombok.RequiredArgsConstructor;
import org.example.socialmediaapp.dto.ProfileUpdateRequest;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.repositories.UserRepo;
import org.springframework.security.crypto.password.PasswordEncoder;
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
/// ////////

public User updateProfile(String email, ProfileUpdateRequest request) {
    User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));


    if (request.getName() != null && !request.getName().isBlank()) user.setName(request.getName());
    if (request.getJob() != null && !request.getJob().isBlank()) user.setJob(request.getJob());
    if (request.getLocation() != null && !request.getLocation().isBlank()) user.setLocation(request.getLocation());
    if (request.getGender() != null && !request.getGender().isBlank()) user.setGender(request.getGender());
    if (request.getPhoneNumber() != null && !request.getPhoneNumber().isBlank()) user.setPhoneNumber(request.getPhoneNumber());
    if (request.getDateOfBirth() != null) user.setDateOfBirth(request.getDateOfBirth());
    if (request.getSocialSituation() != null && !request.getSocialSituation().isBlank()) user.setSocialSituation(request.getSocialSituation());
    if (request.getBio() != null && !request.getBio().isBlank()) user.setBio(request.getBio());


    return userRepository.save(user);
}


    /// ////

    private final PasswordEncoder passwordEncoder;

    public User findByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
    }

    public User changePassword(String email, String oldPassword, String newPassword) {
        User user = findByEmail(email);

        // التحقق من كلمة المرور القديمة باستخدام PasswordEncoder
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new RuntimeException("Old password is incorrect");
        }

        // تشفير كلمة المرور الجديدة قبل الحفظ
        user.setPassword(passwordEncoder.encode(newPassword));
        return userRepository.save(user);
    }
}
