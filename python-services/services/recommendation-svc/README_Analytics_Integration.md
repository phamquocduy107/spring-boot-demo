# Analytics Integration with Recommendation Service

## 🎯 **Tổng quan**

Đã nâng cấp Recommendation Service để tích hợp với Analytics Service, cung cấp smart recommendations dựa trên dữ liệu phân tích thực tế.

## 🚀 **Tính năng mới**

### **1. Smart Recommendation Types:**
- **`basic`**: Random recommendations (như cũ)
- **`bestsellers`**: Dựa trên sản phẩm bán chạy nhất
- **`trending`**: Dựa trên sản phẩm đang trending
- **`hybrid`**: Kết hợp tất cả analytics data (recommended)

### **2. Analytics Integration:**
- **Bestsellers**: Từ `/analytics/products/bestsellers`
- **Trending**: Từ `/analytics/products/trending`
- **Popular Categories**: Từ `/analytics/categories/popular`

### **3. Scoring System:**
```python
# Base score: 1
# Bestseller bonus: +10
# Trending bonus: +5
# Popular category bonus: +3
```

## 📊 **API Endpoints**

### **Enhanced Recommendations:**
```http
POST /recommendations
{
  "userId": 1,
  "limit": 10,
  "useAnalytics": true,
  "recommendationType": "hybrid",
  "categoryId": 1,
  "activeOnly": true,
  "seed": 12345
}
```

### **Analytics Status:**
```http
GET /analytics/status
```

### **Enhanced Readiness:**
```http
GET /readiness
{
  "ready": true,
  "catalog_api": true,
  "analytics_api": true
}
```

## 🔧 **Cấu hình**

### **Environment Variables:**
```bash
CATALOG_API_URL=http://localhost:8080
ANALYTICS_API_URL=http://localhost:8093
```

### **Docker Compose:**
```yaml
recommendation-svc:
  environment:
    CATALOG_API_URL: http://host.docker.internal:8080
    ANALYTICS_API_URL: http://host.docker.internal:8093
  depends_on:
    - analytics-svc
```

## 📈 **Response Format**

### **Basic Response:**
```json
{
  "userId": 1,
  "items": [...],
  "totalCandidates": 50,
  "returnedCount": 10,
  "recommendationType": "hybrid",
  "useAnalytics": true,
  "generatedAt": "2025-09-30T10:00:00Z"
}
```

### **With Analytics Metadata:**
```json
{
  "analytics": {
    "bestsellersCount": 3,
    "trendingCount": 2,
    "popularCategoryCount": 5,
    "averageScore": 8.5
  }
}
```

### **Product with Analytics Flags:**
```json
{
  "id": 123,
  "name": "Product Name",
  "price": 99.99,
  "isBestseller": true,
  "isTrending": false,
  "isPopularCategory": true,
  "recommendationScore": 14,
  "bestsellerRank": 2
}
```

## 🧪 **Testing**

### **1. Analytics Integration Test:**
```powershell
.\test-analytics-integration.ps1
```

### **2. Full Test Suite:**
```powershell
.\test-all-apis.ps1 -Entity Recommendation
```

### **3. Test Cases:**
- ✅ **Analytics Status Check**
- ✅ **Basic Recommendations** (no analytics)
- ✅ **Bestseller Recommendations**
- ✅ **Trending Recommendations**
- ✅ **Hybrid Recommendations**
- ✅ **Category-Filtered Recommendations**

## 🎯 **Use Cases**

### **1. E-commerce Homepage:**
```json
{
  "recommendationType": "hybrid",
  "limit": 12,
  "useAnalytics": true
}
```

### **2. Category Page:**
```json
{
  "recommendationType": "trending",
  "categoryId": 5,
  "limit": 8,
  "useAnalytics": true
}
```

### **3. Product Detail Page:**
```json
{
  "recommendationType": "bestsellers",
  "limit": 6,
  "useAnalytics": true
}
```

## 🔄 **Fallback Strategy**

Nếu Analytics Service không available:
1. **Graceful degradation** → Fallback to basic recommendations
2. **Error logging** → Log analytics failures
3. **Continue service** → Don't break recommendation flow

## 📊 **Performance Impact**

### **Before (Basic):**
- **Response time**: ~100ms
- **Data sources**: Catalog only
- **Recommendation quality**: Random

### **After (Analytics):**
- **Response time**: ~200-300ms
- **Data sources**: Catalog + Analytics
- **Recommendation quality**: Smart, data-driven

## 🚀 **Deployment**

### **1. Start Services:**
```bash
cd python-services/infra
docker-compose up --build recommendation-svc analytics-svc
```

### **2. Verify Integration:**
```bash
curl http://localhost:8091/analytics/status
```

### **3. Test Recommendations:**
```bash
curl -X POST http://localhost:8091/recommendations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT>" \
  -d '{"userId": 1, "limit": 5, "useAnalytics": true, "recommendationType": "hybrid"}'
```

## 📈 **Benefits**

### **1. Better Recommendations:**
- **Data-driven**: Dựa trên sales data thực tế
- **Trending awareness**: Biết sản phẩm nào đang hot
- **Category intelligence**: Hiểu categories phổ biến

### **2. Business Value:**
- **Higher conversion**: Recommendations chất lượng cao hơn
- **Better UX**: Người dùng thấy sản phẩm relevant hơn
- **Data insights**: Hiểu được user behavior

### **3. Technical Benefits:**
- **Modular**: Analytics service độc lập
- **Scalable**: Có thể scale riêng biệt
- **Maintainable**: Dễ maintain và update

## 🔧 **Troubleshooting**

### **Common Issues:**

1. **Analytics Service Down:**
   - Check: `http://localhost:8093/health`
   - Solution: Start analytics service

2. **Authentication Issues:**
   - Check: JWT token valid
   - Solution: Re-login to get new token

3. **Slow Response:**
   - Check: Analytics service performance
   - Solution: Optimize analytics queries

### **Debug Endpoints:**
- `/analytics/status` - Check analytics connectivity
- `/readiness` - Check all dependencies
- `/health` - Basic health check

## 📚 **Next Steps**

### **Future Enhancements:**
1. **Machine Learning**: ML-based recommendations
2. **Real-time Analytics**: Live trending data
3. **Personalization**: User-specific recommendations
4. **A/B Testing**: Test different recommendation algorithms
5. **Caching**: Cache analytics data for better performance

---

**🎉 Analytics Integration hoàn tất! Recommendation Service giờ đây thông minh hơn và data-driven!**
