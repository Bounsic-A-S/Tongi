# Tongi Backend Test Suite

This directory contains comprehensive tests for the Tongi Backend server, including unit tests, integration tests, and API validation scripts.

## Test Files

### 1. Unit Tests (`test_tongi_server.cpp`)
Full unit tests using Google Test framework that test all server endpoints with a dedicated test server instance.

**Features:**
- Tests all API endpoints (`/`, `/hello`, `/api/health`, `/api/data`)
- Validates JSON responses
- Checks HTTP status codes
- Verifies CORS headers
- Tests POST data handling
- Tests 404 error handling

**Requirements:**
- Google Test framework
- Pistache HTTP library
- JsonCpp library

### 2. Integration Tests (`integration_tests.cpp`)
Simplified integration tests that use curl commands to test endpoints.

**Features:**
- Tests server running on default port (9080)
- Basic endpoint validation
- JSON response parsing
- Error handling validation

### 3. Simple API Test Script (`simple_api_test.ps1`)
PowerShell script for comprehensive API testing without requiring C++ compilation.

**Features:**
- 10 comprehensive test cases
- Real-time response validation
- Performance testing (response time)
- Concurrent request handling
- CORS header validation
- Detailed reporting with colors

### 4. Test Runner (`run_tests.ps1`)
Advanced PowerShell test runner that builds and executes tests.

**Features:**
- Automatic building with CMake
- Dependency checking
- Integration with server lifecycle
- Verbose output options
- Test type selection (unit/integration/all)

## Quick Start

### Option 1: Simple API Testing (Recommended)
This is the easiest way to test your backend without any setup:

1. **Start the Tongi server:**
   ```powershell
   # Build and run the server
   cmake --build build --target tongi_server
   ./build/bin/tongi_server.exe
   ```

2. **Run the simple API tests:**
   ```powershell
   # In another terminal
   cd tests
   ./simple_api_test.ps1
   ```

### Option 2: Full Test Suite
For comprehensive testing with C++ unit tests:

1. **Install dependencies:**
   ```powershell
   # Using vcpkg (recommended)
   vcpkg install gtest
   vcpkg install jsoncpp
   
   # Or download and build manually
   ```

2. **Build and run tests:**
   ```powershell
   cd tests
   ./run_tests.ps1 -Verbose
   ```

### Option 3: Manual Testing
You can also run individual tests manually:

```powershell
# Build tests
cd tests
mkdir build
cd build
cmake ..
cmake --build . --config Debug

# Run integration tests (server must be running)
./bin/integration_tests.exe

# Run unit tests (if Google Test is available)
./bin/unit_tests.exe
```

## Test Coverage

The test suite covers the following aspects:

### Functional Testing
- ✅ Root endpoint (`/`) returns HTML
- ✅ Hello endpoint (`/hello`) returns JSON
- ✅ Health check endpoint (`/api/health`) returns status
- ✅ GET data endpoint (`/api/data`) returns sample data
- ✅ POST data endpoint (`/api/data`) accepts and echoes data
- ✅ 404 handling for non-existent endpoints

### Non-Functional Testing
- ✅ CORS headers are properly set
- ✅ Content-Type headers are correct
- ✅ Response times are reasonable (< 1000ms)
- ✅ Server handles concurrent requests
- ✅ JSON response format validation

### Error Handling
- ✅ Invalid endpoints return 404
- ✅ Server responds to malformed requests gracefully
- ✅ Proper HTTP status codes

## Test Results Interpretation

### Simple API Test Script Output
```
=== Tongi Backend API Tests ===
Server URL: http://localhost:9080

Testing: Health Check Endpoint
✅ Health Check Endpoint - PASSED

Testing: Root Endpoint  
✅ Root Endpoint - PASSED

... (more tests)

=== TEST RESULTS ===
Total Tests: 10
✅ Passed: 10
Failed: 0
Success Rate: 100%

🎉 All tests passed! The Tongi Backend is working correctly.
```

### Understanding Test Failures
Common failure scenarios and solutions:

1. **Server not running:**
   ```
   ❌ Health Check Endpoint - FAILED
   ```
   **Solution:** Start the server with `./build/bin/tongi_server.exe`

2. **Port conflicts:**
   ```
   ❌ Server is not running on port 9080
   ```
   **Solution:** Check if another service is using port 9080

3. **Missing curl:**
   ```
   ❌ Missing required tools: curl
   ```
   **Solution:** Install curl or use Windows 10+ built-in curl

## Continuous Integration

To integrate these tests into your CI pipeline:

```yaml
# Example GitHub Actions workflow
- name: Build Server
  run: |
    cmake --build build --target tongi_server
    
- name: Start Server
  run: |
    ./build/bin/tongi_server.exe &
    sleep 5
    
- name: Run Tests
  run: |
    cd tests
    ./simple_api_test.ps1
```

## Customization

### Adding New Tests
To add a new test to the simple API test script:

```powershell
# Add to simple_api_test.ps1
Run-Test "Your New Test" {
    $response = curl -s -w "HTTPSTATUS:%{http_code}" "$ServerUrl/your-endpoint"
    if ($response -match "HTTPSTATUS:200" -and $response -match "expected-content") {
        Write-Info "Test specific info"
        return $true
    }
    return $false
}
```

### Changing Test Configuration
You can customize the test behavior:

```powershell
# Different server URL
./simple_api_test.ps1 -ServerUrl "http://localhost:8080"

# Different timeout
./simple_api_test.ps1 -Timeout 30

# Verbose output
./run_tests.ps1 -Verbose

# Only integration tests
./run_tests.ps1 -TestType integration
```

## Troubleshooting

### Common Issues

1. **PowerShell Execution Policy:**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Curl not found:**
   - Windows 10+: Curl is built-in
   - Older Windows: Install from https://curl.se/windows/

3. **CMake not found:**
   - Install CMake from https://cmake.org/download/
   - Add to PATH

4. **Pistache library not found:**
   - Make sure Pistache is properly installed
   - Check CMake configuration

### Debug Mode
Run tests with verbose output to see detailed information:

```powershell
./simple_api_test.ps1 | Tee-Object -FilePath test_results.log
./run_tests.ps1 -Verbose
```

## Contributing

When adding new features to the backend, please:

1. Add corresponding tests to the test suite
2. Update this README if new test types are added
3. Ensure all existing tests pass
4. Consider edge cases and error scenarios

## License

These tests are part of the Tongi Backend project and follow the same licensing terms.
