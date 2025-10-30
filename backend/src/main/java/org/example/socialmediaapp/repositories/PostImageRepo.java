package org.example.socialmediaapp.repositories;

import org.example.socialmediaapp.entities.PostImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PostImageRepo extends JpaRepository<PostImage, Integer> {
    public List<PostImage> findAllByPost_Id(Integer id);
}
