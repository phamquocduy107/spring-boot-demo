package com.example.demo.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.Objects;

@Entity
@Table(name = "order_items")
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @NotNull
    @Min(1)
    @Column(name = "quantity", nullable = false)
    private Integer quantity;

    @NotNull
    @DecimalMin("0.0")
    @Column(name = "unit_price_at_order", precision = 12, scale = 2, nullable = false)
    private BigDecimal unitPriceAtOrder;

    @NotNull
    @DecimalMin("0.0")
    @Column(name = "total_price", precision = 12, scale = 2, nullable = false)
    private BigDecimal totalPrice;

    // Snapshot chỉ những thông tin có thể thay đổi
    @Column(name = "product_name_at_order")
    private String productNameAtOrder;

    @Column(name = "product_sku_at_order")
    private String productSkuAtOrder;

    // Track changes
    @Column(name = "product_name_changed")
    private Boolean productNameChanged = false;

    @Column(name = "product_price_changed")
    private Boolean productPriceChanged = false;

    // Constructors
    public OrderItem() {}

    public OrderItem(Product product, Integer quantity, BigDecimal unitPriceAtOrder) {
        this.product = product;
        this.quantity = quantity;
        this.unitPriceAtOrder = unitPriceAtOrder;
        this.totalPrice = unitPriceAtOrder.multiply(BigDecimal.valueOf(quantity));
        this.productNameAtOrder = product.getName();
        this.productSkuAtOrder = product.getSku();
    }

    @PrePersist
    @PreUpdate
    protected void checkChanges() {
        if (product != null) {
            productNameChanged = !Objects.equals(productNameAtOrder, product.getName());
            productPriceChanged = !Objects.equals(unitPriceAtOrder, product.getPrice());
        }
    }

    // Helper methods để lấy thông tin từ Product khi cần
    public String getProductDescription() {
        return product.getDescription(); // Lazy load từ Product
    }

    public String getProductBrand() {
        return product.getBrand(); // Lazy load từ Product
    }

    public Category getProductCategory() {
        return product.getCategory(); // Lazy load từ Product
    }

    public String getCurrentProductName() {
        return product.getName(); // So sánh với productNameAtOrder
    }

    public boolean isProductNameChanged() {
        return productNameChanged;
    }

    public boolean isProductPriceChanged() {
        return productPriceChanged;
    }

    public boolean hasProductChanges() {
        return productNameChanged || productPriceChanged;
    }

    public String getChangeSummary() {
        if (!hasProductChanges()) return "Không có thay đổi";
        
        StringBuilder summary = new StringBuilder();
        if (productNameChanged) summary.append("Tên sản phẩm đã thay đổi");
        if (productPriceChanged) {
            if (summary.length() > 0) summary.append(", ");
            summary.append("Giá sản phẩm đã thay đổi");
        }
        return summary.toString();
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Order getOrder() { return order; }
    public void setOrder(Order order) { this.order = order; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { 
        this.quantity = quantity;
        if (unitPriceAtOrder != null) {
            this.totalPrice = unitPriceAtOrder.multiply(BigDecimal.valueOf(quantity));
        }
    }

    public BigDecimal getUnitPriceAtOrder() { return unitPriceAtOrder; }
    public void setUnitPriceAtOrder(BigDecimal unitPriceAtOrder) { 
        this.unitPriceAtOrder = unitPriceAtOrder;
        if (quantity != null) {
            this.totalPrice = unitPriceAtOrder.multiply(BigDecimal.valueOf(quantity));
        }
    }

    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }

    public String getProductNameAtOrder() { return productNameAtOrder; }
    public void setProductNameAtOrder(String productNameAtOrder) { this.productNameAtOrder = productNameAtOrder; }

    public String getProductSkuAtOrder() { return productSkuAtOrder; }
    public void setProductSkuAtOrder(String productSkuAtOrder) { this.productSkuAtOrder = productSkuAtOrder; }

    public Boolean getProductNameChanged() { return productNameChanged; }
    public void setProductNameChanged(Boolean productNameChanged) { this.productNameChanged = productNameChanged; }

    public Boolean getProductPriceChanged() { return productPriceChanged; }
    public void setProductPriceChanged(Boolean productPriceChanged) { this.productPriceChanged = productPriceChanged; }
}
