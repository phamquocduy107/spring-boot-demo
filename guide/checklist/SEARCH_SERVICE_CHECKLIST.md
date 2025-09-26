# Checklist xây dựng search service (local-first)

## 1) Nguồn dữ liệu & schema
- [ ] Xác định nguồn sản phẩm: REST `/api/products` (Java)
- [ ] Định nghĩa document index: `id, name, description, price, categoryId, brand, color, size, isActive, updatedAt`
- [ ] (Nâng cấp) Nhận sự kiện product.created/updated qua Kafka/RabbitMQ

## 2) Hạ tầng
- [ ] OpenSearch chạy local (Docker) cổng 9200
- [ ] Index settings: analyzer (vi/en), mappings chính xác kiểu dữ liệu
- [ ] Tạo index `products` (alias `products_current` nếu cần rollovers)

## 3) API FastAPI
- [ ] GET `/health`
- [ ] POST `/reindex` (tùy chọn): đọc từ catalog và index lại toàn bộ
- [ ] GET `/search?q=...&limit=&offset=` trả `items[], total`
- [ ] (Tùy chọn) filter: `categoryId, priceMin, priceMax, brand, color, size, isActive`
- [ ] Truyền Authorization khi gọi catalog

## 4) Đồng bộ dữ liệu
- [ ] Lần đầu: `/reindex` full
- [ ] Gia tăng: xử lý từng product update (REST hook hoặc sự kiện)
- [ ] Chính sách cập nhật: upsert theo `id`, cập nhật `updatedAt`

## 5) Truy vấn
- [ ] Query builder: `multi_match` (name^3, description), filter theo trường
- [ ] Sắp xếp: score mặc định, (tùy chọn) theo updatedAt/price
- [ ] Highlight (tùy chọn)

## 6) Hiệu năng & ổn định
- [ ] Timeout hợp lý, retry ngắn khi gọi OpenSearch
- [ ] Bulk index khi reindex để tăng tốc
- [ ] Giới hạn limit tối đa (ví dụ 100)

## 7) Observability
- [ ] Log truy vấn (q, filters, thời gian)
- [ ] Metrics: latency p95/p99, lỗi, tốc độ index
- [ ] Tracing: theo dõi call tới OpenSearch & catalog

## 8) Kiểm thử
- [ ] Unit test query builder
- [ ] Contract test với catalog (mock)
- [ ] Test reindex: số doc = số product active

## 9) Chạy local
- [ ] Dockerfile FastAPI + `opensearch-py`
- [ ] docker-compose (search-svc + opensearch)
- [ ] ENV: `OPENSEARCH_URL`, `CATALOG_API_URL`

## 10) Lộ trình nâng cấp
- [ ] Thêm suggest/autocomplete
- [ ] Synonym/typo tolerance
- [ ] Rollovers, ILM, backup snapshots
