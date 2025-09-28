package com.example.demo.dto;

import com.example.demo.entity.OrderItem;
import java.math.BigDecimal;

public class OrderItemDTO {
    private Long id;
    private Long productId;
    private String productName;
    private String productSku;
    private String productDescription;
    private String productBrand;
    private String categoryName;
    private Integer quantity;
    private BigDecimal unitPriceAtOrder;
    private BigDecimal currentUnitPrice;
    private BigDecimal totalPrice;
    private Boolean productNameChanged;
    private Boolean productPriceChanged;
    private String changeSummary;

    // Constructors
    public OrderItemDTO() {}

    public OrderItemDTO(OrderItem orderItem) {
        this.id = orderItem.getId();
        this.productId = orderItem.getProduct().getId();
        this.productName = orderItem.getProductNameAtOrder(); // Snapshot
        this.productSku = orderItem.getProductSkuAtOrder(); // Snapshot
        this.productDescription = orderItem.getProductDescription(); // Current
        this.productBrand = orderItem.getProductBrand(); // Current
        this.categoryName = orderItem.getProductCategory().getName(); // Current
        this.quantity = orderItem.getQuantity();
        this.unitPriceAtOrder = orderItem.getUnitPriceAtOrder();
        this.currentUnitPrice = orderItem.getProduct().getPrice(); // Current price
        this.totalPrice = orderItem.getTotalPrice();
        this.productNameChanged = orderItem.getProductNameChanged();
        this.productPriceChanged = orderItem.getProductPriceChanged();
        this.changeSummary = orderItem.getChangeSummary();
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getProductSku() { return productSku; }
    public void setProductSku(String productSku) { this.productSku = productSku; }

    public String getProductDescription() { return productDescription; }
    public void setProductDescription(String productDescription) { this.productDescription = productDescription; }

    public String getProductBrand() { return productBrand; }
    public void setProductBrand(String productBrand) { this.productBrand = productBrand; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public BigDecimal getUnitPriceAtOrder() { return unitPriceAtOrder; }
    public void setUnitPriceAtOrder(BigDecimal unitPriceAtOrder) { this.unitPriceAtOrder = unitPriceAtOrder; }

    public BigDecimal getCurrentUnitPrice() { return currentUnitPrice; }
    public void setCurrentUnitPrice(BigDecimal currentUnitPrice) { this.currentUnitPrice = currentUnitPrice; }

    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }

    public Boolean getProductNameChanged() { return productNameChanged; }
    public void setProductNameChanged(Boolean productNameChanged) { this.productNameChanged = productNameChanged; }

    public Boolean getProductPriceChanged() { return productPriceChanged; }
    public void setProductPriceChanged(Boolean productPriceChanged) { this.productPriceChanged = productPriceChanged; }

    public String getChangeSummary() { return changeSummary; }
    public void setChangeSummary(String changeSummary) { this.changeSummary = changeSummary; }
}
