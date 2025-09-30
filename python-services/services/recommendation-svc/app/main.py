import os
import random
import time
from typing import Optional, List

import requests
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, validator

CATALOG_API_URL = os.getenv("CATALOG_API_URL", "http://localhost:8080")
CATALOG_PRODUCTS_PATH = os.getenv("CATALOG_PRODUCTS_PATH", "/api/products")
HTTP_TIMEOUT_SECONDS = float(os.getenv("HTTP_TIMEOUT_SECONDS", "5"))
HTTP_RETRIES = int(os.getenv("HTTP_RETRIES", "2"))
HTTP_BACKOFF_BASE_MS = int(os.getenv("HTTP_BACKOFF_BASE_MS", "200"))  # 200, 400, 800...

app = FastAPI(title="recommendation-svc")


class RecommendationRequest(BaseModel):
    userId: int = Field(..., ge=1)
    limit: int = Field(10, ge=1, le=100)
    activeOnly: bool = Field(default=True)
    categoryId: Optional[int] = Field(default=None, ge=1)
    seed: Optional[int] = Field(default=None)

    @validator("categoryId")
    def validate_category(cls, v):
        if v is not None and v < 1:
            raise ValueError("categoryId must be >= 1")
        return v


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.get("/readiness")
async def readiness():
    ok = bool(CATALOG_API_URL) and bool(CATALOG_PRODUCTS_PATH)
    return {"ready": ok}


def _build_catalog_url(active_only: bool, category_id: Optional[int]) -> str:
    base = f"{CATALOG_API_URL}{CATALOG_PRODUCTS_PATH}"
    if active_only and category_id is None:
        return f"{base}/active"
    return base


def _http_get_with_retries(url: str, headers: dict, timeout: float) -> requests.Response:
    last_exc: Optional[Exception] = None
    for attempt in range(HTTP_RETRIES + 1):
        try:
            return requests.get(url, headers=headers, timeout=timeout)
        except Exception as e:
            last_exc = e
            if attempt < HTTP_RETRIES:
                backoff_ms = HTTP_BACKOFF_BASE_MS * (2 ** attempt)
                time.sleep(backoff_ms / 1000.0)
            else:
                raise last_exc


@app.post("/recommendations")
async def recommendations(req: RecommendationRequest, request: Request):
    auth_header = request.headers.get("Authorization")
    headers = {"Accept": "application/json"}
    if auth_header:
        headers["Authorization"] = auth_header

    rng = random.Random(req.seed) if req.seed is not None else random

    try:
        url = _build_catalog_url(req.activeOnly, req.categoryId)
        resp = _http_get_with_retries(url, headers, HTTP_TIMEOUT_SECONDS)
        status = getattr(resp, "status_code", None)
        if status is None:
            return JSONResponse(status_code=502, content={
                "error": "catalog_unreachable",
                "message": "No status code from catalog response"
            })

        if status == 401:
            return JSONResponse(status_code=401, content={
                "error": "unauthorized",
                "message": "Catalog API requires Authorization"
            })
        if status >= 400:
            return JSONResponse(status_code=502, content={
                "error": "catalog_error",
                "message": f"Catalog returned HTTP {status}",
                "upstream": resp.text[:500]
            })

        products = resp.json()
        if not isinstance(products, list):
            return JSONResponse(status_code=502, content={
                "error": "invalid_catalog_payload",
                "message": "Expected a JSON array of products"
            })

        if req.activeOnly:
            products = [p for p in products if p.get("isActive") is True or p.get("is_active") is True]
        if req.categoryId is not None:
            def _match_category(p):
                cat = p.get("category")
                if isinstance(cat, dict):
                    return cat.get("id") == req.categoryId
                return False
            products = [p for p in products if _match_category(p)]

        rng.shuffle(products)
        items = [p for p in products if p.get("id") is not None]
        ids: List[int] = [p["id"] for p in items][: req.limit]

        return {"userId": req.userId, "items": ids, "totalCandidates": len(items)}
    except Exception as e:
        return JSONResponse(status_code=502, content={
            "error": "recommendation_failed",
            "message": str(e)
        })


