package org.example.socialmediaapp.repositories;

import org.example.socialmediaapp.entities.PostComment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PostCommentRepo extends JpaRepository<PostComment, Integer> {
    List<PostComment> findByPost_Id(Integer postId);
}
