package com.example.demo.dto;

import java.time.LocalDateTime;
import java.util.List;

public class CategoryDTO {
    public Long id;
    public String name;
    public String slug;
    public String description;
    public Boolean isActive;
    public LocalDateTime createdAt;
    public LocalDateTime updatedAt;
    // Optional children ids to avoid recursion
    public List<Long> childrenIds;
}


