package com.example.demo.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "carts")
public class Cart {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user; // nullable for guest carts

    @OneToMany(mappedBy = "cart", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CartItem> items = new ArrayList<>();

    @NotNull
    @DecimalMin(value = "0.0")
    @Column(name = "subtotal", precision = 12, scale = 2, nullable = false)
    private BigDecimal subtotal = BigDecimal.ZERO;

    @NotNull
    @DecimalMin(value = "0.0")
    @Column(name = "total", precision = 12, scale = 2, nullable = false)
    private BigDecimal total = BigDecimal.ZERO;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
        recalculateTotals();
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
        recalculateTotals();
    }

    public void addItem(Product product, int quantity, BigDecimal priceAtAdd) {
        CartItem item = new CartItem();
        item.setCart(this);
        item.setProduct(product);
        item.setQuantity(quantity);
        item.setPriceAtAdd(priceAtAdd);
        items.add(item);
        recalculateTotals();
    }

    public void removeItemByProductId(Long productId) {
        items.removeIf(ci -> ci.getProduct() != null && productId.equals(ci.getProduct().getId()));
        recalculateTotals();
    }

    public void updateQuantity(Long productId, int quantity) {
        for (CartItem ci : items) {
            if (ci.getProduct() != null && productId.equals(ci.getProduct().getId())) {
                ci.setQuantity(quantity);
                break;
            }
        }
        recalculateTotals();
    }

    public void recalculateTotals() {
        BigDecimal sum = BigDecimal.ZERO;
        for (CartItem ci : items) {
            if (ci.getPriceAtAdd() != null && ci.getQuantity() != null) {
                sum = sum.add(ci.getPriceAtAdd().multiply(BigDecimal.valueOf(ci.getQuantity())));
            }
        }
        this.subtotal = sum;
        this.total = sum; // taxes/discounts can be applied later
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public List<CartItem> getItems() { return items; }
    public void setItems(List<CartItem> items) { this.items = items; }
    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean active) { isActive = active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}


