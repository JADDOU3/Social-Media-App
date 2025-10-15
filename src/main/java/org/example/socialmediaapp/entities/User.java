package org.example.socialmediaapp.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Entity
@Table(name = "users")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class User {
    @Id
    @GeneratedValue
    private int id;

    private String email;
    private String password;
    private String name;
    private String job;
    private String location;
    private String gender;
    private String phoneNumber;
    private String socialSituation;

    private String bio;
    private String profilePicture;

    private Date createdDate;

}
