package com.example.demo.controller;

import com.example.demo.entity.Category;
import com.example.demo.service.CategoryService;
import com.example.demo.dto.CategoryDTO;
import com.example.demo.mapper.DtoMapper;
import com.example.demo.dto.CategoryDTO;
import com.example.demo.mapper.DtoMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    @Autowired
    private CategoryService categoryService;

    // Basic CRUD Endpoints
    @PostMapping
    public ResponseEntity<CategoryDTO> createCategory(@RequestBody Category category) {
        try {
            Category created = categoryService.createCategory(category);
            return ResponseEntity.status(HttpStatus.CREATED).body(DtoMapper.toCategoryDTO(created, true));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/{id:\\d+}")
    public ResponseEntity<CategoryDTO> getCategory(@PathVariable("id") Long id) {
        Optional<Category> category = categoryService.getCategory(id);
        return category.map(c -> ResponseEntity.ok(DtoMapper.toCategoryDTO(c, true)))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PutMapping("/{id:\\d+}")
    public ResponseEntity<CategoryDTO> updateCategory(@PathVariable("id") Long id, @RequestBody Category category) {
        try {
            Category updated = categoryService.updateCategory(id, category);
            return ResponseEntity.ok(DtoMapper.toCategoryDTO(updated, true));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/{id:\\d+}")
    public ResponseEntity<Void> deleteCategory(@PathVariable("id") Long id) {
        try {
            categoryService.deleteCategory(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Hierarchy Endpoints
    @PostMapping("/{parentId}/children")
    public ResponseEntity<CategoryDTO> addChild(@PathVariable Long parentId, @RequestBody Category child) {
        try {
            Category added = categoryService.addChild(parentId, child);
            return ResponseEntity.status(HttpStatus.CREATED).body(DtoMapper.toCategoryDTO(added, true));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/{parentId}/children/{childId}")
    public ResponseEntity<Void> removeChild(@PathVariable Long parentId, @PathVariable Long childId) {
        try {
            categoryService.removeChild(parentId, childId);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/{id:\\d+}/children")
    public ResponseEntity<List<CategoryDTO>> getChildren(@PathVariable("id") Long id) {
        try {
            List<CategoryDTO> children = categoryService.getChildren(id).stream().map(c -> DtoMapper.toCategoryDTO(c, false)).toList();
            return ResponseEntity.ok(children);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/{id:\\d+}/parent")
    public ResponseEntity<CategoryDTO> getParent(@PathVariable("id") Long id) {
        try {
            Optional<Category> parent = categoryService.getParent(id);
            return parent.map(p -> ResponseEntity.ok(DtoMapper.toCategoryDTO(p, false)))
                    .orElseGet(() -> ResponseEntity.notFound().build());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Search Endpoints
    @GetMapping("/search")
    public ResponseEntity<List<CategoryDTO>> searchCategories(@RequestParam String q) {
        try {
            List<CategoryDTO> categories = categoryService.searchCategories(q).stream().map(c -> DtoMapper.toCategoryDTO(c, false)).toList();
            return ResponseEntity.ok(categories);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/slug/{slug}")
    public ResponseEntity<CategoryDTO> getCategoryBySlug(@PathVariable String slug) {
        try {
            Optional<Category> category = categoryService.findBySlug(slug);
            return category.map(c -> ResponseEntity.ok(DtoMapper.toCategoryDTO(c, true)))
                    .orElseGet(() -> ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/active")
    public ResponseEntity<List<CategoryDTO>> getActiveCategories() {
        try {
            List<CategoryDTO> categories = categoryService.findActiveCategories().stream().map(c -> DtoMapper.toCategoryDTO(c, false)).toList();
            return ResponseEntity.ok(categories);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Paginated categories
    @GetMapping("/page")
    public ResponseEntity<?> getCategoriesPage(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "id,desc") String sort
    ) {
        try {
            // Basic validation for page/size
            if (page < 0) {
                return ResponseEntity.badRequest().body("page must be >= 0");
            }
            if (size < 1 || size > 100) {
                return ResponseEntity.badRequest().body("size must be between 1 and 100");
            }

            // Validate sort in format: field,dir and allowlist known fields
            String[] parts = sort != null ? sort.split(",") : new String[] {"id","desc"};
            String sortBy = parts.length > 0 ? parts[0] : "id";
            String dir = parts.length > 1 ? parts[1] : "desc";

            // Allowlist fields
            java.util.Set<String> allowed = java.util.Set.of("id","name","slug","createdAt","updatedAt","isActive");
            if (!allowed.contains(sortBy)) {
                return ResponseEntity.badRequest().body("Invalid sort field: " + sortBy);
            }
            if (!dir.equalsIgnoreCase("asc") && !dir.equalsIgnoreCase("desc")) {
                return ResponseEntity.badRequest().body("Invalid sort direction: " + dir);
            }

            return ResponseEntity.ok(
                categoryService.getCategoriesPage(page, size, sort)
                    .map(c -> DtoMapper.toCategoryDTO(c, false))
            );
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(ex.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error: " + e.getMessage());
        }
    }

    @GetMapping("/inactive")
    public ResponseEntity<List<CategoryDTO>> getInactiveCategories() {
        try {
            List<CategoryDTO> categories = categoryService.findInactiveCategories().stream().map(c -> DtoMapper.toCategoryDTO(c, false)).toList();
            return ResponseEntity.ok(categories);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Tree Endpoints
    @GetMapping("/tree")
    public ResponseEntity<List<CategoryDTO>> getCategoryTree() {
        try {
            List<CategoryDTO> tree = categoryService.getCategoryTree().stream().map(c -> DtoMapper.toCategoryDTO(c, true)).toList();
            return ResponseEntity.ok(tree);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/roots")
    public ResponseEntity<List<CategoryDTO>> getRootCategories() {
        try {
            List<CategoryDTO> roots = categoryService.getRootCategories().stream().map(c -> DtoMapper.toCategoryDTO(c, true)).toList();
            return ResponseEntity.ok(roots);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/{id:\\d+}/path")
    public ResponseEntity<List<CategoryDTO>> getCategoryPath(@PathVariable("id") Long id) {
        try {
            List<CategoryDTO> path = categoryService.getCategoryPath(id).stream().map(c -> DtoMapper.toCategoryDTO(c, true)).toList();
            return ResponseEntity.ok(path);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Business Logic Endpoints
    @PutMapping("/{id:\\d+}/activate")
    public ResponseEntity<CategoryDTO> activateCategory(@PathVariable("id") Long id) {
        try {
            Category category = categoryService.activateCategory(id);
            return ResponseEntity.ok(DtoMapper.toCategoryDTO(category, true));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PutMapping("/{id:\\d+}/deactivate")
    public ResponseEntity<CategoryDTO> deactivateCategory(@PathVariable("id") Long id) {
        try {
            Category category = categoryService.deactivateCategory(id);
            return ResponseEntity.ok(DtoMapper.toCategoryDTO(category, true));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Advanced Endpoints
    @GetMapping("/with-products")
    public ResponseEntity<List<CategoryDTO>> getCategoriesWithProducts() {
        try {
            List<CategoryDTO> categories = categoryService.findCategoriesWithProducts().stream().map(c -> DtoMapper.toCategoryDTO(c, true)).toList();
            return ResponseEntity.ok(categories);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/product-counts")
    public ResponseEntity<Map<Category, Long>> getCategoryProductCounts() {
        try {
            Map<Category, Long> counts = categoryService.getCategoryProductCounts();
            return ResponseEntity.ok(counts);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/by-product-count")
    public ResponseEntity<List<CategoryDTO>> getCategoriesByProductCount(@RequestParam int minCount) {
        try {
            List<CategoryDTO> categories = categoryService.findCategoriesByProductCount(minCount).stream().map(c -> DtoMapper.toCategoryDTO(c, true)).toList();
            return ResponseEntity.ok(categories);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Utility Endpoints
    @GetMapping("/generate-slug")
    public ResponseEntity<Map<String, String>> generateSlug(@RequestParam String name) {
        try {
            String slug = categoryService.generateSlug(name);
            return ResponseEntity.ok(Map.of("slug", slug));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Bulk Operations
    @PostMapping("/bulk-activate")
    public ResponseEntity<?> bulkActivateCategories(@RequestBody List<Long> categoryIds) {
        try {
            List<Long> activatedIds = new ArrayList<>();
            List<Long> skippedIds = new ArrayList<>();
            for (Long id : categoryIds) {
                try {
                    Category category = categoryService.activateCategory(id);
                    activatedIds.add(category.getId());
                } catch (Exception ex) {
                    skippedIds.add(id);
                }
            }
            return ResponseEntity.ok(Map.of(
                    "activated", activatedIds,
                    "skipped", skippedIds
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PostMapping("/bulk-deactivate")
    public ResponseEntity<?> bulkDeactivateCategories(@RequestBody List<Long> categoryIds) {
        try {
            List<Long> deactivatedIds = new ArrayList<>();
            List<Long> skippedIds = new ArrayList<>();
            for (Long id : categoryIds) {
                try {
                    Category category = categoryService.deactivateCategory(id);
                    deactivatedIds.add(category.getId());
                } catch (Exception ex) {
                    skippedIds.add(id);
                }
            }
            return ResponseEntity.ok(Map.of(
                    "deactivated", deactivatedIds,
                    "skipped", skippedIds
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
