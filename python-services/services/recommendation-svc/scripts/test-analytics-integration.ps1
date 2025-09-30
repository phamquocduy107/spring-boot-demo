# Test Analytics Integration with Recommendation Service
# This script tests the new analytics-powered recommendation features

param(
    [string]$RecommendationUrl = "http://localhost:8091",
    [string]$AnalyticsUrl = "http://localhost:8093",
    [string]$BaseUrl = "http://localhost:8080"
)

function Write-Section($title) {
    Write-Host "`n==== $title ====`n" -ForegroundColor Cyan
}

function Get-JwtToken {
    $loginUrl = "$BaseUrl/api/auth/login"
    $admin = @{ email = "duydeptrai@example.com"; password = "pass123" }
    
    try {
        $response = Invoke-RestMethod -Method POST -Uri $loginUrl -ContentType 'application/json' -Body ($admin | ConvertTo-Json)
        return $response.accessToken
    } catch {
        Write-Host "Failed to get JWT token: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Test-AnalyticsStatus {
    param([string]$Token)
    
    Write-Section "Analytics Status Check"
    $headers = @{ Authorization = "Bearer $Token" }
    
    try {
        $response = Invoke-RestMethod -Method GET -Uri "$RecommendationUrl/analytics/status" -Headers $headers
        Write-Host "Analytics Service Status:" -ForegroundColor Green
        Write-Host "  Service: $($response.analytics_service)" -ForegroundColor White
        Write-Host "  Bestsellers Available: $($response.bestsellers_available)" -ForegroundColor White
        Write-Host "  Trending Available: $($response.trending_available)" -ForegroundColor White
        Write-Host "  Popular Categories Available: $($response.popular_categories_available)" -ForegroundColor White
        
        if ($response.sample_bestsellers) {
            Write-Host "  Sample Bestsellers:" -ForegroundColor Yellow
            foreach ($item in $response.sample_bestsellers) {
                Write-Host "    - $($item.name) (Rank: $($item.rank))" -ForegroundColor White
            }
        }
        
        return $true
    } catch {
        Write-Host "Analytics status check failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-BasicRecommendations {
    param([string]$Token)
    
    Write-Section "Basic Recommendations (No Analytics)"
    $headers = @{ Authorization = "Bearer $Token" }
    $payload = @{
        userId = 1
        limit = 5
        useAnalytics = $false
        recommendationType = "basic"
    }
    
    try {
        $response = Invoke-RestMethod -Method POST -Uri "$RecommendationUrl/recommendations" -Headers $headers -ContentType 'application/json' -Body ($payload | ConvertTo-Json)
        Write-Host "Basic Recommendations:" -ForegroundColor Green
        Write-Host "  Type: $($response.recommendationType)" -ForegroundColor White
        Write-Host "  Use Analytics: $($response.useAnalytics)" -ForegroundColor White
        Write-Host "  Items Count: $($response.returnedCount)" -ForegroundColor White
        
        foreach ($item in $response.items) {
            Write-Host "    - $($item.name) (ID: $($item.id))" -ForegroundColor White
        }
        
        return $true
    } catch {
        Write-Host "Basic recommendations failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-BestsellerRecommendations {
    param([string]$Token)
    
    Write-Section "Bestseller Recommendations"
    $headers = @{ Authorization = "Bearer $Token" }
    $payload = @{
        userId = 1
        limit = 5
        useAnalytics = $true
        recommendationType = "bestsellers"
    }
    
    try {
        $response = Invoke-RestMethod -Method POST -Uri "$RecommendationUrl/recommendations" -Headers $headers -ContentType 'application/json' -Body ($payload | ConvertTo-Json)
        Write-Host "Bestseller Recommendations:" -ForegroundColor Green
        Write-Host "  Type: $($response.recommendationType)" -ForegroundColor White
        Write-Host "  Use Analytics: $($response.useAnalytics)" -ForegroundColor White
        Write-Host "  Items Count: $($response.returnedCount)" -ForegroundColor White
        
        if ($response.analytics) {
            Write-Host "  Analytics Data:" -ForegroundColor Yellow
            Write-Host "    Bestsellers Count: $($response.analytics.bestsellersCount)" -ForegroundColor White
            Write-Host "    Average Score: $([math]::Round($response.analytics.averageScore, 2))" -ForegroundColor White
        }
        
        foreach ($item in $response.items) {
            $flags = @()
            if ($item.isBestseller) { $flags += "Bestseller" }
            if ($item.recommendationScore) { $flags += "Score:$($item.recommendationScore)" }
            
            $flagText = if ($flags) { " ($($flags -join ', '))" } else { "" }
            Write-Host "    - $($item.name) (ID: $($item.id))$flagText" -ForegroundColor White
        }
        
        return $true
    } catch {
        Write-Host "Bestseller recommendations failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-TrendingRecommendations {
    param([string]$Token)
    
    Write-Section "Trending Recommendations"
    $headers = @{ Authorization = "Bearer $Token" }
    $payload = @{
        userId = 1
        limit = 5
        useAnalytics = $true
        recommendationType = "trending"
    }
    
    try {
        $response = Invoke-RestMethod -Method POST -Uri "$RecommendationUrl/recommendations" -Headers $headers -ContentType 'application/json' -Body ($payload | ConvertTo-Json)
        Write-Host "Trending Recommendations:" -ForegroundColor Green
        Write-Host "  Type: $($response.recommendationType)" -ForegroundColor White
        Write-Host "  Use Analytics: $($response.useAnalytics)" -ForegroundColor White
        Write-Host "  Items Count: $($response.returnedCount)" -ForegroundColor White
        
        if ($response.analytics) {
            Write-Host "  Analytics Data:" -ForegroundColor Yellow
            Write-Host "    Trending Count: $($response.analytics.trendingCount)" -ForegroundColor White
            Write-Host "    Average Score: $([math]::Round($response.analytics.averageScore, 2))" -ForegroundColor White
        }
        
        foreach ($item in $response.items) {
            $flags = @()
            if ($item.isTrending) { $flags += "Trending" }
            if ($item.recommendationScore) { $flags += "Score:$($item.recommendationScore)" }
            
            $flagText = if ($flags) { " ($($flags -join ', '))" } else { "" }
            Write-Host "    - $($item.name) (ID: $($item.id))$flagText" -ForegroundColor White
        }
        
        return $true
    } catch {
        Write-Host "Trending recommendations failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-HybridRecommendations {
    param([string]$Token)
    
    Write-Section "Hybrid Recommendations (Best of All)"
    $headers = @{ Authorization = "Bearer $Token" }
    $payload = @{
        userId = 1
        limit = 8
        useAnalytics = $true
        recommendationType = "hybrid"
    }
    
    try {
        $response = Invoke-RestMethod -Method POST -Uri "$RecommendationUrl/recommendations" -Headers $headers -ContentType 'application/json' -Body ($payload | ConvertTo-Json)
        Write-Host "Hybrid Recommendations:" -ForegroundColor Green
        Write-Host "  Type: $($response.recommendationType)" -ForegroundColor White
        Write-Host "  Use Analytics: $($response.useAnalytics)" -ForegroundColor White
        Write-Host "  Items Count: $($response.returnedCount)" -ForegroundColor White
        
        if ($response.analytics) {
            Write-Host "  Analytics Data:" -ForegroundColor Yellow
            Write-Host "    Bestsellers Count: $($response.analytics.bestsellersCount)" -ForegroundColor White
            Write-Host "    Trending Count: $($response.analytics.trendingCount)" -ForegroundColor White
            Write-Host "    Popular Category Count: $($response.analytics.popularCategoryCount)" -ForegroundColor White
            Write-Host "    Average Score: $([math]::Round($response.analytics.averageScore, 2))" -ForegroundColor White
        }
        
        foreach ($item in $response.items) {
            $flags = @()
            if ($item.isBestseller) { $flags += "Bestseller" }
            if ($item.isTrending) { $flags += "Trending" }
            if ($item.isPopularCategory) { $flags += "PopularCat" }
            if ($item.recommendationScore) { $flags += "Score:$($item.recommendationScore)" }
            
            $flagText = if ($flags) { " ($($flags -join ', '))" } else { "" }
            Write-Host "    - $($item.name) (ID: $($item.id))$flagText" -ForegroundColor White
        }
        
        return $true
    } catch {
        Write-Host "Hybrid recommendations failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-CategoryFilteredRecommendations {
    param([string]$Token)
    
    Write-Section "Category-Filtered Hybrid Recommendations"
    $headers = @{ Authorization = "Bearer $Token" }
    $payload = @{
        userId = 1
        limit = 5
        categoryId = 1
        useAnalytics = $true
        recommendationType = "hybrid"
    }
    
    try {
        $response = Invoke-RestMethod -Method POST -Uri "$RecommendationUrl/recommendations" -Headers $headers -ContentType 'application/json' -Body ($payload | ConvertTo-Json)
        Write-Host "Category-Filtered Recommendations:" -ForegroundColor Green
        Write-Host "  Type: $($response.recommendationType)" -ForegroundColor White
        Write-Host "  Category ID: $($payload.categoryId)" -ForegroundColor White
        Write-Host "  Items Count: $($response.returnedCount)" -ForegroundColor White
        
        foreach ($item in $response.items) {
            $categoryName = if ($item.category) { $item.category.name } else { "Unknown" }
            Write-Host "    - $($item.name) (Category: $categoryName)" -ForegroundColor White
        }
        
        return $true
    } catch {
        Write-Host "Category-filtered recommendations failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "=== Analytics Integration Test ===" -ForegroundColor Cyan
Write-Host "Recommendation Service: $RecommendationUrl" -ForegroundColor Yellow
Write-Host "Analytics Service: $AnalyticsUrl" -ForegroundColor Yellow
Write-Host "Spring Boot API: $BaseUrl" -ForegroundColor Yellow

# Get JWT token
$token = Get-JwtToken
if (-not $token) {
    Write-Host "Cannot proceed without JWT token" -ForegroundColor Red
    exit 1
}

Write-Host "JWT token obtained successfully" -ForegroundColor Green

# Run tests
$tests = @(
    @{ Name = "Analytics Status"; Function = { Test-AnalyticsStatus -Token $token } },
    @{ Name = "Basic Recommendations"; Function = { Test-BasicRecommendations -Token $token } },
    @{ Name = "Bestseller Recommendations"; Function = { Test-BestsellerRecommendations -Token $token } },
    @{ Name = "Trending Recommendations"; Function = { Test-TrendingRecommendations -Token $token } },
    @{ Name = "Hybrid Recommendations"; Function = { Test-HybridRecommendations -Token $token } },
    @{ Name = "Category-Filtered Recommendations"; Function = { Test-CategoryFilteredRecommendations -Token $token } }
)

$passed = 0
$total = $tests.Count

foreach ($test in $tests) {
    Write-Host "`nRunning: $($test.Name)" -ForegroundColor Yellow
    if (& $test.Function) {
        $passed++
        Write-Host "✅ $($test.Name) PASSED" -ForegroundColor Green
    } else {
        Write-Host "❌ $($test.Name) FAILED" -ForegroundColor Red
    }
}

Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan
Write-Host "Passed: $passed/$total" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "Success Rate: $([math]::Round(($passed * 100.0) / $total, 1))%" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })

if ($passed -eq $total) {
    Write-Host "`n🎉 All analytics integration tests passed!" -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Some tests failed. Check the output above." -ForegroundColor Yellow
}
