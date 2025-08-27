#!/usr/bin/env pwsh

# Simple API Test Script for Tongi Backend
# This script tests all API endpoints using curl

param(
    [string]$ServerUrl = "http://localhost:9080",
    [int]$Timeout = 10
)

# Colors for output
function Write-Success($Message) { Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Failure($Message) { Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Info($Message) { Write-Host "ℹ️  $Message" -ForegroundColor Blue }
function Write-Warning($Message) { Write-Host "⚠️  $Message" -ForegroundColor Yellow }

Write-Host "=== Tongi Backend API Tests ===" -ForegroundColor Cyan
Write-Host "Server URL: $ServerUrl" -ForegroundColor Gray
Write-Host ""

$testsRun = 0
$testsPassed = 0
$testsFailed = 0

function Run-Test($TestName, $ScriptBlock) {
    $global:testsRun++
    Write-Host "Testing: $TestName" -ForegroundColor Yellow
    
    try {
        $result = & $ScriptBlock
        if ($result) {
            Write-Success "$TestName - PASSED"
            $global:testsPassed++
        } else {
            Write-Failure "$TestName - FAILED"
            $global:testsFailed++
        }
    } catch {
        Write-Failure "$TestName - ERROR: $($_.Exception.Message)"
        $global:testsFailed++
    }
    Write-Host ""
}

# Test 1: Health Check
Run-Test "Health Check Endpoint" {
    $response = curl -s -w "HTTPSTATUS:%{http_code}" "$ServerUrl/api/health"
    if ($response -match "HTTPSTATUS:200" -and $response -match "healthy" -and $response -match "Tongi Backend") {
        Write-Info "Response: $($response -replace 'HTTPSTATUS:\d+', '')"
        return $true
    }
    Write-Info "Response: $response"
    return $false
}

# Test 2: Root Endpoint
Run-Test "Root Endpoint" {
    $response = curl -s -w "HTTPSTATUS:%{http_code}" "$ServerUrl/"
    if ($response -match "HTTPSTATUS:200" -and $response -match "Tongi Backend Server" -and $response -match "<html>") {
        Write-Info "HTML response received successfully"
        return $true
    }
    Write-Info "Response: $($response.Substring(0, [Math]::Min(100, $response.Length)))..."
    return $false
}

# Test 3: Hello Endpoint
Run-Test "Hello Endpoint" {
    $response = curl -s -w "HTTPSTATUS:%{http_code}" "$ServerUrl/hello"
    if ($response -match "HTTPSTATUS:200" -and $response -match "Hello from Tongi Backend") {
        $jsonPart = ($response -replace 'HTTPSTATUS:\d+', '').Trim()
        Write-Info "JSON Response: $jsonPart"
        return $true
    }
    Write-Info "Response: $response"
    return $false
}

# Test 4: GET Data Endpoint
Run-Test "GET /api/data Endpoint" {
    $response = curl -s -w "HTTPSTATUS:%{http_code}" "$ServerUrl/api/data"
    if ($response -match "HTTPSTATUS:200" -and $response -match "item1" -and $response -match "count" -and $response -match "3") {
        $jsonPart = ($response -replace 'HTTPSTATUS:\d+', '').Trim()
        Write-Info "JSON Response: $jsonPart"
        return $true
    }
    Write-Info "Response: $response"
    return $false
}

# Test 5: POST Data Endpoint
Run-Test "POST /api/data Endpoint" {
    $testData = '{"test": "api_test", "timestamp": "' + (Get-Date -Format "yyyy-MM-ddTHH:mm:ss") + '", "value": 12345}'
    $response = curl -s -w "HTTPSTATUS:%{http_code}" -H "Content-Type: application/json" -d $testData "$ServerUrl/api/data"
    if ($response -match "HTTPSTATUS:200" -and $response -match "Data received successfully" -and $response -match "received_data") {
        $jsonPart = ($response -replace 'HTTPSTATUS:\d+', '').Trim()
        Write-Info "JSON Response: $jsonPart"
        return $true
    }
    Write-Info "Response: $response"
    Write-Info "Sent data: $testData"
    return $false
}

# Test 6: CORS Headers
Run-Test "CORS Headers" {
    $response = curl -s -I "$ServerUrl/hello"
    if ($response -match "Access-Control-Allow-Origin: \*") {
        Write-Info "CORS header found: Access-Control-Allow-Origin: *"
        return $true
    }
    Write-Info "Headers: $response"
    return $false
}

# Test 7: 404 Error Handling
Run-Test "404 Error Handling" {
    $response = curl -s -w "HTTPSTATUS:%{http_code}" "$ServerUrl/nonexistent-endpoint"
    if ($response -match "HTTPSTATUS:404") {
        Write-Info "Correctly returned 404 for non-existent endpoint"
        return $true
    }
    Write-Info "Response: $response"
    return $false
}

# Test 8: Server Response Time
Run-Test "Server Response Time" {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = curl -s -w "HTTPSTATUS:%{http_code}" "$ServerUrl/api/health"
    $stopwatch.Stop()
    $responseTime = $stopwatch.ElapsedMilliseconds
    
    if ($response -match "HTTPSTATUS:200" -and $responseTime -lt 1000) {
        Write-Info "Response time: ${responseTime}ms (< 1000ms)"
        return $true
    }
    Write-Info "Response time: ${responseTime}ms"
    Write-Info "Response: $response"
    return $false
}

# Test 9: JSON Content Type
Run-Test "JSON Content Type Headers" {
    $headers = curl -s -I "$ServerUrl/hello"
    if ($headers -match "Content-Type:.*application/json") {
        Write-Info "Correct JSON Content-Type header found"
        return $true
    }
    Write-Info "Headers: $headers"
    return $false
}

# Test 10: Multiple Concurrent Requests
Run-Test "Concurrent Requests Handling" {
    $jobs = @()
    for ($i = 1; $i -le 5; $i++) {
        $jobs += Start-Job -ScriptBlock {
            param($url)
            curl -s -w "HTTPSTATUS:%{http_code}" "$url/api/health"
        } -ArgumentList $ServerUrl
    }
    
    $results = $jobs | Wait-Job | Receive-Job
    $jobs | Remove-Job
    
    $successCount = ($results | Where-Object { $_ -match "HTTPSTATUS:200" -and $_ -match "healthy" }).Count
    
    if ($successCount -eq 5) {
        Write-Info "All 5 concurrent requests succeeded"
        return $true
    }
    Write-Info "Only $successCount out of 5 concurrent requests succeeded"
    return $false
}

# Summary
Write-Host "=== TEST RESULTS ===" -ForegroundColor Cyan
Write-Host "Total Tests: $testsRun" -ForegroundColor Gray
Write-Success "Passed: $testsPassed"
if ($testsFailed -gt 0) {
    Write-Failure "Failed: $testsFailed"
} else {
    Write-Host "Failed: $testsFailed" -ForegroundColor Gray
}

$successRate = [math]::Round(($testsPassed / $testsRun) * 100, 1)
Write-Host "Success Rate: $successRate%" -ForegroundColor $(if ($successRate -eq 100) { "Green" } elseif ($successRate -ge 80) { "Yellow" } else { "Red" })

if ($testsFailed -eq 0) {
    Write-Host ""
    Write-Success "🎉 All tests passed! The Tongi Backend is working correctly."
    exit 0
} else {
    Write-Host ""
    Write-Warning "Some tests failed. Please check the server logs and endpoint implementations."
    exit 1
}
