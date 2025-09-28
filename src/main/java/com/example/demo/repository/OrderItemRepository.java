package com.example.demo.repository;

import com.example.demo.entity.OrderItem;
import com.example.demo.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {

    // Find order items by order
    List<OrderItem> findByOrderIdOrderById(Long orderId);

    // Find order items by product
    List<OrderItem> findByProductOrderByOrderOrderDateDesc(Product product);

    // Find order items with product changes
    @Query("SELECT oi FROM OrderItem oi WHERE oi.productNameChanged = true OR oi.productPriceChanged = true")
    List<OrderItem> findItemsWithProductChanges();

    // Find order items by product ID
    @Query("SELECT oi FROM OrderItem oi WHERE oi.product.id = :productId")
    List<OrderItem> findByProductId(@Param("productId") Long productId);

    // Find order items by category
    @Query("SELECT oi FROM OrderItem oi JOIN oi.product p WHERE p.category.id = :categoryId")
    List<OrderItem> findByCategoryId(@Param("categoryId") Long categoryId);

    // Find most ordered products
    @Query("SELECT oi.product, SUM(oi.quantity) as totalQuantity FROM OrderItem oi GROUP BY oi.product ORDER BY totalQuantity DESC")
    List<Object[]> findMostOrderedProducts();

    // Find products with price changes
    @Query("SELECT oi FROM OrderItem oi WHERE oi.productPriceChanged = true ORDER BY oi.order.orderDate DESC")
    List<OrderItem> findProductsWithPriceChanges();

    // Find products with name changes
    @Query("SELECT oi FROM OrderItem oi WHERE oi.productNameChanged = true ORDER BY oi.order.orderDate DESC")
    List<OrderItem> findProductsWithNameChanges();

    // Count total quantity sold for a product
    @Query("SELECT SUM(oi.quantity) FROM OrderItem oi WHERE oi.product.id = :productId")
    Long countTotalQuantitySoldByProduct(@Param("productId") Long productId);

    // Find order items with specific product name at order time
    @Query("SELECT oi FROM OrderItem oi WHERE oi.productNameAtOrder = :productName")
    List<OrderItem> findByProductNameAtOrder(@Param("productName") String productName);

    // Find order items with specific product SKU at order time
    @Query("SELECT oi FROM OrderItem oi WHERE oi.productSkuAtOrder = :productSku")
    List<OrderItem> findByProductSkuAtOrder(@Param("productSku") String productSku);

    // Find order items by price range at order time
    @Query("SELECT oi FROM OrderItem oi WHERE oi.unitPriceAtOrder BETWEEN :minPrice AND :maxPrice")
    List<OrderItem> findByUnitPriceAtOrderBetween(@Param("minPrice") java.math.BigDecimal minPrice, 
                                                 @Param("maxPrice") java.math.BigDecimal maxPrice);

    // Find order items by quantity range
    @Query("SELECT oi FROM OrderItem oi WHERE oi.quantity BETWEEN :minQuantity AND :maxQuantity")
    List<OrderItem> findByQuantityBetween(@Param("minQuantity") Integer minQuantity, 
                                         @Param("maxQuantity") Integer maxQuantity);

    // Find order items with total price range
    @Query("SELECT oi FROM OrderItem oi WHERE oi.totalPrice BETWEEN :minTotal AND :maxTotal")
    List<OrderItem> findByTotalPriceBetween(@Param("minTotal") java.math.BigDecimal minTotal, 
                                          @Param("maxTotal") java.math.BigDecimal maxTotal);

    // Find order items for revenue analysis
    @Query("SELECT oi.product.category.name, SUM(oi.totalPrice) as totalRevenue FROM OrderItem oi GROUP BY oi.product.category.name ORDER BY totalRevenue DESC")
    List<Object[]> findRevenueByCategory();

    // Find order items for product performance analysis
    @Query("SELECT oi.product.name, COUNT(oi) as orderCount, SUM(oi.quantity) as totalQuantity, SUM(oi.totalPrice) as totalRevenue FROM OrderItem oi GROUP BY oi.product.name ORDER BY totalRevenue DESC")
    List<Object[]> findProductPerformance();
}
