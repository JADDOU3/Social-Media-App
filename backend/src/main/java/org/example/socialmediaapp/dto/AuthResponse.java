package org.example.socialmediaapp.dto;

public class AuthResponse {
    //Todo implement refresh_token
    private String access_token;

    public AuthResponse(String access_token) {
        this.access_token = access_token;
    }
    public String getAccess_token() {
        return access_token;
    }
}
