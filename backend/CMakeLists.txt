cmake_minimum_required(VERSION 3.10)
project(TongiBackend)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(Threads REQUIRED)

# Try to find Pistache using pkg-config first
find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
    pkg_check_modules(PISTACHE QUIET libpistache)
endif()

# Create executable
add_executable(tongi_server main.cpp)

# Link libraries
if(PISTACHE_FOUND)
    target_link_libraries(tongi_server ${PISTACHE_LIBRARIES})
    target_include_directories(tongi_server PRIVATE ${PISTACHE_INCLUDE_DIRS})
    target_compile_options(tongi_server PRIVATE ${PISTACHE_CFLAGS_OTHER})
else()
    # Fallback to manual linking
    target_link_libraries(tongi_server pistache)
endif()

target_link_libraries(tongi_server Threads::Threads)

# Set output directory
set_target_properties(tongi_server PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)
