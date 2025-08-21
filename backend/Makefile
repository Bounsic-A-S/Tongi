# Compiler and flags
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2
LDFLAGS = -lpistache -pthread

# Directories
BUILD_DIR = build
BIN_DIR = bin

# Source files
SOURCES = main.cpp
TARGET = tongi_server

# Default target
all: $(BIN_DIR)/$(TARGET)

# Create directories if they don't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Build the executable
$(BIN_DIR)/$(TARGET): $(SOURCES) | $(BIN_DIR)
	$(CXX) $(CXXFLAGS) -o $@ $< $(LDFLAGS)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)

# Run the server
run: $(BIN_DIR)/$(TARGET)
	./$(BIN_DIR)/$(TARGET)

# Install dependencies (Ubuntu/Debian)
install-deps:
	sudo apt-get update
	sudo apt-get install -y build-essential cmake pkg-config
	sudo apt-get install -y libpistache-dev

# Build using CMake
cmake-build: | $(BUILD_DIR)
	cd $(BUILD_DIR) && cmake .. && make

.PHONY: all clean run install-deps cmake-build
