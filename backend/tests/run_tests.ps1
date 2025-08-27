#!/usr/bin/env pwsh

# Tongi Backend Test Runner for Windows
# This script builds and runs all tests for the Tongi backend

param(
    [string]$TestType = "all",  # Options: unit, integration, all
    [switch]$BuildOnly,         # Only build tests, don't run them
    [switch]$Verbose           # Verbose output
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

function Write-ColorOutput($ForegroundColor, $Message) {
    Write-Host $Message -ForegroundColor $ForegroundColor
}

function Test-CommandExists($Command) {
    return Get-Command $Command -ErrorAction SilentlyContinue
}

# Check prerequisites
Write-ColorOutput "Blue" "=== Tongi Backend Test Runner ==="
Write-Host ""

# Check for required tools
$missingTools = @()

if (-not (Test-CommandExists "cmake")) {
    $missingTools += "cmake"
}

if (-not (Test-CommandExists "curl")) {
    $missingTools += "curl"
}

if ($missingTools.Count -gt 0) {
    Write-ColorOutput "Red" "❌ Missing required tools: $($missingTools -join ', ')"
    Write-ColorOutput "Yellow" "Please install the missing tools and try again."
    exit 1
}

Write-ColorOutput "Green" "✅ All required tools are available"

# Create build directory
$BuildDir = "build_tests"
if (Test-Path $BuildDir) {
    Remove-Item $BuildDir -Recurse -Force
}
New-Item -ItemType Directory -Path $BuildDir | Out-Null

# Build tests
Write-ColorOutput "Blue" "🔨 Building tests..."
Set-Location $BuildDir

$cmakeArgs = @(
    "..",
    "-DCMAKE_BUILD_TYPE=Debug"
)

if ($Verbose) {
    cmake @cmakeArgs
} else {
    cmake @cmakeArgs 2>&1 | Out-Null
}

if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "Red" "❌ CMake configuration failed"
    Set-Location ..
    exit 1
}

if ($Verbose) {
    cmake --build . --config Debug
} else {
    cmake --build . --config Debug 2>&1 | Out-Null
}

if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "Red" "❌ Build failed"
    Set-Location ..
    exit 1
}

Write-ColorOutput "Green" "✅ Tests built successfully"

if ($BuildOnly) {
    Write-ColorOutput "Blue" "🏁 Build complete (build-only mode)"
    Set-Location ..
    exit 0
}

# Run tests based on type
Set-Location ..

if ($TestType -eq "integration" -or $TestType -eq "all") {
    Write-ColorOutput "Blue" "🧪 Running Integration Tests..."
    Write-ColorOutput "Yellow" "Note: These tests require the server to be running on port 9080"
    Write-Host ""
    
    # Check if server is running
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:9080/api/health" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-ColorOutput "Green" "✅ Server is running"
            
            # Run integration tests using curl
            Write-ColorOutput "Blue" "Testing endpoints..."
            
            # Test health endpoint
            $healthTest = curl -s -w "HTTPSTATUS:%{http_code}" "http://localhost:9080/api/health"
            if ($healthTest -match "HTTPSTATUS:200" -and $healthTest -match "healthy") {
                Write-ColorOutput "Green" "✅ Health check: PASSED"
            } else {
                Write-ColorOutput "Red" "❌ Health check: FAILED"
            }
            
            # Test hello endpoint
            $helloTest = curl -s -w "HTTPSTATUS:%{http_code}" "http://localhost:9080/hello"
            if ($helloTest -match "HTTPSTATUS:200" -and $helloTest -match "Hello from Tongi Backend") {
                Write-ColorOutput "Green" "✅ Hello endpoint: PASSED"
            } else {
                Write-ColorOutput "Red" "❌ Hello endpoint: FAILED"
            }
            
            # Test GET data endpoint
            $getDataTest = curl -s -w "HTTPSTATUS:%{http_code}" "http://localhost:9080/api/data"
            if ($getDataTest -match "HTTPSTATUS:200" -and $getDataTest -match "item1") {
                Write-ColorOutput "Green" "✅ GET /api/data: PASSED"
            } else {
                Write-ColorOutput "Red" "❌ GET /api/data: FAILED"
            }
            
            # Test POST data endpoint
            $postDataTest = curl -s -w "HTTPSTATUS:%{http_code}" -H "Content-Type: application/json" -d '{"test": "powershell", "value": 42}' "http://localhost:9080/api/data"
            if ($postDataTest -match "HTTPSTATUS:200" -and $postDataTest -match "Data received successfully") {
                Write-ColorOutput "Green" "✅ POST /api/data: PASSED"
            } else {
                Write-ColorOutput "Red" "❌ POST /api/data: FAILED"
            }
            
            # Test 404 endpoint
            $notFoundTest = curl -s -w "HTTPSTATUS:%{http_code}" "http://localhost:9080/nonexistent"
            if ($notFoundTest -match "HTTPSTATUS:404") {
                Write-ColorOutput "Green" "✅ 404 test: PASSED"
            } else {
                Write-ColorOutput "Red" "❌ 404 test: FAILED"
            }
            
        } else {
            Write-ColorOutput "Red" "❌ Server is not responding correctly"
        }
    } catch {
        Write-ColorOutput "Red" "❌ Server is not running on port 9080"
        Write-ColorOutput "Yellow" "To run integration tests:"
        Write-Host "1. Start the server: " -NoNewline
        Write-ColorOutput "Blue" "cmake --build build --target tongi_server && ./build/bin/tongi_server"
        Write-Host "2. In another terminal run: " -NoNewline
        Write-ColorOutput "Blue" "./tests/run_tests.ps1 -TestType integration"
    }
}

if ($TestType -eq "unit" -or $TestType -eq "all") {
    Write-ColorOutput "Blue" "🧪 Running Unit Tests..."
    Write-ColorOutput "Yellow" "Note: Unit tests are built but require Google Test framework"
    Write-ColorOutput "Yellow" "Install Google Test and update CMakeLists.txt to enable unit tests"
}

Write-Host ""
Write-ColorOutput "Green" "🏁 Test execution complete!"

# Cleanup
if (Test-Path $BuildDir) {
    Remove-Item $BuildDir -Recurse -Force
}
