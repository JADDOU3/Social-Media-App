package org.example.socialmediaapp.entities;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.socialmediaapp.utils.enums.RequestStatus;

@Entity
@Table(name = "friends")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Friend {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "user1_id", nullable = false)
    private User user1;

    @ManyToOne
    @JoinColumn(name = "user2_id", nullable = false)
    private User user2;


    private boolean isBlocked;

    @Enumerated(EnumType.STRING)
    private RequestStatus requestStatus;

    public Friend(
            User user1,
            User user2,
            boolean isBlocked,
            RequestStatus requestStatus
    ) {
        this.user1 = user1;
        this.user2 = user2;
        this.isBlocked = isBlocked;
        this.requestStatus = requestStatus;
    }
}
