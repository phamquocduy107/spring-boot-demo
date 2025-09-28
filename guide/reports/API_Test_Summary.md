# API Test Summary

Date: 2025-09-28 21:33:50
Mode: All
Entity: All
BaseUrl: http://localhost:8080
Total: 46
Passed: 41
Failed: 5
Pass Rate: 89.13%

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
    "targetId":  46,
    "update":  200
}

## Category
{
    "create":  200,
    "deleteNoAuth":  401,
    "getAll":  200,
    "getAllNoAuth":  401,
    "updateNoAuth":  401,
    "createNoAuth":  401,
    "delete":  204,
    "getOne":  401,
    "getOneNoAuth":  401,
    "duplicate":  400,
    "targetId":  8,
    "update":  401
}

## Cart
{
    "updateQty":  400,
    "removeItemNoAuth":  401,
    "clearNoAuth":  401,
    "addItem":  400,
    "getNoAuth":  401,
    "addItemNoAuth":  401,
    "removeItem":  401,
    "get":  404,
    "updateQtyNoAuth":  401,
    "clear":  204
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
- Delete: expected 200/204, actual: 204
- Delete (no token): expected 401/403, actual: 401

### Category
- Create: expected 201/200, actual: 200
- Duplicate Slug: expected 400, actual: 400
- Create (no token): expected 401/403, actual: 401
- GetAll Active: expected 200, actual: 200
- GetAll Active (no token): expected 401/403, actual: 401
- Get by Id: expected 200, actual: 401
- Get by Id (no token): expected 401/403, actual: 401
- Update: expected 200, actual: 401
- Update (no token): expected 401/403, actual: 401
- Delete: expected 200/204, actual: 204
- Delete (no token): expected 401/403, actual: 401

### Cart
- Get: expected 200/404, actual: 404
- Get (no token): expected 401/403, actual: 401
- Add Item: expected 200, actual: 400
- Add Item (no token): expected 401/403, actual: 401
- Update Quantity: expected 200, actual: 400
- Update Quantity (no token): expected 401/403, actual: 401
- Remove Item: expected 200/204, actual: 401
- Remove Item (no token): expected 401/403, actual: 401
- Clear: expected 200/204, actual: 204
- Clear (no token): expected 401/403, actual: 401
