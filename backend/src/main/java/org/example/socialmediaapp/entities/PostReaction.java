package org.example.socialmediaapp.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.socialmediaapp.utils.enums.ReactionType;

@Entity
@Data
@Table(name = "post_reactions", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"post_id", "user_id"})
})
@AllArgsConstructor
@NoArgsConstructor
public class PostReaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id", nullable = false)
    private Post post;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReactionType type;

}
