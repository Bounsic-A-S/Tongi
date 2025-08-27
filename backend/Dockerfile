# Use Ubuntu as base image
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    git \
    libssl-dev \
    zlib1g-dev \
    python3-pip \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Install Meson
RUN pip3 install meson

# Build and install Pistache from source using Meson
RUN git clone https://github.com/pistacheio/pistache.git /tmp/pistache && \
    cd /tmp/pistache && \
    git submodule update --init && \
    meson setup build \
        --buildtype=release \
        -DPISTACHE_BUILD_EXAMPLES=false \
        -DPISTACHE_BUILD_TESTS=false \
        -DPISTACHE_BUILD_DOCS=false && \
    meson compile -C build && \
    meson install -C build && \
    ldconfig && \
    rm -rf /tmp/pistache

# Set working directory
WORKDIR /app

# Copy source files
COPY main.cpp .
COPY CMakeLists.txt .

# Build the application
RUN mkdir build && cd build && \
    cmake .. && \
    make && \
    cp bin/tongi_server /app/

# Expose port
EXPOSE 9080

# Run the server
CMD ["./tongi_server"]
