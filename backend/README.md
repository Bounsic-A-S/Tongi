# Tongi Backend Server

A C++ HTTP server built with the Pistache framework for the Tongi project.

## Features

- RESTful API endpoints
- JSON response support
- CORS enabled
- Multi-threaded request handling
- Health check endpoint
- Simple data operations
- Docker containerization

## Quick Start with Docker (Recommended)

### Prerequisites
- Docker Desktop installed and running

### Build and Run
```bash
# Navigate to backend directory
cd backend

# Build the Docker image
docker build -t tongi-backend .

# Run the server (detached mode)
docker run -d -p 9080:9080 --name tongi_cpp_server tongi-backend

# Check if running
docker ps
```

### Using Docker Compose (Alternative)
```bash
# Start the server
docker-compose up -d

# Stop the server
docker-compose down
```

### Docker Management Commands
```bash
# View server logs
docker logs tongi_cpp_server

# Stop the server
docker stop tongi_cpp_server

# Remove the container
docker rm tongi_cpp_server

# Restart the server
docker restart tongi_cpp_server

# Access container shell (for debugging)
docker exec -it tongi_cpp_server /bin/bash
```

## Manual Build (Alternative)

### Prerequisites

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install build-essential cmake pkg-config git
sudo apt-get install libssl-dev zlib1g-dev python3-pip ninja-build
pip3 install meson
```

#### Windows (with MSYS2)
```bash
# Using MSYS2
pacman -S mingw-w64-x86_64-gcc
pacman -S mingw-w64-x86_64-cmake
pacman -S mingw-w64-x86_64-meson
```

#### macOS
```bash
brew install cmake meson ninja
```

### Building Pistache from Source
```bash
git clone https://github.com/pistacheio/pistache.git
cd pistache
git submodule update --init
meson setup build --buildtype=release
meson compile -C build
sudo meson install -C build
sudo ldconfig  # Linux only
```

### Building the Server

#### Option 1: Using CMake
```bash
cd backend
mkdir build && cd build
cmake ..
make
```

#### Option 2: Using Makefile
```bash
cd backend
make all
```

### Running the Server (Manual Build)

#### Default (port 9080)
```bash
./bin/tongi_server
```

#### Custom port
```bash
./bin/tongi_server 8080
```

#### Custom port and thread count
```bash
./bin/tongi_server 8080 4
```

## API Endpoints

Once the server is running, you can access these endpoints:

- `GET /` - Welcome page with endpoint documentation
- `GET /hello` - Simple hello message (JSON)
- `GET /api/health` - Health check endpoint
- `GET /api/data` - Get sample data (JSON)
- `POST /api/data` - Post data to the server

## Testing the API

### Using curl

**Health Check:**
```bash
curl http://localhost:9080/api/health
```

**Get Hello:**
```bash
curl http://localhost:9080/hello
```

**Get Data:**
```bash
curl http://localhost:9080/api/data
```

**Post Data:**
```bash
curl -X POST http://localhost:9080/api/data \
     -H "Content-Type: application/json" \
     -d '{"name": "test", "value": 123}'
```

### Using a web browser

Open your browser and navigate to:
- http://localhost:9080/ - Main page
- http://localhost:9080/hello - Hello endpoint
- http://localhost:9080/api/health - Health check

## Server Configuration

The server accepts command-line arguments:
1. Port number (default: 9080)
2. Number of threads (default: 2)

Example:
```bash
./bin/tongi_server 8080 4
```

This runs the server on port 8080 with 4 threads.

## Development

### Project Structure
```
backend/
├── main.cpp          # Main server implementation
├── CMakeLists.txt     # CMake build configuration
├── Makefile          # Make build configuration
└── README.md         # This file
```

### Adding New Endpoints

To add new endpoints, modify the `setupRoutes()` method in the `TongiServer` class:

```cpp
void setupRoutes() {
    using namespace Rest;
    
    // Add your new route here
    Routes::Get(router, "/api/newroute", 
                Routes::bind(&TongiServer::doNewRoute, this));
}
```

Then implement the corresponding handler method:

```cpp
void doNewRoute(const Rest::Request& request, Http::ResponseWriter response) {
    response.headers()
        .add<Http::Header::AccessControlAllowOrigin>("*")
        .add<Http::Header::ContentType>(MIME(Application, Json));
    
    response.send(Http::Code::Ok, "{\"message\": \"New route response\"}");
}
```

## Troubleshooting

### Common Issues

1. **Pistache not found**: Make sure Pistache is properly installed
2. **Port already in use**: Try a different port number
3. **Permission denied**: On Linux/macOS, ports below 1024 require sudo

### Build Issues

- Ensure you have C++17 support
- Check that all dependencies are installed
- Verify CMake version (3.10 or higher)

## License

This project is part of the Tongi application.
