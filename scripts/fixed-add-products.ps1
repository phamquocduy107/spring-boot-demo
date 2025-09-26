# Fixed Add Products Script
$baseUrl = "http://localhost:8080"

Write-Host "🚀 Fixed Product Creation" -ForegroundColor Green
Write-Host "=" * 30

# Step 1: Authenticate
Write-Host "🔐 Authenticating..." -ForegroundColor Cyan
$loginResp = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body (@{ email = "duydeptrai@example.com"; password = "pass123" } | ConvertTo-Json) -ContentType "application/json"
$jwtToken = $loginResp.accessToken
Write-Host "✅ Authenticated successfully" -ForegroundColor Green

# Step 2: Use default category ID (assuming 1 exists)
$catId = 1
Write-Host "📂 Using default category ID: $catId" -ForegroundColor Yellow

# Step 3: Define products
$products = @(
    @{ name = "Dell Laptop"; description = "High-performance laptop"; sku = "DELL-001"; price = 25000000; stockQuantity = 50; brand = "Dell"; color = "Silver"; size = "13inch"; isActive = $true; category = @{ id = $catId } },
    @{ name = "iPhone 15"; description = "Latest iPhone"; sku = "APPLE-001"; price = 35000000; stockQuantity = 30; brand = "Apple"; color = "Black"; size = "6.1inch"; isActive = $true; category = @{ id = $catId } },
    @{ name = "Samsung Galaxy"; description = "Android smartphone"; sku = "SAMSUNG-001"; price = 32000000; stockQuantity = 25; brand = "Samsung"; color = "Blue"; size = "6.8inch"; isActive = $true; category = @{ id = $catId } },
    @{ name = "Nike Shoes"; description = "Running shoes"; sku = "NIKE-001"; price = 4500000; stockQuantity = 100; brand = "Nike"; color = "White"; size = "42"; isActive = $true; category = @{ id = $catId } },
    @{ name = "Adidas Shoes"; description = "Sports shoes"; sku = "ADIDAS-001"; price = 5200000; stockQuantity = 80; brand = "Adidas"; color = "Black"; size = "42"; isActive = $true; category = @{ id = $catId } },
    @{ name = "Levi's Jeans"; description = "Classic jeans"; sku = "LEVIS-001"; price = 2500000; stockQuantity = 150; brand = "Levi's"; color = "Blue"; size = "32"; isActive = $true; category = @{ id = $catId } },
    @{ name = "Uniqlo Shirt"; description = "Comfortable shirt"; sku = "UNIQLO-001"; price = 450000; stockQuantity = 200; brand = "Uniqlo"; color = "White"; size = "M"; isActive = $true; category = @{ id = $catId } },
    @{ name = "Sony Headphones"; description = "Noise-canceling headphones"; sku = "SONY-001"; price = 8500000; stockQuantity = 40; brand = "Sony"; color = "Black"; size = "One Size"; isActive = $true; category = @{ id = $catId } },
    @{ name = "AirPods Pro"; description = "Wireless earbuds"; sku = "APPLE-002"; price = 6500000; stockQuantity = 60; brand = "Apple"; color = "White"; size = "One Size"; isActive = $true; category = @{ id = $catId } },
    @{ name = "MacBook Pro"; description = "Professional laptop"; sku = "APPLE-003"; price = 45000000; stockQuantity = 20; brand = "Apple"; color = "Gray"; size = "14inch"; isActive = $true; category = @{ id = $catId } }
)

# Step 4: Create products
Write-Host "`n🛍️ Creating products..." -ForegroundColor Cyan
$created = 0
$failed = 0

for ($i = 0; $i -lt $products.Count; $i++) {
    $product = $products[$i]
    $productNumber = $i + 1
    
    Write-Host "Creating $productNumber. $($product.name)..." -ForegroundColor Yellow
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/products" -Method POST -Body ($product | ConvertTo-Json -Depth 3) -ContentType "application/json" -Headers @{ Authorization = "Bearer $jwtToken" }
        $created++
        Write-Host "✅ $productNumber. $($product.name) created (ID: $($response.id))" -ForegroundColor Green
    }
    catch {
        $failed++
        Write-Host "❌ $productNumber. $($product.name) failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            Write-Host "   Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        }
    }
    
    Start-Sleep -Milliseconds 300
}

# Step 5: Summary
Write-Host "`n📊 Summary:" -ForegroundColor Yellow
Write-Host "   - Created: $created products" -ForegroundColor Green
Write-Host "   - Failed: $failed products" -ForegroundColor Red

# Step 6: Verify
Write-Host "`n🔍 Verifying products..." -ForegroundColor Cyan
try {
    $allProducts = Invoke-RestMethod -Uri "$baseUrl/api/products" -Headers @{ Authorization = "Bearer $jwtToken" }
    Write-Host "✅ Found $($allProducts.Count) products in database" -ForegroundColor Green
    
    if ($allProducts.Count -ge 8) {
        Write-Host "`n🎉 SUCCESS! Products created successfully" -ForegroundColor Green
        Write-Host "`n🔍 Test search service:" -ForegroundColor Yellow
        Write-Host "curl 'http://localhost:8092/search?q=laptop'" -ForegroundColor White
        Write-Host "curl -X POST 'http://localhost:8092/reindex'" -ForegroundColor White
        Write-Host "curl 'http://localhost:8092/search?q=&brand=Apple'" -ForegroundColor White
        Write-Host "curl 'http://localhost:8092/search?q=&color=Black'" -ForegroundColor White
    } else {
        Write-Host "`n⚠️ Warning: Expected 8+ products, found $($allProducts.Count)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Failed to verify products: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✅ Script completed!" -ForegroundColor Green
