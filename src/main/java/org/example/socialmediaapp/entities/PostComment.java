package org.example.socialmediaapp.entities;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "PostComment")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class PostComment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false)
    private String comment;
    @Column(nullable = false)
    private LocalDateTime createdDate;
    @ManyToOne
    @JoinColumn(name=("post_id"), nullable=false)
    private Post post;

    @ManyToOne
    @JoinColumn(name=("user_email"), nullable=false)
    private User author;

}
