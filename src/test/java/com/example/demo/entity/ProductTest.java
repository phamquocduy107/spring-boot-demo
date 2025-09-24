package com.example.demo.entity;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;

import java.math.BigDecimal;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

public class ProductTest {
    
    private Validator validator;
    private Product product;
    
    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
        
        product = new Product();
        product.setName("Test Product");
        product.setDescription("Test Description");
        product.setSku("TEST-001");
        product.setPrice(new BigDecimal("99.99"));
        product.setStockQuantity(100);
        product.setCategory(new Category("Electronics", "electronics"));
        product.setBrand("TestBrand");
        product.setIsActive(true);
        product.setStatus(Product.ProductStatus.ACTIVE);
    }
    
    @Test
    void testValidProduct() {
        Set<ConstraintViolation<Product>> violations = validator.validate(product);
        assertTrue(violations.isEmpty(), "Valid product should have no violations");
    }
    
    @Test
    void testProductNameValidation() {
        // Test null name
        product.setName(null);
        Set<ConstraintViolation<Product>> violations = validator.validate(product);
        assertFalse(violations.isEmpty(), "Null name should cause validation error");
        
        // Test blank name
        product.setName("");
        violations = validator.validate(product);
        assertFalse(violations.isEmpty(), "Blank name should cause validation error");
        
        // Test too short name
        product.setName("A");
        violations = validator.validate(product);
        assertFalse(violations.isEmpty(), "Name too short should cause validation error");
        
        // Test too long name
        product.setName("A".repeat(101));
        violations = validator.validate(product);
        assertFalse(violations.isEmpty(), "Name too long should cause validation error");
    }
    
    @Test
    void testProductPriceValidation() {
        // Test null price
        product.setPrice(null);
        Set<ConstraintViolation<Product>> violations = validator.validate(product);
        assertFalse(violations.isEmpty(), "Null price should cause validation error");
        
        // Test negative price
        product.setPrice(new BigDecimal("-10.00"));
        violations = validator.validate(product);
        assertFalse(violations.isEmpty(), "Negative price should cause validation error");
        
        // Test zero price
        product.setPrice(BigDecimal.ZERO);
        violations = validator.validate(product);
        assertFalse(violations.isEmpty(), "Zero price should cause validation error");
    }
    
    @Test
    void testProductSkuValidation() {
        // Test null SKU
        product.setSku(null);
        Set<ConstraintViolation<Product>> violations = validator.validate(product);
        assertFalse(violations.isEmpty(), "Null SKU should cause validation error");
        
        // Test blank SKU
        product.setSku("");
        violations = validator.validate(product);
        assertFalse(violations.isEmpty(), "Blank SKU should cause validation error");
    }
    
    @Test
    void testProductStockValidation() {
        // Test negative stock
        product.setStockQuantity(-1);
        Set<ConstraintViolation<Product>> violations = validator.validate(product);
        assertFalse(violations.isEmpty(), "Negative stock should cause validation error");
    }
    
    @Test
    void testProductBusinessLogic() {
        // Test isInStock method
        product.setStockQuantity(10);
        assertTrue(product.isInStock(), "Product with stock should be in stock");
        
        product.setStockQuantity(0);
        assertFalse(product.isInStock(), "Product with no stock should not be in stock");
        
        // Test isOnSale method
        product.setStatus(Product.ProductStatus.ON_SALE);
        assertTrue(product.isOnSale(), "Product with ON_SALE status should be on sale");
        
        product.setStatus(Product.ProductStatus.ACTIVE);
        assertFalse(product.isOnSale(), "Product with ACTIVE status should not be on sale");
        
        // Test getFormattedPrice method
        product.setPrice(new BigDecimal("99.99"));
        assertEquals("$99.99", product.getFormattedPrice(), "Price should be formatted correctly");
    }
    
    @Test
    void testProductStockOperations() {
        product.setStockQuantity(100);
        
        // Test addStock method
        product.addStock(50);
        assertEquals(150, product.getStockQuantity(), "Stock should be added correctly");
        
        // Test reduceStock method
        product.reduceStock(30);
        assertEquals(120, product.getStockQuantity(), "Stock should be reduced correctly");
        
        // Test reduceStock with insufficient stock
        assertThrows(IllegalArgumentException.class, () -> {
            product.reduceStock(200);
        }, "Should throw exception when reducing more stock than available");
        
        // Test addStock with negative quantity
        assertThrows(IllegalArgumentException.class, () -> {
            product.addStock(-10);
        }, "Should throw exception when adding negative stock");
    }
    
    @Test
    void testProductEqualsAndHashCode() {
        Product product1 = new Product();
        product1.setId(1L);
        product1.setName("Test Product");
        
        Product product2 = new Product();
        product2.setId(1L);
        product2.setName("Different Name");
        
        Product product3 = new Product();
        product3.setId(2L);
        product3.setName("Test Product");
        
        // Test equals
        assertEquals(product1, product2, "Products with same ID should be equal");
        assertNotEquals(product1, product3, "Products with different ID should not be equal");
        
        // Test hashCode
        assertEquals(product1.hashCode(), product2.hashCode(), "Products with same ID should have same hashCode");
    }
    
    @Test
    void testProductToString() {
        String toString = product.toString();
        assertTrue(toString.contains("Product{"), "toString should contain class name");
        assertTrue(toString.contains("name='Test Product'"), "toString should contain name");
        assertTrue(toString.contains("sku='TEST-001'"), "toString should contain SKU");
    }
    
    @Test
    void testProductConstructor() {
        Category category = new Category("Books", "books");
        Product newProduct = new Product("New Product", "New Description", "NEW-001", 
                                       new BigDecimal("199.99"), 50, category);
        
        assertEquals("New Product", newProduct.getName());
        assertEquals("New Description", newProduct.getDescription());
        assertEquals("NEW-001", newProduct.getSku());
        assertEquals(new BigDecimal("199.99"), newProduct.getPrice());
        assertEquals(50, newProduct.getStockQuantity());
        assertEquals("Books", newProduct.getCategory().getName());
        assertNotNull(newProduct.getCreatedAt());
        assertNotNull(newProduct.getUpdatedAt());
    }
}
