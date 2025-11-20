package org.example.socialmediaapp.dto;

import lombok.Data;
import org.example.socialmediaapp.utils.enums.RequestStatus;

@Data
public class FriendResponse {
    private int id;
    private int senderId;
    private int receiverId;
    private String senderName;
    private String receiverName;
    private boolean isBlocked;
    private RequestStatus requestStatus;
}