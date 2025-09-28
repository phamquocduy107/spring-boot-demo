# User API BugList

Date: 2025-09-29 00:03:56
Scope: scripts/test-user-create.ps1 (All)

1) Product Update with token should be 200
- Expected: 200
- Actual: 400

2) Category Get by id with token should be 200
- Expected: 200
- Actual: 401

3) Category Update with token should be 200
- Expected: 200
- Actual: 401

4) Cart Add Item should be 200
- Expected: 200
- Actual: 401

5) Cart Update Quantity should be 200
- Expected: 200
- Actual: 400
- Details:
```
{
    "error":  "Method parameter \u0027productId\u0027: Failed to convert value of type \u0027java.lang.String\u0027 to required type \u0027java.lang.Long\u0027; For input string: \"=5\""
}
```

6) Cart Remove Item should be 200/204
- Expected: 200/204
- Actual: 401

7) Order Create from Cart should be 200/201
- Expected: 200/201
- Actual: 400

