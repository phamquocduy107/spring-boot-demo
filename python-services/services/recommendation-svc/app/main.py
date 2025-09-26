import os
import requests
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel

app = FastAPI(title="recommendation-svc")


class RecommendationRequest(BaseModel):
    userId: int
    limit: int = 10


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/recommendations")
async def recommendations(req: RecommendationRequest, request: Request):
    catalog_base = os.getenv("CATALOG_API_URL", "http://localhost:8080")
    auth_header = request.headers.get("Authorization")
    headers = {"Accept": "application/json"}
    if auth_header:
        headers["Authorization"] = auth_header

    try:
        resp = requests.get(f"{catalog_base}/api/products", headers=headers, timeout=5)
        resp.raise_for_status()
        products = resp.json()
        # Expecting a list of ProductDTOs; pick top N ids
        product_ids = [p.get("id") for p in products if p.get("id") is not None][: req.limit]
        return {"userId": req.userId, "items": product_ids}
    except Exception as e:
        return JSONResponse(status_code=502, content={
            "error": "Failed to fetch products",
            "message": str(e)
        })


