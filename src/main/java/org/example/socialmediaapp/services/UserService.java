package org.example.socialmediaapp.services;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.AllArgsConstructor;
import org.example.socialmediaapp.dto.RegisterRequest;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.repositories.UserRepo;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Optional;


@Service
@Transactional(rollbackOn =  Exception.class)
@RequiredArgsConstructor
public class UserService implements UserDetailsService {
    private final UserRepo userRepo;
    private final PasswordEncoder passwordEncoder;

    public Optional<User> findByEmail(String email) {
        return userRepo.findByEmail(email);//exclude password
    }

    public void deleteByEmail(String email) {
        if(userRepo.findByEmail(email).isEmpty()) {
            throw new IllegalStateException("User with email " + email + " not found");
        }
        userRepo.findByEmail(email);
    }

    public User updateUserInfo(String Email,User updatedData) {
        User userToBeUpdated=userRepo.findByEmail(Email).orElseThrow(()-> new IllegalStateException("User with email " + Email + " not found"));
        if(userToBeUpdated.getBio() != null && !userToBeUpdated.getBio().equals(updatedData.getBio())) {
            userToBeUpdated.setBio(updatedData.getBio());
        }
        if(userToBeUpdated.getJob() != null && !userToBeUpdated.getJob().equals(updatedData.getJob())) {
            userToBeUpdated.setJob(updatedData.getJob());
        }
        if(userToBeUpdated.getGender() != null && !userToBeUpdated.getGender().equals(updatedData.getGender())) {
            userToBeUpdated.setGender(updatedData.getGender());
        }
        if(userToBeUpdated.getLocation() != null && !userToBeUpdated.getLocation().equals(updatedData.getLocation())) {
            userToBeUpdated.setLocation(updatedData.getLocation());
        }
        if(userToBeUpdated.getName() != null && !userToBeUpdated.getName().equals(updatedData.getName())) {
            userToBeUpdated.setName(updatedData.getName());
        }
        if(userToBeUpdated.getPhoneNumber() != null && !userToBeUpdated.getPhoneNumber().equals(updatedData.getPhoneNumber())) {
            userToBeUpdated.setPhoneNumber(updatedData.getPhoneNumber());
        }
        if(userToBeUpdated.getProfilePicture() != null && !userToBeUpdated.getProfilePicture().equals(updatedData.getProfilePicture())) {
            userToBeUpdated.setProfilePicture(updatedData.getProfilePicture());
        }
        if (userToBeUpdated.getSocialSituation() != null && !userToBeUpdated.getSocialSituation().equals(updatedData.getSocialSituation())) {
            userToBeUpdated.setSocialSituation(updatedData.getSocialSituation());
        }
        return userRepo.save(userToBeUpdated);
    }


    public User createUser(User user) {
        if (userRepo.findByEmail(user.getEmail()).isPresent()) {
            throw new IllegalStateException("User with email already exists");
        }
        return userRepo.save(user);
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        return userRepo.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));
    }

    public User Register(RegisterRequest registerRequest) {
        if(userRepo.existsByEmail(registerRequest.getEmail())){
            throw new IllegalArgumentException("Email already exists");
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
}

