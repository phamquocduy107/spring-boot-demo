# API Test Summary

Date: 2025-09-29 21:51:41
Mode: All
Entity: All
BaseUrl: http://localhost:8080
Total: 100
Passed: 99
Failed: 1
Pass Rate: 99%

## User
{
  "update": 200,
  "deleteNoAuth": 401,
  "create": 200,
  "createNoAuth": 401,
  "duplicate": 400,
  "delete": 204,
  "getAll": 200,
  "getOneNoAuth": 401,
  "getAllNoAuth": 401,
  "getOne": 200,
  "updateNoAuth": 401
}

## Product
{
  "getAll": 200,
  "createNoAuth": 401,
  "getOne": 200,
  "getOneNoAuth": 401,
  "targetId": 100,
  "update": 200,
  "page": 200,
  "create": 200,
  "active": 200,
  "delete": null,
  "deleteNoAuth": null,
  "updateNoAuth": 401,
  "duplicate": 400,
  "getAllNoAuth": 401
}

## Category
{
  "getAll": 200,
  "createNoAuth": 401,
  "getOne": 200,
  "getOneNoAuth": 401,
  "roots": 200,
  "targetId": 73,
  "update": 200,
  "page": 200,
  "create": 200,
  "delete": 204,
  "deleteNoAuth": 401,
  "updateNoAuth": 401,
  "duplicate": 400,
  "getAllNoAuth": 401
}

## Cart
{
  "addItem": 200,
  "getNoAuth": 401,
  "clear": 204,
  "clearNoAuth": 401,
  "get": 200,
  "updateQtyNoAuth": 401,
  "removeItem": 204,
  "updateQty": 200,
  "addItemNoAuth": 401,
  "removeItemNoAuth": 401
}

## Order
{
  "updateShippingFee": 200,
  "pageMax": 200,
  "byStatus": 200,
  "updateNotes": 200,
  "getMyOrdersNoAuth": 401,
  "getWithChanges": 200,
  "page": 200,
  "getNeedingAttention": 200,
  "updateTax": 200,
  "getByNumber": 200,
  "getById": 200,
  "getRecent": 200,
  "getByIdNoAuth": 401,
  "getByNumberNoAuth": 401,
  "updateStatus": 200,
  "getMyOrders": 200,
  "createFromCartNoAuth": 401,
  "getStatistics": 200,
  "updateDiscount": 200,
  "createFromCart": 200,
  "updateNotesNoAuth": 401,
  "updateStatusNoAuth": 401,
  "orderNumber": "ORD-20250929-870",
  "targetId": 34
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
