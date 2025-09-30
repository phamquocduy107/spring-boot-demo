# API Test Summary

Date: 2025-09-30 10:43:02
Mode: All
Entity: All
BaseUrl: http://localhost:8080
Total: 136
Passed: 135
Failed: 1
Pass Rate: 99.26%

## User
{
  "createNoAuth": 401,
  "updateNoAuth": 401,
  "create": 200,
  "getAll": 200,
  "getOne": 200,
  "duplicate": 400,
  "update": 200,
  "getAllNoAuth": 401,
  "getOneNoAuth": 401,
  "delete": 204,
  "deleteNoAuth": 401
}

## Product
{
  "getAll": 200,
  "targetId": 109,
  "deleteNoAuth": null,
  "createNoAuth": 401,
  "page": 200,
  "update": 200,
  "delete": null,
  "getOneNoAuth": 401,
  "create": 200,
  "duplicate": 400,
  "getAllNoAuth": 401,
  "getOne": 200,
  "active": 200,
  "updateNoAuth": 401
}

## Category
{
  "roots": 200,
  "getAll": 200,
  "targetId": 84,
  "deleteNoAuth": 401,
  "createNoAuth": 401,
  "page": 200,
  "update": 200,
  "delete": 204,
  "getOneNoAuth": 401,
  "create": 200,
  "duplicate": 400,
  "getAllNoAuth": 401,
  "getOne": 200,
  "updateNoAuth": 401
}

## Cart
{
  "updateQty": 200,
  "get": 200,
  "addItem": 200,
  "clear": 204,
  "clearNoAuth": 401,
  "addItemNoAuth": 401,
  "updateQtyNoAuth": 401,
  "getNoAuth": 401,
  "removeItemNoAuth": 401,
  "removeItem": 204
}

## Order
{
  "orderNumber": "ORD-20250930-213",
  "getByNumberNoAuth": 401,
  "getMyOrders": 200,
  "getWithChanges": 200,
  "updateNotes": 200,
  "updateShippingFee": 200,
  "targetId": 43,
  "updateNotesNoAuth": 401,
  "getRecent": 200,
  "updateStatus": 200,
  "updateStatusNoAuth": 401,
  "getMyOrdersNoAuth": 401,
  "updateTax": 200,
  "pageMax": 200,
  "createFromCart": 200,
  "byStatus": 200,
  "updateDiscount": 200,
  "getNeedingAttention": 200,
  "getStatistics": 200,
  "getByIdNoAuth": 401,
  "getByNumber": 200,
  "page": 200,
  "getById": 200,
  "createFromCartNoAuth": 401
}

## Recommendation
{
  "analyticsStatus": 200,
  "bestseller": 200,
  "trending": 200,
  "invalidLimit": 422,
  "noAuth": 401,
  "dashboard": 200,
  "withLimit": 200,
  "largeLimit": 200,
  "withSeed": 200,
  "withCategory": 200,
  "readiness": 200,
  "withActiveOnly": 200,
  "health": 200,
  "invalidUserId": 422,
  "invalidCategory": 422,
  "hybrid": 200,
  "basic": 200
}
## Analytics
{
  "dashboard": 200,
  "health": 200,
  "trending": 200,
  "categories": 200,
  "readiness": 200,
  "bestsellers": 200
}
## Search
{
  "priceRange": 200,
  "health": 200,
  "reindex": 200,
  "basic": 200,
  "sortByPrice": 200,
  "categoryFilter": 200
}

## Expected vs Actual

### User
- Create: expected 200, actual: 200
- Duplicate: expected 400, actual: 400
- Create (no token): expected 401/403, actual: 401
- GetAll: expected 200, actual: 200
- GetAll (no token): expected 401/403, actual: 401
- Get by Id: expected 200, actual: 200
- Get by Id (no token): expected 401/403, actual: 401
- Update: expected 200, actual: 200
- Update (no token): expected 401/403, actual: 401
- Delete: expected 204, actual: 204
- Delete (no token): expected 401/403, actual: 401

### Product
- Create: expected 201/200, actual: 200
- Duplicate SKU: expected 400, actual: 400
- Create (no token): expected 401/403, actual: 401
- GetAll: expected 200, actual: 200
- GetAll (no token): expected 401/403, actual: 401
- Get by Id: expected 200, actual: 200
- Get by Id (no token): expected 401/403, actual: 401
- Update: expected 200, actual: 200
- Update (no token): expected 401/403, actual: 401
- Delete: expected 200/204, actual: 
- Delete (no token): expected 401/403, actual: 

### Category
- Create: expected 201/200, actual: 200
- Duplicate Slug: expected 400, actual: 400
- Create (no token): expected 401/403, actual: 401
- GetAll Active: expected 200, actual: 200
- GetAll Active (no token): expected 401/403, actual: 401
- Get by Id: expected 200, actual: 200
- Get by Id (no token): expected 401/403, actual: 401
- Update: expected 200, actual: 200
- Update (no token): expected 401/403, actual: 401
- Delete: expected 200/204, actual: 204
- Delete (no token): expected 401/403, actual: 401

### Cart
- Get: expected 200/404, actual: 200
- Get (no token): expected 401/403, actual: 401
- Add Item: expected 200, actual: 200
- Add Item (no token): expected 401/403, actual: 401
- Update Quantity: expected 200, actual: 200
- Update Quantity (no token): expected 401/403, actual: 401
- Remove Item: expected 200/204, actual: 204
- Remove Item (no token): expected 401/403, actual: 401
- Clear: expected 200/204, actual: 204
- Clear (no token): expected 401/403, actual: 401

### Order
- Create from Cart: expected 200/201, actual: 200
- Create from Cart (no token): expected 401/403, actual: 401
- Get by ID: expected 200, actual: 200
- Get by ID (no token): expected 401/403, actual: 401
- Get by Number: expected 200, actual: 200
- Get by Number (no token): expected 401/403, actual: 401
- Get My Orders: expected 200, actual: 200
- Get My Orders (no token): expected 401/403, actual: 401
- Update Status: expected 200, actual: 200
- Update Status (no token): expected 401/403, actual: 401
- Update Shipping Fee: expected 200, actual: 200
- Update Tax: expected 200, actual: 200
- Update Discount: expected 200, actual: 200
- Update Notes: expected 200, actual: 200
- Update Notes (no token): expected 401/403, actual: 401
- Get with Changes: expected 200, actual: 200
- Get Needing Attention: expected 200, actual: 200
- Get Recent: expected 200, actual: 200
- Get Statistics: expected 200, actual: 200

### Recommendation
- Health: expected 200, actual: 200
- Readiness: expected 200, actual: 200
- Basic: expected 200, actual: 200
- With Limit: expected 200, actual: 200
- With Category: expected 200, actual: 200
- With Active Only: expected 200, actual: 200
- With Seed: expected 200, actual: 200
- Invalid User ID: expected 422, actual: 422
- Invalid Limit: expected 422, actual: 422
- Invalid Category: expected 422, actual: 422
- No Token: expected 401/403, actual: 401
- Analytics Status: expected 200, actual: 200
- Bestseller Recommendations: expected 200, actual: 200
- Trending Recommendations: expected 200, actual: 200
- Hybrid Recommendations: expected 200, actual: 200
- Dashboard Recommendations: expected 200, actual: 200
- Large Limit Recommendations: expected 200, actual: 200
### Analytics
- Health: expected 200, actual: 200
- Readiness: expected 200, actual: 200
- Bestsellers: expected 200, actual: 200
- Trending: expected 200, actual: 200
- Categories: expected 200, actual: 200
- Dashboard: expected 200, actual: 200
### Search
- Health: expected 200, actual: 200
- Reindex: expected 200, actual: 200
- Basic Search: expected 200, actual: 200
- Price Range: expected 200, actual: 200
- Category Filter: expected 200, actual: 200
- Sort by Price: expected 200, actual: 200
