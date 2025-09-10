# 🧪 Tongi Backend Tests

Simple and clean way to run your C++ backend tests using Docker.

## 📋 Prerequisites

- Docker must be installed and running
- No need for local CMake, GTest, or other C++ build tools!

## 🚀 How to Run Tests

### On Windows (PowerShell)
```powershell
.\run-tests.ps1
```

### On Linux/macOS (Bash)
```bash
./run-tests.sh
```

## 📊 What the Scripts Do

1. **Check Docker**: Verify Docker is installed and running
2. **Build Environment**: Create a Docker container with all necessary dependencies
3. **Run Unit Tests**: Execute tests for individual components (DataService, etc.)
4. **Run Integration Tests**: Execute end-to-end tests with the full server
5. **Show Summary**: Display results with clear pass/fail indicators

## 🔧 Test Structure

- **Unit Tests**: Located in `tests/test_*.cpp`
  - `test_data_service.cpp` - Tests for DataService functionality
  - `test_main.cpp` - Test runner main function

- **Integration Tests**: Located in `tests/test_integration.cpp`
  - Tests full server functionality with HTTP requests

## 💡 Tips

- First run will be slower as it builds the Docker image
- Subsequent runs are much faster (image is cached)
- If tests hang, the scripts include automatic timeouts
- You can run individual tests by modifying the Docker commands in the scripts

## 🛠️ Manual Testing (Advanced)

If you prefer to run tests manually:

```bash
# Build test environment
docker build -f Dockerfile.simple-test -t tongi-tests .

# Run unit tests only
docker run --rm tongi-tests /bin/bash -c "cd build/bin && ./unit_tests"

# Run integration tests only
docker run --rm tongi-tests /bin/bash -c "cd build/bin && timeout 15 ./integration_tests"
```
