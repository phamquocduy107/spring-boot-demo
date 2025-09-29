# User API BugList

Date: 2025-09-29 13:58:43
Scope: scripts/test-all-apis.ps1 (All)

1) Product Update with token should be 200
- Expected: 200
- Actual: 400
- Error Message: Type definition error: [simple type, class org.hibernate.proxy.pojo.bytebuddy.ByteBuddyInterceptor]
- Full Response:
```
{
    "error":  "Type definition error: [simple type, class org.hibernate.proxy.pojo.bytebuddy.ByteBuddyInterceptor]"
}
```

