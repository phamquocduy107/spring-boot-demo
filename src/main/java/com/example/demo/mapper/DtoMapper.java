package com.example.demo.mapper;

import com.example.demo.dto.CategoryDTO;
import com.example.demo.dto.ProductDTO;
import com.example.demo.dto.CartDTO;
import com.example.demo.dto.CartItemDTO;
import com.example.demo.entity.Category;
import com.example.demo.entity.Product;
import com.example.demo.entity.Cart;
import com.example.demo.entity.CartItem;

import java.util.List;
import java.util.stream.Collectors;

public class DtoMapper {

    public static ProductDTO toProductDTO(Product p) {
        if (p == null) return null;
        ProductDTO dto = new ProductDTO();
        dto.id = p.getId();
        dto.name = p.getName();
        dto.description = p.getDescription();
        dto.sku = p.getSku();
        dto.price = p.getPrice();
        dto.stockQuantity = p.getStockQuantity();
        dto.brand = p.getBrand();
        dto.color = p.getColor();
        dto.size = p.getSize();
        dto.isActive = p.getIsActive();
        dto.isFeatured = p.getIsFeatured();
        dto.status = p.getStatus() != null ? p.getStatus().name() : null;
        dto.createdAt = p.getCreatedAt();
        dto.updatedAt = p.getUpdatedAt();
        if (p.getCategory() != null) {
            dto.categoryId = p.getCategory().getId();
            dto.categoryName = p.getCategory().getName();
        }
        return dto;
    }

    public static CategoryDTO toCategoryDTO(Category c, boolean includeChildrenIds) {
        if (c == null) return null;
        CategoryDTO dto = new CategoryDTO();
        dto.id = c.getId();
        dto.name = c.getName();
        dto.slug = c.getSlug();
        dto.description = c.getDescription();
        dto.isActive = c.getIsActive();
        dto.createdAt = c.getCreatedAt();
        dto.updatedAt = c.getUpdatedAt();
        if (includeChildrenIds && c.getChildren() != null) {
            dto.childrenIds = c.getChildren().stream()
                    .map(Category::getId)
                    .collect(Collectors.toList());
        }
        return dto;
    }

    public static CartItemDTO toCartItemDTO(CartItem item) {
        if (item == null) return null;
        CartItemDTO dto = new CartItemDTO();
        if (item.getProduct() != null) {
            dto.setProductId(item.getProduct().getId());
            dto.setProductName(item.getProduct().getName());
        }
        dto.setQuantity(item.getQuantity());
        dto.setPriceAtAdd(item.getPriceAtAdd());
        return dto;
    }

    public static CartDTO toCartDTO(Cart cart) {
        if (cart == null) return null;
        CartDTO dto = new CartDTO();
        dto.setId(cart.getId());
        dto.setUserId(cart.getUser() != null ? cart.getUser().getId() : null);
        dto.setIsActive(cart.getIsActive());
        dto.setSubtotal(cart.getSubtotal());
        dto.setTotal(cart.getTotal());
        dto.setCreatedAt(cart.getCreatedAt());
        dto.setUpdatedAt(cart.getUpdatedAt());
        if (cart.getItems() != null) {
            for (CartItem ci : cart.getItems()) {
                dto.getItems().add(toCartItemDTO(ci));
            }
        }
        return dto;
    }
}


