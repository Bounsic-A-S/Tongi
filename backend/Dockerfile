# Use Ubuntu as base image
FROM ubuntu:22.04

ENV CMAKE_PREFIX_PATH=/usr/local/lib/cmake/cpr

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
    curl \
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

RUN git clone https://github.com/libcpr/cpr.git /tmp/cpr && \
    cd /tmp/cpr && mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCPR_BUILD_TESTS=OFF -DCPR_BUILD_TESTS_SSL=OFF && \
    make -j$(nproc) && make install && ldconfig && \
    echo 'prefix=/usr/local' > /usr/local/lib/pkgconfig/libcpr.pc && \
    echo 'exec_prefix=${prefix}' >> /usr/local/lib/pkgconfig/libcpr.pc && \
    echo 'libdir=${exec_prefix}/lib' >> /usr/local/lib/pkgconfig/libcpr.pc && \
    echo 'includedir=${prefix}/include' >> /usr/local/lib/pkgconfig/libcpr.pc && \
    echo '' >> /usr/local/lib/pkgconfig/libcpr.pc && \
    echo 'Name: libcpr' >> /usr/local/lib/pkgconfig/libcpr.pc && \
    echo 'Description: C++ Requests: Curl for People' >> /usr/local/lib/pkgconfig/libcpr.pc && \
    echo 'Version: 1.12.1' >> /usr/local/lib/pkgconfig/libcpr.pc && \
    echo 'Libs: -L${libdir} -lcpr' >> /usr/local/lib/pkgconfig/libcpr.pc && \
    echo 'Cflags: -I${includedir}' >> /usr/local/lib/pkgconfig/libcpr.pc && \
    rm -rf /tmp/cpr

# Set working directory
WORKDIR /app

# Copy all sources
COPY . .

# Build the application
RUN mkdir -p build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    cp tongi_server /app/

# Expose port
EXPOSE 9080

# Run the server
CMD ["./tongi_server"]
