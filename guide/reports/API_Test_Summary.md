# API Test Summary

Date: 2025-09-29 00:07:29
Mode: All
Entity: User
BaseUrl: http://localhost:8080
Total: 12
Passed: 12
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
    "create":  null,
    "deleteNoAuth":  null,
    "getAll":  null,
    "getAllNoAuth":  null,
    "updateNoAuth":  null,
    "createNoAuth":  null,
    "delete":  null,
    "getOne":  null,
    "getOneNoAuth":  null,
    "duplicate":  null,
    "targetId":  null,
    "update":  null
}

## Category
{
    "create":  null,
    "deleteNoAuth":  null,
    "getAll":  null,
    "getAllNoAuth":  null,
    "updateNoAuth":  null,
    "createNoAuth":  null,
    "delete":  null,
    "getOne":  null,
    "getOneNoAuth":  null,
    "duplicate":  null,
    "targetId":  19,
    "update":  null
}

## Cart
{
    "updateQty":  null,
    "removeItemNoAuth":  null,
    "clearNoAuth":  null,
    "addItem":  null,
    "getNoAuth":  null,
    "addItemNoAuth":  null,
    "removeItem":  null,
    "get":  null,
    "updateQtyNoAuth":  null,
    "clear":  null
}

## Order
{
    "getNeedingAttention":  null,
    "getByNumber":  null,
    "updateDiscount":  null,
    "getMyOrders":  null,
    "updateStatus":  null,
    "updateNotes":  null,
    "getByIdNoAuth":  null,
    "createFromCartNoAuth":  null,
    "getRecent":  null,
    "getByNumberNoAuth":  null,
    "targetId":  null,
    "updateNotesNoAuth":  null,
    "getStatistics":  null,
    "orderNumber":  null,
    "updateStatusNoAuth":  null,
    "getWithChanges":  null,
    "createFromCart":  null,
    "getById":  null,
    "updateTax":  null,
    "getMyOrdersNoAuth":  null,
    "updateShippingFee":  null
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
- Create: expected 201/200, actual: 
- Duplicate SKU: expected 400, actual: 
- Create (no token): expected 401/403, actual: 
- GetAll: expected 200, actual: 
- GetAll (no token): expected 401/403, actual: 
- Get by Id: expected 200, actual: 
- Get by Id (no token): expected 401/403, actual: 
- Update: expected 200, actual: 
- Update (no token): expected 401/403, actual: 
- Delete: expected 200/204, actual: 
- Delete (no token): expected 401/403, actual: 

### Category
- Create: expected 201/200, actual: 
- Duplicate Slug: expected 400, actual: 
- Create (no token): expected 401/403, actual: 
- GetAll Active: expected 200, actual: 
- GetAll Active (no token): expected 401/403, actual: 
- Get by Id: expected 200, actual: 
- Get by Id (no token): expected 401/403, actual: 
- Update: expected 200, actual: 
- Update (no token): expected 401/403, actual: 
- Delete: expected 200/204, actual: 
- Delete (no token): expected 401/403, actual: 

### Cart
- Get: expected 200/404, actual: 
- Get (no token): expected 401/403, actual: 
- Add Item: expected 200, actual: 
- Add Item (no token): expected 401/403, actual: 
- Update Quantity: expected 200, actual: 
- Update Quantity (no token): expected 401/403, actual: 
- Remove Item: expected 200/204, actual: 
- Remove Item (no token): expected 401/403, actual: 
- Clear: expected 200/204, actual: 
- Clear (no token): expected 401/403, actual: 

### Order
- Create from Cart: expected 200/201, actual: 
- Create from Cart (no token): expected 401/403, actual: 
- Get by ID: expected 200, actual: 
- Get by ID (no token): expected 401/403, actual: 
- Get by Number: expected 200, actual: 
- Get by Number (no token): expected 401/403, actual: 
- Get My Orders: expected 200, actual: 
- Get My Orders (no token): expected 401/403, actual: 
- Update Status: expected 200, actual: 
- Update Status (no token): expected 401/403, actual: 
- Update Shipping Fee: expected 200, actual: 
- Update Tax: expected 200, actual: 
- Update Discount: expected 200, actual: 
- Update Notes: expected 200, actual: 
- Update Notes (no token): expected 401/403, actual: 
- Get with Changes: expected 200, actual: 
- Get Needing Attention: expected 200, actual: 
- Get Recent: expected 200, actual: 
- Get Statistics: expected 200, actual: 
