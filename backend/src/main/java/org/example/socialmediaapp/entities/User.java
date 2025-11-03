package org.example.socialmediaapp.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.antlr.v4.runtime.misc.NotNull;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "users")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class User implements UserDetails {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;


    @Column(unique = true)
    private String email;
    private String password;
    private String name;
    private String job;
    private String location;
    private String gender;
    private String phoneNumber;
    private Date dateOfBirth;
    private String socialSituation;

    private String bio;
    private String profilePicture;

    private Date createdDate;

    public User(
            String email,
            String password,
            String name,
            String job,
            String location,
            String gender,
            String phoneNumber,
            Date dateOfBirth,
            String socialSituation
    ) {
        this.email = email;
        this.password = password;
        this.name = name;
        this.job = job;
        this.location = location;
        this.gender = gender;
        this.phoneNumber = phoneNumber;
        this.dateOfBirth = dateOfBirth;
        this.socialSituation = socialSituation;
        this.createdDate = new Date();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of();
    }

    @Override
    public String getUsername() {
        return this.email;
    }

    @OneToMany(mappedBy = "author", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Post> posts;

}

