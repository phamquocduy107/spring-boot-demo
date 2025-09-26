package com.example.demo.service;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    @Lazy
    private BCryptPasswordEncoder passwordEncoder;

    public User registerUser(@Valid User user) {
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            throw new RuntimeException("Email already exists");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        if (user.getRole() == null) {
            user.setRole("USER");
        }
        return userRepository.save(user);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public User createUser(User user) {
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            throw new RuntimeException("Email already exists");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        if (user.getRole() == null) {
            user.setRole("USER");
        }
        return userRepository.save(user);
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    public User updateUser(Long id, User userDetails) {
        Optional<User> userOptional = userRepository.findById(id);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            user.setName(userDetails.getName());
            user.setEmail(userDetails.getEmail());
            return userRepository.save(user);
        }
        return null;
    }

    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
}