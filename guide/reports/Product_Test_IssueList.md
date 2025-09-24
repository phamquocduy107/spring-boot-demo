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
