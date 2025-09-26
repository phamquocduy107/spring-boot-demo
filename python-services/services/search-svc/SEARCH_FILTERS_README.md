# Search Service Filters Documentation

## Overview
Search service now supports advanced filtering capabilities allowing users to search products with multiple criteria simultaneously.

## API Endpoint
```
GET /search
```

## Parameters

### Text Search
- `q` (string, optional): Search query text. Searches in product name and description.

### Pagination
- `limit` (int, optional, default: 10, range: 1-100): Number of results to return
- `offset` (int, optional, default: 0, min: 0): Number of results to skip

### Price Filters
- `min_price` (float, optional, min: 0): Minimum price filter
- `max_price` (float, optional, min: 0): Maximum price filter

### Category Filter
- `category_id` (int, optional): Filter by category ID

### Product Attributes
- `brand` (string, optional): Filter by brand name
- `color` (string, optional): Filter by color
- `size` (string, optional): Filter by size
- `is_active` (boolean, optional): Filter by active status

### Sorting
- `sort_by` (string, optional, default: "relevance"): Sort results by:
  - `relevance`: Sort by search relevance score
  - `price_asc`: Sort by price ascending
  - `price_desc`: Sort by price descending
  - `name_asc`: Sort by name ascending
  - `name_desc`: Sort by name descending
  - `updated_desc`: Sort by update date descending
  - `updated_asc`: Sort by update date ascending

## Usage Examples

### Basic Text Search
```bash
curl "http://localhost:8092/search?q=laptop"
```

### Price Range Search
```bash
curl "http://localhost:8092/search?q=&min_price=1000000&max_price=5000000"
```

### Brand Filter
```bash
curl "http://localhost:8092/search?q=&brand=Dell"
```

### Multiple Filters
```bash
curl "http://localhost:8092/search?q=laptop&min_price=2000000&max_price=10000000&brand=Dell&color=black"
```

### Complex Search with Sorting
```bash
curl "http://localhost:8092/search?q=shirt&min_price=500000&max_price=2000000&color=blue&size=M&is_active=true&sort_by=price_asc&limit=5"
```

### Filter Only (No Text Search)
```bash
curl "http://localhost:8092/search?min_price=1000000&max_price=5000000&is_active=true&sort_by=price_asc"
```

## Response Format

```json
{
  "query": "laptop",
  "total": 25,
  "items": [
    {
      "id": "123",
      "name": "Dell Laptop XPS 13",
      "description": "High-performance laptop",
      "price": 25000000,
      "categoryId": 1,
      "brand": "Dell",
      "color": "black",
      "size": "13inch",
      "isActive": true,
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  ],
  "filters_applied": {
    "min_price": 2000000,
    "max_price": 10000000,
    "brand": "Dell",
    "color": "black",
    "sort_by": "price_asc"
  }
}
```

## Error Handling

### Invalid Price Range
```bash
curl "http://localhost:8092/search?min_price=5000000&max_price=1000000"
```
Response:
```json
{
  "error": "invalid_price_range",
  "message": "min_price cannot be greater than max_price"
}
```

### Search Service Error
```json
{
  "error": "search_failed",
  "message": "OpenSearch connection failed"
}
```

## Testing

Run the test script to verify all filters work correctly:

```bash
cd python-services/services/search-svc
python test_filters.py
```

## Performance Notes

1. **Filter Context**: Exact match filters (brand, color, size, etc.) use filter context for better performance
2. **Text Search**: Uses multi_match with field boosting (name^3, description)
3. **Sorting**: Optimized for common sort fields
4. **Pagination**: Efficient with offset/limit

## Integration Examples

### Frontend JavaScript
```javascript
// Search with filters
const searchProducts = async (filters) => {
  const params = new URLSearchParams();
  
  if (filters.query) params.append('q', filters.query);
  if (filters.minPrice) params.append('min_price', filters.minPrice);
  if (filters.maxPrice) params.append('max_price', filters.maxPrice);
  if (filters.brand) params.append('brand', filters.brand);
  if (filters.color) params.append('color', filters.color);
  if (filters.size) params.append('size', filters.size);
  if (filters.isActive !== undefined) params.append('is_active', filters.isActive);
  if (filters.sortBy) params.append('sort_by', filters.sortBy);
  if (filters.limit) params.append('limit', filters.limit);
  
  const response = await fetch(`http://localhost:8092/search?${params}`);
  return await response.json();
};

// Usage
const results = await searchProducts({
  query: 'laptop',
  minPrice: 1000000,
  maxPrice: 10000000,
  brand: 'Dell',
  color: 'black',
  sortBy: 'price_asc',
  limit: 20
});
```

### Python Client
```python
import requests

def search_products(query="", **filters):
    params = {'q': query}
    params.update({k: v for k, v in filters.items() if v is not None})
    
    response = requests.get('http://localhost:8092/search', params=params)
    return response.json()

# Usage
results = search_products(
    query='laptop',
    min_price=1000000,
    max_price=10000000,
    brand='Dell',
    color='black',
    sort_by='price_asc',
    limit=20
)
```

## Backward Compatibility

The API maintains full backward compatibility:
- Existing search calls without filters continue to work
- Default parameters ensure consistent behavior
- No breaking changes to existing integrations

## Future Enhancements

- [ ] Faceted search (return available filter options)
- [ ] Auto-suggestions for filter values
- [ ] Range filters for dates
- [ ] Fuzzy matching for text search
- [ ] Advanced sorting options
- [ ] Filter persistence in session
