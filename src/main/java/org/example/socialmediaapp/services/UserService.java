package org.example.socialmediaapp.services;

import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.example.socialmediaapp.dto.RegisterRequest;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.repositories.UserRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.regex.Pattern;

@Service
@Transactional(rollbackOn =  Exception.class)
@RequiredArgsConstructor
public class UserService implements UserDetailsService {
    private final UserRepo userRepo;
    private final PasswordEncoder passwordEncoder;


    private static final String PASSWORD_REGEX = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*])(.{8,})$";
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(PASSWORD_REGEX);


    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        return userRepo.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));
    }

    public User Register(RegisterRequest registerRequest) {
        if(userRepo.existsByEmail(registerRequest.getEmail())){
            throw new IllegalArgumentException("Email already exists");
        }

        if (!isPasswordStrong(registerRequest.getPassword())) {
            throw new IllegalArgumentException(
                    "Password must be at least 8 characters long and contain: " +
                            "at least one uppercase letter, one lowercase letter, one digit, and one special character (!@#$%^&*)"
            );
        }

        String hashedPassword = passwordEncoder.encode(registerRequest.getPassword());

        User user = new User(
                registerRequest.getEmail(),
                hashedPassword,
                registerRequest.getName(),
                registerRequest.getJob(),
                registerRequest.getLocation(),
                registerRequest.getGender(),
                registerRequest.getPhoneNumber(),
                registerRequest.getDateOfBirth(),
                registerRequest.getSocialSituation()
        );
        return userRepo.save(user);
    }


    public boolean existsByEmail(String email) {
        return userRepo.existsByEmail(email);
    }

    private boolean isPasswordStrong(String password) {
        if (password == null || password.isEmpty()) {
            return false;
        }
        return PASSWORD_PATTERN.matcher(password).matches();
    }

}
