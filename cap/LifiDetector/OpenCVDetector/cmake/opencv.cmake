####################
# OpenCV
####################

include(ExternalProject)

# SET(DESIRED_LIBS core imgproc imgcodecs highgui video videoio)
SET(DESIRED_LIBS core imgproc imgcodecs highgui video)
string(REPLACE ";" "," DESIRED_LIBS_STR "${DESIRED_LIBS}")

set(OPENCV_INSTALL_LOCATION ${CMAKE_BINARY_DIR}/opencv-install)
ExternalProject_Add(opencv
    GIT_REPOSITORY https://github.com/opencv/opencv
    GIT_TAG 4.2.0
    GIT_SHALLOW 1
    SOURCE_DIR opencv-src
    BINARY_DIR opencv-build
    CMAKE_ARGS
      -DWITH_OPENGL=OFF
      -DCMAKE_INSTALL_PREFIX=${OPENCV_INSTALL_LOCATION}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DBUILD_DOCS:BOOL=FALSE
      -DBUILD_EXAMPLES:BOOL=FALSE
      -DBUILD_TESTS:BOOL=FALSE
      -DBUILD_SHARED_LIBS:BOOL=TRUE
      -DWITH_CUDA:BOOL=FALSE
      -DWITH_FFMPEG:BOOL=FALSE
      -DBUILD_PERF_TESTS:BOOL=FALSE
      -DWITH_QT=ON
      -DBUILD_LIST=${DESIRED_LIBS_STR}
      -DQt5_DIR=${Qt5_DIR}
    # Disable the (Disable install step)
    # INSTALL_COMMAND ""
)

# Extract properties and set vars based on installation.
set(OPENCV_INCLUDE_DIRS ${OPENCV_INSTALL_LOCATION}/include/opencv4)
set(OPENCV_LIBS_DIR ${OPENCV_INSTALL_LOCATION}/lib)

# This variable is normally set by find_package which we're not using.
list(TRANSFORM DESIRED_LIBS PREPEND "opencv_")
set(OpenCV_LIBS ${DESIRED_LIBS})

#find_package(OpenCV 4.2 REQUIRED)
message("*****************")
message("OpenCV Variables")
message("-----------------")
message(STATUS "OPENCV_LIBS_DIR: ${OPENCV_LIBS_DIR}")
message(STATUS "OPENCV_INCLUDE_DIRS: ${OPENCV_INCLUDE_DIRS}")
message(STATUS "OpenCV_LIBS ${OpenCV_LIBS}")
message(STATUS "DESIRED_LIBS ${DESIRED_LIBS}")
message("*****************")
message("")
message("")

include_directories(${OPENCV_INCLUDE_DIRS})
link_directories(${OPENCV_LIBS_DIR})