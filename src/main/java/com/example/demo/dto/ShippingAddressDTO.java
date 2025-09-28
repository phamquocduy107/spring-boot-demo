package com.example.demo.dto;

import com.example.demo.entity.ShippingAddress;

public class ShippingAddressDTO {
    private Long id;
    private String fullName;
    private String phone;
    private String addressLine1;
    private String addressLine2;
    private String city;
    private String state;
    private String postalCode;
    private String country;
    private String fullAddress;

    // Constructors
    public ShippingAddressDTO() {}

    public ShippingAddressDTO(ShippingAddress shippingAddress) {
        this.id = shippingAddress.getId();
        this.fullName = shippingAddress.getFullName();
        this.phone = shippingAddress.getPhone();
        this.addressLine1 = shippingAddress.getAddressLine1();
        this.addressLine2 = shippingAddress.getAddressLine2();
        this.city = shippingAddress.getCity();
        this.state = shippingAddress.getState();
        this.postalCode = shippingAddress.getPostalCode();
        this.country = shippingAddress.getCountry();
        this.fullAddress = shippingAddress.getFullAddress();
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddressLine1() { return addressLine1; }
    public void setAddressLine1(String addressLine1) { this.addressLine1 = addressLine1; }

    public String getAddressLine2() { return addressLine2; }
    public void setAddressLine2(String addressLine2) { this.addressLine2 = addressLine2; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getPostalCode() { return postalCode; }
    public void setPostalCode(String postalCode) { this.postalCode = postalCode; }

    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }

    public String getFullAddress() { return fullAddress; }
    public void setFullAddress(String fullAddress) { this.fullAddress = fullAddress; }
}
