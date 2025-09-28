# Order System Documentation

## 🎯 Tổng quan

Hệ thống Order được thiết kế theo **Hybrid Strategy** để tối ưu hóa việc lưu trữ dữ liệu và tránh duplication không cần thiết.

## 🏗️ Kiến trúc

### Entities chính:

1. **Order** - Đơn hàng chính
2. **OrderItem** - Chi tiết sản phẩm trong đơn hàng
3. **ShippingAddress** - Địa chỉ giao hàng
4. **OrderPayment** - Thông tin thanh toán

### Enums:

- **OrderStatus**: PENDING, CONFIRMED, PROCESSING, SHIPPED, DELIVERED, CANCELLED, REFUNDED
- **PaymentMethod**: CASH_ON_DELIVERY, BANK_TRANSFER, CREDIT_CARD, PAYPAL, MOMO, ZALOPAY
- **PaymentStatus**: PENDING, PAID, FAILED, REFUNDED

## 🔄 Hybrid Strategy - Giải pháp Data Duplication

### ✅ Những gì được snapshot (lưu trữ):
- `productNameAtOrder` - Tên sản phẩm tại thời điểm đặt hàng
- `productSkuAtOrder` - SKU sản phẩm tại thời điểm đặt hàng
- `unitPriceAtOrder` - Giá sản phẩm tại thời điểm đặt hàng
- `quantity` - Số lượng đặt hàng

### ❌ Những gì KHÔNG được snapshot (lazy load):
- `productDescription` - Mô tả sản phẩm
- `productBrand` - Thương hiệu
- `productCategory` - Danh mục
- `productWeight` - Trọng lượng
- `productDimensions` - Kích thước

### 🔍 Change Tracking:
- `productNameChanged` - Theo dõi thay đổi tên sản phẩm
- `productPriceChanged` - Theo dõi thay đổi giá sản phẩm
- `changeSummary()` - Tóm tắt các thay đổi

## 📊 Workflow tạo Order

```java
// 1. Lấy cart của user
Cart cart = cartService.getActiveCart(userId);

// 2. Tạo Order mới
Order order = new Order(user);

// 3. Copy CartItem → OrderItem với Hybrid Strategy
for (CartItem cartItem : cart.getItems()) {
    OrderItem orderItem = new OrderItem();
    orderItem.setProduct(cartItem.getProduct()); // Reference, không copy
    
    // Chỉ snapshot những thông tin có thể thay đổi
    orderItem.setQuantity(cartItem.getQuantity());
    orderItem.setUnitPriceAtOrder(cartItem.getPriceAtAdd());
    orderItem.setProductNameAtOrder(product.getName());
    orderItem.setProductSkuAtOrder(product.getSku());
    
    order.getItems().add(orderItem);
}

// 4. Tạo ShippingAddress và OrderPayment
// 5. Tính totals
// 6. Save order
// 7. Clear cart
```

## 🚀 API Endpoints

### User Endpoints:
- `POST /api/orders/create-from-cart` - Tạo đơn hàng từ cart
- `GET /api/orders/{orderId}` - Lấy đơn hàng theo ID
- `GET /api/orders/number/{orderNumber}` - Lấy đơn hàng theo số đơn hàng
- `GET /api/orders/my-orders` - Lấy danh sách đơn hàng của user
- `PUT /api/orders/{orderId}/notes` - Cập nhật ghi chú đơn hàng

### Admin Endpoints:
- `GET /api/orders/status/{status}` - Lấy đơn hàng theo trạng thái
- `PUT /api/orders/{orderId}/status` - Cập nhật trạng thái đơn hàng
- `PUT /api/orders/{orderId}/shipping-fee` - Cập nhật phí ship
- `PUT /api/orders/{orderId}/tax` - Cập nhật thuế
- `PUT /api/orders/{orderId}/discount` - Cập nhật giảm giá
- `GET /api/orders/with-product-changes` - Lấy đơn hàng có thay đổi sản phẩm
- `GET /api/orders/needing-attention` - Lấy đơn hàng cần chú ý
- `GET /api/orders/recent` - Lấy đơn hàng gần đây
- `GET /api/orders/statistics` - Thống kê đơn hàng

## 🧪 Testing

Chạy script test:
```powershell
.\scripts\test-order-apis.ps1
```

Script sẽ test tất cả các endpoints và hiển thị kết quả chi tiết.

## 💡 Lợi ích của Hybrid Strategy

### 1. **Minimal Duplication**
- Chỉ lưu trữ những thông tin thực sự cần thiết
- Giảm thiểu storage space

### 2. **Performance**
- Lazy load những thông tin ít khi thay đổi
- Query nhanh hơn với ít data

### 3. **Flexibility**
- Có thể query cả snapshot và current data
- Dễ dàng so sánh thay đổi

### 4. **Audit Capability**
- Track được thay đổi sản phẩm
- Có thể tạo báo cáo thay đổi

### 5. **Storage Efficient**
- Không lưu trữ data không cần thiết
- Tối ưu hóa database size

## 🔧 Cách sử dụng

### Tạo đơn hàng:
```json
POST /api/orders/create-from-cart
{
  "shippingAddress": {
    "fullName": "Nguyen Van A",
    "phone": "0123456789",
    "addressLine1": "123 Main Street",
    "city": "Ho Chi Minh City",
    "country": "Vietnam"
  },
  "paymentMethod": "CASH_ON_DELIVERY",
  "shippingFee": 30000
}
```

### Cập nhật trạng thái:
```json
PUT /api/orders/{orderId}/status
{
  "status": "CONFIRMED"
}
```

### Lấy thông tin sản phẩm:
```java
// Trong OrderItem
public String getProductDescription() {
    return product.getDescription(); // Lazy load từ Product
}

public String getCurrentProductName() {
    return product.getName(); // So sánh với productNameAtOrder
}

public boolean isProductNameChanged() {
    return !Objects.equals(productNameAtOrder, product.getName());
}
```

## 📈 Monitoring & Analytics

### Orders với thay đổi sản phẩm:
```java
List<Order> ordersWithChanges = orderRepository.findOrdersWithProductChanges();
```

### Thống kê đơn hàng:
```java
OrderStatistics stats = orderService.getOrderStatistics();
```

### Đơn hàng cần chú ý:
```java
List<Order> ordersNeedingAttention = orderService.getOrdersNeedingAttention();
```

## 🎯 Kết luận

Hybrid Strategy giúp:
- ✅ Giảm thiểu data duplication
- ✅ Tối ưu hóa performance
- ✅ Duy trì data integrity
- ✅ Cung cấp audit capability
- ✅ Tiết kiệm storage space

Đây là giải pháp cân bằng tốt nhất giữa data integrity và storage efficiency.
