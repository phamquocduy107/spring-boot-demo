package com.example.demo.service;

import com.example.demo.entity.Cart;
import com.example.demo.entity.Product;
import com.example.demo.entity.User;
import com.example.demo.repository.CartRepository;
import com.example.demo.repository.ProductRepository;
import com.example.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.util.Optional;

@Service
public class CartService {

    private static final String CART_KEY_PREFIX = "cart:";
    private static final Duration CART_TTL = Duration.ofMinutes(30);

    @Autowired private CartRepository cartRepository;
    @Autowired private ProductRepository productRepository;
    @Autowired private RedisTemplate<String, Object> redisTemplate;
    @Autowired private UserRepository userRepository;

    private String key(Long userId) { return CART_KEY_PREFIX + userId; }

    public Optional<Cart> getActiveCartFromCache(Long userId) {
        ValueOperations<String, Object> ops = redisTemplate.opsForValue();
        Object obj = ops.get(key(userId));
        if (obj instanceof Cart) {
            return Optional.of((Cart) obj);
        }
        return Optional.empty();
    }

    @Transactional
    public Cart getOrCreateActiveCart(Long userId) {
        return cartRepository.findByUser_IdAndIsActiveTrue(userId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new IllegalArgumentException("User not found"));
                    Cart c = new Cart();
                    c.setUser(user);
                    c.setIsActive(true);
                    return cartRepository.save(c);
                });
    }

    @Transactional
    public Cart addItem(Long userId, Long productId, int quantity) {
        Cart cart = getOrCreateActiveCart(userId);
        if (quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be positive");
        }
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));
        BigDecimal priceAtAdd = product.getPrice();
        cart.addItem(product, quantity, priceAtAdd);
        Cart saved = cartRepository.save(cart);
        cache(userId, saved);
        return saved;
    }

    @Transactional
    public Cart updateQuantity(Long userId, Long productId, int quantity) {
        Cart cart = getOrCreateActiveCart(userId);
        if (quantity <= 0) {
            cart.removeItemByProductId(productId);
        } else {
            cart.updateQuantity(productId, quantity);
        }
        Cart saved = cartRepository.save(cart);
        cache(userId, saved);
        return saved;
    }

    @Transactional
    public void removeItem(Long userId, Long productId) {
        Cart cart = getOrCreateActiveCart(userId);
        cart.removeItemByProductId(productId);
        cartRepository.save(cart);
        cache(userId, cart);
    }

    @Transactional
    public void clear(Long userId) {
        Cart cart = getOrCreateActiveCart(userId);
        cart.getItems().clear();
        cart.recalculateTotals();
        cartRepository.save(cart);
        evict(userId);
    }

    public Optional<Cart> getActiveCart(Long userId) {
        // Prefer database as source of truth; cache deserialization may not yield Cart instance
        Optional<Cart> fromDb = cartRepository.findByUser_IdAndIsActiveTrue(userId);
        if (fromDb.isPresent()) {
            return fromDb;
        }
        return getActiveCartFromCache(userId);
    }

    private void cache(Long userId, Cart cart) {
        ValueOperations<String, Object> ops = redisTemplate.opsForValue();
        ops.set(key(userId), cart, CART_TTL);
    }

    private void evict(Long userId) {
        redisTemplate.delete(key(userId));
    }
}


