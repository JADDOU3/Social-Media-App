package org.example.socialmediaapp.services;

import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.example.socialmediaapp.repositories.UserRepo;
import org.springframework.stereotype.Service;

@Service
@Transactional(rollbackOn =  Exception.class)
@RequiredArgsConstructor
public class UserService {
    private final UserRepo userRepo;

}
