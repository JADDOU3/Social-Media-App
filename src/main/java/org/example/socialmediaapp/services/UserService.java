package org.example.socialmediaapp.services;

import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.repositories.UserRepo;
import org.springframework.stereotype.Service;

import java.util.Optional;


@Service
@Transactional(rollbackOn =  Exception.class)
@RequiredArgsConstructor
public class UserService {
    private final UserRepo userRepo;

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
}

