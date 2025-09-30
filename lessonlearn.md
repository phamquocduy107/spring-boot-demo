# Lessons Learned - Spring Boot Demo Project

## 📚 Tổng quan
File này ghi lại những bài học, lỗi đã mắc phải và cách tránh trong quá trình phát triển Spring Boot Demo Project.

---

## 🚨 **Lỗi 1: String Interpolation vs String Concatenation trong PowerShell**

### **Vấn đề:**
```powershell
# SAI - String interpolation không hoạt động đúng
$updateQtyUrl = "$cartUrl/items/$pTargetId?quantity=$quantity"
# Kết quả: http://localhost:8080/api/cart/items/=5 thay vì http://localhost:8080/api/cart/items/67?quantity=5
```

### **Nguyên nhân:**
- PowerShell string interpolation có thể gây confusion với biến `$pTargetId`
- Khi biến không được định nghĩa rõ ràng, interpolation tạo ra kết quả không mong muốn

### **Giải pháp:**
```powershell
# ĐÚNG - Sử dụng string concatenation
$updateQtyUrl = $cartUrl + "/items/" + $pTargetId + "?quantity=" + $quantity
```

### **Bài học:**
- **Luôn test string interpolation** trước khi sử dụng trong production
- **Ưu tiên string concatenation** khi có nhiều biến động
- **Debug bằng cách print ra giá trị** của các biến trước khi sử dụng

---

## 🚨 **Lỗi 2: API Endpoint Mapping Sai**

### **Vấn đề:**
```python
# SAI - Gọi endpoint không tồn tại
requests.get(f"{ORDERS_API_URL}/api/orders")  # Không có endpoint này
requests.get(f"{CATALOG_API_URL}/api/categories")  # Không có endpoint này
```

### **Nguyên nhân:**
- Không kiểm tra API documentation trước khi implement
- Giả định endpoints tồn tại mà không verify

### **Giải pháp:**
```python
# ĐÚNG - Sử dụng endpoints thực tế
requests.get(f"{ORDERS_API_URL}/api/orders/recent")  # Endpoint có sẵn
requests.get(f"{CATALOG_API_URL}/api/categories/active")  # Endpoint có sẵn
```

### **Bài học:**
- **Luôn kiểm tra API documentation** trước khi implement
- **Test endpoints trực tiếp** bằng curl/Postman trước khi code
- **Sử dụng grep/search** để tìm endpoints thực tế trong codebase

---

## 🚨 **Lỗi 3: Authentication Headers Không Được Truyền**

### **Vấn đề:**
```python
# SAI - Không truyền JWT token
headers = {"Accept": "application/json"}
# Kết quả: 401 Unauthorized từ Spring Boot APIs
```

### **Nguyên nhân:**
- Quên rằng Spring Boot APIs yêu cầu authentication
- Không implement logic truyền JWT token từ request

### **Giải pháp:**
```python
# ĐÚNG - Truyền JWT token từ request
def _get_auth_headers(request: Request) -> dict:
    headers = {"Accept": "application/json"}
    auth_header = request.headers.get("Authorization")
    if auth_header:
        headers["Authorization"] = auth_header
    return headers
```

### **Bài học:**
- **Luôn kiểm tra authentication requirements** của APIs
- **Implement proper header forwarding** trong microservices
- **Test với và không có authentication** để đảm bảo error handling

---

## 🚨 **Lỗi 4: PowerShell Syntax Sai**

### **Vấn đề:**
```powershell
# SAI - Sử dụng bash syntax trong PowerShell
cd python-services\infra && docker-compose up --build analytics-svc
# Lỗi: The token '&&' is not a valid statement separator
```

### **Nguyên nhân:**
- Nhầm lẫn giữa bash và PowerShell syntax
- Không kiểm tra shell environment

### **Giải pháp:**
```powershell
# ĐÚNG - PowerShell syntax
cd python-services\infra; docker-compose up --build analytics-svc
# Hoặc
cd python-services\infra
docker-compose up --build analytics-svc
```

### **Bài học:**
- **Luôn kiểm tra shell environment** trước khi chạy commands
- **Sử dụng semicolon (;)** thay vì && trong PowerShell
- **Test commands đơn giản** trước khi chạy complex scripts

---

## 🚨 **Lỗi 5: Không Debug Đủ Chi Tiết**

### **Vấn đề:**
- Chỉ thấy 502 Bad Gateway mà không biết nguyên nhân cụ thể
- Không có logging để trace lỗi

### **Nguyên nhân:**
- Thiếu debug logging trong code
- Không kiểm tra response details

### **Giải pháp:**
```python
# Thêm debug logging
print(f"API Status - Products: {products_resp.status_code}")
print(f"Products response: {products_resp.text[:200]}")
print(f"Categories response: {categories_resp.text[:200]}")
```

### **Bài học:**
- **Luôn thêm debug logging** khi develop
- **Log response details** để trace lỗi
- **Sử dụng try-catch với specific error messages**

---

## 🚨 **Lỗi 6: Không Kiểm Tra Dependencies**

### **Vấn đề:**
- Analytics service không hoạt động vì Spring Boot app không chạy
- Không kiểm tra readiness của dependencies

### **Nguyên nhân:**
- Không implement proper health checks
- Không verify dependencies trước khi start service

### **Giải pháp:**
```python
@app.get("/readiness")
async def readiness():
    # Test connectivity to dependencies
    catalog_ok = test_catalog_api()
    orders_ok = test_orders_api()
    return {"ready": catalog_ok and orders_ok}
```

### **Bài học:**
- **Implement proper health checks** cho microservices
- **Verify dependencies** trước khi start service
- **Sử dụng circuit breaker pattern** cho external calls

---

## 🚨 **Lỗi 7: Không Test Incrementally**

### **Vấn đề:**
- Implement nhiều features cùng lúc
- Khó debug khi có lỗi

### **Nguyên nhân:**
- Muốn hoàn thành nhanh
- Không follow incremental development

### **Giải pháp:**
- **Test từng endpoint một** trước khi implement tiếp
- **Verify basic functionality** trước khi add complex features
- **Use feature flags** để enable/disable features

### **Bài học:**
- **Always test incrementally**
- **Verify each step** before moving to next
- **Use proper testing strategy**

---

## 🚨 **Lỗi 8: Không Document Assumptions**

### **Vấn đề:**
- Giả định APIs hoạt động mà không verify
- Không document dependencies và requirements

### **Nguyên nhân:**
- Thiếu documentation
- Không follow documentation-first approach

### **Giải pháp:**
- **Document all assumptions** clearly
- **Create API documentation** before implementation
- **Use OpenAPI/Swagger** for API documentation

### **Bài học:**
- **Document everything** you assume
- **Verify assumptions** before coding
- **Use proper documentation tools**

---

## 🎯 **Best Practices Rút Ra**

### **1. Development Process:**
- ✅ **Test incrementally** - từng feature một
- ✅ **Verify dependencies** trước khi start
- ✅ **Add debug logging** ngay từ đầu
- ✅ **Document assumptions** clearly

### **2. Error Handling:**
- ✅ **Implement proper error handling** với specific messages
- ✅ **Use try-catch blocks** appropriately
- ✅ **Log error details** for debugging

### **3. API Integration:**
- ✅ **Check API documentation** trước khi implement
- ✅ **Test endpoints directly** trước khi code
- ✅ **Handle authentication** properly
- ✅ **Implement retry logic** for external calls

### **4. Testing:**
- ✅ **Test with and without authentication**
- ✅ **Test error scenarios** not just happy path
- ✅ **Use proper test data** and cleanup

### **5. Documentation:**
- ✅ **Document all assumptions**
- ✅ **Create clear API documentation**
- ✅ **Use proper naming conventions**
- ✅ **Keep documentation updated**

---

## 📝 **Action Items**

### **Immediate:**
- [ ] Fix analytics service authentication issue
- [ ] Add proper error handling to all endpoints
- [ ] Implement comprehensive logging

### **Short-term:**
- [ ] Create API documentation for all services
- [ ] Add integration tests
- [ ] Implement proper health checks

### **Long-term:**
- [ ] Add monitoring and alerting
- [ ] Implement circuit breaker pattern
- [ ] Add performance testing

---

## 🔄 Cập nhật bài học mới (2025-09-30)

### ✅ Bài học 1: Đồng bộ kỳ vọng test với hành vi API
- Trường hợp: `PUT /api/orders/{id}/notes` với `notes = ""` trả 200. Ban đầu test kỳ vọng 400.
- Bài học: Nếu cho phép xoá ghi chú, 200 là hợp lý. Điều chỉnh test thay vì ép API sai với nghiệp vụ.
- Thực hành tốt: Ghi rõ quyết định trong tài liệu và OpenAPI.

### ✅ Bài học 2: Quản lý tổng số test theo biến đếm
- Vấn đề: Thêm test nhưng Total không tăng do thiếu biến trong mảng `$executed`.
- Bài học: Mọi test phải có biến kết quả và được thêm vào khối tính tổng, summary JSON, và entity report.
- Hành động: Bổ sung đầy đủ biến (Order/Category negative) → Total tăng chính xác (163).

### ✅ Bài học 3: Chẩn đoán OpenAPI 401 có hệ thống
- Tình huống: `/v3/api-docs` 401 dù đã `permitAll` và skip trong JWT filter.
- Bài học: Cần log chi tiết security chain, xác minh matcher chính xác (`/v3/api-docs/**`) và filter order theo môi trường chạy.
- Hành động: Tách “Docs Suite” trong script, thêm log chẩn đoán; sẽ fix tiếp.

### ✅ Bài học 4: Negative/Boundary tests nâng độ tin cậy
- Triển khai thêm nhiều case cho Order/Category (shippingFee/tax âm, thiếu address, sort invalid, v.v.).
- Bài học: Negative tests phát hiện sớm lỗ hổng validation, chuẩn hoá phản hồi 400/404.

### 🎯 Hành động tiếp theo đề xuất cho flow đặt hàng
- Ưu tiên: Thanh toán + Idempotency.
- Việc làm: Thêm `Idempotency-Key` cho `create-from-cart`, PaymentIntent (mock), finalize đơn, webhook giả lập, tests happy/fail/timeout/double-submit.


## 🚨 **Lỗi 9: Test Case Management và Tracking**

### **Vấn đề:**
- Thêm nhiều test cases nhưng không cập nhật tracking variables
- Test summary không phản ánh đúng số lượng test cases thực tế
- Missing variables trong executed array dẫn đến count sai

### **Nguyên nhân:**
- Không có systematic approach để track test cases
- Quên cập nhật summary và reporting khi thêm test mới
- Thiếu validation cho test count consistency

### **Giải pháp:**
```powershell
# ĐÚNG - Cập nhật đầy đủ tracking variables
$recPerf1 = $null
$recPerf2 = $null
$recZeroLimit = $null
$analyticsTimeRange = $null
$analyticsCategoryFilter = $null
$searchComplex = $null
$searchEmpty = $null

# Cập nhật executed array
$recDashboard,$recLargeLimit,$recPerf1,$recPerf2,$recZeroLimit,
$analyticsTimeRange,$analyticsCategoryFilter,
$searchComplex,$searchEmpty
```

### **Bài học:**
- **Luôn cập nhật tracking variables** khi thêm test cases mới
- **Validate test count consistency** giữa executed array và summary
- **Use systematic approach** để manage test cases

---

## 🚨 **Lỗi 10: Test Case Design và Edge Case Coverage**

### **Vấn đề:**
- Test cases chỉ cover happy path scenarios
- Thiếu edge cases và error scenarios
- Không test performance và concurrent requests

### **Nguyên nhân:**
- Focus vào basic functionality trước
- Chưa có comprehensive test strategy
- Thiếu experience với edge case testing

### **Giải pháp:**
```powershell
# ĐÚNG - Comprehensive test coverage
# Performance testing
$recPerf1 = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recPerfPayload
$recPerf2 = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recPerfPayload

# Edge case testing
$recZeroLimitPayload = @{ userId = 1; limit = 0; useAnalytics = $false; recommendationType = "basic" }

# Complex parameter testing
$analyticsTimeRange = Try-InvokeJsonGet -Uri "$analyticsBaseUrl/analytics/products/bestsellers?timeRange=weekly&limit=3"
```

### **Bài học:**
- **Design comprehensive test strategy** từ đầu
- **Include edge cases và error scenarios** trong test plan
- **Test performance và concurrent access** patterns
- **Validate all parameter combinations** và boundary conditions

---

## 🚨 **Lỗi 11: Microservices Integration Testing**

### **Vấn đề:**
- Test các services riêng lẻ mà không test integration
- Không verify service-to-service communication
- Thiếu end-to-end testing scenarios

### **Nguyên nhân:**
- Focus vào individual service testing
- Chưa có integration test strategy
- Thiếu understanding về service dependencies

### **Giải pháp:**
```python
# ĐÚNG - Integration testing approach
# Test analytics service calling Spring Boot APIs
@app.get("/analytics/products/bestsellers")
async def get_bestsellers(request: Request):
    headers = _get_auth_headers(request)  # Forward JWT token
    orders_resp = _http_get_with_retries(f"{ORDERS_API_URL}/api/orders/recent", headers)
    products_resp = _http_get_with_retries(f"{CATALOG_API_URL}/api/products", headers)
```

### **Bài học:**
- **Test service integration** không chỉ individual services
- **Verify service-to-service communication** với proper authentication
- **Implement end-to-end testing** scenarios
- **Test failure scenarios** khi dependencies không available

---

## 🎯 **Updated Best Practices**

### **6. Test Management:**
- ✅ **Systematic test case tracking** với proper variables
- ✅ **Comprehensive test coverage** including edge cases
- ✅ **Performance và concurrent testing**
- ✅ **Integration testing** between services

### **7. Microservices Testing:**
- ✅ **Service-to-service communication** testing
- ✅ **Authentication forwarding** between services
- ✅ **Dependency failure** scenarios
- ✅ **End-to-end workflow** testing

---

## 📝 **Updated Action Items**

### **Completed:**
- [x] Add comprehensive test cases for all services (35 total)
- [x] Implement analytics integration with recommendation service
- [x] Add performance và edge case testing
- [x] Fix test tracking và summary reporting

### **Immediate:**
- [ ] Add integration tests for service-to-service communication
- [ ] Implement circuit breaker pattern for external calls
- [ ] Add monitoring và alerting for test failures

### **Short-term:**
- [ ] Create test automation pipeline
- [ ] Add load testing scenarios
- [ ] Implement test data management

### **Long-term:**
- [ ] Add chaos engineering tests
- [ ] Implement comprehensive monitoring dashboard
- [ ] Add performance benchmarking

---

**Last Updated:** 2025-01-25
**Author:** AI Assistant
**Project:** Spring Boot Demo
