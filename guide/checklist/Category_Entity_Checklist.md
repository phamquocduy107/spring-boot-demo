# Category Entity Development Checklist

## 📋 Pre-Development Planning

### 1. Requirements Analysis
- [ ] Define category attributes (name, slug, description, isActive)
- [ ] Decide on hierarchy support (parent-child)
- [ ] Plan SEO needs (unique slug)
- [ ] Plan localization (optional: translations)
- [ ] Plan image/icon metadata (optional)

### 2. Database Design
- [ ] Table name: `categories`
- [ ] Primary key: `id` (IDENTITY)
- [ ] Unique index: `slug` (and optionally name)
- [ ] Self-referencing parent: `parent_id` (nullable)
- [ ] Indexes: `parent_id`, `slug`, `is_active`

## 🏗️ Entity Development Steps

### 3. Create Category Entity Class
- [ ] Create `Category.java` in `src/main/java/com/example/demo/entity/`
- [ ] Imports: `jakarta.persistence.*`, `jakarta.validation.constraints.*`, `java.time.LocalDateTime`

### 4. Define Core Fields
- [ ] `id` (Long) - PK
- [ ] `name` (String, not blank, length 2..100)
- [ ] `slug` (String, lowercase, URL-friendly, unique)
- [ ] `description` (String, optional, length <= 1000)
- [ ] `isActive` (Boolean, default true)
- [ ] `createdAt`, `updatedAt` (LocalDateTime, auto timestamps)

### 5. Relationships
- [ ] `parent` (Category) - `@ManyToOne(fetch = LAZY)`, `@JoinColumn(name = "parent_id")`
- [ ] `children` (List<Category>) - `@OneToMany(mappedBy = "parent")`
- [ ] (Optional) `products` - inverse side if needed for queries

### 6. JPA and Validation
- [ ] `@Entity`, `@Table(name = "categories")`
- [ ] `@Column(unique = true)` on `slug`
- [ ] `@NotBlank`, `@Size` on `name`
- [ ] `@PrePersist` / `@PreUpdate` to manage timestamps and slug normalization

### 7. Utility/Business Methods
- [ ] `isRoot()` - parent == null
- [ ] `getPath()` - build full breadcrumb path (e.g., Electronics > Phones)
- [ ] `activate()` / `deactivate()`

## 🗄️ Repository Layer

### 8. Create Category Repository
- [ ] Create `CategoryRepository.java` extending `JpaRepository<Category, Long>`
- [ ] Methods:
  - [ ] `Optional<Category> findBySlug(String slug)`
  - [ ] `List<Category> findByParentIsNull()` (roots)
  - [ ] `List<Category> findByParent_Id(Long parentId)`
  - [ ] `List<Category> findByIsActiveTrue()`
  - [ ] `boolean existsBySlug(String slug)`
  - [ ] `boolean existsByName(String name)`

## 🎯 Service Layer

### 9. Create Category Service
- [ ] `createCategory(Category category)` - validates unique slug/name
- [ ] `updateCategory(Long id, Category category)`
- [ ] `deleteCategory(Long id)` or soft-delete via `isActive`
- [ ] `getCategoryById(Long id)`, `getBySlug(String slug)`
- [ ] `getRootCategories()`, `getChildren(Long parentId)`
- [ ] `moveCategory(Long id, Long newParentId)` (prevent cycles)
- [ ] `activate/deactivate`

## 🌐 Controller Layer

### 10. Create Category Controller
- [ ] Endpoints:
  - [ ] `POST /api/categories`
  - [ ] `GET /api/categories`
  - [ ] `GET /api/categories/{id}`
  - [ ] `GET /api/categories/slug/{slug}`
  - [ ] `PUT /api/categories/{id}`
  - [ ] `DELETE /api/categories/{id}` or `PUT /api/categories/{id}/deactivate`
  - [ ] `GET /api/categories/{id}/children`
  - [ ] `GET /api/categories/roots`

## 🔗 Wiring with Product

### 11. Update Product to Reference Category
- [ ] Add field `private Category category;`
- [ ] Annotate `@ManyToOne(fetch = LAZY)` + `@JoinColumn(name = "category_id", nullable = false)`
- [ ] Update Product repository query methods to use `category.id`/`category.slug`
- [ ] Update Product controller endpoints to accept `categoryId` or `categorySlug`

## ✅ Testing and Validation

### 12. Unit & Integration Tests
- [ ] Validate slug uniqueness and normalization
- [ ] Validate name constraints
- [ ] Test hierarchy: roots/children and cycle prevention
- [ ] Test CRUD endpoints
- [ ] Test Product queries by category id/slug

## 🚀 Migration (if converting from string)

### 13. Migration Steps
- [ ] Create `categories` table
- [ ] Add `category_id` to `products`
- [ ] Seed categories and map old string values -> category rows
- [ ] Backfill `products.category_id`
- [ ] Remove old `products.category` column

## 📋 Quick Reference

### Essential Category Fields:
```java
- id (Long)
- name (String)
- slug (String, unique)
- description (String)
- parent (Category)
- isActive (Boolean)
- createdAt (LocalDateTime)
- updatedAt (LocalDateTime)
```

### Repository Methods:
```java
findBySlug(String slug)
findByParentIsNull()
findByParent_Id(Long parentId)
findByIsActiveTrue()
existsBySlug(String slug)
```

---

Note: Adjust specifics to match your shop's requirements (SEO, i18n, images).


