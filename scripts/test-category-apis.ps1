# Category API Test Script
# This script tests all Category API endpoints

$baseUrl = "http://localhost:8080"
$jwtToken = $null
$adminEmail = "admin_$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())@example.com"

Write-Host "=== Category API Test Script ===" -ForegroundColor Green
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
function Test-CategoryAPI {
    param(
        [string]$Method,
        [string]$Url,
        [string]$Description,
        [object]$Body = $null,
        [string]$AuthToken = $null
    )
    
    Write-Host "Testing: $Description" -ForegroundColor Cyan
    Write-Host "Request: $Method $Url" -ForegroundColor Gray
    
    try {
        $headers = @{}
        if ($AuthToken) { $headers["Authorization"] = "Bearer $AuthToken" }
        if ($Body) {
            if ($Body -is [System.Array]) {
                $jsonBody = (, $Body) | ConvertTo-Json -Depth 3
            } else {
                $jsonBody = $Body | ConvertTo-Json -Depth 3
            }
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
            try {
                $resp = $_.Exception.Response
                $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
                $errorBody = $reader.ReadToEnd()
                if ($errorBody) { Write-Host "Error Body: $errorBody" -ForegroundColor DarkYellow }
            } catch {}
        }
    }
    Write-Host ""
}

# Test 1: Create root category
Write-Host "=== Test 1: Create Root Category ===" -ForegroundColor Magenta
$rootCategory = @{
    name = "Electronics"
    slug = "electronics"
    description = "Electronic devices and gadgets"
    isActive = $true
}
Test-CategoryAPI -Method "POST" -Url "$baseUrl/api/categories" -Description "Create root category 'Electronics'" -Body $rootCategory -AuthToken $jwtToken

# Test 2: Create child category
Write-Host "=== Test 2: Create Child Category ===" -ForegroundColor Magenta
$childCategory = @{
    name = "Smartphones"
    slug = "smartphones"
    description = "Mobile phones and accessories"
    isActive = $true
}
Test-CategoryAPI -Method "POST" -Url "$baseUrl/api/categories/1/children" -Description "Create child category 'Smartphones' under Electronics" -Body $childCategory -AuthToken $jwtToken

# Test 3: Get all categories
Write-Host "=== Test 3: Get All Categories ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "GET" -Url "$baseUrl/api/categories/active" -Description "Get all active categories" -AuthToken $jwtToken

# Test 4: Get category tree
Write-Host "=== Test 4: Get Category Tree ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "GET" -Url "$baseUrl/api/categories/tree" -Description "Get category tree structure" -AuthToken $jwtToken

# Test 5: Get root categories
Write-Host "=== Test 5: Get Root Categories ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "GET" -Url "$baseUrl/api/categories/roots" -Description "Get root categories only" -AuthToken $jwtToken

# Test 6: Search categories
Write-Host "=== Test 6: Search Categories ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "GET" -Url "$baseUrl/api/categories/search?q=electronics" -Description "Search categories by term 'electronics'" -AuthToken $jwtToken

# Test 7: Get category by slug
Write-Host "=== Test 7: Get Category by Slug ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "GET" -Url "$baseUrl/api/categories/slug/electronics" -Description "Get category by slug 'electronics'" -AuthToken $jwtToken

# Test 8: Get specific category
Write-Host "=== Test 8: Get Specific Category ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "GET" -Url "$baseUrl/api/categories/1" -Description "Get category with ID 1" -AuthToken $jwtToken

# Test 9: Get children of category
Write-Host "=== Test 9: Get Category Children ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "GET" -Url "$baseUrl/api/categories/1/children" -Description "Get children of category 1" -AuthToken $jwtToken

# Test 10: Get category path
Write-Host "=== Test 10: Get Category Path ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "GET" -Url "$baseUrl/api/categories/2/path" -Description "Get path to category 2" -AuthToken $jwtToken

# Test 11: Update category
Write-Host "=== Test 11: Update Category ===" -ForegroundColor Magenta
$updateCategory = @{
    name = "Updated Electronics"
    slug = "updated-electronics"
    description = "Updated description for electronics"
    isActive = $true
}
Test-CategoryAPI -Method "PUT" -Url "$baseUrl/api/categories/1" -Description "Update category 1" -Body $updateCategory -AuthToken $jwtToken

# Test 12: Generate slug
Write-Host "=== Test 12: Generate Slug ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "GET" -Url "$baseUrl/api/categories/generate-slug?name=New Category!" -Description "Generate slug for 'New Category!'" -AuthToken $jwtToken

# Test 13: Activate category
Write-Host "=== Test 13: Activate Category ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "PUT" -Url "$baseUrl/api/categories/1/activate" -Description "Activate category 1" -AuthToken $jwtToken

# Test 14: Deactivate category
Write-Host "=== Test 14: Deactivate Category ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "PUT" -Url "$baseUrl/api/categories/1/deactivate" -Description "Deactivate category 1" -AuthToken $jwtToken

# Test 15: Get categories with products
Write-Host "=== Test 15: Get Categories with Products ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "GET" -Url "$baseUrl/api/categories/with-products" -Description "Get categories that have products" -AuthToken $jwtToken

# Test 16: Bulk activate categories
Write-Host "=== Test 16: Bulk Activate Categories ===" -ForegroundColor Magenta
try {
    $roots = Invoke-RestMethod -Uri "$baseUrl/api/categories/roots" -Headers @{ Authorization = "Bearer $jwtToken" }
    $categoryIds = @()
    if ($roots -is [System.Array]) { $categoryIds = $roots | ForEach-Object { $_.id } } else { $categoryIds = @($roots.id) }
    if ($categoryIds.Count -eq 0) { $categoryIds = @(1) }
    $idsJson = "[" + ($categoryIds -join ",") + "]"
    Write-Host "Testing: Bulk activate categories by roots (" ($categoryIds -join ',') ")" -ForegroundColor Cyan
    Write-Host "Request: POST $baseUrl/api/categories/bulk-activate" -ForegroundColor Gray
    try {
        $resp = Invoke-RestMethod -Uri "$baseUrl/api/categories/bulk-activate" -Method POST -Body $idsJson -ContentType "application/json" -Headers @{ Authorization = "Bearer $jwtToken" }
        Write-Host "✅ SUCCESS" -ForegroundColor Green
        if ($resp) { Write-Host "Response: $($resp | ConvertTo-Json -Depth 3)" -ForegroundColor White }
    } catch {
        Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
            Write-Host "Status Code: $statusCode" -ForegroundColor Red
            try { $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); $eb = $reader.ReadToEnd(); if ($eb) { Write-Host "Error Body: $eb" -ForegroundColor DarkYellow } } catch {}
        }
    }
} catch {
    Write-Host "(Skip bulk-activate: cannot fetch roots)" -ForegroundColor Yellow
}

# Test 17: Error cases
Write-Host "=== Test 17: Error Cases ===" -ForegroundColor Magenta
Test-CategoryAPI -Method "GET" -Url "$baseUrl/api/categories/999" -Description "Get non-existent category (should return 404)" -AuthToken $jwtToken
Test-CategoryAPI -Method "POST" -Url "$baseUrl/api/categories" -Description "Create category with invalid data (should fail)" -Body @{name = ""} -AuthToken $jwtToken

Write-Host "=== Category API Tests Complete ===" -ForegroundColor Green
Write-Host "Note: Make sure the application is running on $baseUrl before executing this script" -ForegroundColor Yellow
