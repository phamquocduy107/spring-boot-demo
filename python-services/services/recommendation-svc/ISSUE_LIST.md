# Issue list (recommendation-svc + integration)

- Missing request body (FastAPI)
  - Symptom: 422 with `{ "detail": [{ "type": "missing", "loc": ["body"], ...}] }`
  - Fix: Send JSON body `{ "userId": <int>, "limit": <int> }` with `Content-Type: application/json`.

- Missing Python dependency `fastapi` / `uvicorn` / `requests`
  - Symptom: "Import ... could not be resolved" or import error at runtime
  - Fix: Install deps (pip or Poetry). In Docker, add `pip install fastapi uvicorn requests`.

- Recommendation calling catalog returns 502
  - Causes:
    - Catalog not reachable from container
    - Missing Authorization header to catalog
  - Fixes:
    - Set `CATALOG_API_URL=http://host.docker.internal:8080` in compose
    - Forward Authorization header from request to catalog

- Port 8080 already in use (Java app)
  - Symptom: Docker compose up errors: port bind failure
  - Fix: Stop process on 8080 or change mapping to `8081:8080`.

- Gradle build in Docker fails (org.gradle.java.home)
  - Symptom: `Value 'C:/Program Files/Java/jdk-17' ... invalid`
  - Fix: Remove/override host-specific `org.gradle.java.home` inside Docker build.

- Foreign key constraint when creating product
  - Symptom: `category_id=1 is not present`
  - Fix: Create category first and use its real `id` in product body.

- Cart endpoints 401/400 during Java tests (context)
  - Note: Not part of recommendation; ignore while developing Python services.
