package com.example.demo.repository;

import com.example.demo.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
    
    // Basic Queries
    Optional<Category> findBySlug(String slug);
    
    List<Category> findByParentId(Long parentId);
    
    List<Category> findByIsActiveTrue();
    
    List<Category> findByIsActiveFalse();
    
    // Hierarchy Queries
    List<Category> findByParentIsNull();
    
    List<Category> findByParentIsNullAndIsActiveTrue();
    
    // Search Queries
    List<Category> findByNameContainingIgnoreCase(String name);
    
    List<Category> findBySlugContainingIgnoreCase(String slug);
    
    // Count Queries
    long countByParentId(Long parentId);
    
    long countByIsActiveTrue();
    
    // Custom Queries
    @Query("SELECT c FROM Category c WHERE c.parent IS NULL ORDER BY c.name")
    List<Category> findRootCategoriesOrdered();
    
    @Query("SELECT c FROM Category c WHERE c.parent.id = :parentId ORDER BY c.name")
    List<Category> findChildrenByParentIdOrdered(@Param("parentId") Long parentId);
    
    @Query("SELECT c FROM Category c WHERE c.isActive = true AND c.parent IS NULL ORDER BY c.name")
    List<Category> findActiveRootCategories();
    
    @Query("SELECT c FROM Category c WHERE c.name LIKE %:searchTerm% OR c.slug LIKE %:searchTerm%")
    List<Category> searchCategories(@Param("searchTerm") String searchTerm);
    
    @Query("SELECT c FROM Category c WHERE c.isActive = true AND (c.name LIKE %:searchTerm% OR c.slug LIKE %:searchTerm%)")
    List<Category> searchActiveCategories(@Param("searchTerm") String searchTerm);
    
    @Query("SELECT c FROM Category c WHERE c.parent IS NULL AND c.isActive = true ORDER BY c.name")
    List<Category> findActiveRootCategoriesOrdered();
    
    @Query("SELECT c FROM Category c WHERE c.parent.id = :parentId AND c.isActive = true ORDER BY c.name")
    List<Category> findActiveChildrenByParentIdOrdered(@Param("parentId") Long parentId);
    
    @Query("SELECT c FROM Category c WHERE c.id IN (SELECT DISTINCT p.category.id FROM Product p WHERE p.category.id IS NOT NULL)")
    List<Category> findCategoriesWithProducts();
    
    @Query("SELECT c FROM Category c WHERE c.id IN (SELECT DISTINCT p.category.id FROM Product p WHERE p.category.id IS NOT NULL) AND c.isActive = true")
    List<Category> findActiveCategoriesWithProducts();
    
    @Query("SELECT c FROM Category c WHERE c.parent IS NULL AND c.isActive = true AND c.id IN (SELECT DISTINCT p.category.id FROM Product p WHERE p.category.id IS NOT NULL) ORDER BY c.name")
    List<Category> findActiveRootCategoriesWithProducts();
}
