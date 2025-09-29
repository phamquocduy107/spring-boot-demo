package com.example.demo.controller;

import com.example.demo.dto.OrderDTO;
import com.example.demo.dto.ShippingAddressDTO;
import com.example.demo.entity.*;
import com.example.demo.enums.OrderStatus;
import com.example.demo.enums.PaymentMethod;
import com.example.demo.enums.UserRole;
import com.example.demo.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    @Autowired
    private OrderService orderService;

    // Create order from cart
    @PostMapping("/create-from-cart")
    public ResponseEntity<?> createOrderFromCart(
            @AuthenticationPrincipal User currentUser,
            @RequestBody CreateOrderRequest request) {
        
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        try {
            OrderDTO order = orderService.createOrderFromCart(
                currentUser.getId(),
                request.getShippingAddress(),
                request.getPaymentMethod(),
                request.getShippingFee()
            );
            return ResponseEntity.ok(order);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body("Error creating order: " + e.getMessage());
        }
    }

    // Get order by ID
    @GetMapping("/{orderId:\\d+}")
    public ResponseEntity<?> getOrderById(
            @AuthenticationPrincipal User currentUser,
            @PathVariable("orderId") Long orderId) {
        
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        Optional<OrderDTO> order = orderService.getOrderById(orderId);
        if (order.isPresent()) {
            // Check if user owns this order or is admin
            if (order.get().getUserId().equals(currentUser.getId()) || 
                currentUser.getRole() == UserRole.ADMIN) {
                return ResponseEntity.ok(order.get());
            } else {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("Access denied");
            }
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Get order by order number
    @GetMapping("/number/{orderNumber}")
    public ResponseEntity<?> getOrderByNumber(
            @AuthenticationPrincipal User currentUser,
            @PathVariable String orderNumber) {
        
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        Optional<OrderDTO> order = orderService.getOrderByNumber(orderNumber);
        if (order.isPresent()) {
            // Check if user owns this order or is admin
            if (order.get().getUserId().equals(currentUser.getId()) || 
                currentUser.getRole() == UserRole.ADMIN) {
                return ResponseEntity.ok(order.get());
            } else {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("Access denied");
            }
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Get user's orders
    @GetMapping("/my-orders")
    public ResponseEntity<?> getMyOrders(@AuthenticationPrincipal User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        List<OrderDTO> orders = orderService.getOrdersByUser(currentUser.getId());
        return ResponseEntity.ok(orders);
    }

    // Get orders by status (Admin only)
    @GetMapping("/status/{status}")
    public ResponseEntity<?> getOrdersByStatus(
            @AuthenticationPrincipal User currentUser,
            @PathVariable OrderStatus status) {
        
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        if (currentUser.getRole() != UserRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("Admin access required");
        }

        List<OrderDTO> orders = orderService.getOrdersByStatus(status);
        return ResponseEntity.ok(orders);
    }

    // Update order status (Admin only)
    @PutMapping("/{orderId:\\d+}/status")
    public ResponseEntity<?> updateOrderStatus(
            @AuthenticationPrincipal User currentUser,
            @PathVariable("orderId") Long orderId,
            @RequestBody UpdateStatusRequest request) {
        
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        if (currentUser.getRole() != UserRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("Admin access required");
        }

        try {
            OrderDTO order = orderService.updateOrderStatus(orderId, request.getStatus());
            return ResponseEntity.ok(order);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body("Error updating order status: " + e.getMessage());
        }
    }

    // Update shipping fee (Admin only)
    @PutMapping("/{orderId:\\d+}/shipping-fee")
    public ResponseEntity<?> updateShippingFee(
            @AuthenticationPrincipal User currentUser,
            @PathVariable("orderId") Long orderId,
            @RequestBody UpdateShippingFeeRequest request) {
        
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        if (currentUser.getRole() != UserRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("Admin access required");
        }

        try {
            OrderDTO order = orderService.updateShippingFee(orderId, request.getShippingFee());
            return ResponseEntity.ok(order);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body("Error updating shipping fee: " + e.getMessage());
        }
    }

    // Update tax amount (Admin only)
    @PutMapping("/{orderId:\\d+}/tax")
    public ResponseEntity<?> updateTaxAmount(
            @AuthenticationPrincipal User currentUser,
            @PathVariable("orderId") Long orderId,
            @RequestBody UpdateTaxRequest request) {
        
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        if (currentUser.getRole() != UserRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("Admin access required");
        }

        try {
            OrderDTO order = orderService.updateTaxAmount(orderId, request.getTaxAmount());
            return ResponseEntity.ok(order);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body("Error updating tax amount: " + e.getMessage());
        }
    }

    // Update discount amount (Admin only)
    @PutMapping("/{orderId:\\d+}/discount")
    public ResponseEntity<?> updateDiscountAmount(
            @AuthenticationPrincipal User currentUser,
            @PathVariable("orderId") Long orderId,
            @RequestBody UpdateDiscountRequest request) {
        
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        if (currentUser.getRole() != UserRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("Admin access required");
        }

        try {
            OrderDTO order = orderService.updateDiscountAmount(orderId, request.getDiscountAmount());
            return ResponseEntity.ok(order);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body("Error updating discount amount: " + e.getMessage());
        }
    }

    // Update order notes
    @PutMapping("/{orderId:\\d+}/notes")
    public ResponseEntity<?> updateOrderNotes(
            @AuthenticationPrincipal User currentUser,
            @PathVariable("orderId") Long orderId,
            @RequestBody UpdateNotesRequest request) {
        
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        try {
            OrderDTO order = orderService.updateOrderNotes(orderId, request.getNotes());
            
            // Check if user owns this order or is admin
            if (order.getUserId().equals(currentUser.getId()) || 
                currentUser.getRole() == UserRole.ADMIN) {
                return ResponseEntity.ok(order);
            } else {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("Access denied");
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body("Error updating order notes: " + e.getMessage());
        }
    }

    // Get orders with product changes (Admin only)
    @GetMapping("/with-product-changes")
    public ResponseEntity<?> getOrdersWithProductChanges(@AuthenticationPrincipal User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        if (currentUser.getRole() != UserRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("Admin access required");
        }

        List<OrderDTO> orders = orderService.getOrdersWithProductChanges();
        return ResponseEntity.ok(orders);
    }

    // Get orders needing attention (Admin only)
    @GetMapping("/needing-attention")
    public ResponseEntity<?> getOrdersNeedingAttention(@AuthenticationPrincipal User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        if (currentUser.getRole() != UserRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("Admin access required");
        }

        List<OrderDTO> orders = orderService.getOrdersNeedingAttention();
        return ResponseEntity.ok(orders);
    }

    // Get recent orders (Admin only)
    @GetMapping("/recent")
    public ResponseEntity<?> getRecentOrders(@AuthenticationPrincipal User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        if (currentUser.getRole() != UserRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("Admin access required");
        }

        List<OrderDTO> orders = orderService.getRecentOrders();
        return ResponseEntity.ok(orders);
    }

    // Paginated orders (Admin only)
    @GetMapping("/page")
    public ResponseEntity<?> getOrdersPage(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "orderDate,desc") String sort
    ) {
        if (currentUser == null || currentUser.getRole() != UserRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
        }
        return ResponseEntity.ok(orderService.getOrdersPage(page, size, sort));
    }

    // Get order statistics (Admin only)
    @GetMapping("/statistics")
    public ResponseEntity<?> getOrderStatistics(@AuthenticationPrincipal User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Authentication required");
        }

        if (currentUser.getRole() != UserRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("Admin access required");
        }

        OrderService.OrderStatistics stats = orderService.getOrderStatistics();
        return ResponseEntity.ok(stats);
    }

    // Request DTOs
    public static class CreateOrderRequest {
        private ShippingAddressDTO shippingAddress;
        private PaymentMethod paymentMethod;
        private BigDecimal shippingFee;

        // Getters and setters
        public ShippingAddressDTO getShippingAddress() { return shippingAddress; }
        public void setShippingAddress(ShippingAddressDTO shippingAddress) { this.shippingAddress = shippingAddress; }

        public PaymentMethod getPaymentMethod() { return paymentMethod; }
        public void setPaymentMethod(PaymentMethod paymentMethod) { this.paymentMethod = paymentMethod; }

        public BigDecimal getShippingFee() { return shippingFee; }
        public void setShippingFee(BigDecimal shippingFee) { this.shippingFee = shippingFee; }
    }

    public static class UpdateStatusRequest {
        private OrderStatus status;

        public OrderStatus getStatus() { return status; }
        public void setStatus(OrderStatus status) { this.status = status; }
    }

    public static class UpdateShippingFeeRequest {
        private BigDecimal shippingFee;

        public BigDecimal getShippingFee() { return shippingFee; }
        public void setShippingFee(BigDecimal shippingFee) { this.shippingFee = shippingFee; }
    }

    public static class UpdateTaxRequest {
        private BigDecimal taxAmount;

        public BigDecimal getTaxAmount() { return taxAmount; }
        public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }
    }

    public static class UpdateDiscountRequest {
        private BigDecimal discountAmount;

        public BigDecimal getDiscountAmount() { return discountAmount; }
        public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }
    }

    public static class UpdateNotesRequest {
        private String notes;

        public String getNotes() { return notes; }
        public void setNotes(String notes) { this.notes = notes; }
    }
}
