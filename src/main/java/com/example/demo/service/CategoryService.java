package com.example.demo.service;

import com.example.demo.entity.Category;
import com.example.demo.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class CategoryService {

    private static final String CATEGORY_KEY_PREFIX = "category:";
    private static final String CATEGORY_TREE_KEY = "category:tree";
    private static final String CATEGORY_ROOTS_KEY = "category:roots";
    private static final Duration CACHE_TTL = Duration.ofMinutes(30);

    @Autowired
    private CategoryRepository categoryRepository;
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    // Basic CRUD Operations
    @Transactional
    public Category createCategory(Category category) {
        validateCategory(category);
        ensureUniqueSlug(category);
        Category saved = categoryRepository.save(category);
        evictCache();
        return saved;
    }

    public Optional<Category> getCategory(Long id) {
        // Try cache first
        Optional<Category> cached = getCategoryFromCache(id);
        if (cached.isPresent()) {
            return cached;
        }
        
        // Fallback to database
        Optional<Category> category = categoryRepository.findById(id);
        if (category.isPresent()) {
            cacheCategory(category.get());
        }
        return category;
    }

    @Transactional
    public Category updateCategory(Long id, Category category) {
        Category existing = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));

        // Partial update: only overwrite with non-null fields from request
        // Name
        if (category.getName() != null) {
            String newName = category.getName().trim();
            if (newName.isEmpty() || newName.length() < 2 || newName.length() > 100) {
                throw new IllegalArgumentException("Category name must be between 2 and 100 characters");
            }
            existing.setName(newName);
        }

        // Slug
        if (category.getSlug() != null) {
            // Ensure provided slug is unique (excluding current id)
            ensureUniqueSlug(category, id);
            existing.setSlug(category.getSlug());
        }

        // Description
        if (category.getDescription() != null) {
            existing.setDescription(category.getDescription());
        }

        // Parent (only set if non-null to avoid accidental nulling)
        if (category.getParent() != null) {
            existing.setParent(category.getParent());
        }

        // Active flag
        if (category.getIsActive() != null) {
            existing.setIsActive(category.getIsActive());
        }

        Category saved = categoryRepository.save(existing);
        cacheCategory(saved);
        evictCache();
        return saved;
    }

    @Transactional
    public void deleteCategory(Long id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));
        
        // Check if category has children
        if (!category.getChildren().isEmpty()) {
            throw new IllegalStateException("Cannot delete category with children. Remove children first.");
        }
        
        categoryRepository.deleteById(id);
        evictCategoryFromCache(id);
        evictCache();
    }

    // Hierarchy Management
    @Transactional
    public Category addChild(Long parentId, Category child) {
        Category parent = categoryRepository.findById(parentId)
                .orElseThrow(() -> new IllegalArgumentException("Parent category not found"));
        
        validateCategory(child);
        ensureUniqueSlug(child);
        
        child.setParent(parent);
        Category saved = categoryRepository.save(child);
        parent.getChildren().add(saved);
        categoryRepository.save(parent);
        
        evictCache();
        return saved;
    }

    @Transactional
    public void removeChild(Long parentId, Long childId) {
        Category parent = categoryRepository.findById(parentId)
                .orElseThrow(() -> new IllegalArgumentException("Parent category not found"));
        
        Category child = categoryRepository.findById(childId)
                .orElseThrow(() -> new IllegalArgumentException("Child category not found"));
        
        if (!parent.getChildren().contains(child)) {
            throw new IllegalArgumentException("Category is not a child of the specified parent");
        }
        
        child.setParent(null);
        categoryRepository.save(child);
        parent.getChildren().remove(child);
        categoryRepository.save(parent);
        
        evictCache();
    }

    public List<Category> getChildren(Long parentId) {
        return categoryRepository.findChildrenByParentIdOrdered(parentId);
    }

    public Optional<Category> getParent(Long categoryId) {
        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));
        return Optional.ofNullable(category.getParent());
    }

    // Search Functions
    public List<Category> findByName(String name) {
        return categoryRepository.findByNameContainingIgnoreCase(name);
    }

    public Optional<Category> findBySlug(String slug) {
        return categoryRepository.findBySlug(slug);
    }

    public List<Category> findActiveCategories() {
        return categoryRepository.findByIsActiveTrue();
    }

    public List<Category> findInactiveCategories() {
        return categoryRepository.findByIsActiveFalse();
    }

    // Tree Operations
    public List<Category> getCategoryTree() {
        // Try cache first
        Optional<List<Category>> cached = getCategoryTreeFromCache();
        if (cached.isPresent()) {
            return cached.get();
        }
        
        List<Category> tree = buildCategoryTree();
        cacheCategoryTree(tree);
        return tree;
    }

    public List<Category> getRootCategories() {
        // Try cache first
        Optional<List<Category>> cached = getRootCategoriesFromCache();
        if (cached.isPresent()) {
            return cached.get();
        }
        
        List<Category> roots = categoryRepository.findActiveRootCategoriesOrdered();
        cacheRootCategories(roots);
        return roots;
    }

    public List<Category> getCategoryPath(Long categoryId) {
        List<Category> path = new ArrayList<>();
        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));
        
        while (category != null) {
            path.add(0, category); // Add to beginning for correct order
            category = category.getParent();
        }
        
        return path;
    }

    // Business Logic
    @Transactional
    public Category activateCategory(Long id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));
        
        category.setIsActive(true);
        Category saved = categoryRepository.save(category);
        cacheCategory(saved);
        evictCache();
        return saved;
    }

    @Transactional
    public Category deactivateCategory(Long id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));
        
        category.setIsActive(false);
        Category saved = categoryRepository.save(category);
        cacheCategory(saved);
        evictCache();
        return saved;
    }

    public String generateSlug(String name) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Name cannot be null or empty");
        }
        
        String slug = name.trim().toLowerCase()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-+|-+$", "");
        
        // Ensure uniqueness
        String originalSlug = slug;
        int counter = 1;
        while (categoryRepository.findBySlug(slug).isPresent()) {
            slug = originalSlug + "-" + counter;
            counter++;
        }
        
        return slug;
    }

    // Advanced Functions
    public List<Category> findCategoriesWithProducts() {
        return categoryRepository.findActiveCategoriesWithProducts();
    }

    public Map<Category, Long> getCategoryProductCounts() {
        // This would require a custom query or service method
        // For now, return empty map - can be implemented with ProductRepository
        return new HashMap<>();
    }

    public List<Category> findCategoriesByProductCount(int minCount) {
        // This would require a custom query
        // For now, return empty list - can be implemented with ProductRepository
        return new ArrayList<>();
    }

    // Search with cache
    public List<Category> searchCategories(String searchTerm) {
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            return getRootCategories();
        }
        
        return categoryRepository.searchActiveCategories(searchTerm.trim());
    }

    // Cache Management
    private Optional<Category> getCategoryFromCache(Long id) {
        try {
            ValueOperations<String, Object> ops = redisTemplate.opsForValue();
            Object obj = ops.get(CATEGORY_KEY_PREFIX + id);
            if (obj instanceof Category) {
                return Optional.of((Category) obj);
            }
        } catch (Exception e) {
            // Cache miss or error - continue with database
        }
        return Optional.empty();
    }

    private void cacheCategory(Category category) {
        try {
            ValueOperations<String, Object> ops = redisTemplate.opsForValue();
            ops.set(CATEGORY_KEY_PREFIX + category.getId(), category, CACHE_TTL);
        } catch (Exception e) {
            // Cache error - continue without caching
        }
    }

    private void evictCategoryFromCache(Long id) {
        try {
            redisTemplate.delete(CATEGORY_KEY_PREFIX + id);
        } catch (Exception e) {
            // Cache error - continue
        }
    }

    private Optional<List<Category>> getCategoryTreeFromCache() {
        try {
            ValueOperations<String, Object> ops = redisTemplate.opsForValue();
            Object obj = ops.get(CATEGORY_TREE_KEY);
            if (obj instanceof List) {
                return Optional.of((List<Category>) obj);
            }
        } catch (Exception e) {
            // Cache miss or error
        }
        return Optional.empty();
    }

    private void cacheCategoryTree(List<Category> tree) {
        try {
            ValueOperations<String, Object> ops = redisTemplate.opsForValue();
            ops.set(CATEGORY_TREE_KEY, tree, CACHE_TTL);
        } catch (Exception e) {
            // Cache error - continue without caching
        }
    }

    private Optional<List<Category>> getRootCategoriesFromCache() {
        try {
            ValueOperations<String, Object> ops = redisTemplate.opsForValue();
            Object obj = ops.get(CATEGORY_ROOTS_KEY);
            if (obj instanceof List) {
                return Optional.of((List<Category>) obj);
            }
        } catch (Exception e) {
            // Cache miss or error
        }
        return Optional.empty();
    }

    private void cacheRootCategories(List<Category> roots) {
        try {
            ValueOperations<String, Object> ops = redisTemplate.opsForValue();
            ops.set(CATEGORY_ROOTS_KEY, roots, CACHE_TTL);
        } catch (Exception e) {
            // Cache error - continue without caching
        }
    }

    private void evictCache() {
        try {
            redisTemplate.delete(CATEGORY_TREE_KEY);
            redisTemplate.delete(CATEGORY_ROOTS_KEY);
        } catch (Exception e) {
            // Cache error - continue
        }
    }

    private List<Category> buildCategoryTree() {
        List<Category> roots = categoryRepository.findActiveRootCategoriesOrdered();
        return roots.stream()
                .map(this::buildCategoryWithChildren)
                .collect(Collectors.toList());
    }

    private Category buildCategoryWithChildren(Category category) {
        List<Category> children = categoryRepository.findActiveChildrenByParentIdOrdered(category.getId());
        children = children.stream()
                .map(this::buildCategoryWithChildren)
                .collect(Collectors.toList());
        category.setChildren(children);
        return category;
    }

    // Validation Methods
    private void validateCategory(Category category) {
        if (category == null) {
            throw new IllegalArgumentException("Category cannot be null");
        }
        if (category.getName() == null || category.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Category name cannot be null or empty");
        }
        if (category.getName().length() < 2 || category.getName().length() > 100) {
            throw new IllegalArgumentException("Category name must be between 2 and 100 characters");
        }
    }

    private void ensureUniqueSlug(Category category) {
        ensureUniqueSlug(category, null);
    }

    private void ensureUniqueSlug(Category category, Long excludeId) {
        String slug = category.getSlug();
        if (slug == null || slug.trim().isEmpty()) {
            slug = generateSlug(category.getName());
            category.setSlug(slug);
        }
        
        Optional<Category> existing = categoryRepository.findBySlug(slug);
        if (existing.isPresent() && !existing.get().getId().equals(excludeId)) {
            throw new IllegalArgumentException("Slug already exists: " + slug);
        }
    }
}
