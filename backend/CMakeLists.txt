cmake_minimum_required(VERSION 3.10)
project(TongiServer CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(PkgConfig REQUIRED)

list(APPEND CMAKE_PREFIX_PATH "/usr/local/lib/cmake" "/usr/local/lib/cmake/cpr")

pkg_check_modules(CPR REQUIRED libcpr)
pkg_check_modules(PISTACHE REQUIRED libpistache)

include_directories(
    ${PISTACHE_INCLUDE_DIRS}
    ${CPR_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/server
    ${CMAKE_SOURCE_DIR}/controllers
    ${CMAKE_SOURCE_DIR}/services
    ${CMAKE_SOURCE_DIR}/models
    ${CMAKE_SOURCE_DIR}/utils
)

link_directories(${PISTACHE_LIBRARY_DIRS} ${CPR_LIBRARY_DIRS})

add_executable(tongi_server
    main.cpp
    server/server.cpp
    controllers/health/health_controller.cpp
    controllers/data/data_controller.cpp
    controllers/ttt/ttt_controller.cpp
    controllers/tts/tts_controller.cpp
    controllers/stt/stt_controller.cpp
    services/data/data_service.cpp
    services/ttt/ttt_service.cpp
    services/tts/tts_service.cpp
    services/stt/stt_service.cpp
)

target_link_libraries(tongi_server
    PRIVATE
    ${PISTACHE_LIBRARIES}
    ${CPR_LIBRARIES}
    pthread
)
