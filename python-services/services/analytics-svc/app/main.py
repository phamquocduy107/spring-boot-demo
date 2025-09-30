import os
import time
from datetime import datetime, timedelta
from typing import Optional, List, Dict, Any
from enum import Enum

import requests
from fastapi import FastAPI, Query, Request, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

# Environment variables
CATALOG_API_URL = os.getenv("CATALOG_API_URL", "http://localhost:8080")
ORDERS_API_URL = os.getenv("ORDERS_API_URL", "http://localhost:8080")
HTTP_TIMEOUT_SECONDS = float(os.getenv("HTTP_TIMEOUT_SECONDS", "5"))
HTTP_RETRIES = int(os.getenv("HTTP_RETRIES", "2"))
HTTP_BACKOFF_BASE_MS = int(os.getenv("HTTP_BACKOFF_BASE_MS", "200"))

app = FastAPI(title="analytics-svc", version="1.0.0")


class TimeRange(str, Enum):
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    YEARLY = "yearly"


class AnalyticsRequest(BaseModel):
    timeRange: TimeRange = Field(default=TimeRange.DAILY)
    limit: int = Field(default=10, ge=1, le=100)
    categoryId: Optional[int] = Field(default=None, ge=1)


def _http_get_with_retries(url: str, headers: dict, timeout: float) -> requests.Response:
    """HTTP GET with retry logic and exponential backoff"""
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


def _get_auth_headers(request: Request) -> dict:
    """Extract authorization headers from request"""
    headers = {"Accept": "application/json"}
    auth_header = request.headers.get("Authorization")
    if auth_header:
        headers["Authorization"] = auth_header
    return headers


@app.get("/health")
async def health():
    return {"status": "ok", "service": "analytics-svc"}


@app.get("/readiness")
async def readiness():
    """Check if analytics service is ready"""
    try:
        # Test catalog API connectivity (products endpoint should work without auth for basic check)
        headers = {"Accept": "application/json"}
        resp = requests.get(f"{CATALOG_API_URL}/api/products", headers=headers, timeout=2)
        catalog_ok = resp.status_code == 200
        
        # For orders, we'll just check if the service is reachable
        # (actual orders endpoint requires authentication)
        try:
            resp = requests.get(f"{ORDERS_API_URL}/api/orders/recent", headers=headers, timeout=2)
            orders_ok = resp.status_code in [200, 401]  # 401 means service is up but needs auth
        except:
            orders_ok = False
        
        return {
            "ready": catalog_ok and orders_ok,
            "catalog_api": catalog_ok,
            "orders_api": orders_ok,
            "note": "Orders API requires authentication for full functionality"
        }
    except Exception:
        return {"ready": False, "catalog_api": False, "orders_api": False}


@app.get("/analytics/products/bestsellers")
async def get_bestsellers(
    request: Request,
    timeRange: TimeRange = Query(TimeRange.DAILY, description="Time range for analysis"),
    limit: int = Query(10, ge=1, le=100, description="Number of products to return"),
    categoryId: Optional[int] = Query(None, ge=1, description="Filter by category ID")
):
    """Get best-selling products based on order data"""
    try:
        headers = _get_auth_headers(request)
        
        # Get orders data - use recent orders endpoint
        orders_resp = _http_get_with_retries(
            f"{ORDERS_API_URL}/api/orders/recent", 
            headers, 
            HTTP_TIMEOUT_SECONDS
        )
        
        if orders_resp.status_code != 200:
            raise HTTPException(
                status_code=502, 
                detail=f"Orders API returned {orders_resp.status_code}"
            )
        
        orders = orders_resp.json()
        if not isinstance(orders, list):
            raise HTTPException(status_code=502, detail="Invalid orders data format")
        
        # Get products data
        products_resp = _http_get_with_retries(
            f"{CATALOG_API_URL}/api/products", 
            headers, 
            HTTP_TIMEOUT_SECONDS
        )
        
        if products_resp.status_code != 200:
            raise HTTPException(
                status_code=502, 
                detail=f"Catalog API returned {products_resp.status_code}"
            )
        
        products = products_resp.json()
        if not isinstance(products, list):
            raise HTTPException(status_code=502, detail="Invalid products data format")
        
        # Create products lookup
        products_lookup = {p["id"]: p for p in products if p.get("id")}
        
        # Calculate product sales (simplified - count order items)
        product_sales = {}
        for order in orders:
            if order.get("status") == "COMPLETED":  # Only count completed orders
                order_items = order.get("orderItems", [])
                for item in order_items:
                    product_id = item.get("productId")
                    quantity = item.get("quantity", 0)
                    if product_id and product_id in products_lookup:
                        if product_id not in product_sales:
                            product_sales[product_id] = 0
                        product_sales[product_id] += quantity
        
        # Filter by category if specified
        if categoryId:
            product_sales = {
                pid: sales for pid, sales in product_sales.items()
                if products_lookup[pid].get("category", {}).get("id") == categoryId
            }
        
        # Sort by sales quantity and get top products
        sorted_products = sorted(
            product_sales.items(), 
            key=lambda x: x[1], 
            reverse=True
        )[:limit]
        
        # Build response
        bestsellers = []
        for product_id, total_sold in sorted_products:
            product = products_lookup[product_id]
            bestsellers.append({
                "productId": product_id,
                "name": product.get("name"),
                "price": product.get("price"),
                "totalSold": total_sold,
                "category": product.get("category"),
                "imageUrl": product.get("imageUrl")
            })
        
        return {
            "timeRange": timeRange,
            "categoryId": categoryId,
            "bestsellers": bestsellers,
            "totalProducts": len(bestsellers),
            "generatedAt": datetime.now().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Analytics failed: {str(e)}")


@app.get("/analytics/products/trending")
async def get_trending_products(
    request: Request,
    limit: int = Query(10, ge=1, le=100, description="Number of products to return"),
    categoryId: Optional[int] = Query(None, ge=1, description="Filter by category ID")
):
    """Get trending products (recently popular)"""
    try:
        headers = _get_auth_headers(request)
        
        # Get products data
        products_resp = _http_get_with_retries(
            f"{CATALOG_API_URL}/api/products", 
            headers, 
            HTTP_TIMEOUT_SECONDS
        )
        
        if products_resp.status_code != 200:
            raise HTTPException(
                status_code=502, 
                detail=f"Catalog API returned {products_resp.status_code}"
            )
        
        products = products_resp.json()
        if not isinstance(products, list):
            raise HTTPException(status_code=502, detail="Invalid products data format")
        
        # Filter active products
        active_products = [p for p in products if p.get("isActive", True)]
        
        # Filter by category if specified
        if categoryId:
            active_products = [
                p for p in active_products 
                if p.get("category", {}).get("id") == categoryId
            ]
        
        # Sort by updatedAt (most recently updated = trending)
        trending = sorted(
            active_products,
            key=lambda x: x.get("updatedAt", ""),
            reverse=True
        )[:limit]
        
        # Build response
        trending_products = []
        for product in trending:
            trending_products.append({
                "productId": product.get("id"),
                "name": product.get("name"),
                "price": product.get("price"),
                "description": product.get("description"),
                "category": product.get("category"),
                "imageUrl": product.get("imageUrl"),
                "updatedAt": product.get("updatedAt")
            })
        
        return {
            "categoryId": categoryId,
            "trending": trending_products,
            "totalProducts": len(trending_products),
            "generatedAt": datetime.now().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Analytics failed: {str(e)}")


@app.get("/analytics/categories/popular")
async def get_popular_categories(
    request: Request,
    limit: int = Query(10, ge=1, le=50, description="Number of categories to return")
):
    """Get most popular categories based on product count and sales"""
    try:
        headers = _get_auth_headers(request)
        
        # Get categories data - use active categories endpoint
        categories_resp = _http_get_with_retries(
            f"{CATALOG_API_URL}/api/categories/active", 
            headers, 
            HTTP_TIMEOUT_SECONDS
        )
        
        if categories_resp.status_code != 200:
            raise HTTPException(
                status_code=502, 
                detail=f"Catalog API returned {categories_resp.status_code}"
            )
        
        categories = categories_resp.json()
        if not isinstance(categories, list):
            raise HTTPException(status_code=502, detail="Invalid categories data format")
        
        # Get products data
        products_resp = _http_get_with_retries(
            f"{CATALOG_API_URL}/api/products", 
            headers, 
            HTTP_TIMEOUT_SECONDS
        )
        
        if products_resp.status_code != 200:
            raise HTTPException(
                status_code=502, 
                detail=f"Catalog API returned {products_resp.status_code}"
            )
        
        products = products_resp.json()
        if not isinstance(products, list):
            raise HTTPException(status_code=502, detail="Invalid products data format")
        
        # Count products per category
        category_stats = {}
        for product in products:
            if product.get("isActive", True):
                category = product.get("category")
                if isinstance(category, dict) and category.get("id"):
                    cat_id = category["id"]
                    if cat_id not in category_stats:
                        category_stats[cat_id] = {
                            "categoryId": cat_id,
                            "categoryName": category.get("name"),
                            "productCount": 0,
                            "activeProducts": 0
                        }
                    category_stats[cat_id]["productCount"] += 1
                    if product.get("isActive", True):
                        category_stats[cat_id]["activeProducts"] += 1
        
        # Sort by product count
        popular_categories = sorted(
            category_stats.values(),
            key=lambda x: x["productCount"],
            reverse=True
        )[:limit]
        
        return {
            "popular": popular_categories,
            "totalCategories": len(popular_categories),
            "generatedAt": datetime.now().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Analytics failed: {str(e)}")


@app.get("/analytics/dashboard/summary")
async def get_dashboard_summary(request: Request):
    """Get overall dashboard summary statistics"""
    try:
        headers = _get_auth_headers(request)
        
        # Get all data
        products_resp = _http_get_with_retries(
            f"{CATALOG_API_URL}/api/products", 
            headers, 
            HTTP_TIMEOUT_SECONDS
        )
        categories_resp = _http_get_with_retries(
            f"{CATALOG_API_URL}/api/categories/active", 
            headers, 
            HTTP_TIMEOUT_SECONDS
        )
        orders_resp = _http_get_with_retries(
            f"{ORDERS_API_URL}/api/orders/recent", 
            headers, 
            HTTP_TIMEOUT_SECONDS
        )
        
        # Process data - handle authentication errors gracefully
        products = products_resp.json() if products_resp.status_code == 200 else []
        categories = categories_resp.json() if categories_resp.status_code == 200 else []
        orders = orders_resp.json() if orders_resp.status_code == 200 else []
        
        # Log API response status for debugging
        print(f"API Status - Products: {products_resp.status_code}, Categories: {categories_resp.status_code}, Orders: {orders_resp.status_code}")
        print(f"Products response: {products_resp.text[:200] if hasattr(products_resp, 'text') else 'No text'}")
        print(f"Categories response: {categories_resp.text[:200] if hasattr(categories_resp, 'text') else 'No text'}")
        print(f"Orders response: {orders_resp.text[:200] if hasattr(orders_resp, 'text') else 'No text'}")
        
        # Calculate statistics
        total_products = len(products) if isinstance(products, list) else 0
        active_products = len([p for p in products if p.get("isActive", True)]) if isinstance(products, list) else 0
        total_categories = len(categories) if isinstance(categories, list) else 0
        total_orders = len(orders) if isinstance(orders, list) else 0
        completed_orders = len([o for o in orders if o.get("status") == "COMPLETED"]) if isinstance(orders, list) else 0
        
        # Calculate total revenue (simplified)
        total_revenue = 0
        if isinstance(orders, list):
            for order in orders:
                if order.get("status") == "COMPLETED":
                    total_revenue += order.get("totalAmount", 0)
        
        return {
            "summary": {
                "totalProducts": total_products,
                "activeProducts": active_products,
                "totalCategories": total_categories,
                "totalOrders": total_orders,
                "completedOrders": completed_orders,
                "totalRevenue": total_revenue,
                "completionRate": (completed_orders / total_orders * 100) if total_orders > 0 else 0
            },
            "generatedAt": datetime.now().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Analytics failed: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8090)
