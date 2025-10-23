package org.example.socialmediaapp.services;

import org.example.socialmediaapp.entities.*;
import org.example.socialmediaapp.repositories.*;
import org.springframework.transaction.annotation.Transactional;
import org.example.socialmediaapp.dto.PostRequest;
import org.example.socialmediaapp.dto.PostResponse;
import org.example.socialmediaapp.utils.PostType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
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
    private PostLikeRepo postLikeRepo;

    @Transactional
    public PostResponse createPost(String email,PostRequest postRequest) throws IOException {
    User author=userRepo.findByEmail(email).orElseThrow(()->new RuntimeException("User not found"));
    if((postRequest.getText()==null||postRequest.getText().trim().isEmpty())&&(postRequest.getImages().isEmpty()||postRequest.getImages()==null)){
        throw new RuntimeException("Please fill the fields");
    }
    Post post=new Post();
    post.setAuthor(author);
    post.setText(postRequest.getText());
    post.setCreatedDate(LocalDateTime.now());
    post.setCommentCount(0);
    post.setLikeCount(0);
    post.setDeleted(false);

    Post savedPost=postRepo.save(post);
    int numberOfImages=0;
    if(postRequest.getImages()!=null && !postRequest.getImages().isEmpty()){
        for(MultipartFile mf: postRequest.getImages()){
            if(mf==null||mf.isEmpty())continue;
            PostImage pi = new PostImage();
            pi.setImageName(mf.getOriginalFilename());
            pi.setImageType(mf.getContentType());
            try {
                pi.setImageData(mf.getBytes());
            } catch (IOException e) {
                throw new RuntimeException("Failed to read image bytes", e);
            }
            pi.setPost(savedPost);
            postImageRepo.save(pi);
            numberOfImages++;
        }
        savedPost.setImageCount(numberOfImages);
        if(!post.getText().trim().isEmpty()){
            if(post.getImageCount()>0){
                post.setPostType(PostType.IMAGE_AND_TEXT);
            }else{
                post.setPostType(PostType.TEXT_ONLY);
            }
        }else{
            post.setPostType(PostType.IMAGE_ONLY);
        }
        postRepo.save(savedPost);
    }
    return toResponse(savedPost);
    }
    public PostResponse toResponse(Post post) {
        PostResponse response=new PostResponse();
        response.setId(post.getId());
        response.setText(post.getText());
        response.setAuthorEmail(post.getAuthor().getEmail());
        response.setAuthorName(post.getAuthor().getName());
        response.setCreatedDate(post.getCreatedDate());
        response.setCommentCount(post.getCommentCount());
        response.setLikeCount(post.getLikeCount());
        response.setImageCount(post.getImageCount());
        if(post.getImageCount()>0){
            response.setImageNames(post.getImages().stream().map(PostImage::getImageName).collect(Collectors.toList()));
        }
        return  response;
    }

    public List<PostResponse> getMyPosts(String email) {
        List<Post> posts =postRepo.findAllByAuthor_emailAndDeletedFalse(email);
        return posts.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public void deletePost(int postId, String userEmail) {
        Post post = postRepo.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        if (!post.getAuthor().getEmail().equals(userEmail)) {
            throw new RuntimeException("You can only delete your own posts");
        }

        post.setDeleted(true);
        postRepo.save(post);
    }

    public String toggleLike(int postId, String userEmail) {
        Post post = postRepo.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        User user = userRepo.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Optional<PostLike> existing = postLikeRepo.findByPostAndUser(post, user);

        if (existing.isPresent()) {
            postLikeRepo.delete(existing.get());
            post.setLikeCount(post.getLikeCount() - 1);
            postRepo.save(post);
            return "Unliked this post";
        } else {
            PostLike like = new PostLike();
            like.setPost(post);
            like.setUser(user);
            postLikeRepo.save(like);
            post.setLikeCount(post.getLikeCount() + 1);
            postRepo.save(post);
            return "Liked this post";
        }
    }

    public List<PostResponse> getAllPosts() {
        return postRepo.findAllByDeletedFalse()
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }


}
