# Comprehensive API Test Script
# - Tests all entities: User, Product, Category, Cart, Order
# - Logs in as admin (from rule.md)
# - Performs CRUD operations for each entity
# - Tests both authorized and unauthorized access
# - Generates detailed reports per entity

param(
    [string]$BaseUrl = "http://localhost:8080",
    [ValidateSet("Create","GetAll","Get","Update","Delete","All")][string]$Mode = "All",
    [ValidateSet("User","Product","Category","Cart","Order","All")][string]$Entity = "All",
    [int]$ProductCategoryId = 1
)

function Write-Section($title) {
    Write-Host "`n==== $title ====\n" -ForegroundColor Cyan
}

function Invoke-JsonPost {
    param(
        [string]$Uri,
        [hashtable]$Headers,
        $Body
    )
    $json = $null
    if ($Body -ne $null) { $json = ($Body | ConvertTo-Json -Depth 10) }
    return Invoke-RestMethod -Method POST -Uri $Uri -Headers $Headers -ContentType 'application/json' -Body $json
}

function Invoke-JsonGet {
    param(
        [string]$Uri,
        [hashtable]$Headers
    )
    return Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers -ContentType 'application/json'
}

function Try-InvokeJsonPost {
    param(
        [string]$Uri,
        [hashtable]$Headers,
        $Body
    )
    try {
        $resp = Invoke-JsonPost -Uri $Uri -Headers $Headers -Body $Body
        return @{ success = $true; status = 200; body = $resp }
    } catch {
        $err = $_
        # Attempt to parse response body
        $statusCode = $null
        $respBody = $null
        try { $statusCode = $_.Exception.Response.StatusCode.value__ } catch {}
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $text = $reader.ReadToEnd()
            $reader.Close()
            if ($text) { $respBody = $text | ConvertFrom-Json }
        } catch {}
        return @{ success = $false; status = $statusCode; body = $respBody; error = $err }
    }
}

function Try-InvokeJsonGet {
    param(
        [string]$Uri,
        [hashtable]$Headers
    )
    try {
        $resp = Invoke-JsonGet -Uri $Uri -Headers $Headers
        return @{ success = $true; status = 200; body = $resp }
    } catch {
        $err = $_
        $statusCode = $null
        $respBody = $null
        try { $statusCode = $_.Exception.Response.StatusCode.value__ } catch {}
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $text = $reader.ReadToEnd()
            $reader.Close()
            if ($text) { $respBody = $text | ConvertFrom-Json }
        } catch {}
        return @{ success = $false; status = $statusCode; body = $respBody; error = $err }
    }
}

function Invoke-JsonPut {
    param(
        [string]$Uri,
        [hashtable]$Headers,
        $Body
    )
    $json = $null
    if ($Body -ne $null) { $json = ($Body | ConvertTo-Json -Depth 10) }
    return Invoke-RestMethod -Method PUT -Uri $Uri -Headers $Headers -ContentType 'application/json' -Body $json
}

function Try-InvokeJsonPut {
    param(
        [string]$Uri,
        [hashtable]$Headers,
        $Body
    )
    try {
        $resp = Invoke-JsonPut -Uri $Uri -Headers $Headers -Body $Body
        return @{ success = $true; status = 200; body = $resp }
    } catch {
        $err = $_
        $statusCode = $null
        $respBody = $null
        try { $statusCode = $_.Exception.Response.StatusCode.value__ } catch {}
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $text = $reader.ReadToEnd()
            $reader.Close()
            if ($text) { $respBody = $text | ConvertFrom-Json }
        } catch {}
        return @{ success = $false; status = $statusCode; body = $respBody; error = $err }
    }
}

function Invoke-Delete {
    param(
        [string]$Uri,
        [hashtable]$Headers
    )
    return Invoke-RestMethod -Method DELETE -Uri $Uri -Headers $Headers -ContentType 'application/json'
}

function Try-InvokeDelete {
    param(
        [string]$Uri,
        [hashtable]$Headers
    )
    try {
        Invoke-Delete -Uri $Uri -Headers $Headers | Out-Null
        # Spring returns 204 No Content
        return @{ success = $true; status = 204; body = $null }
    } catch {
        $err = $_
        $statusCode = $null
        $respBody = $null
        try { $statusCode = $_.Exception.Response.StatusCode.value__ } catch {}
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $text = $reader.ReadToEnd()
            $reader.Close()
            if ($text) { $respBody = $text | ConvertFrom-Json }
        } catch {}
        return @{ success = $false; status = $statusCode; body = $respBody; error = $err }
    }
}

function Get-AdminJwtToken {
    param(
        [string]$LoginUrl
    )
    $admin = @{ email = "duydeptrai@example.com"; password = "pass123" }
    $headers = @{}
    $result = Try-InvokeJsonPost -Uri $LoginUrl -Headers $headers -Body $admin
    if (-not $result.success) {
        throw "Login failed ($($result.status)): $($result.body | ConvertTo-Json -Depth 10)"
    }
    if (-not $result.body.accessToken) {
        throw "No accessToken returned from login response"
    }
    return $result.body.accessToken
}

function New-RandomEmail {
    $ts = [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff')
    return "user$ts@example.com"
}

#
# Begin
#
Write-Section "API Test ($Mode) [Entity=$Entity]"

$loginUrl = "$BaseUrl/api/auth/login"
$usersUrl = "$BaseUrl/api/users"
$productsUrl = "$BaseUrl/api/products"
$categoriesUrl = "$BaseUrl/api/categories"
$cartUrl = "$BaseUrl/api/cart"
$ordersUrl = "$BaseUrl/api/orders"

Write-Host "BaseUrl: $BaseUrl"
Write-Host "Login URL: $loginUrl"
Write-Host "Users URL: $usersUrl"
Write-Host "Categories URL: $categoriesUrl"
Write-Host "Cart URL: $cartUrl"
Write-Host "Orders URL: $ordersUrl"

Write-Section "Login as Admin"
$jwt = Get-AdminJwtToken -LoginUrl $loginUrl
Write-Host "Obtained JWT (len=$($jwt.Length))" -ForegroundColor Green

$authHeaders = @{ Authorization = "Bearer $jwt" }

${failures} = @()

${doCreate} = ($Mode -eq "Create" -or $Mode -eq "All")
${doGetAll} = ($Mode -eq "GetAll" -or $Mode -eq "All")
${doGet} = ($Mode -eq "Get" -or $Mode -eq "All")
${doUpdate} = ($Mode -eq "Update" -or $Mode -eq "All")
${doDelete} = ($Mode -eq "Delete" -or $Mode -eq "All")

# Entity gates
${doUser} = ($Entity -eq "User" -or $Entity -eq "All")
${doProduct} = ($Entity -eq "Product" -or $Entity -eq "All")
${doCategory} = ($Entity -eq "Category" -or $Entity -eq "All")
${doCart} = ($Entity -eq "Cart" -or $Entity -eq "All")
${doOrder} = ($Entity -eq "Order" -or $Entity -eq "All")

# User results
$create1 = $null
$create2 = $null
$create3 = $null
$getAllAuth = $null
$getAllNoAuth = $null
$getOneAuth = $null
$getOneNoAuth = $null
$updateAuth = $null
$updateNoAuth = $null
$deleteAuth = $null
$deleteNoAuth = $null

# Product results
$pCreate = $null
$pCreateDup = $null
$pCreateNoAuth = $null
$pGetAllAuth = $null
$pGetAllNoAuth = $null
$pGetOneAuth = $null
$pGetOneNoAuth = $null
$pUpdateAuth = $null
$pUpdateNoAuth = $null
$pDeleteAuth = $null
$pDeleteNoAuth = $null

# Category results
$cCreate = $null
$cCreateDup = $null
$cCreateNoAuth = $null
$cGetAllAuth = $null
$cGetAllNoAuth = $null
$cGetOneAuth = $null
$cGetOneNoAuth = $null
$cUpdateAuth = $null
$cUpdateNoAuth = $null
$cDeleteAuth = $null
$cDeleteNoAuth = $null

# Cart results
$cartGet = $null
$cartGetNoAuth = $null
$cartAddItem = $null
$cartAddItemNoAuth = $null
$cartUpdateQty = $null
$cartUpdateQtyNoAuth = $null
$cartRemoveItem = $null
$cartRemoveItemNoAuth = $null
$cartClear = $null
$cartClearNoAuth = $null

# Order results
$oCreateFromCart = $null
$oCreateFromCartNoAuth = $null
$oGetById = $null
$oGetByIdNoAuth = $null
$oGetByNumber = $null
$oGetByNumberNoAuth = $null
$oGetMyOrders = $null
$oGetMyOrdersNoAuth = $null
$oUpdateStatus = $null
$oUpdateStatusNoAuth = $null
$oUpdateShippingFee = $null
$oUpdateShippingFeeNoAuth = $null
$oUpdateTax = $null
$oUpdateTaxNoAuth = $null
$oUpdateDiscount = $null
$oUpdateDiscountNoAuth = $null
$oUpdateNotes = $null
$oUpdateNotesNoAuth = $null
$oGetWithChanges = $null
$oGetNeedingAttention = $null
$oGetRecent = $null
$oGetStatistics = $null

if (${doUser} -and ${doCreate}) {
    # Prepare new user payload
    $newEmail = New-RandomEmail
    $newUser = @{ name = "Auto Test User"; email = $newEmail; password = "pass1234"; role = "USER" }

    Write-Section "Create User (should succeed)"
    $create1 = Try-InvokeJsonPost -Uri $usersUrl -Headers $authHeaders -Body $newUser
    if ($create1.success -and $create1.status -eq 200) {
        Write-Host "Create success: id=$($create1.body.id) email=$($create1.body.email)" -ForegroundColor Green
    } else {
        Write-Host "Create failed ($($create1.status)): $($create1.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += @{
            test = "Create User should succeed";
            expected = "200 OK";
            actual = $create1.status;
            details = ($create1.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "Create Duplicate (should be 400)"
    $create2 = Try-InvokeJsonPost -Uri $usersUrl -Headers $authHeaders -Body $newUser
    if (-not $create2.success -and $create2.status -eq 400) {
        Write-Host "Duplicate email correctly rejected (400): $($create2.body | ConvertTo-Json -Depth 10)" -ForegroundColor Green
    } else {
        Write-Host "Unexpected duplicate result: success=$($create2.success) status=$($create2.status) body=$($create2.body | ConvertTo-Json -Depth 10)" -ForegroundColor Yellow
        $failures += @{
            test = "Create duplicate should be 400";
            expected = "400 Bad Request";
            actual = $create2.status;
            details = ($create2.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "Create Without Token (should be 401/403)"
    $create3 = Try-InvokeJsonPost -Uri $usersUrl -Headers @{} -Body $newUser
    if (-not $create3.success -and ($create3.status -eq 401 -or $create3.status -eq 403)) {
        Write-Host "Unauthorized access correctly blocked ($($create3.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth result: success=$($create3.success) status=$($create3.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Create without token should be 401/403";
            expected = "401/403";
            actual = $create3.status;
            details = if ($create3.body) { ($create3.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doUser} -and ${doGetAll}) {
    Write-Section "Get All Users (authorized)"
    $getAllAuth = Try-InvokeJsonGet -Uri $usersUrl -Headers $authHeaders
    if ($getAllAuth.success -and $getAllAuth.status -eq 200) {
        $count = 0
        try { $count = ($getAllAuth.body | Measure-Object).Count } catch {}
        Write-Host "Fetched users: $count" -ForegroundColor Green
    } else {
        Write-Host "GetAll failed ($($getAllAuth.status)): $($getAllAuth.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += @{
            test = "GetAll with token should succeed";
            expected = "200 OK";
            actual = $getAllAuth.status;
            details = ($getAllAuth.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "Get All Users (without token should be 401/403)"
    $getAllNoAuth = Try-InvokeJsonGet -Uri $usersUrl -Headers @{}
    if (-not $getAllNoAuth.success -and ($getAllNoAuth.status -eq 401 -or $getAllNoAuth.status -eq 403)) {
        Write-Host "Unauthorized access correctly blocked ($($getAllNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth result: success=$($getAllNoAuth.success) status=$($getAllNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "GetAll without token should be 401/403";
            expected = "401/403";
            actual = $getAllNoAuth.status;
            details = if ($getAllNoAuth.body) { ($getAllNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

# Ensure we have a target user id for Get/Update/Delete
$targetUserId = $null
if ($create1 -and $create1.success -and $create1.body.id) {
    $targetUserId = $create1.body.id
}
if ((${doGet} -or ${doUpdate} -or ${doDelete}) -and -not $targetUserId) {
    # Create a temporary user to operate on when Create step not executed
    Write-Section "Create Temp User for subsequent tests"
    $tempEmail = New-RandomEmail
    $tempUser = @{ name = "Temp User"; email = $tempEmail; password = "pass1234"; role = "USER" }
    $tempCreate = Try-InvokeJsonPost -Uri $usersUrl -Headers $authHeaders -Body $tempUser
    if ($tempCreate.success) {
        $targetUserId = $tempCreate.body.id
        Write-Host "Temp user created id=$targetUserId email=$($tempCreate.body.email)" -ForegroundColor Green
    } else {
        Write-Host "Temp create failed ($($tempCreate.status)): $($tempCreate.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += @{
            test = "Setup temp user for Get/Update/Delete";
            expected = "200 OK";
            actual = $tempCreate.status;
            details = ($tempCreate.body | ConvertTo-Json -Depth 10)
        }
    }
}

if (${doUser} -and ${doGet} -and $targetUserId) {
    $userIdUrl = "$usersUrl/$targetUserId"
    Write-Section "Get User by Id (authorized)"
    $getOneAuth = Try-InvokeJsonGet -Uri $userIdUrl -Headers $authHeaders
    if ($getOneAuth.success -and $getOneAuth.status -eq 200 -and $getOneAuth.body.id -eq $targetUserId) {
        Write-Host "Fetched user id=$($getOneAuth.body.id) email=$($getOneAuth.body.email)" -ForegroundColor Green
    } else {
        Write-Host "Get by id failed ($($getOneAuth.status)): $($getOneAuth.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += @{
            test = "Get by id with token should succeed";
            expected = "200 OK";
            actual = $getOneAuth.status;
            details = ($getOneAuth.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "Get User by Id (without token should be 401/403)"
    $getOneNoAuth = Try-InvokeJsonGet -Uri $userIdUrl -Headers @{}
    if (-not $getOneNoAuth.success -and ($getOneNoAuth.status -eq 401 -or $getOneNoAuth.status -eq 403)) {
        Write-Host "Unauthorized access correctly blocked ($($getOneNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth result: success=$($getOneNoAuth.success) status=$($getOneNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Get by id without token should be 401/403";
            expected = "401/403";
            actual = $getOneNoAuth.status;
            details = if ($getOneNoAuth.body) { ($getOneNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doUser} -and ${doUpdate} -and $targetUserId) {
    $userIdUrl = "$usersUrl/$targetUserId"
    # Fetch current to preserve email unless we intend to change it
    $currentResp = Try-InvokeJsonGet -Uri $userIdUrl -Headers $authHeaders
    $currentEmail = if ($currentResp.success) { $currentResp.body.email } else { $null }
    $updatePayload = @{ name = "Updated User"; role = "ADMIN" }
    if ($currentEmail) { $updatePayload.email = $currentEmail }
    Write-Section "Update User (authorized)"
    $updateAuth = Try-InvokeJsonPut -Uri $userIdUrl -Headers $authHeaders -Body $updatePayload
    if ($updateAuth.success -and $updateAuth.status -eq 200 -and $updateAuth.body.name -eq $updatePayload.name) {
        Write-Host "Update success: id=$($updateAuth.body.id) name=$($updateAuth.body.name) role=$($updateAuth.body.role)" -ForegroundColor Green
    } else {
        Write-Host "Update failed ($($updateAuth.status)): $($updateAuth.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += @{
            test = "Update with token should succeed";
            expected = "200 OK";
            actual = $updateAuth.status;
            details = ($updateAuth.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "Update User (without token should be 401/403)"
    $updateNoAuth = Try-InvokeJsonPut -Uri $userIdUrl -Headers @{} -Body $updatePayload
    if (-not $updateNoAuth.success -and ($updateNoAuth.status -eq 401 -or $updateNoAuth.status -eq 403)) {
        Write-Host "Unauthorized access correctly blocked ($($updateNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth result: success=$($updateNoAuth.success) status=$($updateNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Update without token should be 401/403";
            expected = "401/403";
            actual = $updateNoAuth.status;
            details = if ($updateNoAuth.body) { ($updateNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doUser} -and ${doDelete} -and $targetUserId) {
    $userIdUrl = "$usersUrl/$targetUserId"
    Write-Section "Delete User (authorized)"
    $deleteAuth = Try-InvokeDelete -Uri $userIdUrl -Headers $authHeaders
    if ($deleteAuth.success -and $deleteAuth.status -eq 204) {
        Write-Host "Delete success (204)" -ForegroundColor Green
    } else {
        Write-Host "Delete failed ($($deleteAuth.status)): $($deleteAuth.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += @{
            test = "Delete with token should be 204";
            expected = "204 No Content";
            actual = $deleteAuth.status;
            details = ($deleteAuth.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "Get After Delete (should be 404)"
    $afterDel = Try-InvokeJsonGet -Uri $userIdUrl -Headers $authHeaders
    if (-not $afterDel.success -and $afterDel.status -eq 404) {
        Write-Host "Get after delete returned 404 as expected" -ForegroundColor Green
    } else {
        Write-Host "Unexpected get after delete: success=$($afterDel.success) status=$($afterDel.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Get after delete should be 404";
            expected = "404 Not Found";
            actual = $afterDel.status;
            details = if ($afterDel.body) { ($afterDel.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }

    Write-Section "Delete User (without token should be 401/403)"
    # Try delete again without token; status should be 401/403 regardless of existence
    $deleteNoAuth = Try-InvokeDelete -Uri $userIdUrl -Headers @{}
    if (-not $deleteNoAuth.success -and ($deleteNoAuth.status -eq 401 -or $deleteNoAuth.status -eq 403)) {
        Write-Host "Unauthorized delete correctly blocked ($($deleteNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth delete result: success=$($deleteNoAuth.success) status=$($deleteNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Delete without token should be 401/403";
            expected = "401/403";
            actual = $deleteNoAuth.status;
            details = if ($deleteNoAuth.body) { ($deleteNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

# =====================
# Product CRUD tests
# =====================

function New-RandomSku {
    $ts = [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff')
    return "SKU-$ts"
}

function New-RandomSlug {
    $ts = [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff')
    return "category-$ts"
}

function New-ProductPayload {
    param(
        [int]$CategoryId
    )
    $sku = New-RandomSku
    return @{
        name = "Auto Test Product $sku"
        description = "Created by script"
        sku = $sku
        price = 99.99
        stockQuantity = 10
        category = @{ id = $CategoryId }
        brand = "BrandX"
        color = "Red"
        size = "M"
        isActive = $true
    }
}

function New-CategoryPayload {
    $slug = New-RandomSlug
    return @{
        name = "Auto Test Category $slug"
        slug = $slug
        description = "Created by script"
        isActive = $true
    }
}

function New-OrderPayload {
    return @{
        shippingAddress = @{
            fullName = "Test User"
            phone = "0123456789"
            addressLine1 = "123 Test Street"
            city = "Ho Chi Minh City"
            country = "Vietnam"
        }
        paymentMethod = "CASH_ON_DELIVERY"
        shippingFee = 30000
    }
}

function Write-EntityReport {
    param(
        [string]$Entity,
        [string]$BaseUrl,
        [string]$Mode,
        [string]$Timestamp,
        [array]$EntityTests,
        [array]$EntityFailures,
        [hashtable]$TestResults
    )
    
    $entityReportsDir = Join-Path $PSScriptRoot "..\guide\reports"
    $entityDir = Join-Path $entityReportsDir $Entity
    if (-not (Test-Path $entityDir)) { New-Item -ItemType Directory -Path $entityDir -Force | Out-Null }
    
    $entityReportPath = Join-Path $entityDir "Test_Report.md"
    
    $entityTotal = ($EntityTests | Where-Object { $null -ne $_ }).Count
    $entityFailed = $EntityFailures.Count
    $entityPassed = $entityTotal - $entityFailed
    $entityRate = if ($entityTotal -gt 0) { [math]::Round(($entityPassed*100.0)/$entityTotal,2) } else { 0 }
    
    $entitySummary = @()
    $entitySummary += "# $Entity Entity Test Report"
    $entitySummary += ""
    $entitySummary += "**Date:** $Timestamp"
    $entitySummary += "**BaseUrl:** $BaseUrl"
    $entitySummary += "**Mode:** $Mode"
    $entitySummary += ""
    $entitySummary += "## Summary"
    $entitySummary += "- **Total Tests:** $entityTotal"
    $entitySummary += "- **Passed:** $entityPassed"
    $entitySummary += "- **Failed:** $entityFailed"
    $entitySummary += "- **Pass Rate:** $entityRate%"
    $entitySummary += ""
    
    # Add detailed test results
    $entitySummary += "## Test Results"
    $entitySummary += ""
    
    foreach ($test in $TestResults.GetEnumerator()) {
        $entitySummary += "- **$($test.Key):** Expected $($test.Value.Expected), Actual: $($test.Value.Actual)"
    }
    
    $entitySummary += ""
    
    # Add failure details if any
    if ($entityFailures.Count -gt 0) {
        $entitySummary += "## Failed Tests"
        $entitySummary += ""
        $i = 1
        foreach ($failure in $entityFailures) {
            $entitySummary += "### $i. $($failure.test)"
            $entitySummary += "- **Expected:** $($failure.expected)"
            $entitySummary += "- **Actual:** $($failure.actual)"
            if ($failure.details) {
                $entitySummary += "- **Details:**"
                $entitySummary += '```json'
                $entitySummary += $failure.details
                $entitySummary += '```'
            }
            $entitySummary += ""
            $i++
        }
    } else {
        $entitySummary += "## Failed Tests"
        $entitySummary += ""
        $entitySummary += "No failed tests for $Entity entity."
        $entitySummary += ""
    }
    
    Set-Content -Path $entityReportPath -Value $entitySummary -Encoding UTF8
    Write-Host "$Entity report written to $entityReportPath" -ForegroundColor Cyan
}

$pTargetId = $null

if (${doProduct} -and ${doCreate}) {
    Write-Section "[Product] Create (should be 201)"
    $pPayload = New-ProductPayload -CategoryId $ProductCategoryId
    $pCreate = Try-InvokeJsonPost -Uri $productsUrl -Headers $authHeaders -Body $pPayload
    if ($pCreate.success -and ($pCreate.status -eq 200 -or $pCreate.status -eq 201)) {
        # Some controllers return 201, our Try helper maps success=200. Accept both.
        Write-Host "Product create success: id=$($pCreate.body.id) sku=$($pCreate.body.sku)" -ForegroundColor Green
        $pTargetId = $pCreate.body.id
    } else {
        Write-Host "Product create failed ($($pCreate.status)): $($pCreate.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += @{
            test = "Product Create should be 201/200";
            expected = "201/200";
            actual = $pCreate.status;
            details = ($pCreate.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Product] Create Duplicate SKU (should be 400)"
    $pCreateDup = Try-InvokeJsonPost -Uri $productsUrl -Headers $authHeaders -Body $pPayload
    if (-not $pCreateDup.success -and $pCreateDup.status -eq 400) {
        Write-Host "Duplicate SKU rejected (400)" -ForegroundColor Green
    } else {
        Write-Host "Unexpected duplicate SKU result: success=$($pCreateDup.success) status=$($pCreateDup.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Product Create duplicate should be 400";
            expected = "400";
            actual = $pCreateDup.status;
            details = ($pCreateDup.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Product] Create Without Token (should be 401/403)"
    $pCreateNoAuth = Try-InvokeJsonPost -Uri $productsUrl -Headers @{} -Body $pPayload
    if (-not $pCreateNoAuth.success -and ($pCreateNoAuth.status -eq 401 -or $pCreateNoAuth.status -eq 403)) {
        Write-Host "Unauthorized create blocked ($($pCreateNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth create result: success=$($pCreateNoAuth.success) status=$($pCreateNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Product Create without token should be 401/403";
            expected = "401/403";
            actual = $pCreateNoAuth.status;
            details = if ($pCreateNoAuth.body) { ($pCreateNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doProduct} -and ${doGetAll}) {
    Write-Section "[Product] Get All (authorized)"
    $pGetAllAuth = Try-InvokeJsonGet -Uri $productsUrl -Headers $authHeaders
    if ($pGetAllAuth.success -and $pGetAllAuth.status -eq 200) {
        $cnt = 0; try { $cnt = ($pGetAllAuth.body | Measure-Object).Count } catch {}
        Write-Host "Products fetched: $cnt" -ForegroundColor Green
    } else {
        Write-Host "Product GetAll failed ($($pGetAllAuth.status))" -ForegroundColor Red
        $failures += @{
            test = "Product GetAll with token should be 200";
            expected = "200";
            actual = $pGetAllAuth.status;
            details = ($pGetAllAuth.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Product] Get All (without token should be 401/403)"
    $pGetAllNoAuth = Try-InvokeJsonGet -Uri $productsUrl -Headers @{}
    if (-not $pGetAllNoAuth.success -and ($pGetAllNoAuth.status -eq 401 -or $pGetAllNoAuth.status -eq 403)) {
        Write-Host "Unauthorized getAll blocked ($($pGetAllNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth getAll result: success=$($pGetAllNoAuth.success) status=$($pGetAllNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Product GetAll without token should be 401/403";
            expected = "401/403";
            actual = $pGetAllNoAuth.status;
            details = if ($pGetAllNoAuth.body) { ($pGetAllNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doProduct} -and ${doGet} -and $pTargetId) {
    $pIdUrl = "$productsUrl/$pTargetId"
    Write-Section "[Product] Get By Id (authorized)"
    $pGetOneAuth = Try-InvokeJsonGet -Uri $pIdUrl -Headers $authHeaders
    if ($pGetOneAuth.success -and $pGetOneAuth.status -eq 200 -and $pGetOneAuth.body.id -eq $pTargetId) {
        Write-Host "Product fetched id=$pTargetId" -ForegroundColor Green
    } else {
        Write-Host "Product get by id failed ($($pGetOneAuth.status))" -ForegroundColor Red
        $failures += @{
            test = "Product Get by id with token should be 200";
            expected = "200";
            actual = $pGetOneAuth.status;
            details = ($pGetOneAuth.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Product] Get By Id (without token should be 401/403)"
    $pGetOneNoAuth = Try-InvokeJsonGet -Uri $pIdUrl -Headers @{}
    if (-not $pGetOneNoAuth.success -and ($pGetOneNoAuth.status -eq 401 -or $pGetOneNoAuth.status -eq 403)) {
        Write-Host "Unauthorized get by id blocked ($($pGetOneNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth get by id: success=$($pGetOneNoAuth.success) status=$($pGetOneNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Product Get by id without token should be 401/403";
            expected = "401/403";
            actual = $pGetOneNoAuth.status;
            details = if ($pGetOneNoAuth.body) { ($pGetOneNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doProduct} -and ${doUpdate} -and $pTargetId) {
    $pIdUrl = "$productsUrl/$pTargetId"
    $pUpdatePayload = @{ name = "Updated Product"; price = 79.99; stockQuantity = 5 }
    Write-Section "[Product] Update (authorized)"
    $pUpdateAuth = Try-InvokeJsonPut -Uri $pIdUrl -Headers $authHeaders -Body $pUpdatePayload
    if ($pUpdateAuth.success -and $pUpdateAuth.status -eq 200) {
        Write-Host "Product update success id=$pTargetId" -ForegroundColor Green
    } else {
        Write-Host "Product update failed ($($pUpdateAuth.status))" -ForegroundColor Red
        $failures += @{
            test = "Product Update with token should be 200";
            expected = "200";
            actual = $pUpdateAuth.status;
            details = ($pUpdateAuth.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Product] Update (without token should be 401/403)"
    $pUpdateNoAuth = Try-InvokeJsonPut -Uri $pIdUrl -Headers @{} -Body $pUpdatePayload
    if (-not $pUpdateNoAuth.success -and ($pUpdateNoAuth.status -eq 401 -or $pUpdateNoAuth.status -eq 403)) {
        Write-Host "Unauthorized update blocked ($($pUpdateNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth update result: success=$($pUpdateNoAuth.success) status=$($pUpdateNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Product Update without token should be 401/403";
            expected = "401/403";
            actual = $pUpdateNoAuth.status;
            details = if ($pUpdateNoAuth.body) { ($pUpdateNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doProduct} -and ${doDelete} -and $pTargetId -and -not ${doOrder}) {
    # Only delete product if not testing Order (Order needs product in cart)
    $pIdUrl = "$productsUrl/$pTargetId"
    Write-Section "[Product] Delete (authorized)"
    $pDeleteAuth = Try-InvokeDelete -Uri $pIdUrl -Headers $authHeaders
    if ($pDeleteAuth.success -and ($pDeleteAuth.status -eq 200 -or $pDeleteAuth.status -eq 204)) {
        Write-Host "Product delete success ($($pDeleteAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Product delete failed ($($pDeleteAuth.status))" -ForegroundColor Red
        $failures += @{
            test = "Product Delete with token should be 200/204";
            expected = "200/204";
            actual = $pDeleteAuth.status;
            details = ($pDeleteAuth.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Product] Get After Delete (should be 404)"
    $pAfterDel = Try-InvokeJsonGet -Uri $pIdUrl -Headers $authHeaders
    if (-not $pAfterDel.success -and $pAfterDel.status -eq 404) {
        Write-Host "Product get after delete 404 as expected" -ForegroundColor Green
    } else {
        Write-Host "Unexpected product get after delete: success=$($pAfterDel.success) status=$($pAfterDel.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Product Get after delete should be 404";
            expected = "404";
            actual = $pAfterDel.status;
            details = if ($pAfterDel.body) { ($pAfterDel.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }

    Write-Section "[Product] Delete (without token should be 401/403)"
    $pDeleteNoAuth = Try-InvokeDelete -Uri $pIdUrl -Headers @{}
    if (-not $pDeleteNoAuth.success -and ($pDeleteNoAuth.status -eq 401 -or $pDeleteNoAuth.status -eq 403)) {
        Write-Host "Unauthorized delete blocked ($($pDeleteNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth delete: success=$($pDeleteNoAuth.success) status=$($pDeleteNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Product Delete without token should be 401/403";
            expected = "401/403";
            actual = $pDeleteNoAuth.status;
            details = if ($pDeleteNoAuth.body) { ($pDeleteNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

# =====================
# Category CRUD tests
# =====================

$cTargetId = $null

if (${doCategory} -and ${doCreate}) {
    Write-Section "[Category] Create (should be 201)"
    $cPayload = New-CategoryPayload
    $cCreate = Try-InvokeJsonPost -Uri $categoriesUrl -Headers $authHeaders -Body $cPayload
    if ($cCreate.success -and ($cCreate.status -eq 200 -or $cCreate.status -eq 201)) {
        Write-Host "Category create success: id=$($cCreate.body.id) slug=$($cCreate.body.slug)" -ForegroundColor Green
        $cTargetId = $cCreate.body.id
    } else {
        Write-Host "Category create failed ($($cCreate.status)): $($cCreate.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += @{
            test = "Category Create should be 201/200";
            expected = "201/200";
            actual = $cCreate.status;
            details = ($cCreate.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Category] Create Duplicate Slug (should be 400)"
    $cCreateDup = Try-InvokeJsonPost -Uri $categoriesUrl -Headers $authHeaders -Body $cPayload
    if (-not $cCreateDup.success -and $cCreateDup.status -eq 400) {
        Write-Host "Duplicate slug rejected (400)" -ForegroundColor Green
    } else {
        Write-Host "Unexpected duplicate slug result: success=$($cCreateDup.success) status=$($cCreateDup.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Category Create duplicate should be 400";
            expected = "400";
            actual = $cCreateDup.status;
            details = ($cCreateDup.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Category] Create Without Token (should be 401/403)"
    $cCreateNoAuth = Try-InvokeJsonPost -Uri $categoriesUrl -Headers @{} -Body $cPayload
    if (-not $cCreateNoAuth.success -and ($cCreateNoAuth.status -eq 401 -or $cCreateNoAuth.status -eq 403)) {
        Write-Host "Unauthorized create blocked ($($cCreateNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth create result: success=$($cCreateNoAuth.success) status=$($cCreateNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Category Create without token should be 401/403";
            expected = "401/403";
            actual = $cCreateNoAuth.status;
            details = if ($cCreateNoAuth.body) { ($cCreateNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doCategory} -and ${doGetAll}) {
    Write-Section "[Category] Get All Active (authorized)"
    $cGetAllAuth = Try-InvokeJsonGet -Uri "$categoriesUrl/active" -Headers $authHeaders
    if ($cGetAllAuth.success -and $cGetAllAuth.status -eq 200) {
        $cnt = 0; try { $cnt = ($cGetAllAuth.body | Measure-Object).Count } catch {}
        Write-Host "Active categories fetched: $cnt" -ForegroundColor Green
    } else {
        Write-Host "Category GetAll failed ($($cGetAllAuth.status))" -ForegroundColor Red
        $failures += @{
            test = "Category GetAll with token should be 200";
            expected = "200";
            actual = $cGetAllAuth.status;
            details = ($cGetAllAuth.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Category] Get All Active (without token should be 401/403)"
    $cGetAllNoAuth = Try-InvokeJsonGet -Uri "$categoriesUrl/active" -Headers @{}
    if (-not $cGetAllNoAuth.success -and ($cGetAllNoAuth.status -eq 401 -or $cGetAllNoAuth.status -eq 403)) {
        Write-Host "Unauthorized getAll blocked ($($cGetAllNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth getAll result: success=$($cGetAllNoAuth.success) status=$($cGetAllNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Category GetAll without token should be 401/403";
            expected = "401/403";
            actual = $cGetAllNoAuth.status;
            details = if ($cGetAllNoAuth.body) { ($cGetAllNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

# Ensure we have a target category id for Get/Update/Delete
if ((${doGet} -or ${doUpdate} -or ${doDelete}) -and -not $cTargetId) {
    # Create a temporary category to operate on when Create step not executed
    Write-Section "Create Temp Category for subsequent tests"
    $tempCategory = New-CategoryPayload
    $tempCreate = Try-InvokeJsonPost -Uri $categoriesUrl -Headers $authHeaders -Body $tempCategory
    if ($tempCreate.success) {
        $cTargetId = $tempCreate.body.id
        Write-Host "Temp category created id=$cTargetId slug=$($tempCreate.body.slug)" -ForegroundColor Green
    } else {
        Write-Host "Temp category create failed ($($tempCreate.status)): $($tempCreate.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += @{
            test = "Setup temp category for Get/Update/Delete";
            expected = "200 OK";
            actual = $tempCreate.status;
            details = ($tempCreate.body | ConvertTo-Json -Depth 10)
        }
    }
}

if (${doCategory} -and ${doGet} -and $cTargetId) {
    $cIdUrl = "$categoriesUrl/$cTargetId"
    Write-Section "[Category] Get By Id (authorized)"
    $cGetOneAuth = Try-InvokeJsonGet -Uri $cIdUrl -Headers $authHeaders
    if ($cGetOneAuth.success -and $cGetOneAuth.status -eq 200 -and $cGetOneAuth.body.id -eq $cTargetId) {
        Write-Host "Category fetched id=$cTargetId" -ForegroundColor Green
    } else {
        Write-Host "Category get by id failed ($($cGetOneAuth.status))" -ForegroundColor Red
        $failures += @{
            test = "Category Get by id with token should be 200";
            expected = "200";
            actual = $cGetOneAuth.status;
            details = ($cGetOneAuth.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Category] Get By Id (without token should be 401/403)"
    $cGetOneNoAuth = Try-InvokeJsonGet -Uri $cIdUrl -Headers @{}
    if (-not $cGetOneNoAuth.success -and ($cGetOneNoAuth.status -eq 401 -or $cGetOneNoAuth.status -eq 403)) {
        Write-Host "Unauthorized get by id blocked ($($cGetOneNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth get by id: success=$($cGetOneNoAuth.success) status=$($cGetOneNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Category Get by id without token should be 401/403";
            expected = "401/403";
            actual = $cGetOneNoAuth.status;
            details = if ($cGetOneNoAuth.body) { ($cGetOneNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doCategory} -and ${doUpdate} -and $cTargetId) {
    $cIdUrl = "$categoriesUrl/$cTargetId"
    $cUpdatePayload = @{ name = "Updated Category"; description = "Updated by script" }
    Write-Section "[Category] Update (authorized)"
    $cUpdateAuth = Try-InvokeJsonPut -Uri $cIdUrl -Headers $authHeaders -Body $cUpdatePayload
    if ($cUpdateAuth.success -and $cUpdateAuth.status -eq 200) {
        Write-Host "Category update success id=$cTargetId" -ForegroundColor Green
    } else {
        Write-Host "Category update failed ($($cUpdateAuth.status))" -ForegroundColor Red
        $failures += @{
            test = "Category Update with token should be 200";
            expected = "200";
            actual = $cUpdateAuth.status;
            details = ($cUpdateAuth.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Category] Update (without token should be 401/403)"
    $cUpdateNoAuth = Try-InvokeJsonPut -Uri $cIdUrl -Headers @{} -Body $cUpdatePayload
    if (-not $cUpdateNoAuth.success -and ($cUpdateNoAuth.status -eq 401 -or $cUpdateNoAuth.status -eq 403)) {
        Write-Host "Unauthorized update blocked ($($cUpdateNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth update result: success=$($cUpdateNoAuth.success) status=$($cUpdateNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Category Update without token should be 401/403";
            expected = "401/403";
            actual = $cUpdateNoAuth.status;
            details = if ($cUpdateNoAuth.body) { ($cUpdateNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doCategory} -and ${doDelete} -and $cTargetId) {
    $cIdUrl = "$categoriesUrl/$cTargetId"
    Write-Section "[Category] Delete (authorized)"
    $cDeleteAuth = Try-InvokeDelete -Uri $cIdUrl -Headers $authHeaders
    if ($cDeleteAuth.success -and ($cDeleteAuth.status -eq 200 -or $cDeleteAuth.status -eq 204)) {
        Write-Host "Category delete success ($($cDeleteAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Category delete failed ($($cDeleteAuth.status))" -ForegroundColor Red
        $failures += @{
            test = "Category Delete with token should be 200/204";
            expected = "200/204";
            actual = $cDeleteAuth.status;
            details = ($cDeleteAuth.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Category] Get After Delete (should be 404)"
    $cAfterDel = Try-InvokeJsonGet -Uri $cIdUrl -Headers $authHeaders
    if (-not $cAfterDel.success -and $cAfterDel.status -eq 404) {
        Write-Host "Category get after delete 404 as expected" -ForegroundColor Green
    } else {
        Write-Host "Unexpected category get after delete: success=$($cAfterDel.success) status=$($cAfterDel.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Category Get after delete should be 404";
            expected = "404";
            actual = $cAfterDel.status;
            details = if ($cAfterDel.body) { ($cAfterDel.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }

    Write-Section "[Category] Delete (without token should be 401/403)"
    $cDeleteNoAuth = Try-InvokeDelete -Uri $cIdUrl -Headers @{}
    if (-not $cDeleteNoAuth.success -and ($cDeleteNoAuth.status -eq 401 -or $cDeleteNoAuth.status -eq 403)) {
        Write-Host "Unauthorized delete blocked ($($cDeleteNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth delete: success=$($cDeleteNoAuth.success) status=$($cDeleteNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Category Delete without token should be 401/403";
            expected = "401/403";
            actual = $cDeleteNoAuth.status;
            details = if ($cDeleteNoAuth.body) { ($cDeleteNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

# =====================
# Cart workflow tests
# =====================

if (${doCart}) {
    Write-Section "[Cart] Get Cart (authorized)"
    $cartGet = Try-InvokeJsonGet -Uri $cartUrl -Headers $authHeaders
    if ($cartGet.success -and $cartGet.status -eq 200) {
        Write-Host "Cart fetched successfully" -ForegroundColor Green
    } elseif (-not $cartGet.success -and $cartGet.status -eq 404) {
        Write-Host "Empty cart (404) - this is expected for new user" -ForegroundColor Yellow
    } else {
        Write-Host "Cart get failed ($($cartGet.status)): $($cartGet.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += @{
            test = "Cart Get should be 200 or 404";
            expected = "200/404";
            actual = $cartGet.status;
            details = ($cartGet.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Cart] Get Cart (without token should be 401/403)"
    $cartGetNoAuth = Try-InvokeJsonGet -Uri $cartUrl -Headers @{}
    if (-not $cartGetNoAuth.success -and ($cartGetNoAuth.status -eq 401 -or $cartGetNoAuth.status -eq 403)) {
        Write-Host "Unauthorized cart access blocked ($($cartGetNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth cart result: success=$($cartGetNoAuth.success) status=$($cartGetNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Cart Get without token should be 401/403";
            expected = "401/403";
            actual = $cartGetNoAuth.status;
            details = if ($cartGetNoAuth.body) { ($cartGetNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }

    # Only test cart operations if we have a product to work with
    if ($pTargetId) {
        Write-Section "[Cart] Add Item (authorized)"
        $addItemUrl = "$cartUrl/items?productId=$pTargetId&quantity=2"
        $cartAddItem = Try-InvokeJsonPost -Uri $addItemUrl -Headers $authHeaders -Body $null
        if ($cartAddItem.success -and $cartAddItem.status -eq 200) {
            Write-Host "Item added to cart successfully" -ForegroundColor Green
        } else {
            Write-Host "Add item failed ($($cartAddItem.status)): $($cartAddItem.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
            $failures += @{
                test = "Cart Add Item should be 200";
                expected = "200";
                actual = $cartAddItem.status;
                details = ($cartAddItem.body | ConvertTo-Json -Depth 10)
            }
        }

        Write-Section "[Cart] Add Item (without token should be 401/403)"
        $cartAddItemNoAuth = Try-InvokeJsonPost -Uri $addItemUrl -Headers @{} -Body $null
        if (-not $cartAddItemNoAuth.success -and ($cartAddItemNoAuth.status -eq 401 -or $cartAddItemNoAuth.status -eq 403)) {
            Write-Host "Unauthorized add item blocked ($($cartAddItemNoAuth.status))" -ForegroundColor Green
        } else {
            Write-Host "Unexpected unauth add item result: success=$($cartAddItemNoAuth.success) status=$($cartAddItemNoAuth.status)" -ForegroundColor Yellow
            $failures += @{
                test = "Cart Add Item without token should be 401/403";
                expected = "401/403";
                actual = $cartAddItemNoAuth.status;
                details = if ($cartAddItemNoAuth.body) { ($cartAddItemNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
            }
        }

        Write-Section "[Cart] Update Quantity (authorized)"
        $updateQtyUrl = "$cartUrl/items/$pTargetId?quantity=5"
        $cartUpdateQty = Try-InvokeJsonPut -Uri $updateQtyUrl -Headers $authHeaders -Body $null
        if ($cartUpdateQty.success -and $cartUpdateQty.status -eq 200) {
            Write-Host "Cart quantity updated successfully" -ForegroundColor Green
        } else {
            Write-Host "Update quantity failed ($($cartUpdateQty.status)): $($cartUpdateQty.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
            $failures += @{
                test = "Cart Update Quantity should be 200";
                expected = "200";
                actual = $cartUpdateQty.status;
                details = ($cartUpdateQty.body | ConvertTo-Json -Depth 10)
            }
        }

        Write-Section "[Cart] Update Quantity (without token should be 401/403)"
        $cartUpdateQtyNoAuth = Try-InvokeJsonPut -Uri $updateQtyUrl -Headers @{} -Body $null
        if (-not $cartUpdateQtyNoAuth.success -and ($cartUpdateQtyNoAuth.status -eq 401 -or $cartUpdateQtyNoAuth.status -eq 403)) {
            Write-Host "Unauthorized update quantity blocked ($($cartUpdateQtyNoAuth.status))" -ForegroundColor Green
        } else {
            Write-Host "Unexpected unauth update quantity result: success=$($cartUpdateQtyNoAuth.success) status=$($cartUpdateQtyNoAuth.status)" -ForegroundColor Yellow
            $failures += @{
                test = "Cart Update Quantity without token should be 401/403";
                expected = "401/403";
                actual = $cartUpdateQtyNoAuth.status;
                details = if ($cartUpdateQtyNoAuth.body) { ($cartUpdateQtyNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
            }
        }

        Write-Section "[Cart] Remove Item (authorized)"
        $removeItemUrl = "$cartUrl/items/$pTargetId"
        $cartRemoveItem = Try-InvokeDelete -Uri $removeItemUrl -Headers $authHeaders
        if ($cartRemoveItem.success -and ($cartRemoveItem.status -eq 200 -or $cartRemoveItem.status -eq 204)) {
            Write-Host "Item removed from cart successfully" -ForegroundColor Green
        } else {
            Write-Host "Remove item failed ($($cartRemoveItem.status)): $($cartRemoveItem.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
            $failures += @{
                test = "Cart Remove Item should be 200/204";
                expected = "200/204";
                actual = $cartRemoveItem.status;
                details = ($cartRemoveItem.body | ConvertTo-Json -Depth 10)
            }
        }

        Write-Section "[Cart] Remove Item (without token should be 401/403)"
        $cartRemoveItemNoAuth = Try-InvokeDelete -Uri $removeItemUrl -Headers @{}
        if (-not $cartRemoveItemNoAuth.success -and ($cartRemoveItemNoAuth.status -eq 401 -or $cartRemoveItemNoAuth.status -eq 403)) {
            Write-Host "Unauthorized remove item blocked ($($cartRemoveItemNoAuth.status))" -ForegroundColor Green
        } else {
            Write-Host "Unexpected unauth remove item result: success=$($cartRemoveItemNoAuth.success) status=$($cartRemoveItemNoAuth.status)" -ForegroundColor Yellow
            $failures += @{
                test = "Cart Remove Item without token should be 401/403";
                expected = "401/403";
                actual = $cartRemoveItemNoAuth.status;
                details = if ($cartRemoveItemNoAuth.body) { ($cartRemoveItemNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
            }
        }
    }

    Write-Section "[Cart] Clear Cart (authorized)"
    $cartClear = Try-InvokeDelete -Uri $cartUrl -Headers $authHeaders
    if ($cartClear.success -and ($cartClear.status -eq 200 -or $cartClear.status -eq 204)) {
        Write-Host "Cart cleared successfully" -ForegroundColor Green
    } else {
        Write-Host "Clear cart failed ($($cartClear.status)): $($cartClear.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += @{
            test = "Cart Clear should be 200/204";
            expected = "200/204";
            actual = $cartClear.status;
            details = ($cartClear.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Cart] Clear Cart (without token should be 401/403)"
    $cartClearNoAuth = Try-InvokeDelete -Uri $cartUrl -Headers @{}
    if (-not $cartClearNoAuth.success -and ($cartClearNoAuth.status -eq 401 -or $cartClearNoAuth.status -eq 403)) {
        Write-Host "Unauthorized clear cart blocked ($($cartClearNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth clear cart result: success=$($cartClearNoAuth.success) status=$($cartClearNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Cart Clear without token should be 401/403";
            expected = "401/403";
            actual = $cartClearNoAuth.status;
            details = if ($cartClearNoAuth.body) { ($cartClearNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

# =====================
# Order workflow tests
# =====================

$oTargetId = $null
$oOrderNumber = $null

if (${doOrder} -and ${doCreate}) {
    # First, ensure we have a product and items in cart for order creation
    if (-not $pTargetId) {
        # Create a product for order testing
        Write-Section "[Order] Create product for order testing"
        $pPayload = New-ProductPayload -CategoryId $ProductCategoryId
        $pCreateForOrder = Try-InvokeJsonPost -Uri $productsUrl -Headers $authHeaders -Body $pPayload
        if ($pCreateForOrder.success -and ($pCreateForOrder.status -eq 200 -or $pCreateForOrder.status -eq 201)) {
            $pTargetId = $pCreateForOrder.body.id
            Write-Host "Product created for order testing: id=$pTargetId" -ForegroundColor Green
        } else {
            Write-Host "Failed to create product for order testing ($($pCreateForOrder.status))" -ForegroundColor Red
        }
    }
    
    if ($pTargetId) {
        Write-Section "[Order] Add item to cart for order creation"
        $addItemUrl = "$cartUrl/items?productId=$pTargetId&quantity=2"
        $cartAddForOrder = Try-InvokeJsonPost -Uri $addItemUrl -Headers $authHeaders -Body $null
        if ($cartAddForOrder.success) {
            Write-Host "Item added to cart for order creation" -ForegroundColor Green
        } else {
            Write-Host "Failed to add item to cart for order creation ($($cartAddForOrder.status))" -ForegroundColor Yellow
        }
    }

    Write-Section "[Order] Create Order from Cart (authorized)"
    $oPayload = New-OrderPayload
    $oCreateFromCart = Try-InvokeJsonPost -Uri "$ordersUrl/create-from-cart" -Headers $authHeaders -Body $oPayload
    if ($oCreateFromCart.success -and ($oCreateFromCart.status -eq 200 -or $oCreateFromCart.status -eq 201)) {
        Write-Host "Order created successfully: id=$($oCreateFromCart.body.id) number=$($oCreateFromCart.body.orderNumber)" -ForegroundColor Green
        $oTargetId = $oCreateFromCart.body.id
        $oOrderNumber = $oCreateFromCart.body.orderNumber
    } else {
        Write-Host "Order creation failed ($($oCreateFromCart.status)): $($oCreateFromCart.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += @{
            test = "Order Create from Cart should be 200/201";
            expected = "200/201";
            actual = $oCreateFromCart.status;
            details = ($oCreateFromCart.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Order] Create Order from Cart (without token should be 401/403)"
    $oCreateFromCartNoAuth = Try-InvokeJsonPost -Uri "$ordersUrl/create-from-cart" -Headers @{} -Body $oPayload
    if (-not $oCreateFromCartNoAuth.success -and ($oCreateFromCartNoAuth.status -eq 401 -or $oCreateFromCartNoAuth.status -eq 403)) {
        Write-Host "Unauthorized order creation blocked ($($oCreateFromCartNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth order creation result: success=$($oCreateFromCartNoAuth.success) status=$($oCreateFromCartNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Order Create from Cart without token should be 401/403";
            expected = "401/403";
            actual = $oCreateFromCartNoAuth.status;
            details = if ($oCreateFromCartNoAuth.body) { ($oCreateFromCartNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doOrder} -and ${doGet} -and $oTargetId) {
    Write-Section "[Order] Get Order by ID (authorized)"
    $oGetById = Try-InvokeJsonGet -Uri "$ordersUrl/$oTargetId" -Headers $authHeaders
    if ($oGetById.success -and $oGetById.status -eq 200 -and $oGetById.body.id -eq $oTargetId) {
        Write-Host "Order fetched by ID: id=$oTargetId status=$($oGetById.body.status)" -ForegroundColor Green
    } else {
        Write-Host "Order get by ID failed ($($oGetById.status))" -ForegroundColor Red
        $failures += @{
            test = "Order Get by ID with token should be 200";
            expected = "200";
            actual = $oGetById.status;
            details = ($oGetById.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Order] Get Order by ID (without token should be 401/403)"
    $oGetByIdNoAuth = Try-InvokeJsonGet -Uri "$ordersUrl/$oTargetId" -Headers @{}
    if (-not $oGetByIdNoAuth.success -and ($oGetByIdNoAuth.status -eq 401 -or $oGetByIdNoAuth.status -eq 403)) {
        Write-Host "Unauthorized order get by ID blocked ($($oGetByIdNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth order get by ID result: success=$($oGetByIdNoAuth.success) status=$($oGetByIdNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Order Get by ID without token should be 401/403";
            expected = "401/403";
            actual = $oGetByIdNoAuth.status;
            details = if ($oGetByIdNoAuth.body) { ($oGetByIdNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doOrder} -and ${doGet} -and $oOrderNumber) {
    Write-Section "[Order] Get Order by Number (authorized)"
    $oGetByNumber = Try-InvokeJsonGet -Uri "$ordersUrl/number/$oOrderNumber" -Headers $authHeaders
    if ($oGetByNumber.success -and $oGetByNumber.status -eq 200 -and $oGetByNumber.body.orderNumber -eq $oOrderNumber) {
        Write-Host "Order fetched by number: number=$oOrderNumber" -ForegroundColor Green
    } else {
        Write-Host "Order get by number failed ($($oGetByNumber.status))" -ForegroundColor Red
        $failures += @{
            test = "Order Get by Number with token should be 200";
            expected = "200";
            actual = $oGetByNumber.status;
            details = ($oGetByNumber.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Order] Get Order by Number (without token should be 401/403)"
    $oGetByNumberNoAuth = Try-InvokeJsonGet -Uri "$ordersUrl/number/$oOrderNumber" -Headers @{}
    if (-not $oGetByNumberNoAuth.success -and ($oGetByNumberNoAuth.status -eq 401 -or $oGetByNumberNoAuth.status -eq 403)) {
        Write-Host "Unauthorized order get by number blocked ($($oGetByNumberNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth order get by number result: success=$($oGetByNumberNoAuth.success) status=$($oGetByNumberNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Order Get by Number without token should be 401/403";
            expected = "401/403";
            actual = $oGetByNumberNoAuth.status;
            details = if ($oGetByNumberNoAuth.body) { ($oGetByNumberNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doOrder} -and ${doGetAll}) {
    Write-Section "[Order] Get My Orders (authorized)"
    $oGetMyOrders = Try-InvokeJsonGet -Uri "$ordersUrl/my-orders" -Headers $authHeaders
    if ($oGetMyOrders.success -and $oGetMyOrders.status -eq 200) {
        $cnt = 0; try { $cnt = ($oGetMyOrders.body | Measure-Object).Count } catch {}
        Write-Host "My orders fetched: $cnt" -ForegroundColor Green
    } else {
        Write-Host "Get my orders failed ($($oGetMyOrders.status))" -ForegroundColor Red
        $failures += @{
            test = "Order Get My Orders with token should be 200";
            expected = "200";
            actual = $oGetMyOrders.status;
            details = ($oGetMyOrders.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Order] Get My Orders (without token should be 401/403)"
    $oGetMyOrdersNoAuth = Try-InvokeJsonGet -Uri "$ordersUrl/my-orders" -Headers @{}
    if (-not $oGetMyOrdersNoAuth.success -and ($oGetMyOrdersNoAuth.status -eq 401 -or $oGetMyOrdersNoAuth.status -eq 403)) {
        Write-Host "Unauthorized get my orders blocked ($($oGetMyOrdersNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth get my orders result: success=$($oGetMyOrdersNoAuth.success) status=$($oGetMyOrdersNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Order Get My Orders without token should be 401/403";
            expected = "401/403";
            actual = $oGetMyOrdersNoAuth.status;
            details = if ($oGetMyOrdersNoAuth.body) { ($oGetMyOrdersNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doOrder} -and ${doUpdate} -and $oTargetId) {
    Write-Section "[Order] Update Order Status (authorized - Admin only)"
    $oUpdateStatusPayload = @{ status = "CONFIRMED" }
    $oUpdateStatus = Try-InvokeJsonPut -Uri "$ordersUrl/$oTargetId/status" -Headers $authHeaders -Body $oUpdateStatusPayload
    if ($oUpdateStatus.success -and $oUpdateStatus.status -eq 200) {
        Write-Host "Order status updated successfully: status=$($oUpdateStatus.body.status)" -ForegroundColor Green
    } else {
        Write-Host "Order status update failed ($($oUpdateStatus.status))" -ForegroundColor Red
        $failures += @{
            test = "Order Update Status with token should be 200";
            expected = "200";
            actual = $oUpdateStatus.status;
            details = ($oUpdateStatus.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Order] Update Order Status (without token should be 401/403)"
    $oUpdateStatusNoAuth = Try-InvokeJsonPut -Uri "$ordersUrl/$oTargetId/status" -Headers @{} -Body $oUpdateStatusPayload
    if (-not $oUpdateStatusNoAuth.success -and ($oUpdateStatusNoAuth.status -eq 401 -or $oUpdateStatusNoAuth.status -eq 403)) {
        Write-Host "Unauthorized order status update blocked ($($oUpdateStatusNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth order status update result: success=$($oUpdateStatusNoAuth.success) status=$($oUpdateStatusNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Order Update Status without token should be 401/403";
            expected = "401/403";
            actual = $oUpdateStatusNoAuth.status;
            details = if ($oUpdateStatusNoAuth.body) { ($oUpdateStatusNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }

    Write-Section "[Order] Update Shipping Fee (authorized - Admin only)"
    $oUpdateShippingFeePayload = @{ shippingFee = 50000 }
    $oUpdateShippingFee = Try-InvokeJsonPut -Uri "$ordersUrl/$oTargetId/shipping-fee" -Headers $authHeaders -Body $oUpdateShippingFeePayload
    if ($oUpdateShippingFee.success -and $oUpdateShippingFee.status -eq 200) {
        Write-Host "Order shipping fee updated successfully: fee=$($oUpdateShippingFee.body.shippingFee)" -ForegroundColor Green
    } else {
        Write-Host "Order shipping fee update failed ($($oUpdateShippingFee.status))" -ForegroundColor Red
        $failures += @{
            test = "Order Update Shipping Fee with token should be 200";
            expected = "200";
            actual = $oUpdateShippingFee.status;
            details = ($oUpdateShippingFee.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Order] Update Tax Amount (authorized - Admin only)"
    $oUpdateTaxPayload = @{ taxAmount = 10000 }
    $oUpdateTax = Try-InvokeJsonPut -Uri "$ordersUrl/$oTargetId/tax" -Headers $authHeaders -Body $oUpdateTaxPayload
    if ($oUpdateTax.success -and $oUpdateTax.status -eq 200) {
        Write-Host "Order tax amount updated successfully: tax=$($oUpdateTax.body.taxAmount)" -ForegroundColor Green
    } else {
        Write-Host "Order tax amount update failed ($($oUpdateTax.status))" -ForegroundColor Red
        $failures += @{
            test = "Order Update Tax Amount with token should be 200";
            expected = "200";
            actual = $oUpdateTax.status;
            details = ($oUpdateTax.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Order] Update Discount Amount (authorized - Admin only)"
    $oUpdateDiscountPayload = @{ discountAmount = 5000 }
    $oUpdateDiscount = Try-InvokeJsonPut -Uri "$ordersUrl/$oTargetId/discount" -Headers $authHeaders -Body $oUpdateDiscountPayload
    if ($oUpdateDiscount.success -and $oUpdateDiscount.status -eq 200) {
        Write-Host "Order discount amount updated successfully: discount=$($oUpdateDiscount.body.discountAmount)" -ForegroundColor Green
    } else {
        Write-Host "Order discount amount update failed ($($oUpdateDiscount.status))" -ForegroundColor Red
        $failures += @{
            test = "Order Update Discount Amount with token should be 200";
            expected = "200";
            actual = $oUpdateDiscount.status;
            details = ($oUpdateDiscount.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Order] Update Order Notes (authorized)"
    $oUpdateNotesPayload = @{ notes = "Test notes from script" }
    $oUpdateNotes = Try-InvokeJsonPut -Uri "$ordersUrl/$oTargetId/notes" -Headers $authHeaders -Body $oUpdateNotesPayload
    if ($oUpdateNotes.success -and $oUpdateNotes.status -eq 200) {
        Write-Host "Order notes updated successfully: notes=$($oUpdateNotes.body.notes)" -ForegroundColor Green
    } else {
        Write-Host "Order notes update failed ($($oUpdateNotes.status))" -ForegroundColor Red
        $failures += @{
            test = "Order Update Notes with token should be 200";
            expected = "200";
            actual = $oUpdateNotes.status;
            details = ($oUpdateNotes.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Order] Update Order Notes (without token should be 401/403)"
    $oUpdateNotesNoAuth = Try-InvokeJsonPut -Uri "$ordersUrl/$oTargetId/notes" -Headers @{} -Body $oUpdateNotesPayload
    if (-not $oUpdateNotesNoAuth.success -and ($oUpdateNotesNoAuth.status -eq 401 -or $oUpdateNotesNoAuth.status -eq 403)) {
        Write-Host "Unauthorized order notes update blocked ($($oUpdateNotesNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth order notes update result: success=$($oUpdateNotesNoAuth.success) status=$($oUpdateNotesNoAuth.status)" -ForegroundColor Yellow
        $failures += @{
            test = "Order Update Notes without token should be 401/403";
            expected = "401/403";
            actual = $oUpdateNotesNoAuth.status;
            details = if ($oUpdateNotesNoAuth.body) { ($oUpdateNotesNoAuth.body | ConvertTo-Json -Depth 10) } else { $null }
        }
    }
}

if (${doOrder} -and ${doGetAll}) {
    Write-Section "[Order] Get Orders with Product Changes (authorized - Admin only)"
    $oGetWithChanges = Try-InvokeJsonGet -Uri "$ordersUrl/with-product-changes" -Headers $authHeaders
    if ($oGetWithChanges.success -and $oGetWithChanges.status -eq 200) {
        $cnt = 0; try { $cnt = ($oGetWithChanges.body | Measure-Object).Count } catch {}
        Write-Host "Orders with product changes: $cnt" -ForegroundColor Green
    } else {
        Write-Host "Get orders with product changes failed ($($oGetWithChanges.status))" -ForegroundColor Red
        $failures += @{
            test = "Order Get with Product Changes with token should be 200";
            expected = "200";
            actual = $oGetWithChanges.status;
            details = ($oGetWithChanges.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Order] Get Orders Needing Attention (authorized - Admin only)"
    $oGetNeedingAttention = Try-InvokeJsonGet -Uri "$ordersUrl/needing-attention" -Headers $authHeaders
    if ($oGetNeedingAttention.success -and $oGetNeedingAttention.status -eq 200) {
        $cnt = 0; try { $cnt = ($oGetNeedingAttention.body | Measure-Object).Count } catch {}
        Write-Host "Orders needing attention: $cnt" -ForegroundColor Green
    } else {
        Write-Host "Get orders needing attention failed ($($oGetNeedingAttention.status))" -ForegroundColor Red
        $failures += @{
            test = "Order Get Needing Attention with token should be 200";
            expected = "200";
            actual = $oGetNeedingAttention.status;
            details = ($oGetNeedingAttention.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Order] Get Recent Orders (authorized - Admin only)"
    $oGetRecent = Try-InvokeJsonGet -Uri "$ordersUrl/recent" -Headers $authHeaders
    if ($oGetRecent.success -and $oGetRecent.status -eq 200) {
        $cnt = 0; try { $cnt = ($oGetRecent.body | Measure-Object).Count } catch {}
        Write-Host "Recent orders: $cnt" -ForegroundColor Green
    } else {
        Write-Host "Get recent orders failed ($($oGetRecent.status))" -ForegroundColor Red
        $failures += @{
            test = "Order Get Recent with token should be 200";
            expected = "200";
            actual = $oGetRecent.status;
            details = ($oGetRecent.body | ConvertTo-Json -Depth 10)
        }
    }

    Write-Section "[Order] Get Order Statistics (authorized - Admin only)"
    $oGetStatistics = Try-InvokeJsonGet -Uri "$ordersUrl/statistics" -Headers $authHeaders
    if ($oGetStatistics.success -and $oGetStatistics.status -eq 200) {
        Write-Host "Order statistics fetched: total=$($oGetStatistics.body.totalOrders) pending=$($oGetStatistics.body.pendingOrders)" -ForegroundColor Green
    } else {
        Write-Host "Get order statistics failed ($($oGetStatistics.status))" -ForegroundColor Red
        $failures += @{
            test = "Order Get Statistics with token should be 200";
            expected = "200";
            actual = $oGetStatistics.status;
            details = ($oGetStatistics.body | ConvertTo-Json -Depth 10)
        }
    }
}

Write-Section "Summary"
@{
    baseUrl = $BaseUrl
    mode = $Mode
    entity = $Entity
    createdUser = if ($create1 -and $create1.success) { $create1.body } else { $null }
    duplicateStatus = if ($create2) { $create2.status } else { $null }
    unauthorizedCreateStatus = if ($create3) { $create3.status } else { $null }
    getAllAuthorizedStatus = if ($getAllAuth) { $getAllAuth.status } else { $null }
    getAllUnauthorizedStatus = if ($getAllNoAuth) { $getAllNoAuth.status } else { $null }
    getOneAuthorizedStatus = if ($getOneAuth) { $getOneAuth.status } else { $null }
    getOneUnauthorizedStatus = if ($getOneNoAuth) { $getOneNoAuth.status } else { $null }
    updateAuthorizedStatus = if ($updateAuth) { $updateAuth.status } else { $null }
    updateUnauthorizedStatus = if ($updateNoAuth) { $updateNoAuth.status } else { $null }
    deleteAuthorizedStatus = if ($deleteAuth) { $deleteAuth.status } else { $null }
    deleteUnauthorizedStatus = if ($deleteNoAuth) { $deleteNoAuth.status } else { $null }
    product = @{
        createStatus = if ($pCreate) { $pCreate.status } else { $null }
        duplicateStatus = if ($pCreateDup) { $pCreateDup.status } else { $null }
        createNoAuthStatus = if ($pCreateNoAuth) { $pCreateNoAuth.status } else { $null }
        getAllStatus = if ($pGetAllAuth) { $pGetAllAuth.status } else { $null }
        getAllNoAuthStatus = if ($pGetAllNoAuth) { $pGetAllNoAuth.status } else { $null }
        getOneStatus = if ($pGetOneAuth) { $pGetOneAuth.status } else { $null }
        getOneNoAuthStatus = if ($pGetOneNoAuth) { $pGetOneNoAuth.status } else { $null }
        updateStatus = if ($pUpdateAuth) { $pUpdateAuth.status } else { $null }
        updateNoAuthStatus = if ($pUpdateNoAuth) { $pUpdateNoAuth.status } else { $null }
        deleteStatus = if ($pDeleteAuth) { $pDeleteAuth.status } else { $null }
        deleteNoAuthStatus = if ($pDeleteNoAuth) { $pDeleteNoAuth.status } else { $null }
        targetId = $pTargetId
    }
    category = @{
        createStatus = if ($cCreate) { $cCreate.status } else { $null }
        duplicateStatus = if ($cCreateDup) { $cCreateDup.status } else { $null }
        createNoAuthStatus = if ($cCreateNoAuth) { $cCreateNoAuth.status } else { $null }
        getAllStatus = if ($cGetAllAuth) { $cGetAllAuth.status } else { $null }
        getAllNoAuthStatus = if ($cGetAllNoAuth) { $cGetAllNoAuth.status } else { $null }
        getOneStatus = if ($cGetOneAuth) { $cGetOneAuth.status } else { $null }
        getOneNoAuthStatus = if ($cGetOneNoAuth) { $cGetOneNoAuth.status } else { $null }
        updateStatus = if ($cUpdateAuth) { $cUpdateAuth.status } else { $null }
        updateNoAuthStatus = if ($cUpdateNoAuth) { $cUpdateNoAuth.status } else { $null }
        deleteStatus = if ($cDeleteAuth) { $cDeleteAuth.status } else { $null }
        deleteNoAuthStatus = if ($cDeleteNoAuth) { $cDeleteNoAuth.status } else { $null }
        targetId = $cTargetId
    }
    cart = @{
        getStatus = if ($cartGet) { $cartGet.status } else { $null }
        getNoAuthStatus = if ($cartGetNoAuth) { $cartGetNoAuth.status } else { $null }
        addItemStatus = if ($cartAddItem) { $cartAddItem.status } else { $null }
        addItemNoAuthStatus = if ($cartAddItemNoAuth) { $cartAddItemNoAuth.status } else { $null }
        updateQtyStatus = if ($cartUpdateQty) { $cartUpdateQty.status } else { $null }
        updateQtyNoAuthStatus = if ($cartUpdateQtyNoAuth) { $cartUpdateQtyNoAuth.status } else { $null }
        removeItemStatus = if ($cartRemoveItem) { $cartRemoveItem.status } else { $null }
        removeItemNoAuthStatus = if ($cartRemoveItemNoAuth) { $cartRemoveItemNoAuth.status } else { $null }
        clearStatus = if ($cartClear) { $cartClear.status } else { $null }
        clearNoAuthStatus = if ($cartClearNoAuth) { $cartClearNoAuth.status } else { $null }
    }
    order = @{
        createFromCartStatus = if ($oCreateFromCart) { $oCreateFromCart.status } else { $null }
        createFromCartNoAuthStatus = if ($oCreateFromCartNoAuth) { $oCreateFromCartNoAuth.status } else { $null }
        getByIdStatus = if ($oGetById) { $oGetById.status } else { $null }
        getByIdNoAuthStatus = if ($oGetByIdNoAuth) { $oGetByIdNoAuth.status } else { $null }
        getByNumberStatus = if ($oGetByNumber) { $oGetByNumber.status } else { $null }
        getByNumberNoAuthStatus = if ($oGetByNumberNoAuth) { $oGetByNumberNoAuth.status } else { $null }
        getMyOrdersStatus = if ($oGetMyOrders) { $oGetMyOrders.status } else { $null }
        getMyOrdersNoAuthStatus = if ($oGetMyOrdersNoAuth) { $oGetMyOrdersNoAuth.status } else { $null }
        updateStatusStatus = if ($oUpdateStatus) { $oUpdateStatus.status } else { $null }
        updateStatusNoAuthStatus = if ($oUpdateStatusNoAuth) { $oUpdateStatusNoAuth.status } else { $null }
        updateShippingFeeStatus = if ($oUpdateShippingFee) { $oUpdateShippingFee.status } else { $null }
        updateTaxStatus = if ($oUpdateTax) { $oUpdateTax.status } else { $null }
        updateDiscountStatus = if ($oUpdateDiscount) { $oUpdateDiscount.status } else { $null }
        updateNotesStatus = if ($oUpdateNotes) { $oUpdateNotes.status } else { $null }
        updateNotesNoAuthStatus = if ($oUpdateNotesNoAuth) { $oUpdateNotesNoAuth.status } else { $null }
        getWithChangesStatus = if ($oGetWithChanges) { $oGetWithChanges.status } else { $null }
        getNeedingAttentionStatus = if ($oGetNeedingAttention) { $oGetNeedingAttention.status } else { $null }
        getRecentStatus = if ($oGetRecent) { $oGetRecent.status } else { $null }
        getStatisticsStatus = if ($oGetStatistics) { $oGetStatistics.status } else { $null }
        targetId = $oTargetId
        orderNumber = $oOrderNumber
    }
} | ConvertTo-Json -Depth 10 | Write-Host

# Write BugList if any failures
if ($failures.Count -gt 0) {
    $reportDir = Join-Path $PSScriptRoot "..\guide\reports"
    if (-not (Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
    $reportPath = Join-Path $reportDir "User_API_BugList.md"
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')

    $lines = @()
    $lines += "# User API BugList"
    $lines += ""
    $lines += "Date: $ts"
    $lines += "Scope: scripts/test-all-apis.ps1 ($Mode)"
    $lines += ""
    $i = 1
    foreach ($f in $failures) {
        $lines += "${i}) $($f.test)"
        $lines += "- Expected: $($f.expected)"
        $lines += "- Actual: $($f.actual)"
        if ($f.details) {
            $lines += "- Details:"
            $lines += '```'
            $lines += $f.details
            $lines += '```'
        }
        $lines += ""
        $i++
    }

    Set-Content -Path $reportPath -Value $lines -Encoding UTF8
    Write-Host "BugList written to $reportPath" -ForegroundColor Yellow
} else {
    Write-Host "No failures. BugList not created." -ForegroundColor Green
}

# Always write a test summary
$summaryDir = Join-Path $PSScriptRoot "..\guide\reports"
if (-not (Test-Path $summaryDir)) { New-Item -ItemType Directory -Path $summaryDir -Force | Out-Null }
$summaryPath = Join-Path $summaryDir "API_Test_Summary.md"
$ts2 = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')

# Compute totals
$executed = @()
foreach ($v in @($create1,$create2,$create3,$getAllAuth,$getAllNoAuth,$getOneAuth,$getOneNoAuth,$updateAuth,$updateNoAuth,$deleteAuth,$deleteNoAuth,$afterDel,
                  $pCreate,$pCreateDup,$pCreateNoAuth,$pGetAllAuth,$pGetAllNoAuth,$pGetOneAuth,$pGetOneNoAuth,$pUpdateAuth,$pUpdateNoAuth,$pDeleteAuth,$pDeleteNoAuth,$pAfterDel,
                  $cCreate,$cCreateDup,$cCreateNoAuth,$cGetAllAuth,$cGetAllNoAuth,$cGetOneAuth,$cGetOneNoAuth,$cUpdateAuth,$cUpdateNoAuth,$cDeleteAuth,$cDeleteNoAuth,$cAfterDel,
                  $cartGet,$cartGetNoAuth,$cartAddItem,$cartAddItemNoAuth,$cartUpdateQty,$cartUpdateQtyNoAuth,$cartRemoveItem,$cartRemoveItemNoAuth,$cartClear,$cartClearNoAuth,
                  $oCreateFromCart,$oCreateFromCartNoAuth,$oGetById,$oGetByIdNoAuth,$oGetByNumber,$oGetByNumberNoAuth,$oGetMyOrders,$oGetMyOrdersNoAuth,
                  $oUpdateStatus,$oUpdateStatusNoAuth,$oUpdateShippingFee,$oUpdateTax,$oUpdateDiscount,$oUpdateNotes,$oUpdateNotesNoAuth,
                  $oGetWithChanges,$oGetNeedingAttention,$oGetRecent,$oGetStatistics)) {
    if ($null -ne $v) { $executed += 1 }
}
$total = $executed.Count
$failed = $failures.Count
$passed = $total - $failed
$rate = if ($total -gt 0) { [math]::Round(($passed*100.0)/$total,2) } else { 0 }

$summary = @()
$summary += "# API Test Summary"
$summary += ""
$summary += "Date: $ts2"
$summary += "Mode: $Mode"
$summary += "Entity: $Entity"
$summary += "BaseUrl: $BaseUrl"
$summary += "Total: $total"
$summary += "Passed: $passed"
$summary += "Failed: $failed"
$summary += "Pass Rate: $rate%"
$summary += ""
$summary += "## User"
$summary += (ConvertTo-Json @{
    create = if ($create1) { $create1.status } else { $null }
    duplicate = if ($create2) { $create2.status } else { $null }
    createNoAuth = if ($create3) { $create3.status } else { $null }
    getAll = if ($getAllAuth) { $getAllAuth.status } else { $null }
    getAllNoAuth = if ($getAllNoAuth) { $getAllNoAuth.status } else { $null }
    getOne = if ($getOneAuth) { $getOneAuth.status } else { $null }
    getOneNoAuth = if ($getOneNoAuth) { $getOneNoAuth.status } else { $null }
    update = if ($updateAuth) { $updateAuth.status } else { $null }
    updateNoAuth = if ($updateNoAuth) { $updateNoAuth.status } else { $null }
    delete = if ($deleteAuth) { $deleteAuth.status } else { $null }
    deleteNoAuth = if ($deleteNoAuth) { $deleteNoAuth.status } else { $null }
} -Depth 4)
$summary += ""
$summary += "## Product"
$summary += (ConvertTo-Json @{
    create = if ($pCreate) { $pCreate.status } else { $null }
    duplicate = if ($pCreateDup) { $pCreateDup.status } else { $null }
    createNoAuth = if ($pCreateNoAuth) { $pCreateNoAuth.status } else { $null }
    getAll = if ($pGetAllAuth) { $pGetAllAuth.status } else { $null }
    getAllNoAuth = if ($pGetAllNoAuth) { $pGetAllNoAuth.status } else { $null }
    getOne = if ($pGetOneAuth) { $pGetOneAuth.status } else { $null }
    getOneNoAuth = if ($pGetOneNoAuth) { $pGetOneNoAuth.status } else { $null }
    update = if ($pUpdateAuth) { $pUpdateAuth.status } else { $null }
    updateNoAuth = if ($pUpdateNoAuth) { $pUpdateNoAuth.status } else { $null }
    delete = if ($pDeleteAuth) { $pDeleteAuth.status } else { $null }
    deleteNoAuth = if ($pDeleteNoAuth) { $pDeleteNoAuth.status } else { $null }
    targetId = $pTargetId
} -Depth 4)
$summary += ""
$summary += "## Category"
$summary += (ConvertTo-Json @{
    create = if ($cCreate) { $cCreate.status } else { $null }
    duplicate = if ($cCreateDup) { $cCreateDup.status } else { $null }
    createNoAuth = if ($cCreateNoAuth) { $cCreateNoAuth.status } else { $null }
    getAll = if ($cGetAllAuth) { $cGetAllAuth.status } else { $null }
    getAllNoAuth = if ($cGetAllNoAuth) { $cGetAllNoAuth.status } else { $null }
    getOne = if ($cGetOneAuth) { $cGetOneAuth.status } else { $null }
    getOneNoAuth = if ($cGetOneNoAuth) { $cGetOneNoAuth.status } else { $null }
    update = if ($cUpdateAuth) { $cUpdateAuth.status } else { $null }
    updateNoAuth = if ($cUpdateNoAuth) { $cUpdateNoAuth.status } else { $null }
    delete = if ($cDeleteAuth) { $cDeleteAuth.status } else { $null }
    deleteNoAuth = if ($cDeleteNoAuth) { $cDeleteNoAuth.status } else { $null }
    targetId = $cTargetId
} -Depth 4)
$summary += ""
$summary += "## Cart"
$summary += (ConvertTo-Json @{
    get = if ($cartGet) { $cartGet.status } else { $null }
    getNoAuth = if ($cartGetNoAuth) { $cartGetNoAuth.status } else { $null }
    addItem = if ($cartAddItem) { $cartAddItem.status } else { $null }
    addItemNoAuth = if ($cartAddItemNoAuth) { $cartAddItemNoAuth.status } else { $null }
    updateQty = if ($cartUpdateQty) { $cartUpdateQty.status } else { $null }
    updateQtyNoAuth = if ($cartUpdateQtyNoAuth) { $cartUpdateQtyNoAuth.status } else { $null }
    removeItem = if ($cartRemoveItem) { $cartRemoveItem.status } else { $null }
    removeItemNoAuth = if ($cartRemoveItemNoAuth) { $cartRemoveItemNoAuth.status } else { $null }
    clear = if ($cartClear) { $cartClear.status } else { $null }
    clearNoAuth = if ($cartClearNoAuth) { $cartClearNoAuth.status } else { $null }
} -Depth 4)
$summary += ""
$summary += "## Order"
$summary += (ConvertTo-Json @{
    createFromCart = if ($oCreateFromCart) { $oCreateFromCart.status } else { $null }
    createFromCartNoAuth = if ($oCreateFromCartNoAuth) { $oCreateFromCartNoAuth.status } else { $null }
    getById = if ($oGetById) { $oGetById.status } else { $null }
    getByIdNoAuth = if ($oGetByIdNoAuth) { $oGetByIdNoAuth.status } else { $null }
    getByNumber = if ($oGetByNumber) { $oGetByNumber.status } else { $null }
    getByNumberNoAuth = if ($oGetByNumberNoAuth) { $oGetByNumberNoAuth.status } else { $null }
    getMyOrders = if ($oGetMyOrders) { $oGetMyOrders.status } else { $null }
    getMyOrdersNoAuth = if ($oGetMyOrdersNoAuth) { $oGetMyOrdersNoAuth.status } else { $null }
    updateStatus = if ($oUpdateStatus) { $oUpdateStatus.status } else { $null }
    updateStatusNoAuth = if ($oUpdateStatusNoAuth) { $oUpdateStatusNoAuth.status } else { $null }
    updateShippingFee = if ($oUpdateShippingFee) { $oUpdateShippingFee.status } else { $null }
    updateTax = if ($oUpdateTax) { $oUpdateTax.status } else { $null }
    updateDiscount = if ($oUpdateDiscount) { $oUpdateDiscount.status } else { $null }
    updateNotes = if ($oUpdateNotes) { $oUpdateNotes.status } else { $null }
    updateNotesNoAuth = if ($oUpdateNotesNoAuth) { $oUpdateNotesNoAuth.status } else { $null }
    getWithChanges = if ($oGetWithChanges) { $oGetWithChanges.status } else { $null }
    getNeedingAttention = if ($oGetNeedingAttention) { $oGetNeedingAttention.status } else { $null }
    getRecent = if ($oGetRecent) { $oGetRecent.status } else { $null }
    getStatistics = if ($oGetStatistics) { $oGetStatistics.status } else { $null }
    targetId = $oTargetId
    orderNumber = $oOrderNumber
} -Depth 4)

# Expected vs Actual section
$summary += ""
$summary += "## Expected vs Actual"
$summary += ""
$summary += "### User"
$summary += "- Create: expected 200, actual: " + $(if ($create1) { $create1.status } else { $null })
$summary += "- Duplicate: expected 400, actual: " + $(if ($create2) { $create2.status } else { $null })
$summary += "- Create (no token): expected 401/403, actual: " + $(if ($create3) { $create3.status } else { $null })
$summary += "- GetAll: expected 200, actual: " + $(if ($getAllAuth) { $getAllAuth.status } else { $null })
$summary += "- GetAll (no token): expected 401/403, actual: " + $(if ($getAllNoAuth) { $getAllNoAuth.status } else { $null })
$summary += "- Get by Id: expected 200, actual: " + $(if ($getOneAuth) { $getOneAuth.status } else { $null })
$summary += "- Get by Id (no token): expected 401/403, actual: " + $(if ($getOneNoAuth) { $getOneNoAuth.status } else { $null })
$summary += "- Update: expected 200, actual: " + $(if ($updateAuth) { $updateAuth.status } else { $null })
$summary += "- Update (no token): expected 401/403, actual: " + $(if ($updateNoAuth) { $updateNoAuth.status } else { $null })
$summary += "- Delete: expected 204, actual: " + $(if ($deleteAuth) { $deleteAuth.status } else { $null })
$summary += "- Delete (no token): expected 401/403, actual: " + $(if ($deleteNoAuth) { $deleteNoAuth.status } else { $null })
$summary += ""
$summary += "### Product"
$summary += "- Create: expected 201/200, actual: " + $(if ($pCreate) { $pCreate.status } else { $null })
$summary += "- Duplicate SKU: expected 400, actual: " + $(if ($pCreateDup) { $pCreateDup.status } else { $null })
$summary += "- Create (no token): expected 401/403, actual: " + $(if ($pCreateNoAuth) { $pCreateNoAuth.status } else { $null })
$summary += "- GetAll: expected 200, actual: " + $(if ($pGetAllAuth) { $pGetAllAuth.status } else { $null })
$summary += "- GetAll (no token): expected 401/403, actual: " + $(if ($pGetAllNoAuth) { $pGetAllNoAuth.status } else { $null })
$summary += "- Get by Id: expected 200, actual: " + $(if ($pGetOneAuth) { $pGetOneAuth.status } else { $null })
$summary += "- Get by Id (no token): expected 401/403, actual: " + $(if ($pGetOneNoAuth) { $pGetOneNoAuth.status } else { $null })
$summary += "- Update: expected 200, actual: " + $(if ($pUpdateAuth) { $pUpdateAuth.status } else { $null })
$summary += "- Update (no token): expected 401/403, actual: " + $(if ($pUpdateNoAuth) { $pUpdateNoAuth.status } else { $null })
$summary += "- Delete: expected 200/204, actual: " + $(if ($pDeleteAuth) { $pDeleteAuth.status } else { $null })
$summary += "- Delete (no token): expected 401/403, actual: " + $(if ($pDeleteNoAuth) { $pDeleteNoAuth.status } else { $null })
$summary += ""
$summary += "### Category"
$summary += "- Create: expected 201/200, actual: " + $(if ($cCreate) { $cCreate.status } else { $null })
$summary += "- Duplicate Slug: expected 400, actual: " + $(if ($cCreateDup) { $cCreateDup.status } else { $null })
$summary += "- Create (no token): expected 401/403, actual: " + $(if ($cCreateNoAuth) { $cCreateNoAuth.status } else { $null })
$summary += "- GetAll Active: expected 200, actual: " + $(if ($cGetAllAuth) { $cGetAllAuth.status } else { $null })
$summary += "- GetAll Active (no token): expected 401/403, actual: " + $(if ($cGetAllNoAuth) { $cGetAllNoAuth.status } else { $null })
$summary += "- Get by Id: expected 200, actual: " + $(if ($cGetOneAuth) { $cGetOneAuth.status } else { $null })
$summary += "- Get by Id (no token): expected 401/403, actual: " + $(if ($cGetOneNoAuth) { $cGetOneNoAuth.status } else { $null })
$summary += "- Update: expected 200, actual: " + $(if ($cUpdateAuth) { $cUpdateAuth.status } else { $null })
$summary += "- Update (no token): expected 401/403, actual: " + $(if ($cUpdateNoAuth) { $cUpdateNoAuth.status } else { $null })
$summary += "- Delete: expected 200/204, actual: " + $(if ($cDeleteAuth) { $cDeleteAuth.status } else { $null })
$summary += "- Delete (no token): expected 401/403, actual: " + $(if ($cDeleteNoAuth) { $cDeleteNoAuth.status } else { $null })
$summary += ""
$summary += "### Cart"
$summary += "- Get: expected 200/404, actual: " + $(if ($cartGet) { $cartGet.status } else { $null })
$summary += "- Get (no token): expected 401/403, actual: " + $(if ($cartGetNoAuth) { $cartGetNoAuth.status } else { $null })
$summary += "- Add Item: expected 200, actual: " + $(if ($cartAddItem) { $cartAddItem.status } else { $null })
$summary += "- Add Item (no token): expected 401/403, actual: " + $(if ($cartAddItemNoAuth) { $cartAddItemNoAuth.status } else { $null })
$summary += "- Update Quantity: expected 200, actual: " + $(if ($cartUpdateQty) { $cartUpdateQty.status } else { $null })
$summary += "- Update Quantity (no token): expected 401/403, actual: " + $(if ($cartUpdateQtyNoAuth) { $cartUpdateQtyNoAuth.status } else { $null })
$summary += "- Remove Item: expected 200/204, actual: " + $(if ($cartRemoveItem) { $cartRemoveItem.status } else { $null })
$summary += "- Remove Item (no token): expected 401/403, actual: " + $(if ($cartRemoveItemNoAuth) { $cartRemoveItemNoAuth.status } else { $null })
$summary += "- Clear: expected 200/204, actual: " + $(if ($cartClear) { $cartClear.status } else { $null })
$summary += "- Clear (no token): expected 401/403, actual: " + $(if ($cartClearNoAuth) { $cartClearNoAuth.status } else { $null })
$summary += ""
$summary += "### Order"
$summary += "- Create from Cart: expected 200/201, actual: " + $(if ($oCreateFromCart) { $oCreateFromCart.status } else { $null })
$summary += "- Create from Cart (no token): expected 401/403, actual: " + $(if ($oCreateFromCartNoAuth) { $oCreateFromCartNoAuth.status } else { $null })
$summary += "- Get by ID: expected 200, actual: " + $(if ($oGetById) { $oGetById.status } else { $null })
$summary += "- Get by ID (no token): expected 401/403, actual: " + $(if ($oGetByIdNoAuth) { $oGetByIdNoAuth.status } else { $null })
$summary += "- Get by Number: expected 200, actual: " + $(if ($oGetByNumber) { $oGetByNumber.status } else { $null })
$summary += "- Get by Number (no token): expected 401/403, actual: " + $(if ($oGetByNumberNoAuth) { $oGetByNumberNoAuth.status } else { $null })
$summary += "- Get My Orders: expected 200, actual: " + $(if ($oGetMyOrders) { $oGetMyOrders.status } else { $null })
$summary += "- Get My Orders (no token): expected 401/403, actual: " + $(if ($oGetMyOrdersNoAuth) { $oGetMyOrdersNoAuth.status } else { $null })
$summary += "- Update Status: expected 200, actual: " + $(if ($oUpdateStatus) { $oUpdateStatus.status } else { $null })
$summary += "- Update Status (no token): expected 401/403, actual: " + $(if ($oUpdateStatusNoAuth) { $oUpdateStatusNoAuth.status } else { $null })
$summary += "- Update Shipping Fee: expected 200, actual: " + $(if ($oUpdateShippingFee) { $oUpdateShippingFee.status } else { $null })
$summary += "- Update Tax: expected 200, actual: " + $(if ($oUpdateTax) { $oUpdateTax.status } else { $null })
$summary += "- Update Discount: expected 200, actual: " + $(if ($oUpdateDiscount) { $oUpdateDiscount.status } else { $null })
$summary += "- Update Notes: expected 200, actual: " + $(if ($oUpdateNotes) { $oUpdateNotes.status } else { $null })
$summary += "- Update Notes (no token): expected 401/403, actual: " + $(if ($oUpdateNotesNoAuth) { $oUpdateNotesNoAuth.status } else { $null })
$summary += "- Get with Changes: expected 200, actual: " + $(if ($oGetWithChanges) { $oGetWithChanges.status } else { $null })
$summary += "- Get Needing Attention: expected 200, actual: " + $(if ($oGetNeedingAttention) { $oGetNeedingAttention.status } else { $null })
$summary += "- Get Recent: expected 200, actual: " + $(if ($oGetRecent) { $oGetRecent.status } else { $null })
$summary += "- Get Statistics: expected 200, actual: " + $(if ($oGetStatistics) { $oGetStatistics.status } else { $null })

Set-Content -Path $summaryPath -Value $summary -Encoding UTF8
Write-Host "Summary written to $summaryPath" -ForegroundColor Cyan

# Create individual entity reports
Write-Section "Creating Entity Reports"

# User Entity Report
$userTests = @($create1,$create2,$create3,$getAllAuth,$getAllNoAuth,$getOneAuth,$getOneNoAuth,$updateAuth,$updateNoAuth,$deleteAuth,$deleteNoAuth,$afterDel)
$userFailures = $failures | Where-Object { $_.test -like "*User*" -or $_.test -like "*Create*" -or $_.test -like "*GetAll*" -or $_.test -like "*Get by*" -or $_.test -like "*Update*" -or $_.test -like "*Delete*" }
$userTestResults = @{
    "Create User" = @{ Expected = "200"; Actual = if ($create1) { $create1.status } else { "Not executed" } }
    "Create Duplicate" = @{ Expected = "400"; Actual = if ($create2) { $create2.status } else { "Not executed" } }
    "Create (no token)" = @{ Expected = "401/403"; Actual = if ($create3) { $create3.status } else { "Not executed" } }
    "Get All" = @{ Expected = "200"; Actual = if ($getAllAuth) { $getAllAuth.status } else { "Not executed" } }
    "Get All (no token)" = @{ Expected = "401/403"; Actual = if ($getAllNoAuth) { $getAllNoAuth.status } else { "Not executed" } }
    "Get by ID" = @{ Expected = "200"; Actual = if ($getOneAuth) { $getOneAuth.status } else { "Not executed" } }
    "Get by ID (no token)" = @{ Expected = "401/403"; Actual = if ($getOneNoAuth) { $getOneNoAuth.status } else { "Not executed" } }
    "Update" = @{ Expected = "200"; Actual = if ($updateAuth) { $updateAuth.status } else { "Not executed" } }
    "Update (no token)" = @{ Expected = "401/403"; Actual = if ($updateNoAuth) { $updateNoAuth.status } else { "Not executed" } }
    "Delete" = @{ Expected = "204"; Actual = if ($deleteAuth) { $deleteAuth.status } else { "Not executed" } }
    "Delete (no token)" = @{ Expected = "401/403"; Actual = if ($deleteNoAuth) { $deleteNoAuth.status } else { "Not executed" } }
}
Write-EntityReport -Entity "User" -BaseUrl $BaseUrl -Mode $Mode -Timestamp $ts2 -EntityTests $userTests -EntityFailures $userFailures -TestResults $userTestResults

# Product Entity Report
$productTests = @($pCreate,$pCreateDup,$pCreateNoAuth,$pGetAllAuth,$pGetAllNoAuth,$pGetOneAuth,$pGetOneNoAuth,$pUpdateAuth,$pUpdateNoAuth,$pDeleteAuth,$pDeleteNoAuth,$pAfterDel)
$productFailures = $failures | Where-Object { $_.test -like "*Product*" }
$productTestResults = @{
    "Create Product" = @{ Expected = "200/201"; Actual = if ($pCreate) { $pCreate.status } else { "Not executed" } }
    "Create Duplicate SKU" = @{ Expected = "400"; Actual = if ($pCreateDup) { $pCreateDup.status } else { "Not executed" } }
    "Create (no token)" = @{ Expected = "401/403"; Actual = if ($pCreateNoAuth) { $pCreateNoAuth.status } else { "Not executed" } }
    "Get All" = @{ Expected = "200"; Actual = if ($pGetAllAuth) { $pGetAllAuth.status } else { "Not executed" } }
    "Get All (no token)" = @{ Expected = "401/403"; Actual = if ($pGetAllNoAuth) { $pGetAllNoAuth.status } else { "Not executed" } }
    "Get by ID" = @{ Expected = "200"; Actual = if ($pGetOneAuth) { $pGetOneAuth.status } else { "Not executed" } }
    "Get by ID (no token)" = @{ Expected = "401/403"; Actual = if ($pGetOneNoAuth) { $pGetOneNoAuth.status } else { "Not executed" } }
    "Update" = @{ Expected = "200"; Actual = if ($pUpdateAuth) { $pUpdateAuth.status } else { "Not executed" } }
    "Update (no token)" = @{ Expected = "401/403"; Actual = if ($pUpdateNoAuth) { $pUpdateNoAuth.status } else { "Not executed" } }
    "Delete" = @{ Expected = "200/204"; Actual = if ($pDeleteAuth) { $pDeleteAuth.status } else { "Not executed" } }
    "Delete (no token)" = @{ Expected = "401/403"; Actual = if ($pDeleteNoAuth) { $pDeleteNoAuth.status } else { "Not executed" } }
}
Write-EntityReport -Entity "Product" -BaseUrl $BaseUrl -Mode $Mode -Timestamp $ts2 -EntityTests $productTests -EntityFailures $productFailures -TestResults $productTestResults

# Category Entity Report
$categoryTests = @($cCreate,$cCreateDup,$cCreateNoAuth,$cGetAllAuth,$cGetAllNoAuth,$cGetOneAuth,$cGetOneNoAuth,$cUpdateAuth,$cUpdateNoAuth,$cDeleteAuth,$cDeleteNoAuth,$cAfterDel)
$categoryFailures = $failures | Where-Object { $_.test -like "*Category*" }
$categoryTestResults = @{
    "Create Category" = @{ Expected = "200/201"; Actual = if ($cCreate) { $cCreate.status } else { "Not executed" } }
    "Create Duplicate Slug" = @{ Expected = "400"; Actual = if ($cCreateDup) { $cCreateDup.status } else { "Not executed" } }
    "Create (no token)" = @{ Expected = "401/403"; Actual = if ($cCreateNoAuth) { $cCreateNoAuth.status } else { "Not executed" } }
    "Get All Active" = @{ Expected = "200"; Actual = if ($cGetAllAuth) { $cGetAllAuth.status } else { "Not executed" } }
    "Get All Active (no token)" = @{ Expected = "401/403"; Actual = if ($cGetAllNoAuth) { $cGetAllNoAuth.status } else { "Not executed" } }
    "Get by ID" = @{ Expected = "200"; Actual = if ($cGetOneAuth) { $cGetOneAuth.status } else { "Not executed" } }
    "Get by ID (no token)" = @{ Expected = "401/403"; Actual = if ($cGetOneNoAuth) { $cGetOneNoAuth.status } else { "Not executed" } }
    "Update" = @{ Expected = "200"; Actual = if ($cUpdateAuth) { $cUpdateAuth.status } else { "Not executed" } }
    "Update (no token)" = @{ Expected = "401/403"; Actual = if ($cUpdateNoAuth) { $cUpdateNoAuth.status } else { "Not executed" } }
    "Delete" = @{ Expected = "200/204"; Actual = if ($cDeleteAuth) { $cDeleteAuth.status } else { "Not executed" } }
    "Delete (no token)" = @{ Expected = "401/403"; Actual = if ($cDeleteNoAuth) { $cDeleteNoAuth.status } else { "Not executed" } }
}
Write-EntityReport -Entity "Category" -BaseUrl $BaseUrl -Mode $Mode -Timestamp $ts2 -EntityTests $categoryTests -EntityFailures $categoryFailures -TestResults $categoryTestResults

# Cart Entity Report
$cartTests = @($cartGet,$cartGetNoAuth,$cartAddItem,$cartAddItemNoAuth,$cartUpdateQty,$cartUpdateQtyNoAuth,$cartRemoveItem,$cartRemoveItemNoAuth,$cartClear,$cartClearNoAuth)
$cartFailures = $failures | Where-Object { $_.test -like "*Cart*" }
$cartTestResults = @{
    "Get Cart" = @{ Expected = "200/404"; Actual = if ($cartGet) { $cartGet.status } else { "Not executed" } }
    "Get Cart (no token)" = @{ Expected = "401/403"; Actual = if ($cartGetNoAuth) { $cartGetNoAuth.status } else { "Not executed" } }
    "Add Item" = @{ Expected = "200"; Actual = if ($cartAddItem) { $cartAddItem.status } else { "Not executed" } }
    "Add Item (no token)" = @{ Expected = "401/403"; Actual = if ($cartAddItemNoAuth) { $cartAddItemNoAuth.status } else { "Not executed" } }
    "Update Quantity" = @{ Expected = "200"; Actual = if ($cartUpdateQty) { $cartUpdateQty.status } else { "Not executed" } }
    "Update Quantity (no token)" = @{ Expected = "401/403"; Actual = if ($cartUpdateQtyNoAuth) { $cartUpdateQtyNoAuth.status } else { "Not executed" } }
    "Remove Item" = @{ Expected = "200/204"; Actual = if ($cartRemoveItem) { $cartRemoveItem.status } else { "Not executed" } }
    "Remove Item (no token)" = @{ Expected = "401/403"; Actual = if ($cartRemoveItemNoAuth) { $cartRemoveItemNoAuth.status } else { "Not executed" } }
    "Clear Cart" = @{ Expected = "200/204"; Actual = if ($cartClear) { $cartClear.status } else { "Not executed" } }
    "Clear Cart (no token)" = @{ Expected = "401/403"; Actual = if ($cartClearNoAuth) { $cartClearNoAuth.status } else { "Not executed" } }
}
Write-EntityReport -Entity "Cart" -BaseUrl $BaseUrl -Mode $Mode -Timestamp $ts2 -EntityTests $cartTests -EntityFailures $cartFailures -TestResults $cartTestResults

# Order Entity Report
$orderTests = @($oCreateFromCart,$oCreateFromCartNoAuth,$oGetById,$oGetByIdNoAuth,$oGetByNumber,$oGetByNumberNoAuth,$oGetMyOrders,$oGetMyOrdersNoAuth,$oUpdateStatus,$oUpdateStatusNoAuth,$oUpdateShippingFee,$oUpdateTax,$oUpdateDiscount,$oUpdateNotes,$oUpdateNotesNoAuth,$oGetWithChanges,$oGetNeedingAttention,$oGetRecent,$oGetStatistics)
$orderFailures = $failures | Where-Object { $_.test -like "*Order*" }
$orderTestResults = @{
    "Create from Cart" = @{ Expected = "200/201"; Actual = if ($oCreateFromCart) { $oCreateFromCart.status } else { "Not executed" } }
    "Create from Cart (no token)" = @{ Expected = "401/403"; Actual = if ($oCreateFromCartNoAuth) { $oCreateFromCartNoAuth.status } else { "Not executed" } }
    "Get by ID" = @{ Expected = "200"; Actual = if ($oGetById) { $oGetById.status } else { "Not executed" } }
    "Get by ID (no token)" = @{ Expected = "401/403"; Actual = if ($oGetByIdNoAuth) { $oGetByIdNoAuth.status } else { "Not executed" } }
    "Get by Number" = @{ Expected = "200"; Actual = if ($oGetByNumber) { $oGetByNumber.status } else { "Not executed" } }
    "Get by Number (no token)" = @{ Expected = "401/403"; Actual = if ($oGetByNumberNoAuth) { $oGetByNumberNoAuth.status } else { "Not executed" } }
    "Get My Orders" = @{ Expected = "200"; Actual = if ($oGetMyOrders) { $oGetMyOrders.status } else { "Not executed" } }
    "Get My Orders (no token)" = @{ Expected = "401/403"; Actual = if ($oGetMyOrdersNoAuth) { $oGetMyOrdersNoAuth.status } else { "Not executed" } }
    "Update Status" = @{ Expected = "200"; Actual = if ($oUpdateStatus) { $oUpdateStatus.status } else { "Not executed" } }
    "Update Status (no token)" = @{ Expected = "401/403"; Actual = if ($oUpdateStatusNoAuth) { $oUpdateStatusNoAuth.status } else { "Not executed" } }
    "Update Shipping Fee" = @{ Expected = "200"; Actual = if ($oUpdateShippingFee) { $oUpdateShippingFee.status } else { "Not executed" } }
    "Update Tax" = @{ Expected = "200"; Actual = if ($oUpdateTax) { $oUpdateTax.status } else { "Not executed" } }
    "Update Discount" = @{ Expected = "200"; Actual = if ($oUpdateDiscount) { $oUpdateDiscount.status } else { "Not executed" } }
    "Update Notes" = @{ Expected = "200"; Actual = if ($oUpdateNotes) { $oUpdateNotes.status } else { "Not executed" } }
    "Update Notes (no token)" = @{ Expected = "401/403"; Actual = if ($oUpdateNotesNoAuth) { $oUpdateNotesNoAuth.status } else { "Not executed" } }
    "Get with Changes" = @{ Expected = "200"; Actual = if ($oGetWithChanges) { $oGetWithChanges.status } else { "Not executed" } }
    "Get Needing Attention" = @{ Expected = "200"; Actual = if ($oGetNeedingAttention) { $oGetNeedingAttention.status } else { "Not executed" } }
    "Get Recent" = @{ Expected = "200"; Actual = if ($oGetRecent) { $oGetRecent.status } else { "Not executed" } }
    "Get Statistics" = @{ Expected = "200"; Actual = if ($oGetStatistics) { $oGetStatistics.status } else { "Not executed" } }
}
Write-EntityReport -Entity "Order" -BaseUrl $BaseUrl -Mode $Mode -Timestamp $ts2 -EntityTests $orderTests -EntityFailures $orderFailures -TestResults $orderTestResults


