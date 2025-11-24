package org.example.socialmediaapp.repositories;

import org.example.socialmediaapp.entities.Friend;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.utils.enums.RequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface FriendRepo extends JpaRepository<Friend, Integer> {


    Optional<Friend> findByUser1AndUser2(User user1, User user2);

    List<Friend> findByUser1AndRequestStatusOrderByIdDesc(User user, RequestStatus requestStatus);
    List<Friend> findByUser2AndRequestStatusOrderByIdDesc(User user, RequestStatus requestStatus);

    List<Friend> findByUser1AndUser2AndRequestStatus(User user1, User user2, RequestStatus requestStatus);

    List<Friend> findByUser1AndIsBlockedTrueOrderByIdDesc(User user1);
    List<Friend> findByUser2AndIsBlockedTrue(User user2);

    @Query("SELECT f FROM Friend f WHERE (f.user1 = :user OR f.user2 = :user) AND f.requestStatus = :status AND f.isBlocked = false ORDER BY f.id DESC")
    List<Friend> findAllFriendsByUserAndStatusOrderByIdDesc(@Param("user") User user, @Param("status") RequestStatus status);
}
