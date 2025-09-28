package com.example.demo.repository;

import com.example.demo.entity.Order;
import com.example.demo.enums.OrderStatus;
import com.example.demo.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    // Find orders by user
    List<Order> findByUserOrderByOrderDateDesc(User user);

    // Find orders by status
    List<Order> findByStatusOrderByOrderDateDesc(OrderStatus status);

    // Find orders by user and status
    List<Order> findByUserAndStatusOrderByOrderDateDesc(User user, OrderStatus status);

    // Find order by order number
    Optional<Order> findByOrderNumber(String orderNumber);

    // Find orders by date range
    List<Order> findByOrderDateBetweenOrderByOrderDateDesc(LocalDateTime startDate, LocalDateTime endDate);

    // Find orders by user and date range
    List<Order> findByUserAndOrderDateBetweenOrderByOrderDateDesc(User user, LocalDateTime startDate, LocalDateTime endDate);

    // Count orders by status
    long countByStatus(OrderStatus status);

    // Count orders by user
    long countByUser(User user);

    // Find orders with product changes
    @Query("SELECT DISTINCT o FROM Order o JOIN o.items i WHERE i.productNameChanged = true OR i.productPriceChanged = true")
    List<Order> findOrdersWithProductChanges();

    // Find orders by product
    @Query("SELECT DISTINCT o FROM Order o JOIN o.items i WHERE i.product.id = :productId")
    List<Order> findByProductId(@Param("productId") Long productId);

    // Find orders by category
    @Query("SELECT DISTINCT o FROM Order o JOIN o.items i JOIN i.product p WHERE p.category.id = :categoryId")
    List<Order> findByCategoryId(@Param("categoryId") Long categoryId);

    // Find recent orders (last 30 days)
    @Query("SELECT o FROM Order o WHERE o.orderDate >= :since ORDER BY o.orderDate DESC")
    List<Order> findRecentOrders(@Param("since") LocalDateTime since);

    // Find orders pending for too long
    @Query("SELECT o FROM Order o WHERE o.status = 'PENDING' AND o.orderDate < :threshold")
    List<Order> findPendingOrdersOlderThan(@Param("threshold") LocalDateTime threshold);

    // Find orders by payment method
    @Query("SELECT o FROM Order o JOIN o.payment p WHERE p.paymentMethod = :paymentMethod")
    List<Order> findByPaymentMethod(@Param("paymentMethod") String paymentMethod);

    // Find orders by payment status
    @Query("SELECT o FROM Order o JOIN o.payment p WHERE p.paymentStatus = :paymentStatus")
    List<Order> findByPaymentStatus(@Param("paymentStatus") String paymentStatus);

    // Find orders with shipping address in city
    @Query("SELECT o FROM Order o JOIN o.shippingAddress sa WHERE sa.city = :city")
    List<Order> findByShippingCity(@Param("city") String city);

    // Find orders by total amount range
    @Query("SELECT o FROM Order o WHERE o.totalAmount BETWEEN :minAmount AND :maxAmount ORDER BY o.totalAmount DESC")
    List<Order> findByTotalAmountBetween(@Param("minAmount") java.math.BigDecimal minAmount, 
                                        @Param("maxAmount") java.math.BigDecimal maxAmount);

    // Find top customers by order count
    @Query("SELECT o.user, COUNT(o) as orderCount FROM Order o GROUP BY o.user ORDER BY orderCount DESC")
    List<Object[]> findTopCustomersByOrderCount();

    // Find top customers by total spent
    @Query("SELECT o.user, SUM(o.totalAmount) as totalSpent FROM Order o GROUP BY o.user ORDER BY totalSpent DESC")
    List<Object[]> findTopCustomersByTotalSpent();

    // Find orders that need attention (pending for more than 24 hours)
    @Query("SELECT o FROM Order o WHERE o.status = 'PENDING' AND o.orderDate < :threshold ORDER BY o.orderDate ASC")
    List<Order> findOrdersNeedingAttention(@Param("threshold") LocalDateTime threshold);
}
