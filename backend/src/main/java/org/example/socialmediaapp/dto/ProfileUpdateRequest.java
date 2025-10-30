package org.example.socialmediaapp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProfileUpdateRequest {
    private String name;
    private String job;
    private String location;
    private String gender;
    private String phoneNumber;
    private Date dateOfBirth;
    private String socialSituation;
    private String bio;

}