# Test Order APIs
param(
    [string]$JWT = "",
    [string]$BaseUrl = "http://localhost:8080"
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

Write-Host "${Blue}=== Order API Test Script ===${Reset}" -ForegroundColor Blue

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

# Test data
$shippingAddress = @{
    fullName = "Nguyen Van A"
    phone = "0123456789"
    addressLine1 = "123 Main Street"
    addressLine2 = "Apartment 4B"
    city = "Ho Chi Minh City"
    state = "Ho Chi Minh"
    postalCode = "700000"
    country = "Vietnam"
}

$createOrderRequest = @{
    shippingAddress = $shippingAddress
    paymentMethod = "CASH_ON_DELIVERY"
    shippingFee = 30000
}

Write-Host "`n${Blue}=== Test 1: Create Order from Cart ===${Reset}" -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/create-from-cart" -Method POST -Body ($createOrderRequest | ConvertTo-Json) -Headers $headers
    Write-Host "${Green}✓ Order created successfully${Reset}" -ForegroundColor Green
    Write-Host "Order Number: $($response.orderNumber)" -ForegroundColor Cyan
    Write-Host "Order ID: $($response.id)" -ForegroundColor Cyan
    Write-Host "Total Amount: $($response.totalAmount)" -ForegroundColor Cyan
    Write-Host "Status: $($response.status)" -ForegroundColor Cyan
    
    $orderId = $response.id
    $orderNumber = $response.orderNumber
} catch {
    Write-Host "${Red}✗ Create order failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorStream)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error details: $errorBody" -ForegroundColor Red
    }
    exit 1
}

Write-Host "`n${Blue}=== Test 2: Get Order by ID ===${Reset}" -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/$orderId" -Method GET -Headers $headers
    Write-Host "${Green}✓ Get order by ID successful${Reset}" -ForegroundColor Green
    Write-Host "Order Number: $($response.orderNumber)" -ForegroundColor Cyan
    Write-Host "User: $($response.userName) ($($response.userEmail))" -ForegroundColor Cyan
    Write-Host "Total Items: $($response.totalItems)" -ForegroundColor Cyan
    Write-Host "Has Product Changes: $($response.hasProductChanges)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Get order by ID failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 3: Get Order by Order Number ===${Reset}" -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/number/$orderNumber" -Method GET -Headers $headers
    Write-Host "${Green}✓ Get order by number successful${Reset}" -ForegroundColor Green
    Write-Host "Order Number: $($response.orderNumber)" -ForegroundColor Cyan
    Write-Host "Status: $($response.status)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Get order by number failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 4: Get My Orders ===${Reset}" -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/my-orders" -Method GET -Headers $headers
    Write-Host "${Green}✓ Get my orders successful${Reset}" -ForegroundColor Green
    Write-Host "Total orders: $($response.Count)" -ForegroundColor Cyan
    foreach ($order in $response) {
        Write-Host "  - $($order.orderNumber): $($order.status) - $($order.totalAmount)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "${Red}✗ Get my orders failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 5: Update Order Status (Admin) ===${Reset}" -ForegroundColor Blue
try {
    $updateStatusRequest = @{
        status = "CONFIRMED"
    }
    
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/$orderId/status" -Method PUT -Body ($updateStatusRequest | ConvertTo-Json) -Headers $headers
    Write-Host "${Green}✓ Update order status successful${Reset}" -ForegroundColor Green
    Write-Host "New Status: $($response.status)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Update order status failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 6: Update Shipping Fee (Admin) ===${Reset}" -ForegroundColor Blue
try {
    $updateShippingFeeRequest = @{
        shippingFee = 50000
    }
    
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/$orderId/shipping-fee" -Method PUT -Body ($updateShippingFeeRequest | ConvertTo-Json) -Headers $headers
    Write-Host "${Green}✓ Update shipping fee successful${Reset}" -ForegroundColor Green
    Write-Host "New Shipping Fee: $($response.shippingFee)" -ForegroundColor Cyan
    Write-Host "New Total Amount: $($response.totalAmount)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Update shipping fee failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 7: Update Tax Amount (Admin) ===${Reset}" -ForegroundColor Blue
try {
    $updateTaxRequest = @{
        taxAmount = 10000
    }
    
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/$orderId/tax" -Method PUT -Body ($updateTaxRequest | ConvertTo-Json) -Headers $headers
    Write-Host "${Green}✓ Update tax amount successful${Reset}" -ForegroundColor Green
    Write-Host "New Tax Amount: $($response.taxAmount)" -ForegroundColor Cyan
    Write-Host "New Total Amount: $($response.totalAmount)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Update tax amount failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 8: Update Discount Amount (Admin) ===${Reset}" -ForegroundColor Blue
try {
    $updateDiscountRequest = @{
        discountAmount = 5000
    }
    
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/$orderId/discount" -Method PUT -Body ($updateDiscountRequest | ConvertTo-Json) -Headers $headers
    Write-Host "${Green}✓ Update discount amount successful${Reset}" -ForegroundColor Green
    Write-Host "New Discount Amount: $($response.discountAmount)" -ForegroundColor Cyan
    Write-Host "New Total Amount: $($response.totalAmount)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Update discount amount failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 9: Update Order Notes ===${Reset}" -ForegroundColor Blue
try {
    $updateNotesRequest = @{
        notes = "Please deliver after 2 PM. Contact customer before delivery."
    }
    
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/$orderId/notes" -Method PUT -Body ($updateNotesRequest | ConvertTo-Json) -Headers $headers
    Write-Host "${Green}✓ Update order notes successful${Reset}" -ForegroundColor Green
    Write-Host "Notes: $($response.notes)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Update order notes failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 10: Get Orders with Product Changes (Admin) ===${Reset}" -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/with-product-changes" -Method GET -Headers $headers
    Write-Host "${Green}✓ Get orders with product changes successful${Reset}" -ForegroundColor Green
    Write-Host "Orders with product changes: $($response.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Get orders with product changes failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 11: Get Orders Needing Attention (Admin) ===${Reset}" -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/needing-attention" -Method GET -Headers $headers
    Write-Host "${Green}✓ Get orders needing attention successful${Reset}" -ForegroundColor Green
    Write-Host "Orders needing attention: $($response.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Get orders needing attention failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 12: Get Recent Orders (Admin) ===${Reset}" -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/recent" -Method GET -Headers $headers
    Write-Host "${Green}✓ Get recent orders successful${Reset}" -ForegroundColor Green
    Write-Host "Recent orders: $($response.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Get recent orders failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Blue}=== Test 13: Get Order Statistics (Admin) ===${Reset}" -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/orders/statistics" -Method GET -Headers $headers
    Write-Host "${Green}✓ Get order statistics successful${Reset}" -ForegroundColor Green
    Write-Host "Total Orders: $($response.totalOrders)" -ForegroundColor Cyan
    Write-Host "Pending Orders: $($response.pendingOrders)" -ForegroundColor Cyan
    Write-Host "Confirmed Orders: $($response.confirmedOrders)" -ForegroundColor Cyan
    Write-Host "Shipped Orders: $($response.shippedOrders)" -ForegroundColor Cyan
    Write-Host "Delivered Orders: $($response.deliveredOrders)" -ForegroundColor Cyan
    Write-Host "Cancelled Orders: $($response.cancelledOrders)" -ForegroundColor Cyan
} catch {
    Write-Host "${Red}✗ Get order statistics failed: $($_.Exception.Message)${Reset}" -ForegroundColor Red
}

Write-Host "`n${Green}=== Order API Tests Completed ===${Reset}" -ForegroundColor Green
