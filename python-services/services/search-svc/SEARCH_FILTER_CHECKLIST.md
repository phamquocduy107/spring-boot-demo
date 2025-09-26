# Search Service Filter Enhancement Checklist

## Mục tiêu
Thêm các filter để người dùng có thể tìm kiếm sản phẩm theo nhiều tiêu chí khác nhau.

## 1. Phân tích yêu cầu filter

### 1.1 Các filter cần thêm
- [ ] **Price Range Filter**: Tìm kiếm theo khoảng giá (min_price, max_price)
- [ ] **Category Filter**: Lọc theo danh mục sản phẩm (category_id)
- [ ] **Brand Filter**: Lọc theo thương hiệu (brand)
- [ ] **Color Filter**: Lọc theo màu sắc (color)
- [ ] **Size Filter**: Lọc theo kích thước (size)
- [ ] **Active Status Filter**: Chỉ hiển thị sản phẩm đang hoạt động (is_active)
- [ ] **Sort Options**: Sắp xếp theo giá, tên, ngày cập nhật

### 1.2 API Design
- [ ] Cập nhật endpoint `/search` để nhận thêm filter parameters
- [ ] Thiết kế query parameters cho từng filter
- [ ] Đảm bảo backward compatibility với API hiện tại

## 2. Cập nhật Search API

### 2.1 Thêm Filter Parameters
- [ ] Thêm `min_price: Optional[float] = None`
- [ ] Thêm `max_price: Optional[float] = None`
- [ ] Thêm `category_id: Optional[int] = None`
- [ ] Thêm `brand: Optional[str] = None`
- [ ] Thêm `color: Optional[str] = None`
- [ ] Thêm `size: Optional[str] = None`
- [ ] Thêm `is_active: Optional[bool] = None`
- [ ] Thêm `sort_by: Optional[str] = "relevance"` (relevance, price_asc, price_desc, name_asc, name_desc, updated_desc)

### 2.2 Cập nhật Query Logic
- [ ] Xây dựng bool query với must/should/filter clauses
- [ ] Thêm range filter cho price
- [ ] Thêm term filters cho category_id, brand, color, size, is_active
- [ ] Thêm sort configuration
- [ ] Đảm bảo text search vẫn hoạt động với filters

## 3. Cập nhật OpenSearch Mapping

### 3.1 Kiểm tra mapping hiện tại
- [ ] Xác nhận các field đã có mapping phù hợp
- [ ] Thêm mapping cho các field mới nếu cần
- [ ] Đảm bảo sort fields có proper mapping

### 3.2 Cập nhật Index Creation
- [ ] Cập nhật mapping trong `/reindex` endpoint
- [ ] Thêm sortable fields (price, name, updatedAt)
- [ ] Đảm bảo keyword fields cho exact matching

## 4. Implementation Details

### 4.1 Query Builder Function
- [ ] Tạo function `build_search_query()` để xây dựng OpenSearch query
- [ ] Xử lý text search với multi_match
- [ ] Xử lý filters với bool query
- [ ] Xử lý sorting options

### 4.2 Filter Validation
- [ ] Validate price range (min_price <= max_price)
- [ ] Validate category_id exists
- [ ] Validate enum values cho brand, color, size
- [ ] Sanitize input parameters

### 4.3 Response Enhancement
- [ ] Thêm filter metadata trong response
- [ ] Thêm available filters/facets
- [ ] Thêm pagination info

## 5. Testing

### 5.1 Unit Tests
- [ ] Test search với từng filter riêng lẻ
- [ ] Test search với multiple filters
- [ ] Test edge cases (invalid values, empty results)
- [ ] Test sorting functionality

### 5.2 Integration Tests
- [ ] Test với real data từ catalog API
- [ ] Test performance với large dataset
- [ ] Test backward compatibility

### 5.3 API Testing
- [ ] Test với curl commands
- [ ] Test với Postman/Insomnia
- [ ] Test error handling

## 6. Documentation

### 6.1 API Documentation
- [ ] Cập nhật OpenAPI/Swagger documentation
- [ ] Thêm examples cho từng filter
- [ ] Document response format

### 6.2 Usage Examples
- [ ] Tạo examples cho common use cases
- [ ] Tạo integration examples với frontend
- [ ] Document best practices

## 7. Performance Optimization

### 7.1 Query Optimization
- [ ] Optimize bool query structure
- [ ] Sử dụng filter context thay vì query context khi có thể
- [ ] Index optimization

### 7.2 Caching Strategy
- [ ] Implement response caching cho common queries
- [ ] Cache filter options/facets
- [ ] Cache popular search results

## 8. Monitoring & Logging

### 8.1 Logging
- [ ] Log search queries và filters
- [ ] Log performance metrics
- [ ] Log error cases

### 8.2 Metrics
- [ ] Track filter usage statistics
- [ ] Track search performance
- [ ] Track error rates

## 9. Deployment

### 9.1 Database Migration
- [ ] Backup existing index
- [ ] Update mapping nếu cần
- [ ] Reindex data với new mapping

### 9.2 Service Update
- [ ] Deploy updated search service
- [ ] Test với production data
- [ ] Monitor performance

## 10. Frontend Integration

### 10.1 API Integration
- [ ] Update frontend search calls
- [ ] Implement filter UI components
- [ ] Handle filter state management

### 10.2 User Experience
- [ ] Implement filter persistence
- [ ] Add clear filters functionality
- [ ] Implement filter suggestions

## Example API Usage

```bash
# Basic search với filters
curl "http://localhost:8092/search?q=laptop&min_price=500&max_price=2000&category_id=1&brand=Dell&sort_by=price_asc&limit=20"

# Search với multiple filters
curl "http://localhost:8092/search?q=shirt&color=blue&size=M&is_active=true&sort_by=name_asc"

# Search chỉ với filters (không có text query)
curl "http://localhost:8092/search?min_price=100&max_price=500&category_id=2&sort_by=price_desc"
```

## Success Criteria

- [ ] Tất cả filters hoạt động độc lập và kết hợp
- [ ] Performance không bị ảnh hưởng đáng kể
- [ ] Backward compatibility được duy trì
- [ ] API documentation đầy đủ
- [ ] Tests coverage > 80%
- [ ] Frontend integration hoàn thành
