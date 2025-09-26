# Cart API Test Script
# This script tests all Cart API endpoints

$baseUrl = "http://localhost:8080"
$jwtToken = $null
$adminEmail = "admin_$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())@example.com"
$userId = 1
$productId1 = $null
$productId2 = $null

Write-Host "=== Cart API Test Script ===" -ForegroundColor Green
Write-Host "Base URL: $baseUrl" -ForegroundColor Yellow
Write-Host "User ID: $userId" -ForegroundColor Yellow
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
function Test-CartAPI {
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
        $headers["Accept"] = "application/json"
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 3
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Body $jsonBody -ContentType "application/json" -Headers $headers
        } elseif ($Method -in @("POST","PUT","PATCH")) {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Body '{}' -ContentType "application/json" -Headers $headers
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

# Seed or fetch two valid products first
Write-Host "=== Seed/FETCH Products ===" -ForegroundColor Magenta
try {
    $products = Invoke-RestMethod -Uri "$baseUrl/api/products" -Headers @{ Authorization = "Bearer $jwtToken" }
    if ($products -is [System.Array] -and $products.Count -ge 2) {
        $productId1 = $products[0].id
        $productId2 = $products[1].id
    } else {
        $catId = 1
        try {
            $roots = Invoke-RestMethod -Uri "$baseUrl/api/categories/roots" -Headers @{ Authorization = "Bearer $jwtToken" }
            if ($roots -is [System.Array] -and $roots.Count -gt 0) { $catId = $roots[0].id }
        } catch {}
        $p1 = @{ name = "Cart Prod $([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())-1"; description = "p1"; sku = "CART-P-$(Get-Random)"; price = 10.0; stockQuantity = 100; category = @{ id = $catId } }
        $r1 = Invoke-RestMethod -Uri "$baseUrl/api/products" -Method POST -Body ($p1 | ConvertTo-Json) -ContentType "application/json" -Headers @{ Authorization = "Bearer $jwtToken" }
        $productId1 = $r1.id
        Start-Sleep -Milliseconds 300
        $p2 = @{ name = "Cart Prod $([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())-2"; description = "p2"; sku = "CART-P-$(Get-Random)"; price = 15.0; stockQuantity = 100; category = @{ id = $catId } }
        $r2 = Invoke-RestMethod -Uri "$baseUrl/api/products" -Method POST -Body ($p2 | ConvertTo-Json) -ContentType "application/json" -Headers @{ Authorization = "Bearer $jwtToken" }
        $productId2 = $r2.id
    }
    Write-Host "Using product ids: $productId1, $productId2" -ForegroundColor Gray
} catch { Write-Host "(Product seed/fetch failed)" -ForegroundColor Yellow }

# Test 1: Get empty cart (should return 404)
Write-Host "=== Test 1: Get Empty Cart ===" -ForegroundColor Magenta
Test-CartAPI -Method "GET" -Url "$baseUrl/api/cart" -Description "Get empty cart (should return 404)" -AuthToken $jwtToken

# Test 2: Add first item to cart
Write-Host "=== Test 2: Add First Item to Cart ===" -ForegroundColor Magenta
Write-Host "Testing: Add 2 units of product $productId1 to cart" -ForegroundColor Cyan
$headers = @{ Authorization = "Bearer $jwtToken"; Accept = "application/json" }
try {
    $resp = Invoke-RestMethod -Uri "$baseUrl/api/cart/items?productId=$productId1&quantity=2" -Method POST -Headers $headers -ContentType "application/json" -Body '{}'
    Write-Host "✅ SUCCESS" -ForegroundColor Green
    if ($resp) { Write-Host "Response: $($resp | ConvertTo-Json -Depth 3)" }
} catch { Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red }

# Test 3: Get cart with items
Write-Host "=== Test 3: Get Cart with Items ===" -ForegroundColor Magenta
Test-CartAPI -Method "GET" -Url "$baseUrl/api/cart" -Description "Get cart with items" -AuthToken $jwtToken

# Test 4: Add second item to cart
Write-Host "=== Test 4: Add Second Item to Cart ===" -ForegroundColor Magenta
Write-Host "Testing: Add 1 unit of product $productId2 to cart" -ForegroundColor Cyan
try {
    $resp = Invoke-RestMethod -Uri "$baseUrl/api/cart/items?productId=$productId2&quantity=1" -Method POST -Headers $headers -ContentType "application/json" -Body '{}'
    Write-Host "✅ SUCCESS" -ForegroundColor Green
    if ($resp) { Write-Host "Response: $($resp | ConvertTo-Json -Depth 3)" }
} catch { Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red }

# Test 5: Update quantity of first item
Write-Host "=== Test 5: Update Item Quantity ===" -ForegroundColor Magenta
Write-Host "Testing: Update quantity of product $productId1 to 5" -ForegroundColor Cyan
try {
    $resp = Invoke-RestMethod -Uri "$baseUrl/api/cart/items/$productId1?quantity=5" -Method PUT -Headers $headers -ContentType "application/json" -Body '{}'
    Write-Host "✅ SUCCESS" -ForegroundColor Green
    if ($resp) { Write-Host "Response: $($resp | ConvertTo-Json -Depth 3)" }
} catch { Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red }

# Test 6: Get updated cart
Write-Host "=== Test 6: Get Updated Cart ===" -ForegroundColor Magenta
Test-CartAPI -Method "GET" -Url "$baseUrl/api/cart" -Description "Get updated cart" -AuthToken $jwtToken

# Test 7: Remove second item
Write-Host "=== Test 7: Remove Item ===" -ForegroundColor Magenta
Write-Host "Testing: Remove product $productId2" -ForegroundColor Cyan
try {
    Invoke-RestMethod -Uri "$baseUrl/api/cart/items/$productId2" -Method DELETE -Headers $headers | Out-Null
    Write-Host "✅ SUCCESS" -ForegroundColor Green
} catch { Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red }

# Test 8: Get cart after removal
Write-Host "=== Test 8: Get Cart After Removal ===" -ForegroundColor Magenta
Test-CartAPI -Method "GET" -Url "$baseUrl/api/cart" -Description "Get cart after item removal" -AuthToken $jwtToken

# Test 9: Clear entire cart
Write-Host "=== Test 9: Clear Cart ===" -ForegroundColor Magenta
Test-CartAPI -Method "DELETE" -Url "$baseUrl/api/cart" -Description "Clear entire cart" -AuthToken $jwtToken

# Test 10: Verify empty cart
Write-Host "=== Test 10: Verify Empty Cart ===" -ForegroundColor Magenta
Test-CartAPI -Method "GET" -Url "$baseUrl/api/cart" -Description "Verify cart is empty after clearing" -AuthToken $jwtToken

# Test 11: Error cases
Write-Host "=== Test 11: Error Cases ===" -ForegroundColor Magenta
Write-Host "Testing: Add non-existent product (curl)" -ForegroundColor Cyan
$curlUrl5 = "$baseUrl/api/cart/items?productId=999&quantity=1"
& curl.exe -s -o - -w "%{http_code}\n" -X POST "$curlUrl5" -H "Authorization: Bearer $jwtToken" -H "Content-Type: application/json" | Write-Host
Write-Host "Testing: Add item with zero quantity (curl)" -ForegroundColor Cyan
$curlUrl6 = "$baseUrl/api/cart/items?productId=$productId1&quantity=0"
& curl.exe -s -o - -w "%{http_code}\n" -X POST "$curlUrl6" -H "Authorization: Bearer $jwtToken" -H "Content-Type: application/json" | Write-Host

Write-Host "=== Cart API Tests Complete ===" -ForegroundColor Green
Write-Host "Note: Make sure the application is running on $baseUrl before executing this script" -ForegroundColor Yellow
