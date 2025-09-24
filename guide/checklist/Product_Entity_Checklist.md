# Product Entity Development Checklist

## 📋 Pre-Development Planning

### 1. Requirements Analysis
- [ ] **Define product attributes** - Identify essential fields for a shop product
- [ ] **Determine data types** - Choose appropriate Java types for each field
- [ ] **Plan relationships** - Identify relationships with other entities (User, Category, Order, etc.)
- [ ] **Consider business rules** - Define validation rules and constraints
- [ ] **Plan for scalability** - Consider future requirements and extensibility

### 2. Database Design
- [ ] **Table naming** - Follow consistent naming convention (e.g., `products`)
- [ ] **Primary key strategy** - Use auto-generated ID (IDENTITY)
- [ ] **Index planning** - Identify fields that need database indexes
- [ ] **Foreign key relationships** - Plan relationships with other tables

## 🏗️ Entity Development Steps

### 3. Create Product Entity Class
- [ ] **Create Product.java** in `src/main/java/com/example/demo/entity/`
- [ ] **Add package declaration** - `package com.example.demo.entity;`
- [ ] **Add necessary imports**:
  - [ ] `jakarta.persistence.*` (Entity, Id, GeneratedValue, etc.)
  - [ ] `jakarta.validation.constraints.*` (validation annotations)
  - [ ] `java.math.BigDecimal` (for price)
  - [ ] `java.time.LocalDateTime` (for timestamps)
  - [ ] `java.util.List` (if using collections)

### 4. Define Core Fields
- [ ] **Primary Key**:
  - [ ] `@Id` annotation
  - [ ] `@GeneratedValue(strategy = GenerationType.IDENTITY)`
  - [ ] `private Long id;`

- [ ] **Basic Product Information**:
  - [ ] `name` (String) - Product name with validation
  - [ ] `description` (String) - Product description
  - [ ] `sku` (String) - Stock Keeping Unit (unique identifier)
  - [ ] `price` (BigDecimal) - Product price with precision
  - [ ] `stockQuantity` (Integer) - Available stock quantity

- [ ] **Product Details**:
  - [ ] `category` (Category) - ManyToOne reference to category entity
  - [ ] `brand` (String) - Product brand
  - [ ] `weight` (BigDecimal) - Product weight
  - [ ] `dimensions` (String) - Product dimensions
  - [ ] `color` (String) - Product color
  - [ ] `size` (String) - Product size

- [ ] **Status and Visibility**:
  - [ ] `isActive` (Boolean) - Product availability status
  - [ ] `isFeatured` (Boolean) - Featured product flag
  - [ ] `status` (String) - Product status (ACTIVE, INACTIVE, DISCONTINUED)

- [ ] **Timestamps**:
  - [ ] `createdAt` (LocalDateTime) - Creation timestamp
  - [ ] `updatedAt` (LocalDateTime) - Last update timestamp

### 5. Add JPA Annotations
- [ ] **Class-level annotations**:
  - [ ] `@Entity` annotation
  - [ ] `@Table(name = "products")` annotation

- [ ] **Field-level annotations**:
  - [ ] `@Column` annotations for custom column names (except relations)
  - [ ] `@Temporal` for date/time fields if needed
  - [ ] `@Enumerated` for enum fields if using enums

### 6. Add Validation Annotations
- [ ] **Required field validations**:
  - [ ] `@NotNull` for mandatory fields
  - [ ] `@NotBlank` for non-empty strings
  - [ ] `@Size` for string length constraints
  - [ ] `@Email` for email fields (if applicable)
  - [ ] `@DecimalMin` for minimum price values
  - [ ] `@Min` for minimum quantity values
  - [ ] `@Max` for maximum values

- [ ] **Custom validations**:
  - [ ] `@Unique` for unique fields (SKU)
  - [ ] Custom validation messages

### 7. Add Relationships
- [ ] **Many-to-One relationships**:
  - [ ] `@ManyToOne(fetch = FetchType.LAZY)` with `@JoinColumn(name = "category_id", nullable = false)` for category relationship
  - [ ] `@ManyToOne` for vendor/supplier relationship

- [ ] **One-to-Many relationships**:
  - [ ] `@OneToMany` for product images
  - [ ] `@OneToMany` for product reviews

- [ ] **Many-to-Many relationships**:
  - [ ] `@ManyToMany` for product tags
  - [ ] `@ManyToMany` for related products

### 8. Implement Constructors
- [ ] **Default constructor** - Required by JPA
- [ ] **Parameterized constructor** - For easy object creation
- [ ] **All-args constructor** - Optional, for convenience

### 9. Implement Getters and Setters
- [ ] **Getter methods** - For all fields
- [ ] **Setter methods** - For all fields
- [ ] **Follow JavaBean conventions**

### 10. Add Utility Methods
- [ ] **toString()** method - For debugging and logging
- [ ] **equals() and hashCode()** - For proper object comparison
- [ ] **Business logic methods**:
  - [ ] `isInStock()` - Check if product is available
  - [ ] `isOnSale()` - Check if product is on sale
  - [ ] `getFormattedPrice()` - Format price for display

## 🗄️ Repository Layer

### 11. Create Product Repository
- [ ] **Create ProductRepository.java** in `src/main/java/com/example/demo/repository/`
- [ ] **Extend JpaRepository** - `JpaRepository<Product, Long>`
- [ ] **Add custom query methods**:
  - [ ] `findByCategory_Id(Long categoryId)`
  - [ ] `findByCategory_Slug(String slug)`
  - [ ] `findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice)`
  - [ ] `findByIsActiveTrue()`
  - [ ] `findByNameContainingIgnoreCase(String name)`
  - [ ] `findBySku(String sku)`

## 🎯 Service Layer

### 12. Create Product Service
- [ ] **Create ProductService.java** in `src/main/java/com/example/demo/service/`
- [ ] **Implement business logic**:
  - [ ] `createProduct(Product product)`
  - [ ] `updateProduct(Long id, Product product)`
  - [ ] `deleteProduct(Long id)`
  - [ ] `getProductById(Long id)`
  - [ ] `getAllProducts()`
  - [ ] `getProductsByCategoryId(Long categoryId)`
  - [ ] `getProductsByCategorySlug(String slug)`
  - [ ] `searchProducts(String keyword)`
  - [ ] `updateStock(Long id, Integer quantity)`

## 🌐 Controller Layer

### 13. Create Product Controller
- [ ] **Create ProductController.java** in `src/main/java/com/example/demo/controller/`
- [ ] **Add REST endpoints**:
  - [ ] `POST /api/products` - Create product
  - [ ] `GET /api/products` - Get all products
  - [ ] `GET /api/products/{id}` - Get product by ID
  - [ ] `PUT /api/products/{id}` - Update product
  - [ ] `DELETE /api/products/{id}` - Delete product
  - [ ] `GET /api/products/category/{id}` - Get products by category id
  - [ ] `GET /api/products/category/slug/{slug}` - Get products by category slug
  - [ ] `GET /api/products/search` - Search products

## ✅ Testing and Validation

### 14. Unit Testing
- [ ] **Create ProductTest.java** in `src/test/java/`
- [ ] **Test entity creation** - Valid and invalid data
- [ ] **Test validation annotations** - Ensure constraints work
- [ ] **Test business logic methods** - Custom methods functionality
- [ ] **Test repository methods** - Database operations

### 15. Integration Testing
- [ ] **Test REST endpoints** - Controller integration
- [ ] **Test database operations** - Repository integration
- [ ] **Test service layer** - Business logic integration
- [ ] Security for MVC tests: either `@AutoConfigureMockMvc(addFilters = false)` or use `@WithMockUser`.
- [ ] Ensure test DB driver present: add `testRuntimeOnly 'com.h2database:h2'` in build.gradle.

## 📝 Documentation

### 16. Code Documentation
- [ ] **Add JavaDoc comments** - Class and method documentation
- [ ] **Add inline comments** - Complex business logic
- [ ] **Update README** - Document new entity and endpoints

## 🚀 Deployment Considerations

### 17. Database Migration
- [ ] **Create migration script** - If using Flyway/Liquibase
- [ ] **Test migration** - Ensure database changes work correctly
- [ ] **Backup strategy** - Before applying changes

### 18. Performance Optimization
- [ ] **Add database indexes** - For frequently queried fields
- [ ] **Consider caching** - For frequently accessed products
- [ ] **Optimize queries** - Use appropriate fetch strategies

## 🔧 Additional Considerations

### 19. Security
- [ ] **Add authorization** - Control who can create/update products
- [ ] **Input sanitization** - Prevent injection attacks
- [ ] **Audit logging** - Track product changes

### 20. Monitoring and Logging
- [ ] **Add logging** - For product operations
- [ ] **Add metrics** - Track product-related metrics
- [ ] **Error handling** - Proper exception handling

---

## 📋 Quick Reference

### Essential Product Fields:
```java
- id (Long) - Primary key
- name (String) - Product name
- description (String) - Product description  
- sku (String) - Unique identifier
- price (BigDecimal) - Product price
- stockQuantity (Integer) - Available stock
- category (Category) - ManyToOne link to category
- isActive (Boolean) - Availability status
- createdAt (LocalDateTime) - Creation time
- updatedAt (LocalDateTime) - Last update time
```

### Key Annotations:
```java
@Entity
@Table(name = "products")
@Id @GeneratedValue(strategy = GenerationType.IDENTITY)
@NotNull, @NotBlank, @Size, @DecimalMin
@ManyToOne, @OneToMany, @ManyToMany
```

### Repository Methods:
```java
findByCategory_Id(Long categoryId)
findByCategory_Slug(String slug)
findByPriceBetween(BigDecimal min, BigDecimal max)
findByIsActiveTrue()
findByNameContainingIgnoreCase(String name)
```

---

**Note**: This checklist follows the existing patterns in your Spring Boot application. Adjust the specific requirements based on your shop's business needs and technical requirements.


