# Cart API Test Guide

This guide provides comprehensive testing instructions for the Cart API endpoints.

## Prerequisites

1. **Application Running**: Ensure the Spring Boot application is running on `http://localhost:8080`
2. **Database Setup**: Make sure you have some test products in the database
3. **Redis Running**: Ensure Redis is running for caching functionality

## Test Scripts

### PowerShell Script (Windows)
```powershell
# Run the PowerShell test script
.\scripts\test-cart-apis.ps1
```

### Bash Script (Linux/Mac)
```bash
# Make script executable and run
chmod +x scripts/test-cart-apis.sh
./scripts/test-cart-apis.sh
```

## Manual API Testing

### 1. Get Cart
```bash
GET /api/cart?userId=1
```
**Expected**: 404 for empty cart, 200 with cart data for existing cart

### 2. Add Item to Cart
```bash
POST /api/cart/items?userId=1&productId=1&quantity=2
```
**Expected**: 200 with updated cart data

### 3. Update Item Quantity
```bash
PUT /api/cart/items/1?userId=1&quantity=5
```
**Expected**: 200 with updated cart data

### 4. Remove Item from Cart
```bash
DELETE /api/cart/items/1?userId=1
```
**Expected**: 204 No Content

### 5. Clear Cart
```bash
DELETE /api/cart?userId=1
```
**Expected**: 204 No Content

## Test Scenarios

### Scenario 1: Complete Cart Workflow
1. Get empty cart (404)
2. Add product 1 with quantity 2 (200)
3. Add product 2 with quantity 1 (200)
4. Update product 1 quantity to 5 (200)
5. Remove product 2 (204)
6. Clear entire cart (204)
7. Verify empty cart (404)

### Scenario 2: Error Handling
1. Add non-existent product (should fail)
2. Add item with zero quantity (should fail)
3. Update quantity of non-existent item (should fail)

## Expected Response Format

### Cart Response
```json
{
  "id": 1,
  "user": {
    "id": 1,
    "email": "user@example.com"
  },
  "items": [
    {
      "id": 1,
      "product": {
        "id": 1,
        "name": "Test Product",
        "price": 29.99
      },
      "quantity": 2,
      "priceAtAdd": 29.99
    }
  ],
  "subtotal": 59.98,
  "total": 59.98,
  "isActive": true,
  "createdAt": "2024-01-01T10:00:00",
  "updatedAt": "2024-01-01T10:00:00"
}
```

## Redis Cache Testing

### Verify Cache Behavior
1. Add item to cart
2. Check Redis for cached cart: `redis-cli GET "cart:1"`
3. Update cart
4. Verify cache is updated
5. Clear cart
6. Verify cache is evicted

### Cache TTL Testing
1. Add item to cart
2. Wait 30+ minutes
3. Try to get cart from cache (should miss and fetch from DB)

## Performance Testing

### Load Testing with curl
```bash
# Test concurrent cart operations
for i in {1..10}; do
  curl -X POST "http://localhost:8080/api/cart/items?userId=1&productId=1&quantity=1" &
done
wait
```

## Troubleshooting

### Common Issues

1. **404 on Get Cart**: Normal for empty cart
2. **500 on Add Item**: Check if product exists in database
3. **Redis Connection Error**: Ensure Redis is running
4. **Database Constraint Error**: Check foreign key relationships

### Debug Commands

```bash
# Check application logs
tail -f logs/application.log

# Check Redis
redis-cli ping
redis-cli keys "cart:*"

# Check database
# Connect to your database and verify data
```

## Test Data Setup

### Create Test Products
```sql
INSERT INTO categories (name, slug, description, is_active, created_at, updated_at) 
VALUES ('Electronics', 'electronics', 'Electronic devices', true, NOW(), NOW());

INSERT INTO products (name, description, sku, price, stock, brand, weight, dimensions, color, size, is_active, is_featured, status, category_id, created_at, updated_at)
VALUES 
('Test Product 1', 'Description 1', 'SKU001', 29.99, 100, 'Brand A', 1.5, '10x10x5', 'Red', 'M', true, true, 'ACTIVE', 1, NOW(), NOW()),
('Test Product 2', 'Description 2', 'SKU002', 49.99, 50, 'Brand B', 2.0, '15x15x8', 'Blue', 'L', true, false, 'ACTIVE', 1, NOW(), NOW());
```

## Success Criteria

✅ All API endpoints respond correctly  
✅ Cart operations work as expected  
✅ Redis caching functions properly  
✅ Error handling works correctly  
✅ Database transactions are consistent  
✅ Performance is acceptable  

## Next Steps

After successful testing:
1. Document any issues found
2. Update API documentation if needed
3. Consider adding more comprehensive unit tests
4. Set up automated testing in CI/CD pipeline
