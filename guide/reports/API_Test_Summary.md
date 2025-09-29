# API Test Summary

Date: 2025-09-29 15:54:37
Mode: All
Entity: All
BaseUrl: http://localhost:8080
Total: 77
Passed: 77
Failed: 0
Pass Rate: 100%

## User
{
    "create":  200,
    "deleteNoAuth":  401,
    "getAll":  200,
    "getAllNoAuth":  401,
    "updateNoAuth":  401,
    "createNoAuth":  401,
    "delete":  204,
    "getOne":  200,
    "getOneNoAuth":  401,
    "duplicate":  400,
    "update":  200
}

## Product
{
    "getAllNoAuth":  401,
    "updateNoAuth":  401,
    "deleteNoAuth":  null,
    "createNoAuth":  401,
    "delete":  null,
    "targetId":  85,
    "update":  200,
    "getOne":  200,
    "getAll":  200,
    "duplicate":  400,
    "getOneNoAuth":  401,
    "page":  200,
    "create":  200
}

## Category
{
    "getAllNoAuth":  401,
    "updateNoAuth":  401,
    "deleteNoAuth":  401,
    "createNoAuth":  401,
    "delete":  204,
    "targetId":  58,
    "update":  200,
    "getOne":  200,
    "getAll":  200,
    "duplicate":  400,
    "getOneNoAuth":  401,
    "page":  200,
    "create":  200
}

## Cart
{
    "updateQty":  200,
    "removeItemNoAuth":  401,
    "clearNoAuth":  401,
    "addItem":  200,
    "getNoAuth":  401,
    "addItemNoAuth":  401,
    "removeItem":  204,
    "get":  200,
    "updateQtyNoAuth":  401,
    "clear":  204
}

## Order
{
    "getByNumberNoAuth":  401,
    "createFromCart":  200,
    "page":  200,
    "createFromCartNoAuth":  401,
    "orderNumber":  "ORD-20250929-632",
    "getMyOrdersNoAuth":  401,
    "getRecent":  200,
    "getWithChanges":  200,
    "updateStatusNoAuth":  401,
    "updateNotesNoAuth":  401,
    "getNeedingAttention":  200,
    "getMyOrders":  200,
    "getById":  200,
    "updateShippingFee":  200,
    "getByNumber":  200,
    "updateNotes":  200,
    "getStatistics":  200,
    "targetId":  19,
    "updateDiscount":  200,
    "getByIdNoAuth":  401,
    "updateStatus":  200,
    "updateTax":  200
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
