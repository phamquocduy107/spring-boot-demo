# Analytics API verification script (PowerShell)

param(
    [string]$BaseUrl = "http://localhost:8093",
    [string]$Jwt = "",
    [string]$AuthBase = "http://localhost:8080",
    [string]$TestName = "Duy Dep Trai",
    [string]$TestEmail = "duydeptrai@example.com",
    [string]$TestPassword = "pass123",
    [string]$TestRole = "ADMIN"
)

Write-Host "=== Verify Analytics API ===" -ForegroundColor Green
Write-Host "Base URL: $BaseUrl" -ForegroundColor Yellow

# Acquire JWT automatically if not provided
if (-not $Jwt -or $Jwt.Trim().Length -eq 0) {
    Write-Host "-- Acquire JWT (register+login test account)" -ForegroundColor Magenta
    try {
        $registerBody = @{ name = $TestName; email = $TestEmail; password = $TestPassword; role = $TestRole } | ConvertTo-Json
        Invoke-RestMethod -Uri "$AuthBase/api/auth/register" -Method POST -ContentType "application/json" -Body $registerBody -TimeoutSec 10 | Out-Null
    } catch { }
    try {
        $loginBody = @{ email = $TestEmail; password = $TestPassword } | ConvertTo-Json
        $loginResp = Invoke-RestMethod -Uri "$AuthBase/api/auth/login" -Method POST -ContentType "application/json" -Body $loginBody -TimeoutSec 10
        if ($loginResp -and $loginResp.accessToken) { $Jwt = $loginResp.accessToken; Write-Host "Obtained JWT" -ForegroundColor Gray }
        else { Write-Host "Could not obtain JWT" -ForegroundColor Red }
    } catch {
        Write-Host "Login failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

$headers = @{ 'Accept' = 'application/json' }
if ($Jwt -and $Jwt.Trim().Length -gt 0) { $headers['Authorization'] = "Bearer $Jwt" }

# Health check
Write-Host "-- Health check" -ForegroundColor Magenta
try {
    $h = Invoke-RestMethod -Uri "$BaseUrl/health" -Method GET -TimeoutSec 5
    Write-Host "Health: $($h | ConvertTo-Json)" -ForegroundColor Gray
} catch {
    Write-Host "Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Readiness check
Write-Host "-- Readiness check" -ForegroundColor Magenta
try {
    $r = Invoke-RestMethod -Uri "$BaseUrl/readiness" -Method GET -TimeoutSec 5
    Write-Host "Readiness: $($r | ConvertTo-Json)" -ForegroundColor Gray
} catch {
    Write-Host "Readiness check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Check if we have JWT for authenticated endpoints
if (-not $Jwt -or $Jwt.Trim().Length -eq 0) {
    Write-Host "WARNING: No JWT token available. Some analytics endpoints may not work properly." -ForegroundColor Yellow
}

# Bestsellers
Write-Host "-- GET /analytics/products/bestsellers" -ForegroundColor Magenta
try {
    $resp = Invoke-RestMethod -Uri "$BaseUrl/analytics/products/bestsellers?limit=5" -Method GET -Headers $headers -TimeoutSec 10
    Write-Host "Status: OK" -ForegroundColor Green
    Write-Host "Response: $($resp | ConvertTo-Json -Depth 5)" -ForegroundColor White
    if ($resp.bestsellers -and $resp.bestsellers.Count -gt 0) {
        Write-Host "Top bestseller: $($resp.bestsellers[0].name) (Sold: $($resp.bestsellers[0].totalSold))" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Status: ERROR" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
}

# Trending products
Write-Host "-- GET /analytics/products/trending" -ForegroundColor Magenta
try {
    $resp = Invoke-RestMethod -Uri "$BaseUrl/analytics/products/trending?limit=5" -Method GET -Headers $headers -TimeoutSec 10
    Write-Host "Status: OK" -ForegroundColor Green
    Write-Host "Response: $($resp | ConvertTo-Json -Depth 5)" -ForegroundColor White
    if ($resp.trending -and $resp.trending.Count -gt 0) {
        Write-Host "Top trending: $($resp.trending[0].name)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Status: ERROR" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
}

# Popular categories
Write-Host "-- GET /analytics/categories/popular" -ForegroundColor Magenta
try {
    $resp = Invoke-RestMethod -Uri "$BaseUrl/analytics/categories/popular?limit=5" -Method GET -Headers $headers -TimeoutSec 10
    Write-Host "Status: OK" -ForegroundColor Green
    Write-Host "Response: $($resp | ConvertTo-Json -Depth 5)" -ForegroundColor White
    if ($resp.popular -and $resp.popular.Count -gt 0) {
        Write-Host "Top category: $($resp.popular[0].categoryName) (Products: $($resp.popular[0].productCount))" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Status: ERROR" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
}

# Dashboard summary
Write-Host "-- GET /analytics/dashboard/summary" -ForegroundColor Magenta
try {
    $resp = Invoke-RestMethod -Uri "$BaseUrl/analytics/dashboard/summary" -Method GET -Headers $headers -TimeoutSec 10
    Write-Host "Status: OK" -ForegroundColor Green
    Write-Host "Response: $($resp | ConvertTo-Json -Depth 5)" -ForegroundColor White
    if ($resp.summary) {
        Write-Host "Summary: $($resp.summary.totalProducts) products, $($resp.summary.totalOrders) orders, Revenue: $($resp.summary.totalRevenue)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Status: ERROR" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "=== Done ===" -ForegroundColor Green
