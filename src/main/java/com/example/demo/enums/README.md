# Enums Package

Thư mục này chứa tất cả các enum được sử dụng trong hệ thống.

## 📁 Cấu trúc

```
src/main/java/com/example/demo/enums/
├── OrderStatus.java      # Trạng thái đơn hàng
├── PaymentMethod.java    # Phương thức thanh toán
├── PaymentStatus.java    # Trạng thái thanh toán
├── UserRole.java         # Vai trò người dùng
└── README.md            # Tài liệu này
```

## 🔧 Các Enum

### 1. OrderStatus
**Mô tả**: Trạng thái của đơn hàng trong quy trình xử lý

**Các giá trị**:
- `PENDING` - Đang chờ xử lý
- `CONFIRMED` - Đã xác nhận
- `PROCESSING` - Đang xử lý
- `SHIPPED` - Đã gửi hàng
- `DELIVERED` - Đã giao hàng
- `CANCELLED` - Đã hủy
- `REFUNDED` - Đã hoàn tiền

**Sử dụng**:
```java
@Enumerated(EnumType.STRING)
private OrderStatus status = OrderStatus.PENDING;
```

### 2. PaymentMethod
**Mô tả**: Các phương thức thanh toán được hỗ trợ

**Các giá trị**:
- `CASH_ON_DELIVERY` - Thanh toán khi nhận hàng
- `BANK_TRANSFER` - Chuyển khoản ngân hàng
- `CREDIT_CARD` - Thẻ tín dụng
- `PAYPAL` - PayPal
- `MOMO` - Ví MoMo
- `ZALOPAY` - Ví ZaloPay

**Sử dụng**:
```java
@Enumerated(EnumType.STRING)
private PaymentMethod paymentMethod;
```

### 3. PaymentStatus
**Mô tả**: Trạng thái của giao dịch thanh toán

**Các giá trị**:
- `PENDING` - Chờ thanh toán
- `PAID` - Đã thanh toán
- `FAILED` - Thanh toán thất bại
- `REFUNDED` - Đã hoàn tiền

**Sử dụng**:
```java
@Enumerated(EnumType.STRING)
private PaymentStatus paymentStatus = PaymentStatus.PENDING;
```

### 4. UserRole
**Mô tả**: Vai trò của người dùng trong hệ thống

**Các giá trị**:
- `USER` - Người dùng
- `ADMIN` - Quản trị viên
- `MODERATOR` - Điều hành viên

**Sử dụng**:
```java
@Enumerated(EnumType.STRING)
private UserRole role = UserRole.USER;
```

**Đặc biệt**: Có method `getAuthority()` để tương thích với Spring Security:
```java
public String getAuthority() {
    return "ROLE_" + this.name();
}
```

## 🎯 Lợi ích của việc tách enum

### 1. **Tổ chức code tốt hơn**
- Tất cả enum ở một nơi dễ tìm
- Tách biệt khỏi business logic
- Dễ maintain và update

### 2. **Tái sử dụng**
- Có thể import và sử dụng ở nhiều nơi
- Tránh duplicate enum definitions
- Consistent across toàn bộ hệ thống

### 3. **Type Safety**
- Compile-time checking
- IDE support tốt hơn
- Tránh magic strings

### 4. **Database Integration**
- `@Enumerated(EnumType.STRING)` lưu tên enum
- `@Enumerated(EnumType.ORDINAL)` lưu index (không khuyến khích)
- Dễ query và filter

## 📝 Best Practices

### 1. **Naming Convention**
- Sử dụng UPPER_CASE cho enum values
- Tên enum sử dụng PascalCase
- Tên package: `enums` (lowercase)

### 2. **Database Mapping**
```java
@Enumerated(EnumType.STRING)  // Khuyến khích
private OrderStatus status;

// Thay vì
@Enumerated(EnumType.ORDINAL) // Không khuyến khích
```

### 3. **Validation**
```java
@NotNull
@Enumerated(EnumType.STRING)
private PaymentMethod paymentMethod;
```

### 4. **Default Values**
```java
private OrderStatus status = OrderStatus.PENDING;
private PaymentStatus paymentStatus = PaymentStatus.PENDING;
private UserRole role = UserRole.USER;
```

## 🔄 Migration từ String sang Enum

### Trước (String):
```java
private String role = "USER";
private String status = "PENDING";
```

### Sau (Enum):
```java
@Enumerated(EnumType.STRING)
private UserRole role = UserRole.USER;

@Enumerated(EnumType.STRING)
private OrderStatus status = OrderStatus.PENDING;
```

### Database Migration:
```sql
-- Không cần thay đổi database schema
-- Enum values được lưu dưới dạng string
-- Ví dụ: "USER", "ADMIN", "PENDING", "CONFIRMED"
```

## 🚀 Mở rộng

### Thêm enum mới:
1. Tạo file enum trong package `enums`
2. Thêm `@Enumerated(EnumType.STRING)` annotation
3. Cập nhật import statements
4. Test và validate

### Thêm giá trị mới:
1. Thêm value vào enum
2. Cập nhật description nếu cần
3. Test với existing data
4. Update documentation

## 📚 Tài liệu tham khảo

- [Java Enum Documentation](https://docs.oracle.com/javase/tutorial/java/javaOO/enum.html)
- [JPA Enum Mapping](https://www.baeldung.com/jpa-persisting-enums-in-jpa)
- [Spring Security Roles](https://docs.spring.io/spring-security/reference/servlet/authorization/authorize-http-requests.html)
