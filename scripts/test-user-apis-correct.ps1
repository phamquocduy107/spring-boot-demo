# User API Test Script - Corrected based on actual User entity
# This script tests User APIs with proper JWT authentication and correct field structure

$baseUrl = "http://localhost:8080"
$jwtToken = $null
$adminEmail = "admin_$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())@example.com"
$refreshToken = $null
$adminId = $null
$regularId = $null
$managerId = $null

Write-Host "=== User API Test Script (Corrected) ===" -ForegroundColor Green
Write-Host "Base URL: $baseUrl" -ForegroundColor Yellow
Write-Host "Based on actual User entity structure" -ForegroundColor Yellow
Write-Host ""

# Function to make HTTP requests and display results
function Test-UserAPI {
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
        if ($AuthToken) {
            $headers["Authorization"] = "Bearer $AuthToken"
        }
        
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

# Step 1: Register a new user (using correct User entity structure)
Write-Host "=== Step 1: Register Admin User ===" -ForegroundColor Magenta
$adminUser = @{
    name = "Admin User"
    email = $adminEmail
    password = "admin123"
    role = "ADMIN"
}
try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method POST -Body ($adminUser | ConvertTo-Json) -ContentType "application/json"
    Write-Host "✅ SUCCESS" -ForegroundColor Green
    Write-Host "Response: $($registerResponse | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) { Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red }
}

# Step 2: Login to get JWT token
Write-Host "=== Step 2: Login to Get JWT Token ===" -ForegroundColor Magenta
$loginData = @{
    email = $adminEmail
    password = "admin123"
}

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body ($loginData | ConvertTo-Json) -ContentType "application/json"
    $jwtToken = $loginResponse.accessToken
    $refreshToken = $loginResponse.refreshToken
    Write-Host "✅ Login successful! JWT token obtained" -ForegroundColor Green
    Write-Host "Token: $($jwtToken.Substring(0, 50))..." -ForegroundColor Gray
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Cannot proceed with User API tests without authentication" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Now test User APIs with JWT token
Write-Host "=== USER API TESTS WITH JWT AUTHENTICATION ===" -ForegroundColor Magenta

# Test 1: Get all users and capture admin ID
Write-Host "=== Test 1: Get All Users ===" -ForegroundColor Magenta
try {
    $users = Invoke-RestMethod -Uri "$baseUrl/api/users" -Method GET -Headers @{ Authorization = "Bearer $jwtToken" }
    Write-Host "✅ SUCCESS" -ForegroundColor Green
    Write-Host "Response: $($users | ConvertTo-Json -Depth 3)" -ForegroundColor White
    $admin = $users | Where-Object { $_.email -eq $adminEmail }
    if ($admin) { $adminId = $admin.id }
} catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) { Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red }
}

# Test 2: Get user by captured admin ID
Write-Host "=== Test 2: Get User by ID ===" -ForegroundColor Magenta
if ($adminId) {
    Test-UserAPI -Method "GET" -Url "$baseUrl/api/users/$adminId" -Description "Get user by admin ID $adminId" -AuthToken $jwtToken
} else {
    Write-Host "(Skipping: adminId not found)" -ForegroundColor Yellow
}

# Test 3: Create another user (using correct User entity structure) and capture ID
Write-Host "=== Test 3: Create Regular User ===" -ForegroundColor Magenta
$regularUser = @{
    name = "Regular User"
    email = "user@example.com"
    password = "user123"
    role = "USER"
}
try {
    $regularResp = Invoke-RestMethod -Uri "$baseUrl/api/users" -Method POST -Body ($regularUser | ConvertTo-Json) -ContentType "application/json" -Headers @{ Authorization = "Bearer $jwtToken" }
    $regularId = $regularResp.id
    Write-Host "✅ SUCCESS" -ForegroundColor Green
    Write-Host "Response: $($regularResp | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) { Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red }
}

# Test 4: Get all users (should now have 2 users)
Write-Host "=== Test 4: Get All Users (2 users) ===" -ForegroundColor Magenta
Test-UserAPI -Method "GET" -Url "$baseUrl/api/users" -Description "Get all users (should have 2 users)" -AuthToken $jwtToken

# Test 5: Update user (using correct User entity structure)
Write-Host "=== Test 5: Update User ===" -ForegroundColor Magenta
$updatedUser = @{
    name = "Updated User"
    email = "updated@example.com"
    password = "newpassword123"
    role = "USER"
}
if ($regularId) {
    Test-UserAPI -Method "PUT" -Url "$baseUrl/api/users/$regularId" -Description "Update user $regularId" -Body $updatedUser -AuthToken $jwtToken
} else {
    Write-Host "(Skipping update: regularId not set)" -ForegroundColor Yellow
}

# Test 6: Get updated user
Write-Host "=== Test 6: Get Updated User ===" -ForegroundColor Magenta
if ($regularId) {
    Test-UserAPI -Method "GET" -Url "$baseUrl/api/users/$regularId" -Description "Get updated user $regularId" -AuthToken $jwtToken
} else {
    Write-Host "(Skipping get updated: regularId not set)" -ForegroundColor Yellow
}

# Test 7: Create third user with MANAGER role and capture ID
Write-Host "=== Test 7: Create Manager User ===" -ForegroundColor Magenta
$managerUser = @{
    name = "Manager User"
    email = "manager@example.com"
    password = "manager123"
    role = "MANAGER"
}
try {
    $managerResp = Invoke-RestMethod -Uri "$baseUrl/api/users" -Method POST -Body ($managerUser | ConvertTo-Json) -ContentType "application/json" -Headers @{ Authorization = "Bearer $jwtToken" }
    $managerId = $managerResp.id
    Write-Host "✅ SUCCESS" -ForegroundColor Green
    Write-Host "Response: $($managerResp | ConvertTo-Json -Depth 3)" -ForegroundColor White
} catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) { Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red }
}

# Test 8: Get all users (should now have 3 users)
Write-Host "=== Test 8: Get All Users (3 users) ===" -ForegroundColor Magenta
Test-UserAPI -Method "GET" -Url "$baseUrl/api/users" -Description "Get all users (should have 3 users)" -AuthToken $jwtToken

# Test 9: Test without JWT token (should fail)
Write-Host "=== Test 9: Test Without JWT Token (Should Fail) ===" -ForegroundColor Magenta
Test-UserAPI -Method "GET" -Url "$baseUrl/api/users" -Description "Get users without JWT token (should fail)"

# Test 10: Test with invalid JWT token (should fail)
Write-Host "=== Test 10: Test With Invalid JWT Token (Should Fail) ===" -ForegroundColor Magenta
Test-UserAPI -Method "GET" -Url "$baseUrl/api/users" -Description "Get users with invalid JWT token (should fail)" -AuthToken "invalid-token"

# Test 11: Test validation - invalid email format
Write-Host "=== Test 11: Test Validation - Invalid Email ===" -ForegroundColor Magenta
$invalidUser = @{
    name = "Invalid User"
    email = "invalid-email"
    password = "password123"
    role = "USER"
}
Test-UserAPI -Method "POST" -Url "$baseUrl/api/users" -Description "Create user with invalid email (should fail)" -Body $invalidUser -AuthToken $jwtToken

# Test 12: Test validation - short password
Write-Host "=== Test 12: Test Validation - Short Password ===" -ForegroundColor Magenta
$shortPasswordUser = @{
    name = "Short Password User"
    email = "short@example.com"
    password = "123"
    role = "USER"
}
Test-UserAPI -Method "POST" -Url "$baseUrl/api/users" -Description "Create user with short password (should fail)" -Body $shortPasswordUser -AuthToken $jwtToken

# Test 13: Test validation - short name
Write-Host "=== Test 13: Test Validation - Short Name ===" -ForegroundColor Magenta
$shortNameUser = @{
    name = "A"
    email = "shortname@example.com"
    password = "password123"
    role = "USER"
}
Test-UserAPI -Method "POST" -Url "$baseUrl/api/users" -Description "Create user with short name (should fail)" -Body $shortNameUser -AuthToken $jwtToken

# Test 14: Test validation - missing required fields
Write-Host "=== Test 14: Test Validation - Missing Required Fields ===" -ForegroundColor Magenta
$incompleteUser = @{
    name = "Incomplete User"
    # missing email and password
    role = "USER"
}
Test-UserAPI -Method "POST" -Url "$baseUrl/api/users" -Description "Create user with missing fields (should fail)" -Body $incompleteUser -AuthToken $jwtToken

# Test 15: Delete manager user
Write-Host "=== Test 15: Delete User ===" -ForegroundColor Magenta
if ($managerId) {
    Test-UserAPI -Method "DELETE" -Url "$baseUrl/api/users/$managerId" -Description "Delete user $managerId" -AuthToken $jwtToken
} else {
    Write-Host "(Skipping delete: managerId not set)" -ForegroundColor Yellow
}

# Test 16: Verify deletion
Write-Host "=== Test 16: Verify User Deletion ===" -ForegroundColor Magenta
if ($managerId) {
    Test-UserAPI -Method "GET" -Url "$baseUrl/api/users/$managerId" -Description "Get deleted user (should return 404)" -AuthToken $jwtToken
} else {
    Write-Host "(Skipping verify: managerId not set)" -ForegroundColor Yellow
}

# Test 17: Get remaining users
Write-Host "=== Test 17: Get Remaining Users ===" -ForegroundColor Magenta
Test-UserAPI -Method "GET" -Url "$baseUrl/api/users" -Description "Get remaining users after deletion" -AuthToken $jwtToken

# Test 18: Test duplicate email (should fail)
Write-Host "=== Test 18: Test Duplicate Email ===" -ForegroundColor Magenta
$duplicateUser = @{
    name = "Duplicate User"
    email = $adminEmail  # Same as existing admin
    password = "password123"
    role = "USER"
}
Test-UserAPI -Method "POST" -Url "$baseUrl/api/users" -Description "Create user with duplicate email (should fail)" -Body $duplicateUser -AuthToken $jwtToken

# Test 19: Test invalid role
Write-Host "=== Test 19: Test Invalid Role ===" -ForegroundColor Magenta
$invalidRoleUser = @{
    name = "Invalid Role User"
    email = "invalidrole@example.com"
    password = "password123"
    role = "INVALID_ROLE"
}
Test-UserAPI -Method "POST" -Url "$baseUrl/api/users" -Description "Create user with invalid role" -Body $invalidRoleUser -AuthToken $jwtToken

# Test 20: Test refresh token functionality with real token
Write-Host "=== Test 20: Test Refresh Token ===" -ForegroundColor Magenta
if ($refreshToken) {
    $refreshData = @{ refreshToken = $refreshToken }
    Test-UserAPI -Method "POST" -Url "$baseUrl/api/auth/refresh-token" -Description "Test refresh token" -Body $refreshData
} else {
    Write-Host "(Skipping refresh: no refreshToken from login)" -ForegroundColor Yellow
}

Write-Host "=== User API Tests Complete ===" -ForegroundColor Green
Write-Host "Note: User APIs require ADMIN role and JWT authentication" -ForegroundColor Yellow
Write-Host "User entity fields: id, name, email, password, role" -ForegroundColor Yellow
