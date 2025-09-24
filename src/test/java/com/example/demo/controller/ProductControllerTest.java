package com.example.demo.controller;

import com.example.demo.entity.Category;
import com.example.demo.entity.Product;
import com.example.demo.service.ProductService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@ActiveProfiles("test")
public class ProductControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockitoBean
    private ProductService productService;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    private Product testProduct;
    
    @BeforeEach
    void setUp() {
        Category category = new Category("Electronics", "electronics");
        category.setId(10L);

        testProduct = new Product();
        testProduct.setId(1L);
        testProduct.setName("Test Product");
        testProduct.setDescription("Test Description");
        testProduct.setSku("TEST-001");
        testProduct.setPrice(new BigDecimal("99.99"));
        testProduct.setStockQuantity(100);
        testProduct.setCategory(category);
        testProduct.setBrand("TestBrand");
        testProduct.setIsActive(true);
        testProduct.setStatus(Product.ProductStatus.ACTIVE);
    }
    
    @Test
    void testCreateProduct_Success() throws Exception {
        when(productService.createProduct(any(Product.class))).thenReturn(testProduct);
        
        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(testProduct)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.name").value("Test Product"))
                .andExpect(jsonPath("$.sku").value("TEST-001"))
                .andExpect(jsonPath("$.price").value(99.99));
        
        verify(productService, times(1)).createProduct(any(Product.class));
    }
    
    @Test
    void testCreateProduct_ValidationError() throws Exception {
        when(productService.createProduct(any(Product.class)))
                .thenThrow(new IllegalArgumentException("Product with SKU 'TEST-001' already exists"));
        
        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(testProduct)))
                .andExpect(status().isBadRequest())
                .andExpect(content().string("Error: Product with SKU 'TEST-001' already exists"));
    }
    
    @Test
    void testGetAllProducts() throws Exception {
        List<Product> products = Arrays.asList(testProduct);
        when(productService.getAllProducts()).thenReturn(products);
        
        mockMvc.perform(get("/api/products"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].name").value("Test Product"));
    }
    
    @Test
    void testGetProductById_Success() throws Exception {
        when(productService.getProductById(1L)).thenReturn(Optional.of(testProduct));
        
        mockMvc.perform(get("/api/products/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.name").value("Test Product"));
    }
    
    @Test
    void testGetProductById_NotFound() throws Exception {
        when(productService.getProductById(1L)).thenReturn(Optional.empty());
        
        mockMvc.perform(get("/api/products/1"))
                .andExpect(status().isNotFound());
    }
    
    @Test
    void testUpdateProduct_Success() throws Exception {
        when(productService.updateProduct(anyLong(), any(Product.class))).thenReturn(testProduct);
        
        mockMvc.perform(put("/api/products/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(testProduct)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.name").value("Test Product"));
    }
    
    @Test
    void testDeleteProduct_Success() throws Exception {
        doNothing().when(productService).deleteProduct(1L);
        
        mockMvc.perform(delete("/api/products/1"))
                .andExpect(status().isOk())
                .andExpect(content().string("Product deleted successfully"));
    }
    
    @Test
    void testGetProductsByCategoryId() throws Exception {
        List<Product> products = Arrays.asList(testProduct);
        when(productService.getProductsByCategoryId(10L)).thenReturn(products);
        
        mockMvc.perform(get("/api/products/category/10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void testGetProductsByCategorySlug() throws Exception {
        List<Product> products = Arrays.asList(testProduct);
        when(productService.getProductsByCategorySlug("electronics")).thenReturn(products);

        mockMvc.perform(get("/api/products/category/slug/electronics"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }
    
    @Test
    void testGetActiveProducts() throws Exception {
        List<Product> products = Arrays.asList(testProduct);
        when(productService.getActiveProducts()).thenReturn(products);
        
        mockMvc.perform(get("/api/products/active"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].isActive").value(true));
    }
    
    @Test
    void testSearchProducts() throws Exception {
        List<Product> products = Arrays.asList(testProduct);
        when(productService.searchProducts("test")).thenReturn(products);
        
        mockMvc.perform(get("/api/products/search?keyword=test"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].name").value("Test Product"));
    }
    
    @Test
    void testUpdateStock_Success() throws Exception {
        when(productService.updateStock(1L, 50)).thenReturn(testProduct);
        
        mockMvc.perform(put("/api/products/1/stock?quantity=50"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1));
    }
    
    @Test
    void testGetLowStockProducts() throws Exception {
        List<Product> products = Arrays.asList(testProduct);
        when(productService.getLowStockProducts(10)).thenReturn(products);
        
        mockMvc.perform(get("/api/products/low-stock?threshold=10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }
}
