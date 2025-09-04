cmake_minimum_required(VERSION 3.10)
project(TongiServer CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Busca Pistache via pkg-config (lo instala tu Docker al compilar desde fuente)
find_package(PkgConfig REQUIRED)
pkg_check_modules(PISTACHE REQUIRED libpistache)

include_directories(
    ${PISTACHE_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/server
    ${CMAKE_SOURCE_DIR}/controllers
    ${CMAKE_SOURCE_DIR}/services
    ${CMAKE_SOURCE_DIR}/models
    ${CMAKE_SOURCE_DIR}/utils
)

link_directories(${PISTACHE_LIBRARY_DIRS})

add_executable(tongi_server
    main.cpp
    server/server.cpp
    controllers/health/health_controller.cpp
    controllers/data/data_controller.cpp
    services/data/data_service.cpp
)

target_link_libraries(tongi_server ${PISTACHE_LIBRARIES} pthread)
