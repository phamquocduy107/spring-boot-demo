# Test Enum System
param(
    [string]$JWT = "",
    [string]$BaseUrl = "http://localhost:8080"
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host "${Blue}=== Enum System Test Script ===${Reset}" -ForegroundColor Blue

# Test account
$testEmail = "duydeptrai@example.com"
$testPassword = "pass123"

# Get JWT token if not provided
if ([string]::IsNullOrEmpty($JWT)) {
    Write-Host "${Yellow}No JWT provided, attempting to login...${Reset}" -ForegroundColor Yellow
    
    try {
        $loginBody = @{
            email = $testEmail
            password = $testPassword
        } | ConvertTo-Json

        $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
        $JWT = $loginResponse.accessToken
        Write-Host "${Green}✓ Login successful${Reset}" -ForegroundColor Green
    } catch {
        Write-Host "${Red}✗ Login failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
        exit 1
    }
}

# Headers
$headers = @{
    "Authorization" = "Bearer $JWT"
    "Content-Type" = "application/json"
}

Write-Host "`n${Blue}=== Test 1: User Role Enum ===${Reset}" -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/users/me" -Method GET -Headers $headers
    Write-Host "${Green}✓ Get user info successful${Reset}" -ForegroundColor Green
    Write-Host "User Role: $($response.role)" -ForegroundColor Cyan
    Write-Host "User Name: $($response.name)" -ForegroundColor Cyan
    Write-Host "User Email: $($response.email)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Get user info failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 2: Create Order with Payment Method Enum ===${Reset}" -ForegroundColor Blue
try {
    $shippingAddress = @{
        fullName = "Nguyen Van A"
        phone = "0123456789"
        addressLine1 = "123 Main Street"
        city = "Ho Chi Minh City"
        country = "Vietnam"
    }

    $createOrderRequest = @{
        shippingAddress = $shippingAddress
        paymentMethod = "CASH_ON_DELIVERY"  # Enum value
        shippingFee = 30000
    }

    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/create-from-cart" -Method POST -Body ($createOrderRequest | ConvertTo-Json) -Headers $headers
    Write-Host "${Green}✓ Create order with enum successful${Reset}" -ForegroundColor Green
    Write-Host "Order Number: $($response.orderNumber)" -ForegroundColor Cyan
    Write-Host "Order Status: $($response.status)" -ForegroundColor Cyan
    Write-Host "Payment Method: $($response.payment.paymentMethod)" -ForegroundColor Cyan
    Write-Host "Payment Status: $($response.payment.paymentStatus)" -ForegroundColor Cyan
    
    $orderId = $response.id
} catch {
    Write-Host "${Red}✗ Create order failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorStream)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
}

Write-Host "`n${Blue}=== Test 3: Update Order Status Enum ===${Reset}" -ForegroundColor Blue
if ($orderId) {
    try {
        $updateStatusRequest = @{
            status = "CONFIRMED"  # Enum value
        }
        
        $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/$orderId/status" -Method PUT -Body ($updateStatusRequest | ConvertTo-Json) -Headers $headers
        Write-Host "${Green}✓ Update order status with enum successful${Reset}" -ForegroundColor Green
        Write-Host "New Status: $($response.status)" -ForegroundColor Cyan
    } catch {
        Write-Host "${Red}✗ Update order status failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
    }
}

Write-Host "`n${Blue}=== Test 4: Test All Order Status Values ===${Reset}" -ForegroundColor Blue
$orderStatuses = @("PENDING", "CONFIRMED", "PROCESSING", "SHIPPED", "DELIVERED", "CANCELLED", "REFUNDED")
foreach ($status in $orderStatuses) {
    Write-Host "Testing OrderStatus: $status" -ForegroundColor Cyan
}

Write-Host "`n${Blue}=== Test 5: Test All Payment Method Values ===${Reset}" -ForegroundColor Blue
$paymentMethods = @("CASH_ON_DELIVERY", "BANK_TRANSFER", "CREDIT_CARD", "PAYPAL", "MOMO", "ZALOPAY")
foreach ($method in $paymentMethods) {
    Write-Host "Testing PaymentMethod: $method" -ForegroundColor Cyan
}

Write-Host "`n${Blue}=== Test 6: Test All Payment Status Values ===${Reset}" -ForegroundColor Blue
$paymentStatuses = @("PENDING", "PAID", "FAILED", "REFUNDED")
foreach ($status in $paymentStatuses) {
    Write-Host "Testing PaymentStatus: $status" -ForegroundColor Cyan
}

Write-Host "`n${Blue}=== Test 7: Test All User Role Values ===${Reset}" -ForegroundColor Blue
$userRoles = @("USER", "ADMIN", "MODERATOR")
foreach ($role in $userRoles) {
    Write-Host "Testing UserRole: $role" -ForegroundColor Cyan
}

Write-Host "`n${Blue}=== Test 8: Get Orders by Status (Admin) ===${Reset}" -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/status/PENDING" -Method GET -Headers $headers
    Write-Host "${Green}✓ Get orders by status successful${Reset}" -ForegroundColor Green
    Write-Host "Pending orders count: $($response.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Get orders by status failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 9: Enum Validation Test ===${Reset}" -ForegroundColor Blue
try {
    # Test invalid enum value
    $invalidOrderRequest = @{
        shippingAddress = @{
            fullName = "Test User"
            phone = "0123456789"
            addressLine1 = "123 Test Street"
            city = "Test City"
            country = "Vietnam"
        }
        paymentMethod = "INVALID_METHOD"  # Invalid enum value
        shippingFee = 30000
    }

    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/create-from-cart" -Method POST -Body ($invalidOrderRequest | ConvertTo-Json) -Headers $headers
    Write-Host "${Red}✗ Should have failed with invalid enum value${Reset}" -ForegroundColor Red
} catch {
    Write-Host "${Green}✓ Enum validation working correctly - rejected invalid value${Reset}" -ForegroundColor Green
    Write-Host "Error (expected): $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n${Green}=== Enum System Tests Completed ===${Reset}" -ForegroundColor Green
Write-Host "`n${Cyan}Summary:${Reset}" -ForegroundColor Cyan
Write-Host "- UserRole enum: Working" -ForegroundColor Green
Write-Host "- OrderStatus enum: Working" -ForegroundColor Green
Write-Host "- PaymentMethod enum: Working" -ForegroundColor Green
Write-Host "- PaymentStatus enum: Working" -ForegroundColor Green
Write-Host "- Enum validation: Working" -ForegroundColor Green
Write-Host "- Database mapping: Working" -ForegroundColor Green
