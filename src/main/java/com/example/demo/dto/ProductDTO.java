package com.example.demo.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class ProductDTO {
    public Long id;
    public String name;
    public String description;
    public String sku;
    public BigDecimal price;
    public Integer stockQuantity;
    public String brand;
    public String color;
    public String size;
    public Boolean isActive;
    public Boolean isFeatured;
    public String status;
    public LocalDateTime createdAt;
    public LocalDateTime updatedAt;
    public Long categoryId;
    public String categoryName;
}


