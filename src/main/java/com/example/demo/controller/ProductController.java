package com.example.demo.controller;

import com.example.demo.entity.Product;
import com.example.demo.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/products")
@CrossOrigin(origins = "*")
public class ProductController {
    
    @Autowired
    private ProductService productService;
    
    // Create a new product
    @PostMapping
    public ResponseEntity<?> createProduct(@RequestBody Product product) {
        try {
            Product createdProduct = productService.createProduct(product);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdProduct);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error creating product: " + e.getMessage());
        }
    }
    
    // Get all products
    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() {
        List<Product> products = productService.getAllProducts();
        return ResponseEntity.ok(products);
    }
    
    // Get product by ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getProductById(@PathVariable Long id) {
        Optional<Product> product = productService.getProductById(id);
        if (product.isPresent()) {
            return ResponseEntity.ok(product.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    // Get product by SKU
    @GetMapping("/sku/{sku}")
    public ResponseEntity<?> getProductBySku(@PathVariable String sku) {
        Optional<Product> product = productService.getProductBySku(sku);
        if (product.isPresent()) {
            return ResponseEntity.ok(product.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    // Update product
    @PutMapping("/{id}")
    public ResponseEntity<?> updateProduct(@PathVariable Long id, @RequestBody Product productDetails) {
        try {
            Product updatedProduct = productService.updateProduct(id, productDetails);
            return ResponseEntity.ok(updatedProduct);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error updating product: " + e.getMessage());
        }
    }
    
    // Delete product
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteProduct(@PathVariable Long id) {
        try {
            productService.deleteProduct(id);
            return ResponseEntity.ok("Product deleted successfully");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error deleting product: " + e.getMessage());
        }
    }
    
    // Deactivate product (soft delete)
    @PutMapping("/{id}/deactivate")
    public ResponseEntity<?> deactivateProduct(@PathVariable Long id) {
        try {
            Product product = productService.deactivateProduct(id);
            return ResponseEntity.ok(product);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error deactivating product: " + e.getMessage());
        }
    }
    
    // Get products by category id
    @GetMapping("/category/{id}")
    public ResponseEntity<List<Product>> getProductsByCategoryId(@PathVariable("id") Long categoryId) {
        List<Product> products = productService.getProductsByCategoryId(categoryId);
        return ResponseEntity.ok(products);
    }
    
    // Get products by category slug
    @GetMapping("/category/slug/{slug}")
    public ResponseEntity<List<Product>> getProductsByCategorySlug(@PathVariable String slug) {
        List<Product> products = productService.getProductsByCategorySlug(slug);
        return ResponseEntity.ok(products);
    }
    
    // Get active products by category id
    @GetMapping("/category/{id}/active")
    public ResponseEntity<List<Product>> getActiveProductsByCategoryId(@PathVariable("id") Long categoryId) {
        List<Product> products = productService.getActiveProductsByCategoryId(categoryId);
        return ResponseEntity.ok(products);
    }
    
    // Get products by brand
    @GetMapping("/brand/{brand}")
    public ResponseEntity<List<Product>> getProductsByBrand(@PathVariable String brand) {
        List<Product> products = productService.getProductsByBrand(brand);
        return ResponseEntity.ok(products);
    }
    
    // Get active products
    @GetMapping("/active")
    public ResponseEntity<List<Product>> getActiveProducts() {
        List<Product> products = productService.getActiveProducts();
        return ResponseEntity.ok(products);
    }
    
    // Get featured products
    @GetMapping("/featured")
    public ResponseEntity<List<Product>> getFeaturedProducts() {
        List<Product> products = productService.getFeaturedProducts();
        return ResponseEntity.ok(products);
    }
    
    // Search products
    @GetMapping("/search")
    public ResponseEntity<List<Product>> searchProducts(@RequestParam String keyword) {
        List<Product> products = productService.searchProducts(keyword);
        return ResponseEntity.ok(products);
    }
    
    // Get products by price range
    @GetMapping("/price-range")
    public ResponseEntity<List<Product>> getProductsByPriceRange(
            @RequestParam BigDecimal minPrice, 
            @RequestParam BigDecimal maxPrice) {
        List<Product> products = productService.getProductsByPriceRange(minPrice, maxPrice);
        return ResponseEntity.ok(products);
    }
    
    // Get products by price range and category id
    @GetMapping("/price-range/category/{id}")
    public ResponseEntity<List<Product>> getProductsByPriceRangeAndCategoryId(
            @PathVariable("id") Long categoryId,
            @RequestParam BigDecimal minPrice, 
            @RequestParam BigDecimal maxPrice) {
        List<Product> products = productService.getProductsByPriceRangeAndCategoryId(minPrice, maxPrice, categoryId);
        return ResponseEntity.ok(products);
    }
    
    // Update stock quantity
    @PutMapping("/{id}/stock")
    public ResponseEntity<?> updateStock(@PathVariable Long id, @RequestParam Integer quantity) {
        try {
            Product product = productService.updateStock(id, quantity);
            return ResponseEntity.ok(product);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error updating stock: " + e.getMessage());
        }
    }
    
    // Add stock
    @PutMapping("/{id}/stock/add")
    public ResponseEntity<?> addStock(@PathVariable Long id, @RequestParam Integer quantity) {
        try {
            Product product = productService.addStock(id, quantity);
            return ResponseEntity.ok(product);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error adding stock: " + e.getMessage());
        }
    }
    
    // Reduce stock
    @PutMapping("/{id}/stock/reduce")
    public ResponseEntity<?> reduceStock(@PathVariable Long id, @RequestParam Integer quantity) {
        try {
            Product product = productService.reduceStock(id, quantity);
            return ResponseEntity.ok(product);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error reducing stock: " + e.getMessage());
        }
    }
    
    // Get low stock products
    @GetMapping("/low-stock")
    public ResponseEntity<List<Product>> getLowStockProducts(@RequestParam(defaultValue = "10") Integer threshold) {
        List<Product> products = productService.getLowStockProducts(threshold);
        return ResponseEntity.ok(products);
    }
    
    // Get most expensive products
    @GetMapping("/most-expensive")
    public ResponseEntity<List<Product>> getMostExpensiveProducts() {
        List<Product> products = productService.getMostExpensiveProducts();
        return ResponseEntity.ok(products);
    }
    
    // Get cheapest products
    @GetMapping("/cheapest")
    public ResponseEntity<List<Product>> getCheapestProducts() {
        List<Product> products = productService.getCheapestProducts();
        return ResponseEntity.ok(products);
    }
    
    // Get product count by category id
    @GetMapping("/count/category/{id}")
    public ResponseEntity<Long> getProductCountByCategoryId(@PathVariable("id") Long categoryId) {
        long count = productService.getProductCountByCategoryId(categoryId);
        return ResponseEntity.ok(count);
    }
    
    // Get total active product count
    @GetMapping("/count/active")
    public ResponseEntity<Long> getActiveProductCount() {
        long count = productService.getActiveProductCount();
        return ResponseEntity.ok(count);
    }
    
    // Check if product exists by SKU
    @GetMapping("/exists/sku/{sku}")
    public ResponseEntity<Boolean> existsBySku(@PathVariable String sku) {
        boolean exists = productService.existsBySku(sku);
        return ResponseEntity.ok(exists);
    }
    
    // Check if product exists by name
    @GetMapping("/exists/name/{name}")
    public ResponseEntity<Boolean> existsByName(@PathVariable String name) {
        boolean exists = productService.existsByName(name);
        return ResponseEntity.ok(exists);
    }
}
