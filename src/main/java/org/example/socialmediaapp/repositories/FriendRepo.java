package org.example.socialmediaapp.repositories;

import org.example.socialmediaapp.entities.Friend;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.utils.enums.RequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FriendRepo extends JpaRepository<Friend, Integer> {


    Optional<Friend> findByUser1AndUser2(User user1, User user2);

    List<Friend> findByUser1AndRequestStatus(User user, RequestStatus requestStatus);
    List<Friend> findByUser2AndRequestStatus(User user, RequestStatus requestStatus);

    List<Friend> findByUser1AndUser2AndRequestStatus(User user1, User user2, RequestStatus requestStatus);

    List<Friend> findByUser1AndIsBlockedTrue(User user1);
    List<Friend> findByUser2AndIsBlockedTrue(User user2);
}
