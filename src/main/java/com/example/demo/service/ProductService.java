package com.example.demo.service;

import com.example.demo.entity.Product;
import com.example.demo.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class ProductService {
    
    @Autowired
    private ProductRepository productRepository;
    
    // Create a new product
    public Product createProduct(Product product) {
        // Validate SKU uniqueness
        if (productRepository.existsBySku(product.getSku())) {
            throw new IllegalArgumentException("Product with SKU '" + product.getSku() + "' already exists");
        }
        
        // Validate name uniqueness
        if (productRepository.existsByName(product.getName())) {
            throw new IllegalArgumentException("Product with name '" + product.getName() + "' already exists");
        }
        
        return productRepository.save(product);
    }
    
    // Get all products
    @Transactional(readOnly = true)
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }
    
    // Get product by ID
    @Transactional(readOnly = true)
    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }
    
    // Get product by SKU
    @Transactional(readOnly = true)
    public Optional<Product> getProductBySku(String sku) {
        return productRepository.findBySku(sku);
    }
    
    // Update product (partial update: only apply non-null fields)
    public Product updateProduct(Long id, Product productDetails) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Product not found with id: " + id));

        // SKU
        if (productDetails.getSku() != null && !product.getSku().equals(productDetails.getSku())) {
            Optional<Product> otherBySku = productRepository.findBySku(productDetails.getSku());
            if (otherBySku.isPresent() && !otherBySku.get().getId().equals(id)) {
                throw new IllegalArgumentException("Product with SKU '" + productDetails.getSku() + "' already exists");
            }
            product.setSku(productDetails.getSku());
        }

        // Name
        if (productDetails.getName() != null && !product.getName().equals(productDetails.getName())) {
            if (productRepository.existsByName(productDetails.getName())) {
                throw new IllegalArgumentException("Product with name '" + productDetails.getName() + "' already exists");
            }
            product.setName(productDetails.getName());
        }

        if (productDetails.getDescription() != null) {
            product.setDescription(productDetails.getDescription());
        }
        if (productDetails.getPrice() != null) {
            product.setPrice(productDetails.getPrice());
        }
        if (productDetails.getStockQuantity() != null) {
            product.setStockQuantity(productDetails.getStockQuantity());
        }
        if (productDetails.getCategory() != null) {
            product.setCategory(productDetails.getCategory());
        }
        if (productDetails.getBrand() != null) {
            product.setBrand(productDetails.getBrand());
        }
        if (productDetails.getWeight() != null) {
            product.setWeight(productDetails.getWeight());
        }
        if (productDetails.getDimensions() != null) {
            product.setDimensions(productDetails.getDimensions());
        }
        if (productDetails.getColor() != null) {
            product.setColor(productDetails.getColor());
        }
        if (productDetails.getSize() != null) {
            product.setSize(productDetails.getSize());
        }
        if (productDetails.getIsActive() != null) {
            product.setIsActive(productDetails.getIsActive());
        }
        if (productDetails.getIsFeatured() != null) {
            product.setIsFeatured(productDetails.getIsFeatured());
        }
        if (productDetails.getStatus() != null) {
            product.setStatus(productDetails.getStatus());
        }

        return productRepository.save(product);
    }
    
    // Delete product
    public void deleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Product not found with id: " + id));
        
        productRepository.delete(product);
    }
    
    // Soft delete product (set as inactive)
    public Product deactivateProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Product not found with id: " + id));
        
        product.setIsActive(false);
        product.setStatus(Product.ProductStatus.INACTIVE);
        
        return productRepository.save(product);
    }
    
    // Get products by category
    @Transactional(readOnly = true)
    public List<Product> getProductsByCategoryId(Long categoryId) {
        return productRepository.findByCategory_Id(categoryId);
    }

    @Transactional(readOnly = true)
    public List<Product> getProductsByCategorySlug(String slug) {
        return productRepository.findByCategory_Slug(slug);
    }
    
    // Get active products by category
    @Transactional(readOnly = true)
    public List<Product> getActiveProductsByCategoryId(Long categoryId) {
        return productRepository.findByCategory_IdAndIsActiveTrue(categoryId);
    }
    
    // Get products by brand
    @Transactional(readOnly = true)
    public List<Product> getProductsByBrand(String brand) {
        return productRepository.findByBrand(brand);
    }
    
    // Get active products
    @Transactional(readOnly = true)
    public List<Product> getActiveProducts() {
        return productRepository.findByIsActiveTrue();
    }
    
    // Get featured products
    @Transactional(readOnly = true)
    public List<Product> getFeaturedProducts() {
        return productRepository.findByIsFeaturedTrue();
    }
    
    // Search products by keyword
    @Transactional(readOnly = true)
    public List<Product> searchProducts(String keyword) {
        return productRepository.searchProductsByKeyword(keyword);
    }
    
    // Get products by price range
    @Transactional(readOnly = true)
    public List<Product> getProductsByPriceRange(BigDecimal minPrice, BigDecimal maxPrice) {
        return productRepository.findByPriceBetween(minPrice, maxPrice);
    }
    
    // Get products by price range and category id
    @Transactional(readOnly = true)
    public List<Product> getProductsByPriceRangeAndCategoryId(BigDecimal minPrice, BigDecimal maxPrice, Long categoryId) {
        return productRepository.findByPriceBetweenAndCategory_Id(minPrice, maxPrice, categoryId);
    }
    
    // Update stock quantity
    public Product updateStock(Long id, Integer quantity) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Product not found with id: " + id));
        
        if (quantity < 0) {
            throw new IllegalArgumentException("Stock quantity cannot be negative");
        }
        
        product.setStockQuantity(quantity);
        
        // Update status based on stock
        if (quantity == 0) {
            product.setStatus(Product.ProductStatus.OUT_OF_STOCK);
        } else if (product.getStatus() == Product.ProductStatus.OUT_OF_STOCK) {
            product.setStatus(Product.ProductStatus.ACTIVE);
        }
        
        return productRepository.save(product);
    }
    
    // Add stock
    public Product addStock(Long id, Integer quantity) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Product not found with id: " + id));
        
        if (quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be positive");
        }
        
        product.addStock(quantity);
        
        // Update status if product was out of stock
        if (product.getStatus() == Product.ProductStatus.OUT_OF_STOCK) {
            product.setStatus(Product.ProductStatus.ACTIVE);
        }
        
        return productRepository.save(product);
    }
    
    // Reduce stock
    public Product reduceStock(Long id, Integer quantity) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Product not found with id: " + id));
        
        if (quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be positive");
        }
        
        if (product.getStockQuantity() < quantity) {
            throw new IllegalArgumentException("Insufficient stock. Available: " + product.getStockQuantity());
        }
        
        product.reduceStock(quantity);
        
        // Update status if out of stock
        if (product.getStockQuantity() == 0) {
            product.setStatus(Product.ProductStatus.OUT_OF_STOCK);
        }
        
        return productRepository.save(product);
    }
    
    // Get low stock products
    @Transactional(readOnly = true)
    public List<Product> getLowStockProducts(Integer threshold) {
        return productRepository.findLowStockProducts(threshold);
    }
    
    // Get most expensive products
    @Transactional(readOnly = true)
    public List<Product> getMostExpensiveProducts() {
        return productRepository.findMostExpensiveProducts();
    }
    
    // Get cheapest products
    @Transactional(readOnly = true)
    public List<Product> getCheapestProducts() {
        return productRepository.findCheapestProducts();
    }
    
    // Get product count by category
    @Transactional(readOnly = true)
    public long getProductCountByCategoryId(Long categoryId) {
        return productRepository.countByCategory_Id(categoryId);
    }
    
    // Get total active product count
    @Transactional(readOnly = true)
    public long getActiveProductCount() {
        return productRepository.countByIsActiveTrue();
    }
    
    // Check if product exists by SKU
    @Transactional(readOnly = true)
    public boolean existsBySku(String sku) {
        return productRepository.existsBySku(sku);
    }
    
    // Check if product exists by name
    @Transactional(readOnly = true)
    public boolean existsByName(String name) {
        return productRepository.existsByName(name);
    }
}
