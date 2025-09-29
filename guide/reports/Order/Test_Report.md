# Order Entity Test Report

**Date:** 2025-09-29 16:58:22
**BaseUrl:** http://localhost:8080
**Mode:** All

## Summary
- **Total Tests:** 19
- **Passed:** 17
- **Failed:** 2
- **Pass Rate:** 89.47%

## Test Results

- **Get Statistics:** Expected 200, Actual: 200
- **Update Shipping Fee:** Expected 200, Actual: 200
- **Get Needing Attention:** Expected 200, Actual: 200
- **Get My Orders (no token):** Expected 401/403, Actual: 401
- **Get by Number:** Expected 200, Actual: 200
- **Update Notes (no token):** Expected 401/403, Actual: 401
- **Get by ID:** Expected 200, Actual: 200
- **Create from Cart (no token):** Expected 401/403, Actual: 401
- **Update Notes:** Expected 200, Actual: 200
- **Get by ID (no token):** Expected 401/403, Actual: 401
- **Update Discount:** Expected 200, Actual: 200
- **Get Recent:** Expected 200, Actual: 200
- **Create from Cart:** Expected 200/201, Actual: 200
- **Get My Orders:** Expected 200, Actual: 200
- **Update Status:** Expected 200, Actual: 200
- **Get by Number (no token):** Expected 401/403, Actual: 401
- **Get with Changes:** Expected 200, Actual: 200
- **Update Status (no token):** Expected 401/403, Actual: 401
- **Update Tax:** Expected 200, Actual: 200

## Failed Tests

### 1. Order Page size>100 should be 400
- **Expected:** 400
- **Actual:** 200
- **Error Message:** No error message available
- **Full Response:**
```json
{
    "content":  [
                    {
                        "id":  28,
                        "orderNumber":  "ORD-20250929-829",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  27,
                                          "productId":  94,
                                          "productName":  "Auto Test Product SKU-20250929095821328",
                                          "productSku":  "SKU-20250929095821328",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  27,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  27,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "PENDING",
                        "subtotal":  159.98,
                        "shippingFee":  30000.00,
                        "taxAmount":  0.00,
                        "discountAmount":  0.00,
                        "totalAmount":  30159.98,
                        "orderDate":  "2025-09-29T16:58:21.846855",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  null,
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  26,
                        "orderNumber":  "ORD-20250929-325",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  26,
                                          "productId":  92,
                                          "productName":  "Auto Test Product SKU-20250929095634587",
                                          "productSku":  "SKU-20250929095634587",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  26,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  26,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T16:56:35.092669",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  25,
                        "orderNumber":  "ORD-20250929-010",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  25,
                                          "productId":  91,
                                          "productName":  "Auto Test Product SKU-20250929095553971",
                                          "productSku":  "SKU-20250929095553971",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  25,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  25,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T16:55:54.591283",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  24,
                        "orderNumber":  "ORD-20250929-162",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  24,
                                          "productId":  90,
                                          "productName":  "Auto Test Product SKU-20250929095220789",
                                          "productSku":  "SKU-20250929095220789",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  24,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  24,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T16:52:21.299701",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  23,
                        "orderNumber":  "ORD-20250929-724",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  23,
                                          "productId":  89,
                                          "productName":  "Auto Test Product SKU-20250929094558394",
                                          "productSku":  "SKU-20250929094558394",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  23,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  23,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T16:45:58.751229",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  22,
                        "orderNumber":  "ORD-20250929-469",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  22,
                                          "productId":  88,
                                          "productName":  "Auto Test Product SKU-20250929093737427",
                                          "productSku":  "SKU-20250929093737427",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  22,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  22,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T16:37:37.848109",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  21,
                        "orderNumber":  "ORD-20250929-738",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  21,
                                          "productId":  87,
                                          "productName":  "Auto Test Product SKU-20250929093246237",
                                          "productSku":  "SKU-20250929093246237",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  21,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  21,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T16:32:46.62041",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  20,
                        "orderNumber":  "ORD-20250929-428",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  20,
                                          "productId":  86,
                                          "productName":  "Auto Test Product SKU-20250929093135228",
                                          "productSku":  "SKU-20250929093135228",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  20,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  20,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T16:31:36.563759",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  19,
                        "orderNumber":  "ORD-20250929-632",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  19,
                                          "productId":  85,
                                          "productName":  "Auto Test Product SKU-20250929085435171",
                                          "productSku":  "SKU-20250929085435171",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  19,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  19,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T15:54:36.480582",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  18,
                        "orderNumber":  "ORD-20250929-634",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  18,
                                          "productId":  84,
                                          "productName":  "Auto Test Product SKU-20250929085305240",
                                          "productSku":  "SKU-20250929085305240",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  18,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  18,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T15:53:05.653883",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  17,
                        "orderNumber":  "ORD-20250929-106",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  17,
                                          "productId":  83,
                                          "productName":  "Auto Test Product SKU-20250929084925787",
                                          "productSku":  "SKU-20250929084925787",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  17,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  17,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T15:49:26.126664",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  16,
                        "orderNumber":  "ORD-20250929-906",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  16,
                                          "productId":  82,
                                          "productName":  "Auto Test Product SKU-20250929084326753",
                                          "productSku":  "SKU-20250929084326753",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  16,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  16,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T15:43:27.153246",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  15,
                        "orderNumber":  "ORD-20250929-316",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  15,
                                          "productId":  81,
                                          "productName":  "Auto Test Product SKU-20250929084257192",
                                          "productSku":  "SKU-20250929084257192",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  15,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  15,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T15:42:57.56663",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  14,
                        "orderNumber":  "ORD-20250929-210",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  14,
                                          "productId":  80,
                                          "productName":  "Auto Test Product SKU-20250929083454540",
                                          "productSku":  "SKU-20250929083454540",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  14,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  14,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T15:34:54.843525",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  13,
                        "orderNumber":  "ORD-20250929-472",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  13,
                                          "productId":  79,
                                          "productName":  "Auto Test Product SKU-20250929083427143",
                                          "productSku":  "SKU-20250929083427143",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  13,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  13,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T15:34:27.448904",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  12,
                        "orderNumber":  "ORD-20250929-643",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  12,
                                          "productId":  78,
                                          "productName":  "Auto Test Product SKU-20250929083420551",
                                          "productSku":  "SKU-20250929083420551",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  12,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  12,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T15:34:20.879273",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  11,
                        "orderNumber":  "ORD-20250929-978",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  11,
                                          "productId":  77,
                                          "productName":  "Auto Test Product SKU-20250929082319998",
                                          "productSku":  "SKU-20250929082319998",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  11,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  11,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T15:23:20.351912",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  10,
                        "orderNumber":  "ORD-20250929-194",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  10,
                                          "productId":  76,
                                          "productName":  "Auto Test Product SKU-20250929082028034",
                                          "productSku":  "SKU-20250929082028034",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  10,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  10,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T15:20:28.962108",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  9,
                        "orderNumber":  "ORD-20250929-438",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  9,
                                          "productId":  75,
                                          "productName":  "Auto Test Product SKU-20250929081631639",
                                          "productSku":  "SKU-20250929081631639",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  9,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  9,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T15:16:31.968274",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  8,
                        "orderNumber":  "ORD-20250929-904",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  8,
                                          "productId":  74,
                                          "productName":  "Auto Test Product SKU-20250929081249669",
                                          "productSku":  "SKU-20250929081249669",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  8,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  8,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T15:12:50.906264",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  7,
                        "orderNumber":  "ORD-20250929-750",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  7,
                                          "productId":  73,
                                          "productName":  "Auto Test Product SKU-20250929070444885",
                                          "productSku":  "SKU-20250929070444885",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  7,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  7,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T14:04:45.801876",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  6,
                        "orderNumber":  "ORD-20250929-157",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  6,
                                          "productId":  72,
                                          "productName":  "Auto Test Product SKU-20250929065842533",
                                          "productSku":  "SKU-20250929065842533",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  6,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  6,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T13:58:42.883195",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  5,
                        "orderNumber":  "ORD-20250929-358",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  5,
                                          "productId":  71,
                                          "productName":  "Auto Test Product SKU-20250929065518548",
                                          "productSku":  "SKU-20250929065518548",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  5,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  5,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T13:55:19.122605",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  4,
                        "orderNumber":  "ORD-20250929-065",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  4,
                                          "productId":  70,
                                          "productName":  "Auto Test Product SKU-20250929064707626",
                                          "productSku":  "SKU-20250929064707626",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  99.99,
                                          "currentUnitPrice":  99.99,
                                          "totalPrice":  199.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  4,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  4,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  199.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55199.98,
                        "orderDate":  "2025-09-29T13:47:08.610687",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  3,
                        "orderNumber":  "ORD-20250929-236",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  3,
                                          "productId":  69,
                                          "productName":  "Auto Test Product SKU-20250929042841925",
                                          "productSku":  "SKU-20250929042841925",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  99.99,
                                          "currentUnitPrice":  99.99,
                                          "totalPrice":  199.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  3,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  3,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  199.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55199.98,
                        "orderDate":  "2025-09-29T11:28:42.236697",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  2,
                        "orderNumber":  "ORD-20250929-717",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  2,
                                          "productId":  67,
                                          "productName":  "Auto Test Product SKU-20250929042628130",
                                          "productSku":  "SKU-20250929042628130",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  99.99,
                                          "currentUnitPrice":  99.99,
                                          "totalPrice":  199.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  2,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  2,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  199.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55199.98,
                        "orderDate":  "2025-09-29T11:26:28.627245",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  1,
                        "orderNumber":  "ORD-20250929-695",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  1,
                                          "productId":  66,
                                          "productName":  "Auto Test Product SKU-20250929041430705",
                                          "productSku":  "SKU-20250929041430705",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  99.99,
                                          "currentUnitPrice":  99.99,
                                          "totalPrice":  199.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  1,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  1,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  199.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55199.98,
                        "orderDate":  "2025-09-29T11:14:31.586085",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    }
                ],
    "pageable":  {
                     "pageNumber":  0,
                     "pageSize":  101,
                     "sort":  {
                                  "empty":  false,
                                  "sorted":  true,
                                  "unsorted":  false
                              },
                     "offset":  0,
                     "paged":  true,
                     "unpaged":  false
                 },
    "totalElements":  27,
    "totalPages":  1,
    "last":  true,
    "numberOfElements":  27,
    "size":  101,
    "number":  0,
    "sort":  {
                 "empty":  false,
                 "sorted":  true,
                 "unsorted":  false
             },
    "first":  true,
    "empty":  false
}
```

### 2. Order Page missing sort dir should be 400
- **Expected:** 400
- **Actual:** 200
- **Error Message:** No error message available
- **Full Response:**
```json
{
    "content":  [
                    {
                        "id":  28,
                        "orderNumber":  "ORD-20250929-829",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  27,
                                          "productId":  94,
                                          "productName":  "Auto Test Product SKU-20250929095821328",
                                          "productSku":  "SKU-20250929095821328",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  27,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  27,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "PENDING",
                        "subtotal":  159.98,
                        "shippingFee":  30000.00,
                        "taxAmount":  0.00,
                        "discountAmount":  0.00,
                        "totalAmount":  30159.98,
                        "orderDate":  "2025-09-29T16:58:21.846855",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  null,
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  26,
                        "orderNumber":  "ORD-20250929-325",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  26,
                                          "productId":  92,
                                          "productName":  "Auto Test Product SKU-20250929095634587",
                                          "productSku":  "SKU-20250929095634587",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  26,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  26,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T16:56:35.092669",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  25,
                        "orderNumber":  "ORD-20250929-010",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  25,
                                          "productId":  91,
                                          "productName":  "Auto Test Product SKU-20250929095553971",
                                          "productSku":  "SKU-20250929095553971",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  25,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  25,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T16:55:54.591283",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  24,
                        "orderNumber":  "ORD-20250929-162",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  24,
                                          "productId":  90,
                                          "productName":  "Auto Test Product SKU-20250929095220789",
                                          "productSku":  "SKU-20250929095220789",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  24,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  24,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T16:52:21.299701",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    },
                    {
                        "id":  23,
                        "orderNumber":  "ORD-20250929-724",
                        "userId":  138,
                        "userName":  "Duy Dep Trai",
                        "userEmail":  "duydeptrai@example.com",
                        "items":  [
                                      {
                                          "id":  23,
                                          "productId":  89,
                                          "productName":  "Auto Test Product SKU-20250929094558394",
                                          "productSku":  "SKU-20250929094558394",
                                          "productDescription":  "Created by script",
                                          "productBrand":  "BrandX",
                                          "categoryName":  "Updated Electronics",
                                          "quantity":  2,
                                          "unitPriceAtOrder":  79.99,
                                          "currentUnitPrice":  79.99,
                                          "totalPrice":  159.98,
                                          "productNameChanged":  false,
                                          "productPriceChanged":  false,
                                          "changeSummary":  "KhÃ´ng cÃ³ thay Äá»i"
                                      }
                                  ],
                        "shippingAddress":  {
                                                "id":  23,
                                                "fullName":  "Test User",
                                                "phone":  "0123456789",
                                                "addressLine1":  "123 Test Street",
                                                "addressLine2":  null,
                                                "city":  "Ho Chi Minh City",
                                                "state":  null,
                                                "postalCode":  null,
                                                "country":  "Vietnam",
                                                "fullAddress":  "123 Test Street, Ho Chi Minh City, Vietnam"
                                            },
                        "payment":  {
                                        "id":  23,
                                        "paymentMethod":  "CASH_ON_DELIVERY",
                                        "paymentStatus":  "PENDING",
                                        "amount":  30000.00,
                                        "transactionId":  null,
                                        "paymentDate":  null,
                                        "notes":  null
                                    },
                        "status":  "CONFIRMED",
                        "subtotal":  159.98,
                        "shippingFee":  50000.00,
                        "taxAmount":  10000.00,
                        "discountAmount":  5000.00,
                        "totalAmount":  55159.98,
                        "orderDate":  "2025-09-29T16:45:58.751229",
                        "shippedDate":  null,
                        "deliveredDate":  null,
                        "notes":  "Test notes from script",
                        "totalItems":  2,
                        "hasProductChanges":  false
                    }
                ],
    "pageable":  {
                     "pageNumber":  0,
                     "pageSize":  5,
                     "sort":  {
                                  "empty":  false,
                                  "sorted":  true,
                                  "unsorted":  false
                              },
                     "offset":  0,
                     "paged":  true,
                     "unpaged":  false
                 },
    "totalElements":  27,
    "totalPages":  6,
    "last":  false,
    "numberOfElements":  5,
    "size":  5,
    "number":  0,
    "sort":  {
                 "empty":  false,
                 "sorted":  true,
                 "unsorted":  false
             },
    "first":  true,
    "empty":  false
}
```

