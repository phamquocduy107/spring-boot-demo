# Product API Test Script
# This script tests all Product API endpoints

$baseUrl = "http://localhost:8080"
$jwtToken = $null
$adminEmail = "admin_$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())@example.com"

Write-Host "=== Product API Test Script ===" -ForegroundColor Green
Write-Host "Base URL: $baseUrl" -ForegroundColor Yellow
Write-Host ""

# Auth: Register admin and login to obtain JWT
Write-Host "=== Auth: Register + Login ===" -ForegroundColor Magenta
$adminUser = @{
    name = "Admin User"
    email = $adminEmail
    password = "admin123"
    role = "ADMIN"
}
try { Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method POST -Body ($adminUser | ConvertTo-Json) -ContentType "application/json" | Out-Null } catch { }
try {
    $loginResp = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body (@{ email = $adminEmail; password = "admin123" } | ConvertTo-Json) -ContentType "application/json"
    $jwtToken = $loginResp.accessToken
    Write-Host "Obtained JWT token" -ForegroundColor Gray
} catch {
    Write-Host "❌ Failed to login to obtain token: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Function to make HTTP requests and display results
function Test-ProductAPI {
    param(
        [string]$Method,
        [string]$Url,
        [string]$Description,
        [hashtable]$Body = $null,
        [string]$AuthToken = $null
    )
    
    Write-Host "Testing: $Description" -ForegroundColor Cyan
    Write-Host "Request: $Method $Url" -ForegroundColor Gray
    
    try {
        $headers = @{}
        if ($AuthToken) { $headers["Authorization"] = "Bearer $AuthToken" }
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 3
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Body $jsonBody -ContentType "application/json" -Headers $headers
        } else {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers
        }
        
        Write-Host "✅ SUCCESS" -ForegroundColor Green
        if ($response) {
            Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor White
        }
    }
    catch {
        Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
            Write-Host "Status Code: $statusCode" -ForegroundColor Red
        }
    }
    Write-Host ""
}

# Test 1: Get all products (should return empty list initially)
Write-Host "=== Test 1: Get All Products ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products" -Description "Get all products (should return empty list initially)" -AuthToken $jwtToken

# Test 2: Create a product
Write-Host "=== Test 2: Create Product ===" -ForegroundColor Magenta
$product = @{
    name = "Test Product"
    description = "A test product for API testing"
    sku = "TEST-$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
    price = 29.99
    stockQuantity = 100
    brand = "TestBrand"
    weight = 1.5
    dimensions = "10x10x5"
    color = "Red"
    size = "M"
    isActive = $true
    isFeatured = $true
    status = "ACTIVE"
    category = @{
        id = 1
        name = "Electronics"
        slug = "electronics"
    }
}
Test-ProductAPI -Method "POST" -Url "$baseUrl/api/products" -Description "Create a new product" -Body $product -AuthToken $jwtToken

# Test 3: Get all products (should now have 1 product)
Write-Host "=== Test 3: Get All Products After Creation ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products" -Description "Get all products after creation" -AuthToken $jwtToken

# Test 4: Get product by ID
Write-Host "=== Test 4: Get Product by ID ===" -ForegroundColor Magenta
$all = Invoke-RestMethod -Uri "$baseUrl/api/products" -Headers @{ Authorization = "Bearer $jwtToken" }
if ($all -is [System.Array]) { $pid1 = $all[0].id } else { $pid1 = $all.id }
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products/$pid1" -Description "Get product by ID $pid1" -AuthToken $jwtToken

# Test 5: Update product
Write-Host "=== Test 5: Update Product ===" -ForegroundColor Magenta
$updatedProduct = @{
    name = "Updated Test Product"
    description = "An updated test product"
    sku = "TEST-UPDATED-$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
    price = 39.99
    stockQuantity = 150
    brand = "UpdatedBrand"
    weight = 2.0
    dimensions = "12x12x6"
    color = "Blue"
    size = "L"
    isActive = $true
    isFeatured = $false
    status = "ACTIVE"
    category = @{
        id = 1
        name = "Electronics"
        slug = "electronics"
    }
}
Test-ProductAPI -Method "PUT" -Url "$baseUrl/api/products/$pid1" -Description "Update product $pid1" -Body $updatedProduct -AuthToken $jwtToken

# Test 6: Get updated product
Write-Host "=== Test 6: Get Updated Product ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products/$pid1" -Description "Get updated product $pid1" -AuthToken $jwtToken

# Test 7: Create second product
Write-Host "=== Test 7: Create Second Product ===" -ForegroundColor Magenta
$product2 = @{
    name = "Second Test Product"
    description = "Another test product"
    sku = "TEST2-$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
    price = 49.99
    stockQuantity = 50
    brand = "SecondBrand"
    weight = 2.5
    dimensions = "15x15x8"
    color = "Green"
    size = "XL"
    isActive = $true
    isFeatured = $true
    status = "ACTIVE"
    category = @{
        id = 1
        name = "Electronics"
        slug = "electronics"
    }
}
Test-ProductAPI -Method "POST" -Url "$baseUrl/api/products" -Description "Create second product" -Body $product2 -AuthToken $jwtToken

# Test 8: Get all products (should now have 2 products)
Write-Host "=== Test 8: Get All Products (2 products) ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products" -Description "Get all products (should have 2 products)" -AuthToken $jwtToken

# Test 9: Search products by name
Write-Host "=== Test 9: Search Products by Name ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products/search?keyword=Test" -Description "Search products by name 'Test'" -AuthToken $jwtToken

# Test 10: Get products by category
Write-Host "=== Test 10: Get Products by Category ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products/category/1" -Description "Get products by category ID 1" -AuthToken $jwtToken

# Test 11: Get products by price range
Write-Host "=== Test 11: Get Products by Price Range ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products/price-range?minPrice=30&maxPrice=60" -Description "Get products by price range 30-60" -AuthToken $jwtToken

# Test 12: Get active products
Write-Host "=== Test 12: Get Active Products ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products/active" -Description "Get active products" -AuthToken $jwtToken

# Test 13: Get featured products
Write-Host "=== Test 13: Get Featured Products ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products/featured" -Description "Get featured products" -AuthToken $jwtToken

# Test 14: Get products by brand
Write-Host "=== Test 14: Get Products by Brand ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products/brand/TestBrand" -Description "Get products by brand 'TestBrand'" -AuthToken $jwtToken

## Removed non-existent endpoints: color, size

# Test 17: Get low stock products
Write-Host "=== Test 17: Get Low Stock Products ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products/low-stock?threshold=75" -Description "Get products with stock less than 75" -AuthToken $jwtToken

## Removed non-existent endpoint: status

## Removed non-existent endpoint: total count

# Test 20: Get products by category slug
Write-Host "=== Test 20: Get Products by Category Slug ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products/category/slug/electronics" -Description "Get products by category slug 'electronics'" -AuthToken $jwtToken

# Test 21: Error cases
Write-Host "=== Test 21: Error Cases ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products/999" -Description "Get non-existent product (should return 404)" -AuthToken $jwtToken
Test-ProductAPI -Method "POST" -Url "$baseUrl/api/products" -Description "Create product with invalid data (should fail)" -Body @{name = ""} -AuthToken $jwtToken

# Test 22: Delete product
Write-Host "=== Test 22: Delete Product ===" -ForegroundColor Magenta
$all2 = Invoke-RestMethod -Uri "$baseUrl/api/products" -Headers @{ Authorization = "Bearer $jwtToken" }
if ($all2 -is [System.Array] -and $all2.Count -gt 1) { $pid2 = $all2[1].id } else { $pid2 = $pid1 }
Test-ProductAPI -Method "DELETE" -Url "$baseUrl/api/products/$pid2" -Description "Delete product $pid2" -AuthToken $jwtToken

# Test 23: Verify deletion
Write-Host "=== Test 23: Verify Product Deletion ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products/$pid2" -Description "Get deleted product (should return 404)" -AuthToken $jwtToken

# Test 24: Get remaining products
Write-Host "=== Test 24: Get Remaining Products ===" -ForegroundColor Magenta
Test-ProductAPI -Method "GET" -Url "$baseUrl/api/products" -Description "Get remaining products after deletion" -AuthToken $jwtToken

Write-Host "=== Product API Tests Complete ===" -ForegroundColor Green
Write-Host "Note: Make sure the application is running on $baseUrl before executing this script" -ForegroundColor Yellow
