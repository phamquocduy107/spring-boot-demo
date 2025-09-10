package com.example.demo.service;

import com.example.demo.entity.RefreshToken;
import com.example.demo.entity.User;
import com.example.demo.repository.RefreshTokenRepository;
import com.example.demo.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Optional;

@Service
public class RefreshTokenService {

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Autowired
    private JwtUtil jwtUtil;

    public RefreshToken createRefreshToken(User user) {
        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setUser(user);
        refreshToken.setToken(jwtUtil.generateRefreshToken(user.getEmail()));
        refreshToken.setExpiryDate(Instant.now().plusMillis(1000 * 60 * 60 * 24 * 7));
        refreshTokenRepository.deleteByUserId(user.getId());
        return refreshTokenRepository.save(refreshToken);
    }

    public Optional<RefreshToken> findByToken(String token) {
        return refreshTokenRepository.findByToken(token);
    }

    public boolean validateRefreshToken(String token) {
        Optional<RefreshToken> refreshToken = findByToken(token);
        return refreshToken.isPresent() && !refreshToken.get().getExpiryDate().isBefore(Instant.now());
    }
}