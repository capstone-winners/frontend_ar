# CMakeLists files in this project can
# refer to the root source directory of the project as ${HELLO_SOURCE_DIR} and
# to the root binary directory of the project as ${HELLO_BINARY_DIR}.
cmake_minimum_required (VERSION 3.0)

# Fix behavior of CMAKE_CXX_STANDARD when targeting macOS.
if (POLICY CMP0025)
    cmake_policy(SET CMP0025 NEW)
endif ()

#include(CheckCXXCompilerFlag)
#CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
#if(COMPILER_SUPPORTS_CXX11)
#    message(STATUS "${COMPILER_SUPPORTS_CXX11}")
#else(COMPILER_SUPPORTS_CXX11)
#    message(STATUS "Compiler doesn't support cx11")
#    message(FATAL_ERROR "${COMPILER_SUPPORTS_CXX11}")
#endif(COMPILER_SUPPORTS_CXX11)

set(CMAKE_C_COMPILER "/usr/local/bin/gcc-9")
set(CMAKE_CXX_COMPILER "/usr/local/bin/g++-9")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project (OPENCV_LIFI_DETECTOR)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR}/cmake)

#set("OpenCV_DIR" "../../../libs/opencv-4.2.0/cmake")
set("OpenCV_DIR" "/usr/local/Cellar/opencv/4.2.0_3")
find_package(OpenCV 4.2 REQUIRED )

# Bring the headers into the project
include_directories(include)

# Add subdirectories
add_subdirectory(src)

add_subdirectory(test)
