package com.example.demo.enums;

public enum PaymentMethod {
    CASH_ON_DELIVERY("Thanh toán khi nhận hàng"),
    BANK_TRANSFER("Chuyển khoản ngân hàng"),
    CREDIT_CARD("Thẻ tín dụng"),
    PAYPAL("PayPal"),
    MOMO("Ví MoMo"),
    ZALOPAY("Ví ZaloPay");
    
    private final String description;
    
    PaymentMethod(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}
