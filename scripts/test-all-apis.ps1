# Comprehensive API Test Script
# - Tests all entities: User, Product, Category, Cart, Order
# - Logs in as admin (from rule.md)
# - Performs CRUD operations for each entity
# - Tests both authorized and unauthorized access
# - Generates detailed reports per entity

param(
    [string]$BaseUrl = "http://localhost:8080",
    [ValidateSet("Create","GetAll","Get","Update","Delete","All")][string]$Mode = "All",
    [ValidateSet("User","Product","Category","Cart","Order","Recommendation","All")][string]$Entity = "All",
    [int]$ProductCategoryId = 1
)

function Write-Section($title) {
    Write-Host "`n==== $title ====\n" -ForegroundColor Cyan
}

function Write-Success($message) {
    Write-Host "✅ $message" -ForegroundColor Green
}

function Write-Error($message) {
    Write-Host "❌ $message" -ForegroundColor Red
}

function Write-Warning($message) {
    Write-Host "⚠️ $message" -ForegroundColor Yellow
}

function Write-Info($message) {
    Write-Host "ℹ️ $message" -ForegroundColor Blue
}

function Write-TestResult($testName, $expected, $actual, $success = $true) {
    if ($success) {
        Write-Host "  ✅ $testName`: Expected $expected, Got $actual" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $testName`: Expected $expected, Got $actual" -ForegroundColor Red
    }
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
        $rawText = $null
        try { $statusCode = $_.Exception.Response.StatusCode.value__ } catch {}
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $text = $reader.ReadToEnd()
            $reader.Close()
            if ($text) {
                $rawText = $text
                try {
                    $respBody = $text | ConvertFrom-Json
                } catch {
                    # Fallback: expose raw text so reports can show actual server message
                    $respBody = @{ message = $rawText }
                }
            }
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
Write-Success "Obtained JWT (len=$($jwt.Length))"

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
${doRecommendation} = ($Entity -eq "Recommendation" -or $Entity -eq "All")

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
$pPage = $null
$pPageOut = $null
$pPageNoAuth = $null
$pPageBadSort = $null
$pPageNeg = $null
$pPage2 = $null
$pGetActive = $null
$pGetActiveNoAuth = $null
$pPageTooBig = $null
$pPageBadDir = $null
$pGetNotFound = $null
$pPageMax = $null
$pPageNegPage = $null
$pPageMissingDir = $null

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
$cPage = $null
$cPageOut = $null
$cPageNoAuth = $null
$cPageBadSort = $null
$cPageNeg = $null
$cPage2 = $null
$cGetRoots = $null
$cGetRootsNoAuth = $null
$cPageTooBig = $null
$cPageBadDir = $null
$cGetNotFound = $null
$cPageMax = $null
$cPageNegPage = $null
$cPageMissingDir = $null

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
$oPage = $null
$oPageForbidden = $null
$oPageNoAuth = $null
$oPageBadSort = $null
$oPageNeg = $null
$oPage2 = $null
$oGetByStatus = $null
$oGetByStatusNoAuth = $null
$oPageTooBig = $null
$oByStatusForbiddenUser = $null
$oWithChangesForbiddenUser = $null
$oNeedingAttentionForbiddenUser = $null
$oRecentForbiddenUser = $null
$oStatsForbiddenUser = $null
$oGetOtherForbidden = $null
$oGetNumberOtherForbidden = $null
$oPageMax = $null
$oPageNegPage = $null
$oPageMissingDir = $null
$oGetByIdNotFound = $null
$oGetByNumberNotFound = $null

# OpenAPI/Swagger results
$openApiDocs = $null
$swaggerUi = $null
$openApiSwaggerConfig = $null

# Recommendation results
$recHealth = $null
$recReadiness = $null
$recBasic = $null
$recWithLimit = $null
$recWithCategory = $null
$recWithActiveOnly = $null
$recWithSeed = $null
$recInvalidUserId = $null
$recInvalidLimit = $null
$recInvalidCategory = $null
$recNoAuth = $null
$recAnalyticsStatus = $null
$recBestseller = $null
$recTrending = $null
$recHybrid = $null
$recDashboard = $null
$recLargeLimit = $null
$recPerf1 = $null
$recPerf2 = $null
$recZeroLimit = $null

# Analytics results
$analyticsHealth = $null
$analyticsReadiness = $null
$analyticsBestsellers = $null
$analyticsTrending = $null
$analyticsCategories = $null
$analyticsDashboard = $null
$analyticsTimeRange = $null
$analyticsCategoryFilter = $null

# Search results
$searchHealth = $null
$searchReindex = $null
$searchBasic = $null
$searchPrice = $null
$searchCategory = $null
$searchSort = $null
$searchComplex = $null
$searchEmpty = $null

if (${doUser} -and ${doCreate}) {
    # Prepare new user payload
    $newEmail = New-RandomEmail
    $newUser = @{ name = "Auto Test User"; email = $newEmail; password = "pass1234"; role = "USER" }

    Write-Section "Create User (should succeed)"
    $create1 = Try-InvokeJsonPost -Uri $usersUrl -Headers $authHeaders -Body $newUser
    if ($create1.success -and $create1.status -eq 200) {
        Write-Success "Create success: id=$($create1.body.id) email=$($create1.body.email)"
    } else {
        Write-Error "Create failed ($($create1.status)): $($create1.body | ConvertTo-Json -Depth 10)"
        $failures += Add-Failure -TestName "Create User should succeed" -Expected "200 OK" -Actual $create1.status -ResponseBody $create1.body -FailuresArray $failures
    }

    Write-Section "Create Duplicate (should be 400)"
    $create2 = Try-InvokeJsonPost -Uri $usersUrl -Headers $authHeaders -Body $newUser
    if (-not $create2.success -and $create2.status -eq 400) {
        Write-Success "Duplicate email correctly rejected (400): $($create2.body | ConvertTo-Json -Depth 10)"
    } else {
        Write-Warning "Unexpected duplicate result: success=$($create2.success) status=$($create2.status) body=$($create2.body | ConvertTo-Json -Depth 10)"
        $failures += Add-Failure -TestName "Create duplicate should be 400" -Expected "400 Bad Request" -Actual $create2.status -ResponseBody $create2.body -FailuresArray $failures
    }

    Write-Section "Create Without Token (should be 401/403)"
    $create3 = Try-InvokeJsonPost -Uri $usersUrl -Headers @{} -Body $newUser
    if (-not $create3.success -and ($create3.status -eq 401 -or $create3.status -eq 403)) {
        Write-Success "Unauthorized access correctly blocked ($($create3.status))"
    } else {
        Write-Warning "Unexpected unauth result: success=$($create3.success) status=$($create3.status)"
        $failures += Add-Failure -TestName "Create without token should be 401/403" -Expected "401/403" -Actual $create3.status -ResponseBody $create3.body -FailuresArray $failures
    }
}

if (${doUser} -and ${doGetAll}) {
    Write-Section "Get All Users (authorized)"
    $getAllAuth = Try-InvokeJsonGet -Uri $usersUrl -Headers $authHeaders
    if ($getAllAuth.success -and $getAllAuth.status -eq 200) {
        $count = 0
        try { $count = ($getAllAuth.body | Measure-Object).Count } catch {}
        Write-Success "Fetched users: $count"
    } else {
        Write-Error "GetAll failed ($($getAllAuth.status)): $($getAllAuth.body | ConvertTo-Json -Depth 10)"
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

function Add-Failure {
    param(
        [string]$TestName,
        [string]$Expected,
        [int]$Actual,
        [object]$ResponseBody,
        [array]$FailuresArray
    )
    
    $errorMsg = "No error message available"
    if ($ResponseBody) {
        if ($ResponseBody.error) {
            $errorMsg = $ResponseBody.error
        } elseif ($ResponseBody.message) {
            $errorMsg = $ResponseBody.message
        } elseif ($ResponseBody.detail) {
            $errorMsg = $ResponseBody.detail
        }
    }
    
    $failure = @{
        test = $TestName
        expected = $Expected
        actual = $Actual
        details = if ($ResponseBody) { ($ResponseBody | ConvertTo-Json -Depth 10) } else { $null }
        errorMessage = $errorMsg
    }
    
    return $failure
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
            $entitySummary += "- **Error Message:** $($failure.errorMessage)"
            if ($failure.details) {
                $entitySummary += "- **Full Response:**"
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

if (${doProduct}) {
    Write-Section "[Product] Page (authorized)"
    $pPage = Try-InvokeJsonGet -Uri ($productsUrl + "/page?page=0&size=5&sort=id,desc") -Headers $authHeaders
    if ($pPage.success -and $pPage.status -eq 200) {
        # Basic assertions on pagination content
        $hasContent = $false; try { $hasContent = ($pPage.body.content | Measure-Object).Count -ge 0 } catch {}
        $hasPageable = $null -ne $pPage.body.pageable
        if ($hasPageable -and $hasContent) {
            Write-Host "Product page fetched (items=$(($pPage.body.content | Measure-Object).Count))" -ForegroundColor Green
        } else {
            Write-Host "Product page structure unexpected" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Product page failed ($($pPage.status))" -ForegroundColor Red
        $failures += Add-Failure -TestName "Product Page should be 200" -Expected "200" -Actual $pPage.status -ResponseBody $pPage.body -FailuresArray $failures
    }

    # Out-of-range page should still return 200 with empty content
    Write-Section "[Product] Page (out-of-range)"
    $pPageOut = Try-InvokeJsonGet -Uri ($productsUrl + "/page?page=9999&size=5&sort=id,desc") -Headers $authHeaders
    if ($pPageOut.success -and $pPageOut.status -eq 200) {
        $count = 0; try { $count = ($pPageOut.body.content | Measure-Object).Count } catch {}
        Write-Host "Product out-of-range page items=$count" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Product Page out-of-range should be 200" -Expected "200" -Actual $pPageOut.status -ResponseBody $pPageOut.body -FailuresArray $failures
    }
}

if (${doProduct}) {
    # Product page unauthorized
    Write-Section "[Product] Page (no token should be 401/403)"
    $pPageNoAuth = Try-InvokeJsonGet -Uri ($productsUrl + "/page?page=0&size=5&sort=id,desc") -Headers @{}
    if (-not $pPageNoAuth.success -and ($pPageNoAuth.status -eq 401 -or $pPageNoAuth.status -eq 403)) {
        Write-Host "Product page unauthorized blocked ($($pPageNoAuth.status))" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Product Page no token should be 401/403" -Expected "401/403" -Actual $pPageNoAuth.status -ResponseBody $pPageNoAuth.body -FailuresArray $failures
    }

    # Invalid sort
    Write-Section "[Product] Page (invalid sort should be 400)"
    $pPageBadSort = Try-InvokeJsonGet -Uri ($productsUrl + "/page?page=0&size=5&sort=@@,desc") -Headers $authHeaders
    if (-not $pPageBadSort.success -and $pPageBadSort.status -eq 400) {
        Write-Host "Product page invalid sort rejected (400)" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Product Page invalid sort should be 400" -Expected "400" -Actual $pPageBadSort.status -ResponseBody $pPageBadSort.body -FailuresArray $failures
    }

    # Negative size
    Write-Section "[Product] Page (negative size should be 400)"
    $pPageNeg = Try-InvokeJsonGet -Uri ($productsUrl + "/page?page=0&size=-1&sort=id,desc") -Headers $authHeaders
    if (-not $pPageNeg.success -and $pPageNeg.status -eq 400) {
        Write-Host "Product page negative size rejected (400)" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Product Page negative size should be 400" -Expected "400" -Actual $pPageNeg.status -ResponseBody $pPageNeg.body -FailuresArray $failures
    }

    # Product active list (authorized)
    Write-Section "[Product] Get Active (authorized)"
    $pGetActive = Try-InvokeJsonGet -Uri ($productsUrl + "/active") -Headers $authHeaders
    if ($pGetActive.success -and $pGetActive.status -eq 200) {
        Write-Host "Product active fetched" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Product Get Active should be 200" -Expected "200" -Actual $pGetActive.status -ResponseBody $pGetActive.body -FailuresArray $failures
    }

    # Product active list (no token)
    Write-Section "[Product] Get Active (no token should be 401/403)"
    $pGetActiveNoAuth = Try-InvokeJsonGet -Uri ($productsUrl + "/active") -Headers @{}
    if (-not $pGetActiveNoAuth.success -and ($pGetActiveNoAuth.status -eq 401 -or $pGetActiveNoAuth.status -eq 403)) {
        Write-Host "Product active unauthorized blocked ($($pGetActiveNoAuth.status))" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Product Get Active no token should be 401/403" -Expected "401/403" -Actual $pGetActiveNoAuth.status -ResponseBody $pGetActiveNoAuth.body -FailuresArray $failures
    }

    # Size too big (>100)
    Write-Section "[Product] Page (size too big should be 400)"
    $pPageTooBig = Try-InvokeJsonGet -Uri ($productsUrl + "/page?page=0&size=101&sort=id,desc") -Headers $authHeaders
    if (-not $pPageTooBig.success -and $pPageTooBig.status -eq 400) {
        Write-Host "Product page size too big rejected (400)" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Product Page size>100 should be 400" -Expected "400" -Actual $pPageTooBig.status -ResponseBody $pPageTooBig.body -FailuresArray $failures
    }

    # Invalid sort direction
    Write-Section "[Product] Page (invalid sort direction should be 400)"
    $pPageBadDir = Try-InvokeJsonGet -Uri ($productsUrl + "/page?page=0&size=5&sort=id,sideways") -Headers $authHeaders
    if (-not $pPageBadDir.success -and $pPageBadDir.status -eq 400) {
        Write-Host "Product page invalid sort direction rejected (400)" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Product Page invalid sort direction should be 400" -Expected "400" -Actual $pPageBadDir.status -ResponseBody $pPageBadDir.body -FailuresArray $failures
    }

    # Get non-existent product
    Write-Section "[Product] Get By Id (not found should be 404)"
    $pGetNotFound = Try-InvokeJsonGet -Uri ($productsUrl + "/99999999") -Headers $authHeaders
    if (-not $pGetNotFound.success -and $pGetNotFound.status -eq 404) {
        Write-Host "Product not found returns 404" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Product Get non-existent should be 404" -Expected "404" -Actual $pGetNotFound.status -ResponseBody $pGetNotFound.body -FailuresArray $failures
    }

    # Page size boundary = 100
    Write-Section "[Product] Page (size 100 boundary)"
    $pPageMax = Try-InvokeJsonGet -Uri ($productsUrl + "/page?page=0&size=100&sort=id,desc") -Headers $authHeaders
    if ($pPageMax.success -and $pPageMax.status -eq 200) { Write-Host "Product page size 100 OK" -ForegroundColor Green } else { $failures += Add-Failure -TestName "Product Page size=100 should be 200" -Expected "200" -Actual $pPageMax.status -ResponseBody $pPageMax.body -FailuresArray $failures }

    # Negative page number
    Write-Section "[Product] Page (negative page should be 400)"
    $pPageNegPage = Try-InvokeJsonGet -Uri ($productsUrl + "/page?page=-1&size=5&sort=id,desc") -Headers $authHeaders
    if (-not $pPageNegPage.success -and $pPageNegPage.status -eq 400) { Write-Host "Product negative page rejected (400)" -ForegroundColor Green } else { $failures += Add-Failure -TestName "Product Page negative page should be 400" -Expected "400" -Actual $pPageNegPage.status -ResponseBody $pPageNegPage.body -FailuresArray $failures }

    # Missing sort direction (invalid format)
    Write-Section "[Product] Page (missing sort direction should be 400)"
    $pPageMissingDir = Try-InvokeJsonGet -Uri ($productsUrl + "/page?page=0&size=5&sort=id") -Headers $authHeaders
    if (-not $pPageMissingDir.success -and $pPageMissingDir.status -eq 400) { Write-Host "Product missing sort direction rejected (400)" -ForegroundColor Green } else { $failures += Add-Failure -TestName "Product Page missing sort dir should be 400" -Expected "400" -Actual $pPageMissingDir.status -ResponseBody $pPageMissingDir.body -FailuresArray $failures }
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
    # Fetch current product to preserve required relations (e.g., category)
    $pCurrent = Try-InvokeJsonGet -Uri $pIdUrl -Headers $authHeaders
    $currentCategoryId = $null
    if ($pCurrent.success -and $pCurrent.body -and $pCurrent.body.category -and $pCurrent.body.category.id) {
        $currentCategoryId = $pCurrent.body.category.id
    }
    $pUpdatePayload = @{ 
        price = 79.99; 
        stockQuantity = 5
    }
    if ($currentCategoryId) { $pUpdatePayload.category = @{ id = $currentCategoryId } }
    Write-Section "[Product] Update (authorized)"
    $pUpdateAuth = Try-InvokeJsonPut -Uri $pIdUrl -Headers $authHeaders -Body $pUpdatePayload
    if ($pUpdateAuth.success -and $pUpdateAuth.status -eq 200) {
        Write-Host "Product update success id=$pTargetId" -ForegroundColor Green
    } else {
        Write-Host "Product update failed ($($pUpdateAuth.status))" -ForegroundColor Red
        $failures += Add-Failure -TestName "Product Update with token should be 200" -Expected "200" -Actual $pUpdateAuth.status -ResponseBody $pUpdateAuth.body -FailuresArray $failures
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

if (${doCategory}) {
    Write-Section "[Category] Page (authorized)"
    $cPage = Try-InvokeJsonGet -Uri ($categoriesUrl + "/page?page=0&size=5&sort=id,desc") -Headers $authHeaders
    if ($cPage.success -and $cPage.status -eq 200) {
        $hasContent = $false; try { $hasContent = ($cPage.body.content | Measure-Object).Count -ge 0 } catch {}
        if ($hasContent) { Write-Host "Category page fetched" -ForegroundColor Green } else { Write-Host "Category page structure unexpected" -ForegroundColor Yellow }
    } else {
        Write-Host "Category page failed ($($cPage.status))" -ForegroundColor Red
        $failures += Add-Failure -TestName "Category Page should be 200" -Expected "200" -Actual $cPage.status -ResponseBody $cPage.body -FailuresArray $failures
    }

    # Out-of-range page
    Write-Section "[Category] Page (out-of-range)"
    $cPageOut = Try-InvokeJsonGet -Uri ($categoriesUrl + "/page?page=9999&size=5&sort=id,desc") -Headers $authHeaders
    if (-not $cPageOut.success -or $cPageOut.status -ne 200) {
        $failures += Add-Failure -TestName "Category Page out-of-range should be 200" -Expected "200" -Actual $cPageOut.status -ResponseBody $cPageOut.body -FailuresArray $failures
    }
}

if (${doCategory}) {
    # Category page unauthorized
    Write-Section "[Category] Page (no token should be 401/403)"
    $cPageNoAuth = Try-InvokeJsonGet -Uri ($categoriesUrl + "/page?page=0&size=5&sort=id,desc") -Headers @{}
    if (-not $cPageNoAuth.success -and ($cPageNoAuth.status -eq 401 -or $cPageNoAuth.status -eq 403)) {
        Write-Host "Category page unauthorized blocked ($($cPageNoAuth.status))" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Category Page no token should be 401/403" -Expected "401/403" -Actual $cPageNoAuth.status -ResponseBody $cPageNoAuth.body -FailuresArray $failures
    }

    # Invalid sort
    Write-Section "[Category] Page (invalid sort should be 400)"
    $cPageBadSort = Try-InvokeJsonGet -Uri ($categoriesUrl + "/page?page=0&size=5&sort=@@,desc") -Headers $authHeaders
    if (-not $cPageBadSort.success -and $cPageBadSort.status -eq 400) {
        Write-Host "Category page invalid sort rejected (400)" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Category Page invalid sort should be 400" -Expected "400" -Actual $cPageBadSort.status -ResponseBody $cPageBadSort.body -FailuresArray $failures
    }

    # Negative size
    Write-Section "[Category] Page (negative size should be 400)"
    $cPageNeg = Try-InvokeJsonGet -Uri ($categoriesUrl + "/page?page=0&size=-1&sort=id,desc") -Headers $authHeaders
    if (-not $cPageNeg.success -and $cPageNeg.status -eq 400) {
        Write-Host "Category page negative size rejected (400)" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Category Page negative size should be 400" -Expected "400" -Actual $cPageNeg.status -ResponseBody $cPageNeg.body -FailuresArray $failures
    }

    # Category roots (authorized)
    Write-Section "[Category] Get Roots (authorized)"
    $cGetRoots = Try-InvokeJsonGet -Uri ($categoriesUrl + "/roots") -Headers $authHeaders
    if ($cGetRoots.success -and $cGetRoots.status -eq 200) {
        Write-Host "Category roots fetched" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Category Get Roots should be 200" -Expected "200" -Actual $cGetRoots.status -ResponseBody $cGetRoots.body -FailuresArray $failures
    }

    # Category roots (no token)
    Write-Section "[Category] Get Roots (no token should be 401/403)"
    $cGetRootsNoAuth = Try-InvokeJsonGet -Uri ($categoriesUrl + "/roots") -Headers @{}
    if (-not $cGetRootsNoAuth.success -and ($cGetRootsNoAuth.status -eq 401 -or $cGetRootsNoAuth.status -eq 403)) {
        Write-Host "Category roots unauthorized blocked ($($cGetRootsNoAuth.status))" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Category Get Roots no token should be 401/403" -Expected "401/403" -Actual $cGetRootsNoAuth.status -ResponseBody $cGetRootsNoAuth.body -FailuresArray $failures
    }

    # Size too big (>100)
    Write-Section "[Category] Page (size too big should be 400)"
    $cPageTooBig = Try-InvokeJsonGet -Uri ($categoriesUrl + "/page?page=0&size=101&sort=id,desc") -Headers $authHeaders
    if (-not $cPageTooBig.success -and $cPageTooBig.status -eq 400) {
        Write-Host "Category page size too big rejected (400)" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Category Page size>100 should be 400" -Expected "400" -Actual $cPageTooBig.status -ResponseBody $cPageTooBig.body -FailuresArray $failures
    }

    # Invalid sort direction
    Write-Section "[Category] Page (invalid sort direction should be 400)"
    $cPageBadDir = Try-InvokeJsonGet -Uri ($categoriesUrl + "/page?page=0&size=5&sort=id,sideways") -Headers $authHeaders
    if (-not $cPageBadDir.success -and $cPageBadDir.status -eq 400) {
        Write-Host "Category page invalid sort direction rejected (400)" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Category Page invalid sort direction should be 400" -Expected "400" -Actual $cPageBadDir.status -ResponseBody $cPageBadDir.body -FailuresArray $failures
    }

    # Get non-existent category
    Write-Section "[Category] Get By Id (not found should be 404)"
    $cGetNotFound = Try-InvokeJsonGet -Uri ($categoriesUrl + "/99999999") -Headers $authHeaders
    if (-not $cGetNotFound.success -and $cGetNotFound.status -eq 404) {
        Write-Host "Category not found returns 404" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Category Get non-existent should be 404" -Expected "404" -Actual $cGetNotFound.status -ResponseBody $cGetNotFound.body -FailuresArray $failures
    }

    # Page size boundary = 100
    Write-Section "[Category] Page (size 100 boundary)"
    $cPageMax = Try-InvokeJsonGet -Uri ($categoriesUrl + "/page?page=0&size=100&sort=id,desc") -Headers $authHeaders
    if ($cPageMax.success -and $cPageMax.status -eq 200) { Write-Host "Category page size 100 OK" -ForegroundColor Green } else { $failures += Add-Failure -TestName "Category Page size=100 should be 200" -Expected "200" -Actual $cPageMax.status -ResponseBody $cPageMax.body -FailuresArray $failures }

    # Negative page number
    Write-Section "[Category] Page (negative page should be 400)"
    $cPageNegPage = Try-InvokeJsonGet -Uri ($categoriesUrl + "/page?page=-1&size=5&sort=id,desc") -Headers $authHeaders
    if (-not $cPageNegPage.success -and $cPageNegPage.status -eq 400) { Write-Host "Category negative page rejected (400)" -ForegroundColor Green } else { $failures += Add-Failure -TestName "Category Page negative page should be 400" -Expected "400" -Actual $cPageNegPage.status -ResponseBody $cPageNegPage.body -FailuresArray $failures }

    # Missing sort direction (invalid format)
    Write-Section "[Category] Page (missing sort direction should be 400)"
    $cPageMissingDir = Try-InvokeJsonGet -Uri ($categoriesUrl + "/page?page=0&size=5&sort=id") -Headers $authHeaders
    if (-not $cPageMissingDir.success -and $cPageMissingDir.status -eq 400) { Write-Host "Category missing sort direction rejected (400)" -ForegroundColor Green } else { $failures += Add-Failure -TestName "Category Page missing sort dir should be 400" -Expected "400" -Actual $cPageMissingDir.status -ResponseBody $cPageMissingDir.body -FailuresArray $failures }
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
        $addItemUrl = $cartUrl + "/items?productId=" + $pTargetId + "&quantity=2"
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
        Write-Host "Debug: pTargetId value = '$pTargetId'" -ForegroundColor Yellow
        
        # Validate pTargetId is a valid number
        if (-not $pTargetId -or $pTargetId -notmatch '^\d+$') {
            Write-Host "Error: pTargetId is not a valid number: '$pTargetId'" -ForegroundColor Red
            $failures += Add-Failure -TestName "Cart Update Quantity - Invalid pTargetId" -Expected "Valid product ID" -Actual "Invalid ID: $pTargetId" -ResponseBody $null -FailuresArray $failures
            $cartUpdateQty = @{ success = $false; status = 400; body = @{ error = "Invalid product ID: $pTargetId" } }
        } else {
            $updateQtyUrl = $cartUrl + "/items/" + $pTargetId + "?quantity=5"
            Write-Host "Debug: updateQtyUrl = '$updateQtyUrl'" -ForegroundColor Yellow
            $cartUpdateQty = Try-InvokeJsonPut -Uri $updateQtyUrl -Headers $authHeaders -Body $null
        }
        
        if ($cartUpdateQty.success -and $cartUpdateQty.status -eq 200) {
            Write-Host "Cart quantity updated successfully" -ForegroundColor Green
        } else {
            Write-Host "Update quantity failed ($($cartUpdateQty.status)): $($cartUpdateQty.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += Add-Failure -TestName "Cart Update Quantity should be 200" -Expected "200" -Actual $cartUpdateQty.status -ResponseBody $cartUpdateQty.body -FailuresArray $failures
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
        $removeItemUrl = $cartUrl + "/items/" + $pTargetId
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
        $addItemUrl = $cartUrl + "/items?productId=" + $pTargetId + "&quantity=2"
        $cartAddForOrder = Try-InvokeJsonPost -Uri $addItemUrl -Headers $authHeaders -Body $null
        if ($cartAddForOrder.success) {
            Write-Host "Item added to cart for order creation" -ForegroundColor Green
        } else {
            Write-Host "Failed to add item to cart for order creation ($($cartAddForOrder.status))" -ForegroundColor Yellow
        }
    }

    Write-Section "[Order] Create Order from Cart (authorized)"
    
    # Debug: Check cart before creating order
    Write-Host "Debug: Checking cart before order creation..." -ForegroundColor Yellow
    $cartCheck = Try-InvokeJsonGet -Uri $cartUrl -Headers $authHeaders
    if ($cartCheck.success) {
        $cartItemsCount = 0
        try { $cartItemsCount = ($cartCheck.body.items | Measure-Object).Count } catch {}
        Write-Host "Debug: Cart has $cartItemsCount items" -ForegroundColor Yellow
        if ($cartItemsCount -eq 0) {
            Write-Host "Warning: Cart is empty! Order creation may fail." -ForegroundColor Red
        }
    } else {
        Write-Host "Debug: Failed to check cart: $($cartCheck.status)" -ForegroundColor Red
    }
    
    $oPayload = New-OrderPayload
    $oCreateFromCart = Try-InvokeJsonPost -Uri "$ordersUrl/create-from-cart" -Headers $authHeaders -Body $oPayload
    if ($oCreateFromCart.success -and ($oCreateFromCart.status -eq 200 -or $oCreateFromCart.status -eq 201)) {
        Write-Host "Order created successfully: id=$($oCreateFromCart.body.id) number=$($oCreateFromCart.body.orderNumber)" -ForegroundColor Green
        $oTargetId = $oCreateFromCart.body.id
        $oOrderNumber = $oCreateFromCart.body.orderNumber
    } else {
        Write-Host "Order creation failed ($($oCreateFromCart.status)): $($oCreateFromCart.body | ConvertTo-Json -Depth 10)" -ForegroundColor Red
        $failures += Add-Failure -TestName "Order Create from Cart should be 200/201" -Expected "200/201" -Actual $oCreateFromCart.status -ResponseBody $oCreateFromCart.body -FailuresArray $failures
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

# =====================
# OpenAPI / Swagger tests
# =====================

Write-Section "OpenAPI and Swagger UI"
$openApiDocs = Try-InvokeJsonGet -Uri ($BaseUrl + "/v3/api-docs") -Headers @{}
if ($openApiDocs.success -and $openApiDocs.status -eq 200) { Write-Host "/v3/api-docs OK" -ForegroundColor Green } else { $failures += Add-Failure -TestName "OpenAPI /v3/api-docs should be 200" -Expected "200" -Actual $openApiDocs.status -ResponseBody $openApiDocs.body -FailuresArray $failures }

try {
    $swaggerUi = @{ success = $false; status = $null; body = $null }
    $resp = Invoke-RestMethod -Method GET -Uri ($BaseUrl + "/swagger-ui/index.html") -Headers @{}
    if ($resp) { $swaggerUi = @{ success = $true; status = 200; body = $null } }
} catch {
    try { $code = $_.Exception.Response.StatusCode.value__ } catch { $code = $null }
    $swaggerUi = @{ success = $false; status = $code; body = $null }
}
if ($swaggerUi.success -and $swaggerUi.status -eq 200) { Write-Host "/swagger-ui/index.html OK" -ForegroundColor Green } else { $failures += Add-Failure -TestName "Swagger UI should be 200" -Expected "200" -Actual $swaggerUi.status -ResponseBody $swaggerUi.body -FailuresArray $failures }

# Extra OpenAPI swagger-config
$openApiSwaggerConfig = Try-InvokeJsonGet -Uri ($BaseUrl + "/v3/api-docs/swagger-config") -Headers @{}
if ($openApiSwaggerConfig.success -and $openApiSwaggerConfig.status -eq 200) { Write-Host "/v3/api-docs/swagger-config OK" -ForegroundColor Green } else { $failures += Add-Failure -TestName "OpenAPI /v3/api-docs/swagger-config should be 200" -Expected "200" -Actual $openApiSwaggerConfig.status -ResponseBody $openApiSwaggerConfig.body -FailuresArray $failures }

# =====================
# Recommendation Service tests
# =====================

if (${doRecommendation}) {
    $recommendationBaseUrl = "http://localhost:8091"
    
    Write-Section "[Recommendation] Health Check"
    $recHealth = Try-InvokeJsonGet -Uri "$recommendationBaseUrl/health" -Headers @{}
    if ($recHealth.success -and $recHealth.status -eq 200) {
        Write-Success "Recommendation health check OK"
    } else {
        Write-Error "Recommendation health check failed ($($recHealth.status))"
        $failures += Add-Failure -TestName "Recommendation Health should be 200" -Expected "200" -Actual $recHealth.status -ResponseBody $recHealth.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Readiness Check"
    $recReadiness = Try-InvokeJsonGet -Uri "$recommendationBaseUrl/readiness" -Headers @{}
    if ($recReadiness.success -and $recReadiness.status -eq 200) {
        Write-Success "Recommendation readiness check OK"
    } else {
        Write-Error "Recommendation readiness check failed ($($recReadiness.status))"
        $failures += Add-Failure -TestName "Recommendation Readiness should be 200" -Expected "200" -Actual $recReadiness.status -ResponseBody $recReadiness.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Basic Recommendations (authorized)"
    $recBasicPayload = @{ userId = 1; limit = 5 }
    $recBasic = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recBasicPayload
    if ($recBasic.success -and $recBasic.status -eq 200) {
        $itemCount = 0
        try { $itemCount = ($recBasic.body.items | Measure-Object).Count } catch {}
        Write-Success "Basic recommendations fetched: $itemCount items"
    } else {
        Write-Error "Basic recommendations failed ($($recBasic.status))"
        $failures += Add-Failure -TestName "Recommendation Basic should be 200" -Expected "200" -Actual $recBasic.status -ResponseBody $recBasic.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Recommendations with Custom Limit"
    $recWithLimitPayload = @{ userId = 1; limit = 10 }
    $recWithLimit = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recWithLimitPayload
    if ($recWithLimit.success -and $recWithLimit.status -eq 200) {
        $itemCount = 0
        try { $itemCount = ($recWithLimit.body.items | Measure-Object).Count } catch {}
        Write-Host "Recommendations with limit fetched: $itemCount items" -ForegroundColor Green
    } else {
        Write-Host "Recommendations with limit failed ($($recWithLimit.status))" -ForegroundColor Red
        $failures += Add-Failure -TestName "Recommendation With Limit should be 200" -Expected "200" -Actual $recWithLimit.status -ResponseBody $recWithLimit.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Recommendations with Category Filter"
    $recWithCategoryPayload = @{ userId = 1; limit = 5; categoryId = $ProductCategoryId }
    $recWithCategory = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recWithCategoryPayload
    if ($recWithCategory.success -and $recWithCategory.status -eq 200) {
        $itemCount = 0
        try { $itemCount = ($recWithCategory.body.items | Measure-Object).Count } catch {}
        Write-Host "Recommendations with category filter fetched: $itemCount items" -ForegroundColor Green
    } else {
        Write-Host "Recommendations with category filter failed ($($recWithCategory.status))" -ForegroundColor Red
        $failures += Add-Failure -TestName "Recommendation With Category should be 200" -Expected "200" -Actual $recWithCategory.status -ResponseBody $recWithCategory.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Recommendations with Active Only Filter"
    $recWithActiveOnlyPayload = @{ userId = 1; limit = 5; activeOnly = $true }
    $recWithActiveOnly = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recWithActiveOnlyPayload
    if ($recWithActiveOnly.success -and $recWithActiveOnly.status -eq 200) {
        $itemCount = 0
        try { $itemCount = ($recWithActiveOnly.body.items | Measure-Object).Count } catch {}
        Write-Host "Recommendations with active only filter fetched: $itemCount items" -ForegroundColor Green
    } else {
        Write-Host "Recommendations with active only filter failed ($($recWithActiveOnly.status))" -ForegroundColor Red
        $failures += Add-Failure -TestName "Recommendation With Active Only should be 200" -Expected "200" -Actual $recWithActiveOnly.status -ResponseBody $recWithActiveOnly.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Recommendations with Seed (Deterministic)"
    $recWithSeedPayload = @{ userId = 1; limit = 5; seed = 12345 }
    $recWithSeed = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recWithSeedPayload
    if ($recWithSeed.success -and $recWithSeed.status -eq 200) {
        $itemCount = 0
        try { $itemCount = ($recWithSeed.body.items | Measure-Object).Count } catch {}
        Write-Host "Recommendations with seed fetched: $itemCount items" -ForegroundColor Green
    } else {
        Write-Host "Recommendations with seed failed ($($recWithSeed.status))" -ForegroundColor Red
        $failures += Add-Failure -TestName "Recommendation With Seed should be 200" -Expected "200" -Actual $recWithSeed.status -ResponseBody $recWithSeed.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Invalid User ID (should be 422)"
    $recInvalidUserIdPayload = @{ userId = -1; limit = 5 }
    $recInvalidUserId = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recInvalidUserIdPayload
    if (-not $recInvalidUserId.success -and $recInvalidUserId.status -eq 422) {
        Write-Host "Invalid user ID correctly rejected (422)" -ForegroundColor Green
    } else {
        Write-Host "Unexpected invalid user ID result: success=$($recInvalidUserId.success) status=$($recInvalidUserId.status)" -ForegroundColor Yellow
        $failures += Add-Failure -TestName "Recommendation Invalid User ID should be 422" -Expected "422" -Actual $recInvalidUserId.status -ResponseBody $recInvalidUserId.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Invalid Limit (should be 422)"
    $recInvalidLimitPayload = @{ userId = 1; limit = 0 }
    $recInvalidLimit = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recInvalidLimitPayload
    if (-not $recInvalidLimit.success -and $recInvalidLimit.status -eq 422) {
        Write-Host "Invalid limit correctly rejected (422)" -ForegroundColor Green
    } else {
        Write-Host "Unexpected invalid limit result: success=$($recInvalidLimit.success) status=$($recInvalidLimit.status)" -ForegroundColor Yellow
        $failures += Add-Failure -TestName "Recommendation Invalid Limit should be 422" -Expected "422" -Actual $recInvalidLimit.status -ResponseBody $recInvalidLimit.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Invalid Category ID (should be 422)"
    $recInvalidCategoryPayload = @{ userId = 1; limit = 5; categoryId = -1 }
    $recInvalidCategory = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recInvalidCategoryPayload
    if (-not $recInvalidCategory.success -and $recInvalidCategory.status -eq 422) {
        Write-Host "Invalid category ID correctly rejected (422)" -ForegroundColor Green
    } else {
        Write-Host "Unexpected invalid category ID result: success=$($recInvalidCategory.success) status=$($recInvalidCategory.status)" -ForegroundColor Yellow
        $failures += Add-Failure -TestName "Recommendation Invalid Category ID should be 422" -Expected "422" -Actual $recInvalidCategory.status -ResponseBody $recInvalidCategory.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Recommendations without Token (should be 401/403)"
    $recNoAuthPayload = @{ userId = 1; limit = 5 }
    $recNoAuth = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers @{} -Body $recNoAuthPayload
    if (-not $recNoAuth.success -and ($recNoAuth.status -eq 401 -or $recNoAuth.status -eq 403)) {
        Write-Host "Unauthorized recommendation access blocked ($($recNoAuth.status))" -ForegroundColor Green
    } else {
        Write-Host "Unexpected unauth recommendation result: success=$($recNoAuth.success) status=$($recNoAuth.status)" -ForegroundColor Yellow
        $failures += Add-Failure -TestName "Recommendation No Token should be 401/403" -Expected "401/403" -Actual $recNoAuth.status -ResponseBody $recNoAuth.body -FailuresArray $failures
    }

    # Analytics Integration Tests
    Write-Section "[Recommendation] Analytics Status Check"
    $recAnalyticsStatus = Try-InvokeJsonGet -Uri "$recommendationBaseUrl/analytics/status" -Headers $authHeaders
    if ($recAnalyticsStatus.success -and $recAnalyticsStatus.status -eq 200) {
        Write-Host "Analytics status check OK" -ForegroundColor Green
    } else {
        Write-Host "Analytics status check failed ($($recAnalyticsStatus.status))" -ForegroundColor Red
        $failures += Add-Failure -TestName "Recommendation Analytics Status should be 200" -Expected "200" -Actual $recAnalyticsStatus.status -ResponseBody $recAnalyticsStatus.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Bestseller Recommendations"
    $recBestsellerPayload = @{ userId = 1; limit = 5; useAnalytics = $true; recommendationType = "bestsellers" }
    $recBestseller = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recBestsellerPayload
    if ($recBestseller.success -and $recBestseller.status -eq 200) {
        $itemCount = 0
        try { $itemCount = ($recBestseller.body.items | Measure-Object).Count } catch {}
        Write-Host "Bestseller recommendations fetched: $itemCount items" -ForegroundColor Green
    } else {
        Write-Host "Bestseller recommendations failed ($($recBestseller.status))" -ForegroundColor Red
        $failures += Add-Failure -TestName "Recommendation Bestsellers should be 200" -Expected "200" -Actual $recBestseller.status -ResponseBody $recBestseller.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Trending Recommendations"
    $recTrendingPayload = @{ userId = 1; limit = 5; useAnalytics = $true; recommendationType = "trending" }
    $recTrending = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recTrendingPayload
    if ($recTrending.success -and $recTrending.status -eq 200) {
        $itemCount = 0
        try { $itemCount = ($recTrending.body.items | Measure-Object).Count } catch {}
        Write-Host "Trending recommendations fetched: $itemCount items" -ForegroundColor Green
    } else {
        Write-Host "Trending recommendations failed ($($recTrending.status))" -ForegroundColor Red
        $failures += Add-Failure -TestName "Recommendation Trending should be 200" -Expected "200" -Actual $recTrending.status -ResponseBody $recTrending.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Hybrid Recommendations"
    $recHybridPayload = @{ userId = 1; limit = 8; useAnalytics = $true; recommendationType = "hybrid" }
    $recHybrid = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recHybridPayload
    if ($recHybrid.success -and $recHybrid.status -eq 200) {
        $itemCount = 0
        try { $itemCount = ($recHybrid.body.items | Measure-Object).Count } catch {}
        Write-Success "Hybrid recommendations fetched: $itemCount items"
    } else {
        Write-Error "Hybrid recommendations failed ($($recHybrid.status))"
        $failures += Add-Failure -TestName "Recommendation Hybrid should be 200" -Expected "200" -Actual $recHybrid.status -ResponseBody $recHybrid.body -FailuresArray $failures
    }

    # Additional Recommendation Test Cases
    Write-Section "[Recommendation] Analytics Dashboard Summary"
    $recDashboardPayload = @{ userId = 1; limit = 5; useAnalytics = $true; recommendationType = "hybrid" }
    $recDashboard = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recDashboardPayload
    if ($recDashboard.success -and $recDashboard.status -eq 200) {
        Write-Success "Dashboard recommendations fetched successfully"
    } else {
        Write-Error "Dashboard recommendations failed ($($recDashboard.status))"
        $failures += Add-Failure -TestName "Recommendation Dashboard should be 200" -Expected "200" -Actual $recDashboard.status -ResponseBody $recDashboard.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Large Limit Test"
    $recLargeLimitPayload = @{ userId = 1; limit = 50; useAnalytics = $true; recommendationType = "hybrid" }
    $recLargeLimit = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recLargeLimitPayload
    if ($recLargeLimit.success -and $recLargeLimit.status -eq 200) {
        $itemCount = 0
        try { $itemCount = ($recLargeLimit.body.items | Measure-Object).Count } catch {}
        Write-Success "Large limit recommendations fetched: $itemCount items"
    } else {
        Write-Error "Large limit recommendations failed ($($recLargeLimit.status))"
        $failures += Add-Failure -TestName "Recommendation Large Limit should be 200" -Expected "200" -Actual $recLargeLimit.status -ResponseBody $recLargeLimit.body -FailuresArray $failures
    }

    # Additional Recommendation Test Cases
    Write-Section "[Recommendation] Performance Test (Multiple Requests)"
    $recPerfPayload = @{ userId = 1; limit = 3; useAnalytics = $true; recommendationType = "hybrid" }
    $recPerf1 = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recPerfPayload
    $recPerf2 = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recPerfPayload
    if ($recPerf1.success -and $recPerf1.status -eq 200 -and $recPerf2.success -and $recPerf2.status -eq 200) {
        Write-Success "Performance test passed - multiple requests handled correctly"
    } else {
        Write-Error "Performance test failed - requests: $($recPerf1.status), $($recPerf2.status)"
        $failures += Add-Failure -TestName "Recommendation Performance should be 200" -Expected "200" -Actual "$($recPerf1.status), $($recPerf2.status)" -ResponseBody $recPerf1.body -FailuresArray $failures
    }

    Write-Section "[Recommendation] Edge Case - Zero Limit"
    $recZeroLimitPayload = @{ userId = 1; limit = 0; useAnalytics = $false; recommendationType = "basic" }
    $recZeroLimit = Try-InvokeJsonPost -Uri "$recommendationBaseUrl/recommendations" -Headers $authHeaders -Body $recZeroLimitPayload
    if (-not $recZeroLimit.success -and $recZeroLimit.status -eq 422) {
        Write-Success "Zero limit correctly rejected (422)"
    } else {
        Write-Warning "Unexpected zero limit result: success=$($recZeroLimit.success) status=$($recZeroLimit.status)"
        $failures += Add-Failure -TestName "Recommendation Zero Limit should be 422" -Expected "422" -Actual $recZeroLimit.status -ResponseBody $recZeroLimit.body -FailuresArray $failures
    }
}

# Analytics Service Tests
if (${doRecommendation}) {
    $analyticsBaseUrl = "http://localhost:8093"
    
    Write-Section "[Analytics] Health Check"
    $analyticsHealth = Try-InvokeJsonGet -Uri "$analyticsBaseUrl/health" -Headers @{}
    if ($analyticsHealth.success -and $analyticsHealth.status -eq 200) {
        Write-Success "Analytics health check OK"
    } else {
        Write-Error "Analytics health check failed ($($analyticsHealth.status))"
        $failures += Add-Failure -TestName "Analytics Health should be 200" -Expected "200" -Actual $analyticsHealth.status -ResponseBody $analyticsHealth.body -FailuresArray $failures
    }

    Write-Section "[Analytics] Readiness Check"
    $analyticsReadiness = Try-InvokeJsonGet -Uri "$analyticsBaseUrl/readiness" -Headers @{}
    if ($analyticsReadiness.success -and $analyticsReadiness.status -eq 200) {
        Write-Success "Analytics readiness check OK"
    } else {
        Write-Error "Analytics readiness check failed ($($analyticsReadiness.status))"
        $failures += Add-Failure -TestName "Analytics Readiness should be 200" -Expected "200" -Actual $analyticsReadiness.status -ResponseBody $analyticsReadiness.body -FailuresArray $failures
    }

    Write-Section "[Analytics] Bestsellers"
    $analyticsBestsellers = Try-InvokeJsonGet -Uri "$analyticsBaseUrl/analytics/products/bestsellers?limit=5" -Headers $authHeaders
    if ($analyticsBestsellers.success -and $analyticsBestsellers.status -eq 200) {
        $bestsellerCount = 0
        try { $bestsellerCount = ($analyticsBestsellers.body.bestsellers | Measure-Object).Count } catch {}
        Write-Success "Bestsellers fetched: $bestsellerCount items"
    } else {
        Write-Error "Bestsellers failed ($($analyticsBestsellers.status))"
        $failures += Add-Failure -TestName "Analytics Bestsellers should be 200" -Expected "200" -Actual $analyticsBestsellers.status -ResponseBody $analyticsBestsellers.body -FailuresArray $failures
    }

    Write-Section "[Analytics] Trending Products"
    $analyticsTrending = Try-InvokeJsonGet -Uri "$analyticsBaseUrl/analytics/products/trending?limit=5" -Headers $authHeaders
    if ($analyticsTrending.success -and $analyticsTrending.status -eq 200) {
        $trendingCount = 0
        try { $trendingCount = ($analyticsTrending.body.trending | Measure-Object).Count } catch {}
        Write-Success "Trending products fetched: $trendingCount items"
    } else {
        Write-Error "Trending products failed ($($analyticsTrending.status))"
        $failures += Add-Failure -TestName "Analytics Trending should be 200" -Expected "200" -Actual $analyticsTrending.status -ResponseBody $analyticsTrending.body -FailuresArray $failures
    }

    Write-Section "[Analytics] Popular Categories"
    $analyticsCategories = Try-InvokeJsonGet -Uri "$analyticsBaseUrl/analytics/categories/popular?limit=5" -Headers $authHeaders
    if ($analyticsCategories.success -and $analyticsCategories.status -eq 200) {
        $categoryCount = 0
        try { $categoryCount = ($analyticsCategories.body.popular | Measure-Object).Count } catch {}
        Write-Success "Popular categories fetched: $categoryCount items"
    } else {
        Write-Error "Popular categories failed ($($analyticsCategories.status))"
        $failures += Add-Failure -TestName "Analytics Categories should be 200" -Expected "200" -Actual $analyticsCategories.status -ResponseBody $analyticsCategories.body -FailuresArray $failures
    }

    Write-Section "[Analytics] Dashboard Summary"
    $analyticsDashboard = Try-InvokeJsonGet -Uri "$analyticsBaseUrl/analytics/dashboard/summary" -Headers $authHeaders
    if ($analyticsDashboard.success -and $analyticsDashboard.status -eq 200) {
        Write-Success "Dashboard summary fetched successfully"
    } else {
        Write-Error "Dashboard summary failed ($($analyticsDashboard.status))"
        $failures += Add-Failure -TestName "Analytics Dashboard should be 200" -Expected "200" -Actual $analyticsDashboard.status -ResponseBody $analyticsDashboard.body -FailuresArray $failures
    }

    # Additional Analytics Test Cases
    Write-Section "[Analytics] Time Range Test"
    $analyticsTimeRange = Try-InvokeJsonGet -Uri "$analyticsBaseUrl/analytics/products/bestsellers?timeRange=weekly&limit=3" -Headers $authHeaders
    if ($analyticsTimeRange.success -and $analyticsTimeRange.status -eq 200) {
        $timeRangeCount = 0
        try { $timeRangeCount = ($analyticsTimeRange.body.bestsellers | Measure-Object).Count } catch {}
        Write-Success "Time range test passed - weekly bestsellers: $timeRangeCount items"
    } else {
        Write-Error "Time range test failed ($($analyticsTimeRange.status))"
        $failures += Add-Failure -TestName "Analytics Time Range should be 200" -Expected "200" -Actual $analyticsTimeRange.status -ResponseBody $analyticsTimeRange.body -FailuresArray $failures
    }

    Write-Section "[Analytics] Category Filter Test"
    $analyticsCategoryFilter = Try-InvokeJsonGet -Uri "$analyticsBaseUrl/analytics/products/trending?categoryId=1&limit=3" -Headers $authHeaders
    if ($analyticsCategoryFilter.success -and $analyticsCategoryFilter.status -eq 200) {
        $categoryFilterCount = 0
        try { $categoryFilterCount = ($analyticsCategoryFilter.body.trending | Measure-Object).Count } catch {}
        Write-Success "Category filter test passed - trending in category 1: $categoryFilterCount items"
    } else {
        Write-Error "Category filter test failed ($($analyticsCategoryFilter.status))"
        $failures += Add-Failure -TestName "Analytics Category Filter should be 200" -Expected "200" -Actual $analyticsCategoryFilter.status -ResponseBody $analyticsCategoryFilter.body -FailuresArray $failures
    }
}

# Search Service Tests
if (${doRecommendation}) {
    $searchBaseUrl = "http://localhost:8092"
    
    Write-Section "[Search] Health Check"
    $searchHealth = Try-InvokeJsonGet -Uri "$searchBaseUrl/health" -Headers @{}
    if ($searchHealth.success -and $searchHealth.status -eq 200) {
        Write-Success "Search health check OK"
    } else {
        Write-Error "Search health check failed ($($searchHealth.status))"
        $failures += Add-Failure -TestName "Search Health should be 200" -Expected "200" -Actual $searchHealth.status -ResponseBody $searchHealth.body -FailuresArray $failures
    }

    Write-Section "[Search] Reindex Products"
    $searchReindex = Try-InvokeJsonPost -Uri "$searchBaseUrl/reindex" -Headers $authHeaders -Body @{}
    if ($searchReindex.success -and $searchReindex.status -eq 200) {
        $indexedCount = 0
        try { $indexedCount = $searchReindex.body.indexed } catch {}
        Write-Success "Products reindexed: $indexedCount items"
    } else {
        Write-Error "Reindex failed ($($searchReindex.status))"
        $failures += Add-Failure -TestName "Search Reindex should be 200" -Expected "200" -Actual $searchReindex.status -ResponseBody $searchReindex.body -FailuresArray $failures
    }

    Write-Section "[Search] Basic Search"
    $searchBasic = Try-InvokeJsonGet -Uri "$searchBaseUrl/search?q=product&limit=5" -Headers @{}
    if ($searchBasic.success -and $searchBasic.status -eq 200) {
        $searchCount = 0
        try { $searchCount = ($searchBasic.body.items | Measure-Object).Count } catch {}
        Write-Success "Basic search returned: $searchCount items"
    } else {
        Write-Error "Basic search failed ($($searchBasic.status))"
        $failures += Add-Failure -TestName "Search Basic should be 200" -Expected "200" -Actual $searchBasic.status -ResponseBody $searchBasic.body -FailuresArray $failures
    }

    Write-Section "[Search] Price Range Search"
    $searchPrice = Try-InvokeJsonGet -Uri "$searchBaseUrl/search?min_price=10&max_price=100&limit=5" -Headers @{}
    if ($searchPrice.success -and $searchPrice.status -eq 200) {
        $priceCount = 0
        try { $priceCount = ($searchPrice.body.items | Measure-Object).Count } catch {}
        Write-Success "Price range search returned: $priceCount items"
    } else {
        Write-Error "Price range search failed ($($searchPrice.status))"
        $failures += Add-Failure -TestName "Search Price Range should be 200" -Expected "200" -Actual $searchPrice.status -ResponseBody $searchPrice.body -FailuresArray $failures
    }

    Write-Section "[Search] Category Filter Search"
    $searchCategory = Try-InvokeJsonGet -Uri "$searchBaseUrl/search?category_id=1&limit=5" -Headers @{}
    if ($searchCategory.success -and $searchCategory.status -eq 200) {
        $categoryCount = 0
        try { $categoryCount = ($searchCategory.body.items | Measure-Object).Count } catch {}
        Write-Success "Category filter search returned: $categoryCount items"
    } else {
        Write-Error "Category filter search failed ($($searchCategory.status))"
        $failures += Add-Failure -TestName "Search Category Filter should be 200" -Expected "200" -Actual $searchCategory.status -ResponseBody $searchCategory.body -FailuresArray $failures
    }

    Write-Section "[Search] Sort by Price"
    $searchSort = Try-InvokeJsonGet -Uri "$searchBaseUrl/search?sort_by=price_asc&limit=5" -Headers @{}
    if ($searchSort.success -and $searchSort.status -eq 200) {
        $sortCount = 0
        try { $sortCount = ($searchSort.body.items | Measure-Object).Count } catch {}
        Write-Success "Sort by price returned: $sortCount items"
    } else {
        Write-Error "Sort by price failed ($($searchSort.status))"
        $failures += Add-Failure -TestName "Search Sort by Price should be 200" -Expected "200" -Actual $searchSort.status -ResponseBody $searchSort.body -FailuresArray $failures
    }

    # Additional Search Test Cases
    Write-Section "[Search] Complex Search Query"
    $searchComplex = Try-InvokeJsonGet -Uri "$searchBaseUrl/search?q=laptop computer&min_price=100&max_price=2000&sort_by=price_desc&limit=3" -Headers @{}
    if ($searchComplex.success -and $searchComplex.status -eq 200) {
        $complexCount = 0
        try { $complexCount = ($searchComplex.body.items | Measure-Object).Count } catch {}
        Write-Success "Complex search query returned: $complexCount items"
    } else {
        Write-Error "Complex search query failed ($($searchComplex.status))"
        $failures += Add-Failure -TestName "Search Complex Query should be 200" -Expected "200" -Actual $searchComplex.status -ResponseBody $searchComplex.body -FailuresArray $failures
    }

    Write-Section "[Search] Empty Search Test"
    $searchEmpty = Try-InvokeJsonGet -Uri "$searchBaseUrl/search?q=&limit=5" -Headers @{}
    if ($searchEmpty.success -and $searchEmpty.status -eq 200) {
        $emptyCount = 0
        try { $emptyCount = ($searchEmpty.body.items | Measure-Object).Count } catch {}
        Write-Success "Empty search query returned: $emptyCount items"
    } else {
        Write-Error "Empty search query failed ($($searchEmpty.status))"
        $failures += Add-Failure -TestName "Search Empty Query should be 200" -Expected "200" -Actual $searchEmpty.status -ResponseBody $searchEmpty.body -FailuresArray $failures
    }
}

if (${doOrder}) {
    Write-Section "[Order] Page (authorized - Admin only)"
    if ($oTargetId -eq $null) {
        # ensure at least one order exists by triggering the create flow quickly if needed is complex; just call page
    }
    $oPage = Try-InvokeJsonGet -Uri ($ordersUrl + "/page?page=0&size=5&sort=orderDate,desc") -Headers $authHeaders
    if ($oPage.success -and $oPage.status -eq 200) {
        Write-Host "Order page fetched" -ForegroundColor Green
    } else {
        Write-Host "Order page failed ($($oPage.status))" -ForegroundColor Red
        $failures += Add-Failure -TestName "Order Page should be 200" -Expected "200" -Actual $oPage.status -ResponseBody $oPage.body -FailuresArray $failures
    }

    # Forbidden for non-admin
    Write-Section "[Order] Page (forbidden for non-admin)"
    # Create a normal user token
    $userEmail = New-RandomEmail
    $newUserPayload = @{ name = "Pagination Test User"; email = $userEmail; password = "pass1234"; role = "USER" }
    $createUserResp = Try-InvokeJsonPost -Uri $usersUrl -Headers $authHeaders -Body $newUserPayload
    if ($createUserResp.success) {
        $userLogin = Try-InvokeJsonPost -Uri $loginUrl -Headers @{} -Body @{ email = $userEmail; password = "pass1234" }
        if ($userLogin.success) {
            $userHeaders = @{ Authorization = "Bearer $($userLogin.body.accessToken)" }
            $oPageForbidden = Try-InvokeJsonGet -Uri ($ordersUrl + "/page?page=0&size=5") -Headers $userHeaders
            if (-not $oPageForbidden.success -and ($oPageForbidden.status -eq 401 -or $oPageForbidden.status -eq 403)) {
                Write-Host "Order page forbidden for normal user ($($oPageForbidden.status))" -ForegroundColor Green
            } else {
                $failures += Add-Failure -TestName "Order Page should be forbidden for user" -Expected "401/403" -Actual $oPageForbidden.status -ResponseBody $oPageForbidden.body -FailuresArray $failures
            }
        }
    }

    # Unauthorized page
    Write-Section "[Order] Page (no token should be 401/403)"
    $oPageNoAuth = Try-InvokeJsonGet -Uri ($ordersUrl + "/page?page=0&size=5&sort=orderDate,desc") -Headers @{}
    if (-not $oPageNoAuth.success -and ($oPageNoAuth.status -eq 401 -or $oPageNoAuth.status -eq 403)) {
        Write-Host "Order page unauthorized blocked ($($oPageNoAuth.status))" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Order Page no token should be 401/403" -Expected "401/403" -Actual $oPageNoAuth.status -ResponseBody $oPageNoAuth.body -FailuresArray $failures
    }

    # Invalid sort
    Write-Section "[Order] Page (invalid sort should be 400)"
    $oPageBadSort = Try-InvokeJsonGet -Uri ($ordersUrl + "/page?page=0&size=5&sort=@@,desc") -Headers $authHeaders
    if (-not $oPageBadSort.success -and $oPageBadSort.status -eq 400) {
        Write-Host "Order page invalid sort rejected (400)" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Order Page invalid sort should be 400" -Expected "400" -Actual $oPageBadSort.status -ResponseBody $oPageBadSort.body -FailuresArray $failures
    }

    # Negative size
    Write-Section "[Order] Page (negative size should be 400)"
    $oPageNeg = Try-InvokeJsonGet -Uri ($ordersUrl + "/page?page=0&size=-1&sort=orderDate,desc") -Headers $authHeaders
    if (-not $oPageNeg.success -and $oPageNeg.status -eq 400) {
        Write-Host "Order page negative size rejected (400)" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Order Page negative size should be 400" -Expected "400" -Actual $oPageNeg.status -ResponseBody $oPageNeg.body -FailuresArray $failures
    }

    # Size too big (>100)
    Write-Section "[Order] Page (size too big should be 400)"
    $oPageTooBig = Try-InvokeJsonGet -Uri ($ordersUrl + "/page?page=0&size=101&sort=orderDate,desc") -Headers $authHeaders
    if (-not $oPageTooBig.success -and $oPageTooBig.status -eq 400) {
        Write-Host "Order page size too big rejected (400)" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Order Page size>100 should be 400" -Expected "400" -Actual $oPageTooBig.status -ResponseBody $oPageTooBig.body -FailuresArray $failures
    }

    # Get orders by status (authorized - Admin only)
    Write-Section "[Order] Get By Status (authorized - Admin only)"
    $oGetByStatus = Try-InvokeJsonGet -Uri ($ordersUrl + "/status/PENDING") -Headers $authHeaders
    if ($oGetByStatus.success -and $oGetByStatus.status -eq 200) {
        Write-Host "Order by status fetched" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Order Get By Status should be 200" -Expected "200" -Actual $oGetByStatus.status -ResponseBody $oGetByStatus.body -FailuresArray $failures
    }

    # Get orders by status (no token)
    Write-Section "[Order] Get By Status (no token should be 401/403)"
    $oGetByStatusNoAuth = Try-InvokeJsonGet -Uri ($ordersUrl + "/status/PENDING") -Headers @{}
    if (-not $oGetByStatusNoAuth.success -and ($oGetByStatusNoAuth.status -eq 401 -or $oGetByStatusNoAuth.status -eq 403)) {
        Write-Host "Order by status unauthorized blocked ($($oGetByStatusNoAuth.status))" -ForegroundColor Green
    } else {
        $failures += Add-Failure -TestName "Order Get By Status no token should be 401/403" -Expected "401/403" -Actual $oGetByStatusNoAuth.status -ResponseBody $oGetByStatusNoAuth.body -FailuresArray $failures
    }

    # Page size boundary = 100
    Write-Section "[Order] Page (size 100 boundary)"
    $oPageMax = Try-InvokeJsonGet -Uri ($ordersUrl + "/page?page=0&size=100&sort=orderDate,desc") -Headers $authHeaders
    if ($oPageMax.success -and $oPageMax.status -eq 200) { Write-Host "Order page size 100 OK" -ForegroundColor Green } else { $failures += Add-Failure -TestName "Order Page size=100 should be 200" -Expected "200" -Actual $oPageMax.status -ResponseBody $oPageMax.body -FailuresArray $failures }

    # Negative page number
    Write-Section "[Order] Page (negative page should be 400)"
    $oPageNegPage = Try-InvokeJsonGet -Uri ($ordersUrl + "/page?page=-1&size=5&sort=orderDate,desc") -Headers $authHeaders
    if (-not $oPageNegPage.success -and $oPageNegPage.status -eq 400) { Write-Host "Order negative page rejected (400)" -ForegroundColor Green } else { $failures += Add-Failure -TestName "Order Page negative page should be 400" -Expected "400" -Actual $oPageNegPage.status -ResponseBody $oPageNegPage.body -FailuresArray $failures }

    # Missing sort direction (invalid format)
    Write-Section "[Order] Page (missing sort direction should be 400)"
    $oPageMissingDir = Try-InvokeJsonGet -Uri ($ordersUrl + "/page?page=0&size=5&sort=orderDate") -Headers $authHeaders
    if (-not $oPageMissingDir.success -and $oPageMissingDir.status -eq 400) { Write-Host "Order missing sort direction rejected (400)" -ForegroundColor Green } else { $failures += Add-Failure -TestName "Order Page missing sort dir should be 400" -Expected "400" -Actual $oPageMissingDir.status -ResponseBody $oPageMissingDir.body -FailuresArray $failures }

    # Not found by ID/Number
    Write-Section "[Order] Get By ID (not found should be 404)"
    $oGetByIdNotFound = Try-InvokeJsonGet -Uri ($ordersUrl + "/99999999") -Headers $authHeaders
    if (-not $oGetByIdNotFound.success -and $oGetByIdNotFound.status -eq 404) { Write-Host "Order not found (ID) returns 404" -ForegroundColor Green } else { $failures += Add-Failure -TestName "Order Get non-existent ID should be 404" -Expected "404" -Actual $oGetByIdNotFound.status -ResponseBody $oGetByIdNotFound.body -FailuresArray $failures }

    Write-Section "[Order] Get By Number (not found should be 404)"
    $oGetByNumberNotFound = Try-InvokeJsonGet -Uri ($ordersUrl + "/number/ORD-NOPE-000") -Headers $authHeaders
    if (-not $oGetByNumberNotFound.success -and $oGetByNumberNotFound.status -eq 404) { Write-Host "Order not found (Number) returns 404" -ForegroundColor Green } else { $failures += Add-Failure -TestName "Order Get non-existent Number should be 404" -Expected "404" -Actual $oGetByNumberNotFound.status -ResponseBody $oGetByNumberNotFound.body -FailuresArray $failures }
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
        pageStatus = if ($pPage) { $pPage.status } else { $null }
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
        pageStatus = if ($cPage) { $cPage.status } else { $null }
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
        pageStatus = if ($oPage) { $oPage.status } else { $null }
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
        $lines += "- Error Message: $($f.errorMessage)"
        if ($f.details) {
            $lines += "- Full Response:"
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
foreach ($v in @(
    $create1,$create2,$create3,$getAllAuth,$getAllNoAuth,$getOneAuth,$getOneNoAuth,$updateAuth,$updateNoAuth,$deleteAuth,$deleteNoAuth,$afterDel,
    $pCreate,$pCreateDup,$pCreateNoAuth,$pGetAllAuth,$pGetAllNoAuth,$pGetOneAuth,$pGetOneNoAuth,$pUpdateAuth,$pUpdateNoAuth,$pDeleteAuth,$pDeleteNoAuth,$pAfterDel,
    $cCreate,$cCreateDup,$cCreateNoAuth,$cGetAllAuth,$cGetAllNoAuth,$cGetOneAuth,$cGetOneNoAuth,$cUpdateAuth,$cUpdateNoAuth,$cDeleteAuth,$cDeleteNoAuth,$cAfterDel,
    $cartGet,$cartGetNoAuth,$cartAddItem,$cartAddItemNoAuth,$cartUpdateQty,$cartUpdateQtyNoAuth,$cartRemoveItem,$cartRemoveItemNoAuth,$cartClear,$cartClearNoAuth,
    $oCreateFromCart,$oCreateFromCartNoAuth,$oGetById,$oGetByIdNoAuth,$oGetByNumber,$oGetByNumberNoAuth,$oGetMyOrders,$oGetMyOrdersNoAuth,
    $oUpdateStatus,$oUpdateStatusNoAuth,$oUpdateShippingFee,$oUpdateTax,$oUpdateDiscount,$oUpdateNotes,$oUpdateNotesNoAuth,
    $oGetWithChanges,$oGetNeedingAttention,$oGetRecent,$oGetStatistics,
    # Newly added pagination/OpenAPI results
    $pPage,$pPageOut,$pPageNoAuth,$pPageBadSort,$pPageNeg,
    $cPage,$cPageOut,$cPageNoAuth,$cPageBadSort,$cPageNeg,
    $pPageTooBig,$pPageBadDir,$pGetNotFound,
    $cPageTooBig,$cPageBadDir,$cGetNotFound,
    $oPage,$oPageForbidden,$oPageNoAuth,$oPageBadSort,$oPageNeg,$oGetByStatus,$oGetByStatusNoAuth,
    $oPageTooBig,$oByStatusForbiddenUser,$oWithChangesForbiddenUser,$oNeedingAttentionForbiddenUser,$oRecentForbiddenUser,$oStatsForbiddenUser,$oGetOtherForbidden,$oGetNumberOtherForbidden,
    $oPageMax,$oPageNegPage,$oPageMissingDir,$oGetByIdNotFound,$oGetByNumberNotFound,
    $pPageMax,$pPageNegPage,$pPageMissingDir,
    $cPageMax,$cPageNegPage,$cPageMissingDir,
    $openApiDocs,$swaggerUi,$openApiSwaggerConfig,
    $recHealth,$recReadiness,$recBasic,$recWithLimit,$recWithCategory,$recWithActiveOnly,$recWithSeed,
    $recInvalidUserId,$recInvalidLimit,$recInvalidCategory,$recNoAuth,$recAnalyticsStatus,$recBestseller,$recTrending,$recHybrid,
    $recDashboard,$recLargeLimit,$recPerf1,$recPerf2,$recZeroLimit,
    $analyticsHealth,$analyticsReadiness,$analyticsBestsellers,$analyticsTrending,$analyticsCategories,$analyticsDashboard,
    $analyticsTimeRange,$analyticsCategoryFilter,
    $searchHealth,$searchReindex,$searchBasic,$searchPrice,$searchCategory,$searchSort,
    $searchComplex,$searchEmpty
)) {
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
    page = if ($pPage) { $pPage.status } else { $null }
    active = if ($pGetActive) { $pGetActive.status } else { $null }
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
    page = if ($cPage) { $cPage.status } else { $null }
    roots = if ($cGetRoots) { $cGetRoots.status } else { $null }
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
    page = if ($oPage) { $oPage.status } else { $null }
    byStatus = if ($oGetByStatus) { $oGetByStatus.status } else { $null }
    pageMax = if ($oPageMax) { $oPageMax.status } else { $null }
} -Depth 4)
$summary += ""
$summary += "## Recommendation"
$summary += (ConvertTo-Json @{
    health = if ($recHealth) { $recHealth.status } else { $null }
    readiness = if ($recReadiness) { $recReadiness.status } else { $null }
    basic = if ($recBasic) { $recBasic.status } else { $null }
    withLimit = if ($recWithLimit) { $recWithLimit.status } else { $null }
    withCategory = if ($recWithCategory) { $recWithCategory.status } else { $null }
    withActiveOnly = if ($recWithActiveOnly) { $recWithActiveOnly.status } else { $null }
    withSeed = if ($recWithSeed) { $recWithSeed.status } else { $null }
    invalidUserId = if ($recInvalidUserId) { $recInvalidUserId.status } else { $null }
    invalidLimit = if ($recInvalidLimit) { $recInvalidLimit.status } else { $null }
    invalidCategory = if ($recInvalidCategory) { $recInvalidCategory.status } else { $null }
    noAuth = if ($recNoAuth) { $recNoAuth.status } else { $null }
    analyticsStatus = if ($recAnalyticsStatus) { $recAnalyticsStatus.status } else { $null }
    bestseller = if ($recBestseller) { $recBestseller.status } else { $null }
    trending = if ($recTrending) { $recTrending.status } else { $null }
    hybrid = if ($recHybrid) { $recHybrid.status } else { $null }
    dashboard = if ($recDashboard) { $recDashboard.status } else { $null }
    largeLimit = if ($recLargeLimit) { $recLargeLimit.status } else { $null }
    performance = if ($recPerf1 -and $recPerf2) { "200,200" } else { $null }
    zeroLimit = if ($recZeroLimit) { $recZeroLimit.status } else { $null }
} -Depth 4)

$summary += "## Analytics"
$summary += (ConvertTo-Json @{
    health = if ($analyticsHealth) { $analyticsHealth.status } else { $null }
    readiness = if ($analyticsReadiness) { $analyticsReadiness.status } else { $null }
    bestsellers = if ($analyticsBestsellers) { $analyticsBestsellers.status } else { $null }
    trending = if ($analyticsTrending) { $analyticsTrending.status } else { $null }
    categories = if ($analyticsCategories) { $analyticsCategories.status } else { $null }
    dashboard = if ($analyticsDashboard) { $analyticsDashboard.status } else { $null }
    timeRange = if ($analyticsTimeRange) { $analyticsTimeRange.status } else { $null }
    categoryFilter = if ($analyticsCategoryFilter) { $analyticsCategoryFilter.status } else { $null }
} -Depth 4)

$summary += "## Search"
$summary += (ConvertTo-Json @{
    health = if ($searchHealth) { $searchHealth.status } else { $null }
    reindex = if ($searchReindex) { $searchReindex.status } else { $null }
    basic = if ($searchBasic) { $searchBasic.status } else { $null }
    priceRange = if ($searchPrice) { $searchPrice.status } else { $null }
    categoryFilter = if ($searchCategory) { $searchCategory.status } else { $null }
    sortByPrice = if ($searchSort) { $searchSort.status } else { $null }
    complexQuery = if ($searchComplex) { $searchComplex.status } else { $null }
    emptyQuery = if ($searchEmpty) { $searchEmpty.status } else { $null }
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
$summary += ""
$summary += "### Recommendation"
$summary += "- Health: expected 200, actual: " + $(if ($recHealth) { $recHealth.status } else { $null })
$summary += "- Readiness: expected 200, actual: " + $(if ($recReadiness) { $recReadiness.status } else { $null })
$summary += "- Basic: expected 200, actual: " + $(if ($recBasic) { $recBasic.status } else { $null })
$summary += "- With Limit: expected 200, actual: " + $(if ($recWithLimit) { $recWithLimit.status } else { $null })
$summary += "- With Category: expected 200, actual: " + $(if ($recWithCategory) { $recWithCategory.status } else { $null })
$summary += "- With Active Only: expected 200, actual: " + $(if ($recWithActiveOnly) { $recWithActiveOnly.status } else { $null })
$summary += "- With Seed: expected 200, actual: " + $(if ($recWithSeed) { $recWithSeed.status } else { $null })
$summary += "- Invalid User ID: expected 422, actual: " + $(if ($recInvalidUserId) { $recInvalidUserId.status } else { $null })
$summary += "- Invalid Limit: expected 422, actual: " + $(if ($recInvalidLimit) { $recInvalidLimit.status } else { $null })
$summary += "- Invalid Category: expected 422, actual: " + $(if ($recInvalidCategory) { $recInvalidCategory.status } else { $null })
$summary += "- No Token: expected 401/403, actual: " + $(if ($recNoAuth) { $recNoAuth.status } else { $null })
$summary += "- Analytics Status: expected 200, actual: " + $(if ($recAnalyticsStatus) { $recAnalyticsStatus.status } else { $null })
$summary += "- Bestseller Recommendations: expected 200, actual: " + $(if ($recBestseller) { $recBestseller.status } else { $null })
$summary += "- Trending Recommendations: expected 200, actual: " + $(if ($recTrending) { $recTrending.status } else { $null })
$summary += "- Hybrid Recommendations: expected 200, actual: " + $(if ($recHybrid) { $recHybrid.status } else { $null })
$summary += "- Dashboard Recommendations: expected 200, actual: " + $(if ($recDashboard) { $recDashboard.status } else { $null })
$summary += "- Large Limit Recommendations: expected 200, actual: " + $(if ($recLargeLimit) { $recLargeLimit.status } else { $null })
$summary += "- Performance Test: expected 200,200, actual: " + $(if ($recPerf1 -and $recPerf2) { "$($recPerf1.status),$($recPerf2.status)" } else { $null })
$summary += "- Zero Limit Test: expected 422, actual: " + $(if ($recZeroLimit) { $recZeroLimit.status } else { $null })

$summary += "### Analytics"
$summary += "- Health: expected 200, actual: " + $(if ($analyticsHealth) { $analyticsHealth.status } else { $null })
$summary += "- Readiness: expected 200, actual: " + $(if ($analyticsReadiness) { $analyticsReadiness.status } else { $null })
$summary += "- Bestsellers: expected 200, actual: " + $(if ($analyticsBestsellers) { $analyticsBestsellers.status } else { $null })
$summary += "- Trending: expected 200, actual: " + $(if ($analyticsTrending) { $analyticsTrending.status } else { $null })
$summary += "- Categories: expected 200, actual: " + $(if ($analyticsCategories) { $analyticsCategories.status } else { $null })
$summary += "- Dashboard: expected 200, actual: " + $(if ($analyticsDashboard) { $analyticsDashboard.status } else { $null })
$summary += "- Time Range: expected 200, actual: " + $(if ($analyticsTimeRange) { $analyticsTimeRange.status } else { $null })
$summary += "- Category Filter: expected 200, actual: " + $(if ($analyticsCategoryFilter) { $analyticsCategoryFilter.status } else { $null })

$summary += "### Search"
$summary += "- Health: expected 200, actual: " + $(if ($searchHealth) { $searchHealth.status } else { $null })
$summary += "- Reindex: expected 200, actual: " + $(if ($searchReindex) { $searchReindex.status } else { $null })
$summary += "- Basic Search: expected 200, actual: " + $(if ($searchBasic) { $searchBasic.status } else { $null })
$summary += "- Price Range: expected 200, actual: " + $(if ($searchPrice) { $searchPrice.status } else { $null })
$summary += "- Category Filter: expected 200, actual: " + $(if ($searchCategory) { $searchCategory.status } else { $null })
$summary += "- Sort by Price: expected 200, actual: " + $(if ($searchSort) { $searchSort.status } else { $null })
$summary += "- Complex Query: expected 200, actual: " + $(if ($searchComplex) { $searchComplex.status } else { $null })
$summary += "- Empty Query: expected 200, actual: " + $(if ($searchEmpty) { $searchEmpty.status } else { $null })

Set-Content -Path $summaryPath -Value $summary -Encoding UTF8
Write-Info "Summary written to $summaryPath"

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

# Recommendation Entity Report
$recommendationTests = @($recHealth,$recReadiness,$recBasic,$recWithLimit,$recWithCategory,$recWithActiveOnly,$recWithSeed,$recInvalidUserId,$recInvalidLimit,$recInvalidCategory,$recNoAuth,$recAnalyticsStatus,$recBestseller,$recTrending,$recHybrid,$recDashboard,$recLargeLimit,$recPerf1,$recPerf2,$recZeroLimit)
$recommendationFailures = $failures | Where-Object { $_.test -like "*Recommendation*" }
$recommendationTestResults = @{
    "Health Check" = @{ Expected = "200"; Actual = if ($recHealth) { $recHealth.status } else { "Not executed" } }
    "Readiness Check" = @{ Expected = "200"; Actual = if ($recReadiness) { $recReadiness.status } else { "Not executed" } }
    "Basic Recommendations" = @{ Expected = "200"; Actual = if ($recBasic) { $recBasic.status } else { "Not executed" } }
    "With Limit" = @{ Expected = "200"; Actual = if ($recWithLimit) { $recWithLimit.status } else { "Not executed" } }
    "With Category" = @{ Expected = "200"; Actual = if ($recWithCategory) { $recWithCategory.status } else { "Not executed" } }
    "With Active Only" = @{ Expected = "200"; Actual = if ($recWithActiveOnly) { $recWithActiveOnly.status } else { "Not executed" } }
    "With Seed" = @{ Expected = "200"; Actual = if ($recWithSeed) { $recWithSeed.status } else { "Not executed" } }
    "Invalid User ID" = @{ Expected = "422"; Actual = if ($recInvalidUserId) { $recInvalidUserId.status } else { "Not executed" } }
    "Invalid Limit" = @{ Expected = "422"; Actual = if ($recInvalidLimit) { $recInvalidLimit.status } else { "Not executed" } }
    "Invalid Category" = @{ Expected = "422"; Actual = if ($recInvalidCategory) { $recInvalidCategory.status } else { "Not executed" } }
    "No Token" = @{ Expected = "401/403"; Actual = if ($recNoAuth) { $recNoAuth.status } else { "Not executed" } }
    "Analytics Status" = @{ Expected = "200"; Actual = if ($recAnalyticsStatus) { $recAnalyticsStatus.status } else { "Not executed" } }
    "Bestseller Recommendations" = @{ Expected = "200"; Actual = if ($recBestseller) { $recBestseller.status } else { "Not executed" } }
    "Trending Recommendations" = @{ Expected = "200"; Actual = if ($recTrending) { $recTrending.status } else { "Not executed" } }
    "Hybrid Recommendations" = @{ Expected = "200"; Actual = if ($recHybrid) { $recHybrid.status } else { "Not executed" } }
    "Dashboard Recommendations" = @{ Expected = "200"; Actual = if ($recDashboard) { $recDashboard.status } else { "Not executed" } }
    "Large Limit Recommendations" = @{ Expected = "200"; Actual = if ($recLargeLimit) { $recLargeLimit.status } else { "Not executed" } }
    "Performance Test" = @{ Expected = "200,200"; Actual = if ($recPerf1 -and $recPerf2) { "$($recPerf1.status),$($recPerf2.status)" } else { "Not executed" } }
    "Zero Limit Test" = @{ Expected = "422"; Actual = if ($recZeroLimit) { $recZeroLimit.status } else { "Not executed" } }
}
Write-EntityReport -Entity "Recommendation" -BaseUrl $BaseUrl -Mode $Mode -Timestamp $ts2 -EntityTests $recommendationTests -EntityFailures $recommendationFailures -TestResults $recommendationTestResults

# Analytics Entity Report
$analyticsTests = @($analyticsHealth,$analyticsReadiness,$analyticsBestsellers,$analyticsTrending,$analyticsCategories,$analyticsDashboard,$analyticsTimeRange,$analyticsCategoryFilter)
$analyticsFailures = $failures | Where-Object { $_.test -like "*Analytics*" }
$analyticsTestResults = @{
    "Health Check" = @{ Expected = "200"; Actual = if ($analyticsHealth) { $analyticsHealth.status } else { "Not executed" } }
    "Readiness Check" = @{ Expected = "200"; Actual = if ($analyticsReadiness) { $analyticsReadiness.status } else { "Not executed" } }
    "Bestsellers" = @{ Expected = "200"; Actual = if ($analyticsBestsellers) { $analyticsBestsellers.status } else { "Not executed" } }
    "Trending Products" = @{ Expected = "200"; Actual = if ($analyticsTrending) { $analyticsTrending.status } else { "Not executed" } }
    "Popular Categories" = @{ Expected = "200"; Actual = if ($analyticsCategories) { $analyticsCategories.status } else { "Not executed" } }
    "Dashboard Summary" = @{ Expected = "200"; Actual = if ($analyticsDashboard) { $analyticsDashboard.status } else { "Not executed" } }
    "Time Range Test" = @{ Expected = "200"; Actual = if ($analyticsTimeRange) { $analyticsTimeRange.status } else { "Not executed" } }
    "Category Filter Test" = @{ Expected = "200"; Actual = if ($analyticsCategoryFilter) { $analyticsCategoryFilter.status } else { "Not executed" } }
}
Write-EntityReport -Entity "Analytics" -BaseUrl $BaseUrl -Mode $Mode -Timestamp $ts2 -EntityTests $analyticsTests -EntityFailures $analyticsFailures -TestResults $analyticsTestResults

# Search Entity Report
$searchTests = @($searchHealth,$searchReindex,$searchBasic,$searchPrice,$searchCategory,$searchSort,$searchComplex,$searchEmpty)
$searchFailures = $failures | Where-Object { $_.test -like "*Search*" }
$searchTestResults = @{
    "Health Check" = @{ Expected = "200"; Actual = if ($searchHealth) { $searchHealth.status } else { "Not executed" } }
    "Reindex Products" = @{ Expected = "200"; Actual = if ($searchReindex) { $searchReindex.status } else { "Not executed" } }
    "Basic Search" = @{ Expected = "200"; Actual = if ($searchBasic) { $searchBasic.status } else { "Not executed" } }
    "Price Range Search" = @{ Expected = "200"; Actual = if ($searchPrice) { $searchPrice.status } else { "Not executed" } }
    "Category Filter Search" = @{ Expected = "200"; Actual = if ($searchCategory) { $searchCategory.status } else { "Not executed" } }
    "Sort by Price" = @{ Expected = "200"; Actual = if ($searchSort) { $searchSort.status } else { "Not executed" } }
    "Complex Search Query" = @{ Expected = "200"; Actual = if ($searchComplex) { $searchComplex.status } else { "Not executed" } }
    "Empty Search Test" = @{ Expected = "200"; Actual = if ($searchEmpty) { $searchEmpty.status } else { "Not executed" } }
}
Write-EntityReport -Entity "Search" -BaseUrl $BaseUrl -Mode $Mode -Timestamp $ts2 -EntityTests $searchTests -EntityFailures $searchFailures -TestResults $searchTestResults

# Final Summary with Colors
Write-Section "🎯 Final Test Summary"
Write-Host "`n" -NoNewline

if ($failed -eq 0) {
    Write-Success "🎉 ALL TESTS PASSED! ($total/$total tests passed)"
    Write-Success "✅ No failures detected"
} elseif ($failed -le 3) {
    Write-Warning "⚠️ MOSTLY SUCCESSFUL: $passed/$total tests passed ($failed failures)"
    Write-Warning "🔧 Minor issues detected - check individual reports"
} else {
    Write-Error "❌ MULTIPLE FAILURES: $passed/$total tests passed ($failed failures)"
    Write-Error "🚨 Significant issues detected - review failed tests"
}

Write-Host "`n📊 Test Statistics:" -ForegroundColor Cyan
Write-Host "  📈 Total Tests: $total" -ForegroundColor White
Write-Host "  ✅ Passed: $passed" -ForegroundColor Green
Write-Host "  ❌ Failed: $failed" -ForegroundColor Red
Write-Host "  📊 Success Rate: $([math]::Round(($passed * 100.0) / $total, 1))%" -ForegroundColor $(if ($failed -eq 0) { "Green" } elseif ($failed -le 3) { "Yellow" } else { "Red" })

Write-Host "`n📁 Reports Generated:" -ForegroundColor Cyan
Write-Host "  📄 Main Summary: $summaryPath" -ForegroundColor White
Write-Host "  📋 Entity Reports: guide/reports/[Entity]/Test_Report.md" -ForegroundColor White

if ($failed -gt 0) {
    Write-Host "`n🔍 Failed Tests:" -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host "  ❌ $($failure.test)" -ForegroundColor Red
        Write-Host "     Expected: $($failure.expected)" -ForegroundColor Yellow
        Write-Host "     Actual: $($failure.actual)" -ForegroundColor Yellow
    }
}

Write-Host "`n🚀 Test execution completed!" -ForegroundColor Cyan


