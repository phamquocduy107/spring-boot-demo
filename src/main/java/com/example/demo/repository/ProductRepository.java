package com.example.demo.repository;

import com.example.demo.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    
    // Find products by category id/slug
    List<Product> findByCategory_Id(Long categoryId);
    List<Product> findByCategory_Slug(String slug);
    
    // Find products by brand
    List<Product> findByBrand(String brand);
    
    // Find active products
    List<Product> findByIsActiveTrue();
    
    // Find featured products
    List<Product> findByIsFeaturedTrue();
    
    // Find products by status
    List<Product> findByStatus(Product.ProductStatus status);
    
    // Find products by SKU (unique)
    Optional<Product> findBySku(String sku);
    
    // Find products by name containing (case insensitive)
    List<Product> findByNameContainingIgnoreCase(String name);
    
    // Find products by price range
    List<Product> findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice);
    
    // Find products with stock greater than specified quantity
    List<Product> findByStockQuantityGreaterThan(Integer quantity);
    
    // Find products with stock less than or equal to specified quantity
    List<Product> findByStockQuantityLessThanEqual(Integer quantity);
    
    // Find active products by category
    List<Product> findByCategory_IdAndIsActiveTrue(Long categoryId);
    
    // Find products by name containing and category
    List<Product> findByNameContainingIgnoreCaseAndCategory_Id(String name, Long categoryId);
    
    // Find products by price range and category
    List<Product> findByPriceBetweenAndCategory_Id(BigDecimal minPrice, BigDecimal maxPrice, Long categoryId);
    
    // Custom query to find products with low stock
    @Query("SELECT p FROM Product p WHERE p.stockQuantity <= :threshold AND p.isActive = true")
    List<Product> findLowStockProducts(@Param("threshold") Integer threshold);
    
    // Custom query to find products by partial name search
    @Query("SELECT p FROM Product p WHERE LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Product> searchProductsByKeyword(@Param("keyword") String keyword);
    
    // Custom query to find products with highest price
    @Query("SELECT p FROM Product p WHERE p.price = (SELECT MAX(p2.price) FROM Product p2 WHERE p2.isActive = true)")
    List<Product> findMostExpensiveProducts();
    
    // Custom query to find products with lowest price
    @Query("SELECT p FROM Product p WHERE p.price = (SELECT MIN(p2.price) FROM Product p2 WHERE p2.isActive = true)")
    List<Product> findCheapestProducts();
    
    // Count products by category
    long countByCategory_Id(Long categoryId);
    
    // Count active products
    long countByIsActiveTrue();
    
    // Check if product exists by SKU
    boolean existsBySku(String sku);
    
    // Check if product exists by name
    boolean existsByName(String name);
}
