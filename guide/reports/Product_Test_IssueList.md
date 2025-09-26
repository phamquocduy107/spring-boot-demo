# Product Test Issue List

Date: 2025-09-24
Scope: ProductControllerTest, ProductTest, test infrastructure

## Resolved Issues

1) 403 Forbidden in MVC tests
- Symptom: Expected 200/201 but got 403 in ProductControllerTest
- Root cause: Spring Security filters active under @SpringBootTest
- Resolution: Use `@AutoConfigureMockMvc(addFilters = false)` in test class
- Alternative: Keep filters and annotate tests/class with `@WithMockUser`

2) Missing H2 driver under @SpringBootTest
- Symptom: ApplicationContext failed with `Cannot load driver class: org.h2.Driver`
- Root cause: H2 not on test runtime classpath
- Resolution: Added `testRuntimeOnly 'com.h2database:h2'` to build.gradle
- Note: test profile is configured via `src/test/resources/application-test.properties`

3) Mocking annotation deprecation
- Symptom: `@MockBean` marked deprecated (Spring Boot ≥ 3.4)
- Decision: Prefer `@MockitoBean` when available; otherwise keep `@MockBean` and optionally `@SuppressWarnings("deprecation")`

4) Partial context vs full context for controller tests
- Symptom: Context/bean issues with lighter slices
- Decision: Use `@SpringBootTest` + MockMvc for end-to-end wiring; consider `@WebMvcTest` for pure MVC slice tests with explicit mocking of collaborators

## Follow-ups / Risks
- If security configuration changes, tests may fail again unless `addFilters=false` or `@WithMockUser` is applied
- If moving to `@WebMvcTest`, ensure all required beans (e.g., controllers, advices) are in the slice and collaborators are mocked
- Keep H2 aligned with Spring Boot BOM versions

## Nice-to-haves
- Add minimal security test(s) with `@WithMockUser` to assert 401/403 for protected endpoints
- Add negative validation tests for Product payloads (missing category.id, invalid price, etc.)

---

# Search Service Implementation Issues

Date: 2025-01-25
Scope: Search Service Filters Implementation

## Resolved Issues

5) PowerShell syntax error in script files
- Symptom: `./# Quick Add Products Script` caused "The term './#' is not recognized" error
- Root cause: Incorrect comment syntax in PowerShell script
- Resolution: Changed to `# Quick Add Products Script` (removed `./` prefix)
- Prevention: Always use proper PowerShell comment syntax `#` for single-line comments

6) Python requests module not found
- Symptom: `ModuleNotFoundError: No module named 'requests'` when running Python scripts
- Root cause: Python environment doesn't have requests module installed
- Resolution: Use PowerShell scripts instead of Python for API testing
- Alternative: Install requests module with `pip install requests`

7) Categories endpoint returns 401 Unauthorized
- Symptom: `{"path":"/error","error":"Unauthorized","message":"Full authentication is required to access this resource"}`
- Root cause: Categories endpoint requires special permissions or different authentication
- Resolution: Use default category ID (1) instead of fetching categories dynamically
- Workaround: Hardcode category ID in product creation scripts

8) Search service reindex requires JWT authentication
- Symptom: `{"error":"reindex_failed","message":"401 Client Error: for url: http://host.docker.internal:8080/api/products"}`
- Root cause: Search service reindex endpoint requires JWT token to access catalog API
- Resolution: Pass JWT token in Authorization header when calling reindex endpoint
- Implementation: `Invoke-RestMethod -Uri "$searchUrl/reindex" -Method POST -Headers @{ Authorization = "Bearer $jwtToken" }`

9) PowerShell curl command syntax issues
- Symptom: `Cannot bind parameter 'Headers'. Cannot convert the "Authorization: Bearer..." value`
- Root cause: PowerShell's `curl` alias doesn't work the same as Unix curl
- Resolution: Use `Invoke-RestMethod` instead of `curl` for PowerShell scripts
- Best practice: Use native PowerShell cmdlets for HTTP requests

## Follow-ups / Risks
- If category permissions change, scripts may need to be updated
- If search service authentication changes, reindex calls may fail
- Python environment setup needed if switching back to Python scripts

## Nice-to-haves
- Set up proper Python environment with required modules
- Add error handling for missing categories
- Implement retry logic for failed API calls
- Add logging for debugging authentication issues
