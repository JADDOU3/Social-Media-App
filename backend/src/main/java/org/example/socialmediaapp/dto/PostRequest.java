package org.example.socialmediaapp.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Data
public class PostRequest {
    private String text;
    private List<MultipartFile> images;
}
