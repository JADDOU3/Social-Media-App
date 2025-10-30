package org.example.socialmediaapp.dto;


import lombok.Data;

import java.util.Date;

@Data
public class RegisterRequest {
    private String email;
    private String password;
    private String name;
    private String job;
    private String location;
    private String gender;
    private String phoneNumber;
    private Date dateOfBirth;
    private String socialSituation;
}