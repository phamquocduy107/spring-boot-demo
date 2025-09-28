# User API BugList

Date: 2025-09-28 21:33:50
Scope: scripts/test-user-create.ps1 (All)

1) Category Get by id with token should be 200
- Expected: 200
- Actual: 401

2) Category Update with token should be 200
- Expected: 200
- Actual: 401

3) Cart Add Item should be 200
- Expected: 200
- Actual: 400

4) Cart Update Quantity should be 200
- Expected: 200
- Actual: 400
- Details:
```
{
    "error":  "Method parameter \u0027productId\u0027: Failed to convert value of type \u0027java.lang.String\u0027 to required type \u0027java.lang.Long\u0027; For input string: \"=5\""
}
```

5) Cart Remove Item should be 200/204
- Expected: 200/204
- Actual: 401

