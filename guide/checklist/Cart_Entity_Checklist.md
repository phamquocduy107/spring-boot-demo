# Cart Entity Development Checklist (with Redis Cache)

## 📋 Planning
- [ ] Define storage model: DB as source of truth + Redis cache-aside
- [ ] Decide TTL for cart cache (e.g., 30 minutes inactive, 24h max)
- [ ] Identify cart scope: per `userId` (registered) and `sessionId` (guest)
- [ ] Choose cache key scheme: `cart:{userId}` or `cart:guest:{sessionId}`
- [ ] Serialization: Jackson JSON for Redis values

## 🗄️ Database Design
- [ ] Table `carts` (id, user_id nullable for guest, totals, is_active, created_at, updated_at)
- [ ] Table `cart_items` (id, cart_id, product_id, quantity, price_at_add)
- [ ] FKs: `cart_items.cart_id -> carts.id`, `cart_items.product_id -> products.id`
- [ ] Indexes: `carts.user_id`, `cart_items.cart_id`, `cart_items.product_id`

## 🏗️ Entities
- [ ] Create `Cart` entity
  - [ ] Fields: id, user (ManyToOne User, nullable), items (OneToMany CartItem), subtotal, total, isActive, createdAt, updatedAt
  - [ ] Methods: `addItem(product, qty)`, `removeItem(productId)`, `updateQty(productId, qty)`, `recalculateTotals()`
- [ ] Create `CartItem` entity
  - [ ] Fields: id, cart (ManyToOne), product (ManyToOne), quantity, priceAtAdd
  - [ ] Validation: qty >= 1, product not null
- [ ] Validation on `Cart`
  - [ ] items not empty (on checkout), totals >= 0

## 🔌 Repositories
- [ ] `CartRepository extends JpaRepository<Cart, Long>`
  - [ ] `Optional<Cart> findByUser_IdAndIsActiveTrue(Long userId)`
- [ ] `CartItemRepository` (optional) for bulk ops

## 🧠 Service Layer (Cache-Aside Strategy)
- [ ] `CartService`
  - [ ] `getActiveCartForUser(userId)`:
    - [ ] Try Redis `cart:{userId}`
    - [ ] Fallback DB, then populate cache
  - [ ] `addItem(userId, productId, qty)`:
    - [ ] Load cart (cache/db), modify, save DB, update cache
  - [ ] `updateItemQty(userId, productId, qty)` (qty=0 => remove)
  - [ ] `removeItem(userId, productId)`
  - [ ] `clearCart(userId)` (DB + evict cache)
  - [ ] `mergeGuestCart(sessionId, userId)` (on login)
  - [ ] Evict/refresh cache on any mutation
  - [ ] Recalculate totals on each mutation
- [ ] Handle product price changes (price_at_add for reference, recalc using current price if needed)

## 🌐 Controller Layer
- [ ] Endpoints `/api/cart` (auth required; add guest endpoints if needed)
  - [ ] `GET /api/cart` – get active cart
  - [ ] `POST /api/cart/items` – add item {productId, quantity}
  - [ ] `PUT /api/cart/items/{productId}` – update quantity
  - [ ] `DELETE /api/cart/items/{productId}` – remove item
  - [ ] `DELETE /api/cart` – clear cart

## 🚀 Redis Configuration
- [ ] Add dependency: `spring-boot-starter-data-redis`
- [ ] Configure Redis connection (host, port, password via properties)
- [ ] `RedisTemplate<String, CartDto>` with `Jackson2JsonRedisSerializer`
- [ ] Enable caching: `@EnableCaching` (if using Cache Abstraction)
- [ ] TTL policy: set per-key TTL on writes (e.g., 30m)
- [ ] Namespacing: `cart:` prefix; avoid key collisions

## 🧱 DTOs & Mapping
- [ ] `CartDto` (id, items, totals) and `CartItemDto`
- [ ] MapStruct or manual mappers between Entity ↔ DTO
- [ ] Use DTOs for Redis to avoid lazy-loading issues

## 🧪 Testing
- [ ] Unit tests for `Cart` and `CartItem` entities (validation, totals)
- [ ] Service tests (mock Redis + Repo): cache hit/miss, write-through behavior, eviction
- [ ] Integration tests with Embedded Redis (or Testcontainers Redis)
- [ ] Controller tests: add/update/remove/clear flows
- [ ] Concurrency tests for concurrent item updates (optional)

## 🔐 Security
- [ ] Require authenticated user for `/api/cart` (or handle guest carts via sessionId header)
- [ ] In tests: disable filters or use `@WithMockUser`

## ⚙️ Ops & Maintenance
- [ ] Cache invalidation strategies on product deletion or price change
- [ ] Observability: metrics (cache hit rate), logs on cache errors
- [ ] Fallback behavior if Redis is down (serve DB; degrade gracefully)

## 📦 Gradle Dependencies (add as needed)
- [ ] `implementation 'org.springframework.boot:spring-boot-starter-data-redis'`
- [ ] `testImplementation 'it.ozimov:embedded-redis:0.7.3'` (or Testcontainers Redis)

## ✅ Done Criteria
- [ ] All entity/service/controller tests pass
- [ ] Redis cache keys populated and TTL works
- [ ] Cart flows function with and without cache (graceful fallback)
- [ ] Documentation for cache keys, TTL, and invalidation
