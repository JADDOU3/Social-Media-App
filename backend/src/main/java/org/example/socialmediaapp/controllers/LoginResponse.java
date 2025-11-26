package org.example.socialmediaapp.controllers;

import org.example.socialmediaapp.entities.User;

public class LoginResponse {
    private String jwt;
    private User user;

    public LoginResponse(String jwt, User user) {
        this.jwt = jwt;
        this.user = user;
    }

    // Constructors, getters, and setters

}
