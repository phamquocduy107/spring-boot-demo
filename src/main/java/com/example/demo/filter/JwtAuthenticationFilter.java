package com.example.demo.filter;

import com.example.demo.util.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private com.example.demo.service.UserService userService;

    private static final Logger log = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String requestUri = request.getRequestURI();
        String method = request.getMethod();
        String authorizationHeader = request.getHeader("Authorization");

        // Skip JWT processing for Swagger/OpenAPI resources
        if (requestUri.startsWith("/v3/api-docs") || requestUri.startsWith("/swagger-ui") || "/swagger-ui.html".equals(requestUri)) {
            filterChain.doFilter(request, response);
            return;
        }

        String username = null;
        String jwt = null;

        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            jwt = authorizationHeader.substring(7);
            try {
                username = jwtUtil.extractUsername(jwt);
            } catch (Exception ex) {
                log.warn("JWT extractUsername failed for {} {}: {}", method, requestUri, ex.getMessage());
            }
        } else {
            if (authorizationHeader == null) {
                log.debug("No Authorization header for {} {}", method, requestUri);
            } else {
                log.debug("Authorization header present but not Bearer for {} {}", method, requestUri);
            }
        }

        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            UserDetails userDetails = userService.findByEmail(username).orElse(null);

            if (userDetails != null && jwtUtil.validateToken(jwt, username)) {
                UsernamePasswordAuthenticationToken usernamePasswordAuthenticationToken = new UsernamePasswordAuthenticationToken(
                        userDetails, null, userDetails.getAuthorities());
                usernamePasswordAuthenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(usernamePasswordAuthenticationToken);
                log.debug("Authenticated user '{}' for {} {}", username, method, requestUri);
            } else {
                log.debug("JWT validation failed or user not found for {} {} (username={})", method, requestUri, username);
            }
        }
        filterChain.doFilter(request, response);
    }
}