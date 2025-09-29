# Category Entity Test Report

**Date:** 2025-09-29 16:58:22
**BaseUrl:** http://localhost:8080
**Mode:** All

## Summary
- **Total Tests:** 12
- **Passed:** 11
- **Failed:** 1
- **Pass Rate:** 91.67%

## Test Results

- **Get by ID:** Expected 200, Actual: 200
- **Get by ID (no token):** Expected 401/403, Actual: 401
- **Get All Active (no token):** Expected 401/403, Actual: 401
- **Update (no token):** Expected 401/403, Actual: 401
- **Delete:** Expected 200/204, Actual: 204
- **Create Category:** Expected 200/201, Actual: 200
- **Get All Active:** Expected 200, Actual: 200
- **Create (no token):** Expected 401/403, Actual: 401
- **Create Duplicate Slug:** Expected 400, Actual: 400
- **Update:** Expected 200, Actual: 200
- **Delete (no token):** Expected 401/403, Actual: 401

## Failed Tests

### 1. Category Page missing sort dir should be 400
- **Expected:** 400
- **Actual:** 200
- **Error Message:** No error message available
- **Full Response:**
```json
{
    "content":  [
                    {
                        "id":  67,
                        "name":  "Auto Test Category category-20250929095821520",
                        "slug":  "category-20250929095821520",
                        "description":  "Created by script",
                        "isActive":  true,
                        "createdAt":  "2025-09-29T16:58:21.525663",
                        "updatedAt":  "2025-09-29T16:58:21.525663",
                        "childrenIds":  null
                    },
                    {
                        "id":  45,
                        "name":  "Auto Test Category category-20250929070328048",
                        "slug":  "category-20250929070328048",
                        "description":  "Created by script",
                        "isActive":  true,
                        "createdAt":  "2025-09-29T14:03:28.055025",
                        "updatedAt":  "2025-09-29T14:03:28.055025",
                        "childrenIds":  null
                    },
                    {
                        "id":  44,
                        "name":  "Auto Test Category category-20250929070144755",
                        "slug":  "category-20250929070144755",
                        "description":  "Created by script",
                        "isActive":  true,
                        "createdAt":  "2025-09-29T14:01:44.763935",
                        "updatedAt":  "2025-09-29T14:01:44.763935",
                        "childrenIds":  null
                    },
                    {
                        "id":  42,
                        "name":  "Auto Test Category category-20250929065809883",
                        "slug":  "category-20250929065809883",
                        "description":  "Created by script",
                        "isActive":  true,
                        "createdAt":  "2025-09-29T13:58:09.892655",
                        "updatedAt":  "2025-09-29T13:58:09.892655",
                        "childrenIds":  null
                    },
                    {
                        "id":  40,
                        "name":  "Auto Test Category category-20250929065441164",
                        "slug":  "category-20250929065441164",
                        "description":  "Created by script",
                        "isActive":  true,
                        "createdAt":  "2025-09-29T13:54:41.171052",
                        "updatedAt":  "2025-09-29T13:54:41.171052",
                        "childrenIds":  null
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
    "totalElements":  20,
    "totalPages":  4,
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

