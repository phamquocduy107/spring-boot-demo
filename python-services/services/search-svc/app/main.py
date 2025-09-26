import os
import requests
from fastapi import FastAPI, Query, Request
from fastapi.responses import JSONResponse
from opensearchpy import OpenSearch
from typing import Optional

app = FastAPI(title="search-svc")

OPENSEARCH_URL = os.getenv("OPENSEARCH_URL", "http://localhost:9200")
CATALOG_API_URL = os.getenv("CATALOG_API_URL", "http://localhost:8080")
INDEX_NAME = os.getenv("SEARCH_INDEX", "products")

client = OpenSearch(hosts=[OPENSEARCH_URL])


def build_search_query(
    query_text: str,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    category_id: Optional[int] = None,
    brand: Optional[str] = None,
    color: Optional[str] = None,
    size: Optional[str] = None,
    is_active: Optional[bool] = None,
    sort_by: str = "relevance"
):
    """
    Build OpenSearch query with filters and sorting
    """
    # Base query structure
    query = {
        "bool": {
            "must": [],
            "filter": []
        }
    }
    
    # Text search (if provided)
    if query_text and query_text.strip():
        query["bool"]["must"].append({
            "multi_match": {
                "query": query_text.strip(),
                "fields": ["name^3", "description"]
            }
        })
    
    # Price range filter
    if min_price is not None or max_price is not None:
        price_range = {}
        if min_price is not None:
            price_range["gte"] = min_price
        if max_price is not None:
            price_range["lte"] = max_price
        query["bool"]["filter"].append({
            "range": {
                "price": price_range
            }
        })
    
    # Category filter
    if category_id is not None:
        query["bool"]["filter"].append({
            "term": {
                "categoryId": category_id
            }
        })
    
    # Brand filter
    if brand is not None and brand.strip():
        query["bool"]["filter"].append({
            "term": {
                "brand": brand.strip()
            }
        })
    
    # Color filter
    if color is not None and color.strip():
        query["bool"]["filter"].append({
            "term": {
                "color": color.strip()
            }
        })
    
    # Size filter
    if size is not None and size.strip():
        query["bool"]["filter"].append({
            "term": {
                "size": size.strip()
            }
        })
    
    # Active status filter
    if is_active is not None:
        query["bool"]["filter"].append({
            "term": {
                "isActive": is_active
            }
        })
    
    # If no text search and no filters, return match_all
    if not query["bool"]["must"] and not query["bool"]["filter"]:
        query = {"match_all": {}}
    elif not query["bool"]["must"]:
        # Only filters, no text search
        query = {"bool": {"filter": query["bool"]["filter"]}}
    
    return query


def build_sort_config(sort_by: str):
    """
    Build sort configuration based on sort_by parameter
    """
    sort_mapping = {
        "relevance": "_score",
        "price_asc": {"price": {"order": "asc"}},
        "price_desc": {"price": {"order": "desc"}},
        "name_asc": {"name.keyword": {"order": "asc"}},
        "name_desc": {"name.keyword": {"order": "desc"}},
        "updated_desc": {"updatedAt": {"order": "desc"}},
        "updated_asc": {"updatedAt": {"order": "asc"}}
    }
    
    return sort_mapping.get(sort_by, "_score")


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/reindex")
async def reindex(request: Request):
    try:
        # ensure index exists
        if not client.indices.exists(INDEX_NAME):
            client.indices.create(INDEX_NAME, body={
                "mappings": {
                    "properties": {
                        "id": {"type": "long"},
                        "name": {
                            "type": "text",
                            "fields": {
                                "keyword": {
                                    "type": "keyword",
                                    "ignore_above": 256
                                }
                            }
                        },
                        "description": {"type": "text"},
                        "price": {"type": "double"},
                        "categoryId": {"type": "long"},
                        "brand": {"type": "keyword"},
                        "color": {"type": "keyword"},
                        "size": {"type": "keyword"},
                        "isActive": {"type": "boolean"},
                        "updatedAt": {"type": "date", "format": "strict_date_optional_time||epoch_millis"}
                    }
                }
            })

        # fetch from catalog
        headers = {"Accept": "application/json"}
        auth = request.headers.get("Authorization")
        if auth:
            headers["Authorization"] = auth
        r = requests.get(f"{CATALOG_API_URL}/api/products", headers=headers, timeout=10)
        r.raise_for_status()
        products = r.json() if isinstance(r.json(), list) else []

        # bulk index
        actions = []
        for p in products:
            doc = {
                "id": p.get("id"),
                "name": p.get("name"),
                "description": p.get("description"),
                "price": p.get("price"),
                "categoryId": p.get("categoryId") or p.get("category", {}).get("id"),
                "brand": p.get("brand"),
                "color": p.get("color"),
                "size": p.get("size"),
                "isActive": p.get("isActive"),
                "updatedAt": p.get("updatedAt")
            }
            actions.append({"index": {"_index": INDEX_NAME, "_id": doc["id"]}})
            actions.append(doc)

        if actions:
            client.bulk(body=actions, refresh=True)

        return {"indexed": len(products), "indexedNames": [p.get("name") for p in products]}
    except Exception as e:
        return JSONResponse(status_code=502, content={"error": "reindex_failed", "message": str(e)})


@app.get("/search")
async def search(
    q: str = Query("", description="Search query text"),
    limit: int = Query(10, ge=1, le=100, description="Number of results to return"),
    offset: int = Query(0, ge=0, description="Number of results to skip"),
    min_price: Optional[float] = Query(None, ge=0, description="Minimum price filter"),
    max_price: Optional[float] = Query(None, ge=0, description="Maximum price filter"),
    category_id: Optional[int] = Query(None, description="Category ID filter"),
    brand: Optional[str] = Query(None, description="Brand filter"),
    color: Optional[str] = Query(None, description="Color filter"),
    size: Optional[str] = Query(None, description="Size filter"),
    is_active: Optional[bool] = Query(None, description="Active status filter"),
    sort_by: str = Query("relevance", description="Sort by: relevance, price_asc, price_desc, name_asc, name_desc, updated_desc, updated_asc")
):
    try:
        # Validate price range
        if min_price is not None and max_price is not None and min_price > max_price:
            return JSONResponse(
                status_code=400, 
                content={"error": "invalid_price_range", "message": "min_price cannot be greater than max_price"}
            )
        
        # Build search query
        search_query = build_search_query(
            query_text=q,
            min_price=min_price,
            max_price=max_price,
            category_id=category_id,
            brand=brand,
            color=color,
            size=size,
            is_active=is_active,
            sort_by=sort_by
        )
        
        # Build sort configuration
        sort_config = build_sort_config(sort_by)
        
        # Execute search
        res = client.search(
            index=INDEX_NAME, 
            body={
                "from": offset,
                "size": limit,
                "query": search_query,
                "sort": sort_config
            }
        )
        
        hits = res.get("hits", {}).get("hits", [])
        items = [{"id": h.get("_id"), **h.get("_source", {})} for h in hits]
        total = res.get("hits", {}).get("total", {}).get("value", 0)
        
        # Build response with applied filters
        response = {
            "query": q,
            "total": total,
            "items": items,
            "filters_applied": {}
        }
        
        # Add applied filters to response
        if min_price is not None:
            response["filters_applied"]["min_price"] = min_price
        if max_price is not None:
            response["filters_applied"]["max_price"] = max_price
        if category_id is not None:
            response["filters_applied"]["category_id"] = category_id
        if brand is not None:
            response["filters_applied"]["brand"] = brand
        if color is not None:
            response["filters_applied"]["color"] = color
        if size is not None:
            response["filters_applied"]["size"] = size
        if is_active is not None:
            response["filters_applied"]["is_active"] = is_active
        if sort_by != "relevance":
            response["filters_applied"]["sort_by"] = sort_by
        
        return response
        
    except Exception as e:
        return JSONResponse(status_code=502, content={"error": "search_failed", "message": str(e)})


