import os
import random
import time
from typing import Optional, List, Dict, Any
from datetime import datetime

import requests
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, validator

CATALOG_API_URL = os.getenv("CATALOG_API_URL", "http://localhost:8080")
ANALYTICS_API_URL = os.getenv("ANALYTICS_API_URL", "http://localhost:8093")
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
    useAnalytics: bool = Field(default=True, description="Use analytics data for smart recommendations")
    recommendationType: str = Field(default="hybrid", description="Type: basic, trending, bestsellers, hybrid")

    @validator("categoryId")
    def validate_category(cls, v):
        if v is not None and v < 1:
            raise ValueError("categoryId must be >= 1")
        return v
    
    @validator("recommendationType")
    def validate_recommendation_type(cls, v):
        allowed_types = ["basic", "trending", "bestsellers", "hybrid"]
        if v not in allowed_types:
            raise ValueError(f"recommendationType must be one of: {allowed_types}")
        return v


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.get("/readiness")
async def readiness():
    catalog_ok = bool(CATALOG_API_URL) and bool(CATALOG_PRODUCTS_PATH)
    analytics_ok = bool(ANALYTICS_API_URL)
    return {
        "ready": catalog_ok and analytics_ok,
        "catalog_api": catalog_ok,
        "analytics_api": analytics_ok
    }


@app.get("/analytics/status")
async def analytics_status(request: Request):
    """Check analytics service connectivity and get sample data"""
    headers = {"Accept": "application/json"}
    auth_header = request.headers.get("Authorization")
    if auth_header:
        headers["Authorization"] = auth_header
    
    try:
        # Test analytics endpoints
        bestsellers = _get_bestsellers(headers, 5)
        trending = _get_trending_products(headers, 5)
        popular_categories = _get_popular_categories(headers, 5)
        
        return {
            "analytics_service": "connected",
            "bestsellers_available": len(bestsellers),
            "trending_available": len(trending),
            "popular_categories_available": len(popular_categories),
            "sample_bestsellers": bestsellers[:3] if bestsellers else [],
            "sample_trending": trending[:3] if trending else [],
            "sample_categories": popular_categories[:3] if popular_categories else []
        }
    except Exception as e:
        return {
            "analytics_service": "error",
            "error": str(e)
        }


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


def _get_analytics_data(endpoint: str, headers: dict, params: dict = None) -> Optional[Dict[str, Any]]:
    """Get analytics data from analytics service"""
    try:
        url = f"{ANALYTICS_API_URL}{endpoint}"
        if params:
            url += "?" + "&".join([f"{k}={v}" for k, v in params.items()])
        
        resp = _http_get_with_retries(url, headers, HTTP_TIMEOUT_SECONDS)
        if resp.status_code == 200:
            return resp.json()
        else:
            print(f"Analytics API {endpoint} returned {resp.status_code}: {resp.text[:200]}")
            return None
    except Exception as e:
        print(f"Failed to get analytics data from {endpoint}: {str(e)}")
        return None


def _get_bestsellers(headers: dict, limit: int = 10) -> List[Dict[str, Any]]:
    """Get bestsellers from analytics service"""
    analytics_data = _get_analytics_data("/analytics/products/bestsellers", headers, {"limit": limit})
    if analytics_data and "bestsellers" in analytics_data:
        return analytics_data["bestsellers"]
    return []


def _get_trending_products(headers: dict, limit: int = 10, category_id: Optional[int] = None) -> List[Dict[str, Any]]:
    """Get trending products from analytics service"""
    params = {"limit": limit}
    if category_id:
        params["categoryId"] = category_id
    
    analytics_data = _get_analytics_data("/analytics/products/trending", headers, params)
    if analytics_data and "trending" in analytics_data:
        return analytics_data["trending"]
    return []


def _get_popular_categories(headers: dict, limit: int = 10) -> List[Dict[str, Any]]:
    """Get popular categories from analytics service"""
    analytics_data = _get_analytics_data("/analytics/categories/popular", headers, {"limit": limit})
    if analytics_data and "categories" in analytics_data:
        return analytics_data["categories"]
    return []


def _score_products(products: List[Dict[str, Any]], bestsellers: List[Dict[str, Any]], 
                   trending: List[Dict[str, Any]], popular_categories: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Score products based on analytics data"""
    # Create lookup dictionaries for faster access
    bestseller_ids = {item.get("productId"): item for item in bestsellers}
    trending_ids = {item.get("productId"): item for item in trending}
    popular_category_ids = {cat.get("id"): cat for cat in popular_categories}
    
    scored_products = []
    for product in products:
        score = 0
        product_id = product.get("id")
        category_id = product.get("category", {}).get("id") if isinstance(product.get("category"), dict) else None
        
        # Base score
        score += 1
        
        # Bestseller bonus
        if product_id in bestseller_ids:
            score += 10
            product["isBestseller"] = True
            product["bestsellerRank"] = bestseller_ids[product_id].get("rank", 0)
        else:
            product["isBestseller"] = False
        
        # Trending bonus
        if product_id in trending_ids:
            score += 5
            product["isTrending"] = True
        else:
            product["isTrending"] = False
        
        # Popular category bonus
        if category_id in popular_category_ids:
            score += 3
            product["isPopularCategory"] = True
        else:
            product["isPopularCategory"] = False
        
        product["recommendationScore"] = score
        scored_products.append(product)
    
    return scored_products


@app.post("/recommendations")
async def recommendations(req: RecommendationRequest, request: Request):
    auth_header = request.headers.get("Authorization")
    headers = {"Accept": "application/json"}
    if auth_header:
        headers["Authorization"] = auth_header

    rng = random.Random(req.seed) if req.seed is not None else random

    try:
        # Get analytics data if enabled
        bestsellers = []
        trending = []
        popular_categories = []
        
        if req.useAnalytics:
            print(f"Getting analytics data for recommendation type: {req.recommendationType}")
            
            # Get analytics data based on recommendation type
            if req.recommendationType in ["bestsellers", "hybrid"]:
                bestsellers = _get_bestsellers(headers, req.limit * 2)
                print(f"Got {len(bestsellers)} bestsellers")
            
            if req.recommendationType in ["trending", "hybrid"]:
                trending = _get_trending_products(headers, req.limit * 2, req.categoryId)
                print(f"Got {len(trending)} trending products")
            
            if req.recommendationType == "hybrid":
                popular_categories = _get_popular_categories(headers, 10)
                print(f"Got {len(popular_categories)} popular categories")

        # Get products from catalog
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

        # Filter products
        if req.activeOnly:
            products = [p for p in products if p.get("isActive") is True or p.get("is_active") is True]
        if req.categoryId is not None:
            def _match_category(p):
                cat = p.get("category")
                if isinstance(cat, dict):
                    return cat.get("id") == req.categoryId
                return False
            products = [p for p in products if _match_category(p)]

        # Apply analytics-based scoring and selection
        if req.useAnalytics and req.recommendationType != "basic":
            # Score products based on analytics data
            scored_products = _score_products(products, bestsellers, trending, popular_categories)
            
            # Sort by recommendation score (descending)
            scored_products.sort(key=lambda x: x.get("recommendationScore", 0), reverse=True)
            
            # Select top products
            selected_items = scored_products[:req.limit]
            
            # Add analytics metadata
            analytics_metadata = {
                "bestsellersCount": len([p for p in selected_items if p.get("isBestseller", False)]),
                "trendingCount": len([p for p in selected_items if p.get("isTrending", False)]),
                "popularCategoryCount": len([p for p in selected_items if p.get("isPopularCategory", False)]),
                "averageScore": sum(p.get("recommendationScore", 0) for p in selected_items) / len(selected_items) if selected_items else 0
            }
        else:
            # Basic random selection
            rng.shuffle(products)
            items = [p for p in products if p.get("id") is not None]
            selected_items = items[:req.limit]
            analytics_metadata = None

        # Build response
        product_info = []
        for item in selected_items:
            product_data = {
                "id": item.get("id"),
                "name": item.get("name"),
                "price": item.get("price"),
                "description": item.get("description"),
                "imageUrl": item.get("imageUrl"),
                "isActive": item.get("isActive", item.get("is_active", True)),
                "category": {
                    "id": item.get("category", {}).get("id") if isinstance(item.get("category"), dict) else None,
                    "name": item.get("category", {}).get("name") if isinstance(item.get("category"), dict) else None
                } if item.get("category") else None
            }
            
            # Add analytics metadata if available
            if req.useAnalytics and req.recommendationType != "basic":
                product_data.update({
                    "isBestseller": item.get("isBestseller", False),
                    "isTrending": item.get("isTrending", False),
                    "isPopularCategory": item.get("isPopularCategory", False),
                    "recommendationScore": item.get("recommendationScore", 0)
                })
                
                if item.get("bestsellerRank"):
                    product_data["bestsellerRank"] = item.get("bestsellerRank")
            
            product_info.append(product_data)

        response_data = {
            "userId": req.userId,
            "items": product_info,
            "totalCandidates": len(products),
            "returnedCount": len(product_info),
            "recommendationType": req.recommendationType,
            "useAnalytics": req.useAnalytics,
            "generatedAt": datetime.now().isoformat()
        }
        
        if analytics_metadata:
            response_data["analytics"] = analytics_metadata

        return response_data
        
    except Exception as e:
        return JSONResponse(status_code=502, content={
            "error": "recommendation_failed",
            "message": str(e)
        })


