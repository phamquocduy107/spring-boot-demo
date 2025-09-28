package com.example.demo.dto;

import com.example.demo.entity.Order;
import com.example.demo.enums.OrderStatus;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

public class OrderDTO {
    private Long id;
    private String orderNumber;
    private Long userId;
    private String userName;
    private String userEmail;
    private List<OrderItemDTO> items;
    private ShippingAddressDTO shippingAddress;
    private OrderPaymentDTO payment;
    private OrderStatus status;
    private BigDecimal subtotal;
    private BigDecimal shippingFee;
    private BigDecimal taxAmount;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;
    private LocalDateTime orderDate;
    private LocalDateTime shippedDate;
    private LocalDateTime deliveredDate;
    private String notes;
    private Integer totalItems;
    private Boolean hasProductChanges;

    // Constructors
    public OrderDTO() {}

    public OrderDTO(Order order) {
        this.id = order.getId();
        this.orderNumber = order.getOrderNumber();
        this.userId = order.getUser().getId();
        this.userName = order.getUser().getName();
        this.userEmail = order.getUser().getEmail();
        this.items = order.getItems().stream()
            .map(OrderItemDTO::new)
            .collect(Collectors.toList());
        this.shippingAddress = order.getShippingAddress() != null ? 
            new ShippingAddressDTO(order.getShippingAddress()) : null;
        this.payment = order.getPayment() != null ? 
            new OrderPaymentDTO(order.getPayment()) : null;
        this.status = order.getStatus();
        this.subtotal = order.getSubtotal();
        this.shippingFee = order.getShippingFee();
        this.taxAmount = order.getTaxAmount();
        this.discountAmount = order.getDiscountAmount();
        this.totalAmount = order.getTotalAmount();
        this.orderDate = order.getOrderDate();
        this.shippedDate = order.getShippedDate();
        this.deliveredDate = order.getDeliveredDate();
        this.notes = order.getNotes();
        this.totalItems = order.getTotalItems();
        this.hasProductChanges = order.hasProductChanges();
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getOrderNumber() { return orderNumber; }
    public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public List<OrderItemDTO> getItems() { return items; }
    public void setItems(List<OrderItemDTO> items) { this.items = items; }

    public ShippingAddressDTO getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(ShippingAddressDTO shippingAddress) { this.shippingAddress = shippingAddress; }

    public OrderPaymentDTO getPayment() { return payment; }
    public void setPayment(OrderPaymentDTO payment) { this.payment = payment; }

    public OrderStatus getStatus() { return status; }
    public void setStatus(OrderStatus status) { this.status = status; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getShippingFee() { return shippingFee; }
    public void setShippingFee(BigDecimal shippingFee) { this.shippingFee = shippingFee; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public LocalDateTime getOrderDate() { return orderDate; }
    public void setOrderDate(LocalDateTime orderDate) { this.orderDate = orderDate; }

    public LocalDateTime getShippedDate() { return shippedDate; }
    public void setShippedDate(LocalDateTime shippedDate) { this.shippedDate = shippedDate; }

    public LocalDateTime getDeliveredDate() { return deliveredDate; }
    public void setDeliveredDate(LocalDateTime deliveredDate) { this.deliveredDate = deliveredDate; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Integer getTotalItems() { return totalItems; }
    public void setTotalItems(Integer totalItems) { this.totalItems = totalItems; }

    public Boolean getHasProductChanges() { return hasProductChanges; }
    public void setHasProductChanges(Boolean hasProductChanges) { this.hasProductChanges = hasProductChanges; }
}
