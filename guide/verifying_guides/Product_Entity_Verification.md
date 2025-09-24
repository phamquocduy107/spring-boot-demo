# Product Entity Verification Guide

## Run Build & Tests
```bash
./gradlew clean test
```

If tests fail, open the report at `build/reports/tests/test/index.html`.

## API Smoke (optional)
Start the app (test profile):
```bash
./gradlew bootRun -Dspring-boot.run.profiles=test
```

Then create a category and product via HTTP (examples in project root README or test scripts).

## What this verifies
- Product entity fields, validation, and relations
- Product REST endpoints (create/read/update/delete/search)
- Category linkage via `category.id`
- Basic repository/service flows
