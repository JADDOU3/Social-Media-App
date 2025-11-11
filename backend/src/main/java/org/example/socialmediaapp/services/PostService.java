package org.example.socialmediaapp.services;

import org.example.socialmediaapp.dto.FriendResponse;
import org.example.socialmediaapp.dto.PostRequest;
import org.example.socialmediaapp.dto.PostResponse;
import org.example.socialmediaapp.entities.Friend;
import org.example.socialmediaapp.entities.Post;
import org.example.socialmediaapp.entities.PostImage;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.repositories.*;
import org.example.socialmediaapp.utils.SecurityUtils;
import org.example.socialmediaapp.utils.enums.RequestStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.URI;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class PostService {

    @Autowired
    private PostRepo postRepo;

    @Autowired
    private UserRepo userRepo;

    @Autowired
    private PostImageRepo postImageRepo;

    @Autowired
    private FriendRepo friendRepo;

    @Autowired
    private PostCommentRepo postCommentRepo;

    @Autowired
    private PostReactionRepo postReactionRepo;

    @Autowired
    private FriendService friendService;


    @Transactional
    public PostResponse createPost(User user , PostRequest postRequest) throws IOException {
        boolean hasText = postRequest.getText() != null && !postRequest.getText().trim().isEmpty();
        boolean hasImages = postRequest.getImages() != null && !postRequest.getImages().isEmpty();
        System.out.println("before checking");
        if (!hasText && !hasImages) {
            throw new RuntimeException("Post must have text or at least one image.");
        }
        System.out.println("after checking");
        Post post = new Post();
        post.setAuthor(user);
        post.setText(hasText ? postRequest.getText().trim() : null);
        post.setCreatedDate(LocalDateTime.now());
        post.setDeleted(false);

        Post savedPost = postRepo.save(post);

        int imageCount = 0;
        if (hasImages) {
            for (MultipartFile file : postRequest.getImages()) {
                if (file == null || file.isEmpty()) continue;

                PostImage image = new PostImage();
                image.setImageName(file.getOriginalFilename());
                image.setImageType(file.getContentType());
                image.setImageData(file.getBytes());
                image.setPost(savedPost);

                postImageRepo.save(image);
                imageCount++;
            }
        }

        savedPost.setImageCount(imageCount);
        postRepo.save(savedPost);

        return toResponse(savedPost);
    }

    public List<PostResponse> getAllPosts() {
        User currentUser = SecurityUtils.getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("Unauthorized");
        }

        List<FriendResponse> friendResponses = friendService.getAllFriends(currentUser.getId());

        List<User> allowedAuthors = friendResponses.stream()
                .map(f -> {
                    int friendId = f.getSenderId() == currentUser.getId()
                            ? f.getReceiverId()
                            : f.getSenderId();
                    return userRepo.findById(friendId).orElse(null);
                })
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        allowedAuthors.add(currentUser);

        return postRepo.findAllByAuthorInAndDeletedFalse(allowedAuthors)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }


    public List<PostResponse> getMyPosts(String email) {
        return postRepo.findAllByAuthor_emailAndDeletedFalse(email)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public PostResponse updatePost(int postId, String userEmail, PostRequest updatedRequest) throws IOException {
        Post post = postRepo.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        if (!post.getAuthor().getEmail().equals(userEmail)) {
            throw new RuntimeException("You can only edit your own posts");
        }

        boolean hasText = updatedRequest.getText() != null && !updatedRequest.getText().trim().isEmpty();

        if (hasText) {
            post.setText(updatedRequest.getText().trim());
        }

        postRepo.save(post);

        return toResponse(post);
    }

    @Transactional
    public void deletePost(int postId, String userEmail) {
        Post post = postRepo.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        if (!post.getAuthor().getEmail().equals(userEmail)) {
            throw new RuntimeException("You can only delete your own posts");
        }

        post.setDeleted(true);
        postRepo.save(post);
    }

    public PostResponse toResponse(Post post) {
        PostResponse response = new PostResponse();
        response.setId(post.getId());
        response.setText(post.getText());
        response.setAuthorEmail(post.getAuthor().getEmail());
        response.setAuthorName(post.getAuthor().getName());
        response.setCreatedDate(post.getCreatedDate());
        response.setImageCount(post.getImageCount());

        if (post.getImages() != null && !post.getImages().isEmpty()) {
            String baseUrl = "http://localhost:8080";
            response.setImageUrls(
                    post.getImages().stream()
                            .map(img -> baseUrl + "/api/posts/" + post.getId() + "/images/" + img.getId())
                            .collect(Collectors.toList())
            );
        }

        return response;
    }


    public List<PostResponse> getUserPosts(int userId) {
        User currentUser = SecurityUtils.getCurrentUser();
        User targetUser = userRepo.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (currentUser != null && currentUser.getId() == userId) {
            return postRepo.findByAuthor_IdAndDeletedFalse(userId)
                    .stream()
                    .map(this::toResponse)
                    .collect(Collectors.toList());
        }

        if (currentUser != null && friendService.areFriends(currentUser.getId(), userId)) {
            return postRepo.findByAuthor_IdAndDeletedFalse(userId)
                    .stream()
                    .map(this::toResponse)
                    .collect(Collectors.toList());
        }

        return List.of();
    }

    public List<PostResponse> getFriendsPosts(int userId) {
        User currentUser = userRepo.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Friend> friendshipsAsUser1 = friendRepo.findByUser1AndRequestStatus(
                currentUser, RequestStatus.APPROVED);
        List<Friend> friendshipsAsUser2 = friendRepo.findByUser2AndRequestStatus(
                currentUser, RequestStatus.APPROVED);

        List<User> friends = new ArrayList<>();

        for (Friend friendship : friendshipsAsUser1) {
            if (!friendship.isBlocked()) {
                friends.add(friendship.getUser2());
            }
        }

        for (Friend friendship : friendshipsAsUser2) {
            if (!friendship.isBlocked()) {
                friends.add(friendship.getUser1());
            }
        }

        if (friends.isEmpty()) {
            return Collections.emptyList();
        }

        List<Post> friendsPosts = postRepo.findAllByAuthorInAndDeletedFalse(friends);

        friendsPosts.sort((p1, p2) -> p2.getCreatedDate().compareTo(p1.getCreatedDate()));

        return friendsPosts.stream()
                .map(this::convertToPostResponse)
                .collect(Collectors.toList());
    }

    private PostResponse convertToPostResponse(Post post) {
        PostResponse response = new PostResponse();
        response.setId(post.getId());
        response.setText(post.getText());
        response.setAuthorEmail(post.getAuthor().getEmail());
        response.setAuthorName(post.getAuthor().getName());
        response.setCreatedDate(post.getCreatedDate());

        if (post.getImages() != null && !post.getImages().isEmpty()) {
            response.setImageCount(post.getImages().size());

            List<String> imageUrls = post.getImages().stream()
                    .map(image -> "/api/posts/" + post.getId() + "/images/" + image.getId())
                    .collect(Collectors.toList());
            response.setImageUrls(imageUrls);
        } else {
            response.setImageCount(0);
            response.setImageUrls(Collections.emptyList());
        }

        return response;
    }
}