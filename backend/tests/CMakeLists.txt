cmake_minimum_required(VERSION 3.10)
project(TongiBackendTests)

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

# Try to find Google Test
find_package(GTest QUIET)

# Check if we can build unit tests
if(GTest_FOUND OR GTEST_FOUND)
    message(STATUS "Google Test found, building unit tests")
    
# Build unit tests
    add_executable(unit_tests test_main.cpp test_data_service.cpp ../services/data/data_service.cpp)
    
    # Add include directories for project sources
    target_include_directories(unit_tests PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/..
        ${CMAKE_CURRENT_SOURCE_DIR}/../services
        ${CMAKE_CURRENT_SOURCE_DIR}/../models
        ${CMAKE_CURRENT_SOURCE_DIR}/../utils
    )
    
    # Link libraries for unit tests
    if(PISTACHE_FOUND)
        target_link_libraries(unit_tests ${PISTACHE_LIBRARIES})
        target_include_directories(unit_tests PRIVATE ${PISTACHE_INCLUDE_DIRS})
        target_compile_options(unit_tests PRIVATE ${PISTACHE_CFLAGS_OTHER})
    else()
        target_link_libraries(unit_tests pistache)
    endif()
    
    # Link Google Test
    if(GTest_FOUND)
        target_link_libraries(unit_tests GTest::GTest GTest::Main)
    else()
        target_link_libraries(unit_tests gtest gtest_main)
    endif()
    
    target_link_libraries(unit_tests Threads::Threads)
    
    # Find jsoncpp
    find_package(PkgConfig)
    if(PkgConfig_FOUND)
        pkg_check_modules(JSONCPP jsoncpp)
        if(JSONCPP_FOUND)
            target_link_libraries(unit_tests ${JSONCPP_LIBRARIES})
            target_include_directories(unit_tests PRIVATE ${JSONCPP_INCLUDE_DIRS})
        endif()
    endif()
    
    # Enable testing
    enable_testing()
    add_test(NAME UnitTests COMMAND unit_tests)
    
else()
    message(WARNING "Google Test not found, skipping unit tests")
    message(STATUS "To install Google Test on Windows:")
    message(STATUS "  vcpkg install gtest")
    message(STATUS "  or download and build from https://github.com/google/googletest")
endif()

# Always build integration tests (they don't require GTest)
add_executable(integration_tests test_integration.cpp
    ../server/server.cpp
    ../controllers/health/health_controller.cpp
    ../controllers/data/data_controller.cpp
    ../services/data/data_service.cpp
)

# Add include directories for integration tests
target_include_directories(integration_tests PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${CMAKE_CURRENT_SOURCE_DIR}/../server
    ${CMAKE_CURRENT_SOURCE_DIR}/../controllers
    ${CMAKE_CURRENT_SOURCE_DIR}/../services
    ${CMAKE_CURRENT_SOURCE_DIR}/../models
    ${CMAKE_CURRENT_SOURCE_DIR}/../utils
)

# Link libraries for integration tests
if(PISTACHE_FOUND)
    target_link_libraries(integration_tests ${PISTACHE_LIBRARIES})
    target_include_directories(integration_tests PRIVATE ${PISTACHE_INCLUDE_DIRS})
    target_compile_options(integration_tests PRIVATE ${PISTACHE_CFLAGS_OTHER})
else()
    target_link_libraries(integration_tests pistache)
endif()

target_link_libraries(integration_tests Threads::Threads)

# Link Google Test for integration tests too if available
if(GTest_FOUND)
    target_link_libraries(integration_tests GTest::GTest GTest::Main)
elseif(GTEST_FOUND)
    target_link_libraries(integration_tests gtest gtest_main)
endif()

# Set output directories
set_target_properties(integration_tests PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

if(TARGET unit_tests)
    set_target_properties(unit_tests PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    )
endif()

# Custom target to run all tests
add_custom_target(run_tests
    COMMAND ${CMAKE_COMMAND} -E echo "Running integration tests..."
    COMMAND integration_tests
    DEPENDS integration_tests
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

if(TARGET unit_tests)
    add_dependencies(run_tests unit_tests)
endif()
