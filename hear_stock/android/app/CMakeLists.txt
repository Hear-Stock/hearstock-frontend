cmake_minimum_required(VERSION 3.4.1)
project(soloud_flutter)

# SoLoud root directory
set(SOLOUD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../native/soloud-master)

include_directories(${SOLOUD_DIR}/include)
include_directories(${SOLOUD_DIR}/src)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../native) # wrapper


# Source files
file(GLOB SOLOUD_SOURCES
  ${SOLOUD_DIR}/src/*.cpp
  ${SOLOUD_DIR}/src/backend/miniaudio/*.c
)

set(WRAPPER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../../native/soloud_c_wrapper.cpp)
set(ALL_SOURCES ${SOLOUD_SOURCES} ${WRAPPER_FILE})

# Build shared library
add_library(soloud SHARED ${ALL_SOURCES})

# Link log library
find_library(log-lib log)
target_link_libraries(soloud ${log-lib})
