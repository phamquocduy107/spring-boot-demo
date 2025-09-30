# Recommendation API verification script (PowerShell)

param(
    [string]$BaseUrl = "http://localhost:8091",
    [int]$UserId = 1,
    [int]$Limit = 5,
    [string]$Jwt = "",
    [string]$AuthBase = "http://localhost:8080",
    [string]$TestName = "Duy Dep Trai",
    [string]$TestEmail = "duydeptrai@example.com",
    [string]$TestPassword = "pass123",
    [string]$TestRole = "ADMIN"
)

Write-Host "=== Verify Recommendation API ===" -ForegroundColor Green
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

# Health
Write-Host "-- Health check" -ForegroundColor Magenta
try {
    $h = Invoke-RestMethod -Uri "$BaseUrl/health" -Method GET -TimeoutSec 5
    Write-Host "Health: $($h | ConvertTo-Json)" -ForegroundColor Gray
} catch {
    Write-Host "Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Recommendations
Write-Host "-- POST /recommendations" -ForegroundColor Magenta
$headers = @{ 'Accept' = 'application/json' }
if ($Jwt -and $Jwt.Trim().Length -gt 0) { $headers['Authorization'] = "Bearer $Jwt" }
$body = @{ userId = $UserId; limit = $Limit } | ConvertTo-Json
try {
    $resp = Invoke-RestMethod -Uri "$BaseUrl/recommendations" -Method POST -Headers $headers -ContentType 'application/json' -Body $body -TimeoutSec 10
    Write-Host "Status: OK" -ForegroundColor Green
    Write-Host "Response: $($resp | ConvertTo-Json -Depth 5)" -ForegroundColor White
    if ($resp.items -and $resp.items.Count -gt 0) {
        Write-Host "Sample product info:" -ForegroundColor Cyan
        Write-Host "  - Product: $($resp.items[0].name) (ID: $($resp.items[0].id))" -ForegroundColor Gray
        Write-Host "  - Price: $($resp.items[0].price)" -ForegroundColor Gray
        Write-Host "  - Category: $($resp.items[0].category.name)" -ForegroundColor Gray
    }
} catch {
    Write-Host "Status: ERROR" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errBody = $reader.ReadToEnd()
            Write-Host "Body: $errBody" -ForegroundColor DarkYellow
        } catch {}
    }
}

Write-Host "=== Done ===" -ForegroundColor Green


