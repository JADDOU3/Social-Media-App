package org.example.socialmediaapp.dto;

import lombok.Data;

@Data
public class SuggestedFriendResponse {
    private int id;
    private String name;
    private int mutualFriendsCount;
}