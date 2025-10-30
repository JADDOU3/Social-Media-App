package org.example.socialmediaapp.services;

import org.example.socialmediaapp.dto.PostRequest;
import org.example.socialmediaapp.dto.PostResponse;
import org.example.socialmediaapp.entities.Post;
import org.example.socialmediaapp.entities.PostImage;
import org.example.socialmediaapp.entities.User;
import org.example.socialmediaapp.repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
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
    private PostCommentRepo postCommentRepo;

    @Autowired
    private PostReactionRepo postReactionRepo;

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
        return postRepo.findAllByDeletedFalse()
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
            response.setImageNames(
                    post.getImages().stream()
                            .map(PostImage::getImageName)
                            .collect(Collectors.toList())
            );
        }

        return response;
    }
}
