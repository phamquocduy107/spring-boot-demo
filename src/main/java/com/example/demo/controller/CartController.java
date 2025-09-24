package com.example.demo.controller;

import com.example.demo.entity.Cart;
import com.example.demo.service.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/cart")
public class CartController {

    @Autowired
    private CartService cartService;

    // For simplicity, accept userId as request param/body in this example
    @GetMapping
    public ResponseEntity<Cart> getCart(@RequestParam Long userId) {
        Optional<Cart> cart = cartService.getActiveCart(userId);
        return cart.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping("/items")
    public ResponseEntity<Cart> addItem(@RequestParam Long userId,
                                        @RequestParam Long productId,
                                        @RequestParam int quantity) {
        Cart updated = cartService.addItem(userId, productId, quantity);
        return ResponseEntity.ok(updated);
    }

    @PutMapping("/items/{productId}")
    public ResponseEntity<Cart> updateQty(@RequestParam Long userId,
                                          @PathVariable Long productId,
                                          @RequestParam int quantity) {
        Cart updated = cartService.updateQuantity(userId, productId, quantity);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/items/{productId}")
    public ResponseEntity<Void> removeItem(@RequestParam Long userId,
                                           @PathVariable Long productId) {
        cartService.removeItem(userId, productId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> clear(@RequestParam Long userId) {
        cartService.clear(userId);
        return ResponseEntity.noContent().build();
    }
}


