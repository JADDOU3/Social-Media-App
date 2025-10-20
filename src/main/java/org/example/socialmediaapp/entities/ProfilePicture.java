package org.example.socialmediaapp.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "ProfilePicture")
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ProfilePicture {

    @Id
    @GeneratedValue
    private int id;

    private String pictureName;
    private String pictureType;

    @Lob
    @Basic(fetch = FetchType.LAZY)
    private byte[] imageData;

    @OneToOne
    @JoinColumn(name=("user_email"))
    private User user;
}
