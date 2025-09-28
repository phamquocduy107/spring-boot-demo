package com.example.demo.service;

import com.example.demo.dto.OrderDTO;
import com.example.demo.dto.ShippingAddressDTO;
import com.example.demo.entity.*;
import com.example.demo.enums.OrderStatus;
import com.example.demo.enums.PaymentMethod;
import com.example.demo.repository.OrderRepository;
import com.example.demo.repository.UserRepository;
import com.example.demo.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private CartService cartService;

    // Create order from cart
    public OrderDTO createOrderFromCart(Long userId, ShippingAddressDTO shippingAddressDTO, 
                                       PaymentMethod paymentMethod, BigDecimal shippingFee) {
        
        // 1. Lấy cart của user
        Optional<Cart> cartOpt = cartService.getActiveCart(userId);
        if (!cartOpt.isPresent() || cartOpt.get().getItems().isEmpty()) {
            throw new RuntimeException("Cart is empty or not found");
        }
        Cart cart = cartOpt.get();

        // 2. Tạo Order mới
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        Order order = new Order(user);
        order.setShippingFee(shippingFee != null ? shippingFee : BigDecimal.ZERO);

        // 3. Copy CartItem → OrderItem với Hybrid Strategy
        for (CartItem cartItem : cart.getItems()) {
            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setProduct(cartItem.getProduct()); // Reference, không copy
            
            // Chỉ copy những thông tin có thể thay đổi
            orderItem.setQuantity(cartItem.getQuantity());
            orderItem.setUnitPriceAtOrder(cartItem.getPriceAtAdd());
            
            // Snapshot chỉ khi cần thiết
            Product product = cartItem.getProduct();
            orderItem.setProductNameAtOrder(product.getName());
            orderItem.setProductSkuAtOrder(product.getSku());
            
            // Không copy: description, category, brand, weight, dimensions
            // Có thể query từ Product khi cần
            
            order.getItems().add(orderItem);
        }

        // 4. Tạo ShippingAddress
        ShippingAddress shippingAddress = new ShippingAddress();
        shippingAddress.setOrder(order);
        shippingAddress.setFullName(shippingAddressDTO.getFullName());
        shippingAddress.setPhone(shippingAddressDTO.getPhone());
        shippingAddress.setAddressLine1(shippingAddressDTO.getAddressLine1());
        shippingAddress.setAddressLine2(shippingAddressDTO.getAddressLine2());
        shippingAddress.setCity(shippingAddressDTO.getCity());
        shippingAddress.setState(shippingAddressDTO.getState());
        shippingAddress.setPostalCode(shippingAddressDTO.getPostalCode());
        shippingAddress.setCountry(shippingAddressDTO.getCountry());
        order.setShippingAddress(shippingAddress);

        // 5. Tạo OrderPayment
        OrderPayment payment = new OrderPayment(paymentMethod, order.getTotalAmount());
        payment.setOrder(order);
        order.setPayment(payment);

        // 6. Tính totals (method sẽ được gọi tự động trong @PrePersist)

        // 7. Save order
        Order savedOrder = orderRepository.save(order);

        // 8. Clear cart
        cartService.clear(userId);

        return new OrderDTO(savedOrder);
    }

    // Get order by ID
    @Transactional(readOnly = true)
    public Optional<OrderDTO> getOrderById(Long orderId) {
        return orderRepository.findById(orderId)
            .map(OrderDTO::new);
    }

    // Get order by order number
    @Transactional(readOnly = true)
    public Optional<OrderDTO> getOrderByNumber(String orderNumber) {
        return orderRepository.findByOrderNumber(orderNumber)
            .map(OrderDTO::new);
    }

    // Get orders by user
    @Transactional(readOnly = true)
    public List<OrderDTO> getOrdersByUser(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        return orderRepository.findByUserOrderByOrderDateDesc(user)
            .stream()
            .map(OrderDTO::new)
            .collect(Collectors.toList());
    }

    // Get orders by status
    @Transactional(readOnly = true)
    public List<OrderDTO> getOrdersByStatus(OrderStatus status) {
        return orderRepository.findByStatusOrderByOrderDateDesc(status)
            .stream()
            .map(OrderDTO::new)
            .collect(Collectors.toList());
    }

    // Update order status
    public OrderDTO updateOrderStatus(Long orderId, OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("Order not found"));

        switch (newStatus) {
            case CONFIRMED -> order.confirm();
            case PROCESSING -> order.process();
            case SHIPPED -> order.ship();
            case DELIVERED -> order.deliver();
            case CANCELLED -> order.cancel();
            case REFUNDED -> order.refund();
            default -> throw new RuntimeException("Invalid status transition");
        }

        Order savedOrder = orderRepository.save(order);
        return new OrderDTO(savedOrder);
    }

    // Update shipping fee
    public OrderDTO updateShippingFee(Long orderId, BigDecimal shippingFee) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("Order not found"));

        order.setShippingFee(shippingFee);
        Order savedOrder = orderRepository.save(order);
        return new OrderDTO(savedOrder);
    }

    // Update tax amount
    public OrderDTO updateTaxAmount(Long orderId, BigDecimal taxAmount) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("Order not found"));

        order.setTaxAmount(taxAmount);
        Order savedOrder = orderRepository.save(order);
        return new OrderDTO(savedOrder);
    }

    // Update discount amount
    public OrderDTO updateDiscountAmount(Long orderId, BigDecimal discountAmount) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("Order not found"));

        order.setDiscountAmount(discountAmount);
        Order savedOrder = orderRepository.save(order);
        return new OrderDTO(savedOrder);
    }

    // Update order notes
    public OrderDTO updateOrderNotes(Long orderId, String notes) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("Order not found"));

        order.setNotes(notes);
        Order savedOrder = orderRepository.save(order);
        return new OrderDTO(savedOrder);
    }

    // Get orders with product changes
    @Transactional(readOnly = true)
    public List<OrderDTO> getOrdersWithProductChanges() {
        return orderRepository.findOrdersWithProductChanges()
            .stream()
            .map(OrderDTO::new)
            .collect(Collectors.toList());
    }

    // Get orders needing attention (pending for more than 24 hours)
    @Transactional(readOnly = true)
    public List<OrderDTO> getOrdersNeedingAttention() {
        LocalDateTime threshold = LocalDateTime.now().minusHours(24);
        return orderRepository.findOrdersNeedingAttention(threshold)
            .stream()
            .map(OrderDTO::new)
            .collect(Collectors.toList());
    }

    // Get recent orders (last 30 days)
    @Transactional(readOnly = true)
    public List<OrderDTO> getRecentOrders() {
        LocalDateTime since = LocalDateTime.now().minusDays(30);
        return orderRepository.findRecentOrders(since)
            .stream()
            .map(OrderDTO::new)
            .collect(Collectors.toList());
    }

    // Get orders by date range
    @Transactional(readOnly = true)
    public List<OrderDTO> getOrdersByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return orderRepository.findByOrderDateBetweenOrderByOrderDateDesc(startDate, endDate)
            .stream()
            .map(OrderDTO::new)
            .collect(Collectors.toList());
    }

    // Get orders by user and date range
    @Transactional(readOnly = true)
    public List<OrderDTO> getOrdersByUserAndDateRange(Long userId, LocalDateTime startDate, LocalDateTime endDate) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        return orderRepository.findByUserAndOrderDateBetweenOrderByOrderDateDesc(user, startDate, endDate)
            .stream()
            .map(OrderDTO::new)
            .collect(Collectors.toList());
    }

    // Get order statistics
    @Transactional(readOnly = true)
    public OrderStatistics getOrderStatistics() {
        long totalOrders = orderRepository.count();
        long pendingOrders = orderRepository.countByStatus(OrderStatus.PENDING);
        long confirmedOrders = orderRepository.countByStatus(OrderStatus.CONFIRMED);
        long shippedOrders = orderRepository.countByStatus(OrderStatus.SHIPPED);
        long deliveredOrders = orderRepository.countByStatus(OrderStatus.DELIVERED);
        long cancelledOrders = orderRepository.countByStatus(OrderStatus.CANCELLED);

        return new OrderStatistics(totalOrders, pendingOrders, confirmedOrders, 
                                 shippedOrders, deliveredOrders, cancelledOrders);
    }

    // Inner class for statistics
    public static class OrderStatistics {
        private final long totalOrders;
        private final long pendingOrders;
        private final long confirmedOrders;
        private final long shippedOrders;
        private final long deliveredOrders;
        private final long cancelledOrders;

        public OrderStatistics(long totalOrders, long pendingOrders, long confirmedOrders,
                            long shippedOrders, long deliveredOrders, long cancelledOrders) {
            this.totalOrders = totalOrders;
            this.pendingOrders = pendingOrders;
            this.confirmedOrders = confirmedOrders;
            this.shippedOrders = shippedOrders;
            this.deliveredOrders = deliveredOrders;
            this.cancelledOrders = cancelledOrders;
        }

        // Getters
        public long getTotalOrders() { return totalOrders; }
        public long getPendingOrders() { return pendingOrders; }
        public long getConfirmedOrders() { return confirmedOrders; }
        public long getShippedOrders() { return shippedOrders; }
        public long getDeliveredOrders() { return deliveredOrders; }
        public long getCancelledOrders() { return cancelledOrders; }
    }
}
