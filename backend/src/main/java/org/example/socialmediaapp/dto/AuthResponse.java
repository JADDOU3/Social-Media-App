package org.example.socialmediaapp.dto;

public class AuthResponse {
    private String access_token;
    private int userId;

    public AuthResponse(String access_token, int userId) {
        this.access_token = access_token;
        this.userId = userId;
    }

    public String getAccess_token() {
        return access_token;
    }

    public int getUserId() {
        return userId;
    }
}