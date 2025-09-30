package com.example.demo.controller;

import com.example.demo.entity.Cart;
import com.example.demo.entity.User;
import com.example.demo.service.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.validation.annotation.Validated;
import jakarta.validation.constraints.Min;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import java.util.Optional;
import com.example.demo.dto.CartDTO;
import com.example.demo.mapper.DtoMapper;

@RestController
@RequestMapping("/api/cart")
@Validated
public class CartController {

    @Autowired
    private CartService cartService;

    // For simplicity, accept userId as request param/body in this example
    @GetMapping
    public ResponseEntity<CartDTO> getCart(@AuthenticationPrincipal User currentUser) {
        Optional<Cart> cart = cartService.getActiveCart(currentUser.getId());
        return cart.map(c -> ResponseEntity.ok(DtoMapper.toCartDTO(c)))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping("/items")
    public ResponseEntity<CartDTO> addItem(@AuthenticationPrincipal User currentUser,
                                        @RequestParam Long productId,
                                        @RequestParam @Min(1) int quantity) {
        try {
            Cart updated = cartService.addItem(currentUser.getId(), productId, quantity);
            return ResponseEntity.ok(DtoMapper.toCartDTO(updated));
        } catch (java.util.NoSuchElementException ex) {
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PutMapping("/items/{productId}")
    public ResponseEntity<CartDTO> updateQty(@AuthenticationPrincipal User currentUser,
                                          @PathVariable Long productId,
                                          @RequestParam @Min(1) int quantity) {
        try {
            Cart updated = cartService.updateQuantity(currentUser.getId(), productId, quantity);
            return ResponseEntity.ok(DtoMapper.toCartDTO(updated));
        } catch (java.util.NoSuchElementException ex) {
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().build();
        }
    }

    @DeleteMapping("/items/{productId}")
    public ResponseEntity<Void> removeItem(@AuthenticationPrincipal User currentUser,
                                           @PathVariable Long productId) {
        try {
            cartService.removeItem(currentUser.getId(), productId);
            return ResponseEntity.noContent().build();
        } catch (java.util.NoSuchElementException ex) {
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().build();
        }
    }

    @DeleteMapping
    public ResponseEntity<Void> clear(@AuthenticationPrincipal User currentUser) {
        try {
            cartService.clear(currentUser.getId());
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().build();
        }
    }
}


