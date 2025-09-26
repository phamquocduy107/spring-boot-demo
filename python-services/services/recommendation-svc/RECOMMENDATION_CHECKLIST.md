# Checklist xây dựng recommendation (local-first)

## 1) Dữ liệu & sự kiện
- [ ] Xác định nguồn dữ liệu: products, categories (REST), cart.item_* / order.created (event)
- [ ] Chuẩn hóa schema event: `{ userId, productId, ts }`
- [ ] (Tùy chọn) Kho tạm: Redis/ClickHouse cho thống kê

## 2) API FastAPI (MVP)
- [ ] Endpoint: POST `/recommendations` body `{ userId, limit }`
- [ ] Fallback: gọi catalog `/api/products` lấy top-N id (tạm)
- [ ] Truyền Authorization sang catalog (forward header)
- [ ] Biến môi trường: `CATALOG_API_URL`

## 3) Co‑visitation (phiên bản 1)
- [ ] Lưu cặp sản phẩm khi add-to-cart hoặc order (A→B)
- [ ] Tính điểm theo đếm (có thể decay theo thời gian)
- [ ] Gợi ý theo giỏ hàng/đã mua gần đây của user

## 4) Lọc kết quả
- [ ] Loại trừ sản phẩm hết hàng/inactive
- [ ] Tránh lặp lại quá nhiều sản phẩm đã mua
- [ ] Đa dạng hóa theo category

## 5) Cache & hiệu năng
- [ ] Redis: cache key `rec:{userId}:{limit}` TTL 5–15m
- [ ] Cache top‑N toàn hệ thống (fallback)

## 6) Observability
- [ ] Log input (userId, context) & output (productIds)
- [ ] Metrics: hit cache, latency p95/p99, error rate
- [ ] Tracing: propagate traceId khi gọi sang catalog

## 7) Kiểm thử
- [ ] Unit test thuật toán co‑visitation/merging
- [ ] Contract test với catalog API (mock)
- [ ] Load test nhẹ (100–500 RPS)

## 8) Chạy local (Docker)
- [ ] Dockerfile (fastapi + uvicorn)
- [ ] docker-compose (service + opensearch/redis nếu cần)
- [ ] Cổng mặc định: 8091

## 9) Lộ trình nâng cấp
- [ ] Đồng bộ sự kiện thật (Kafka/RabbitMQ) từ Java
- [ ] Batch job (Airflow/Prefect) cập nhật ma trận co‑visitation hằng ngày
- [ ] A/B test: so sánh fallback vs co‑visitation
- [ ] Mô hình nâng cao (Item2Vec/MF) khi dữ liệu đủ lớn
