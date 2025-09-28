package com.example.demo.enums;

public enum UserRole {
    USER("Người dùng"),
    ADMIN("Quản trị viên"),
    MODERATOR("Điều hành viên");
    
    private final String description;
    
    UserRole(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
    
    public String getAuthority() {
        return "ROLE_" + this.name();
    }
}
