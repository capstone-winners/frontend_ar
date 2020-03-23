set(BINARY ${CMAKE_PROJECT_NAME})

file(GLOB_RECURSE SOURCES LIST_DIRECTORIES true *.h *.cpp)
set(SOURCES ${SOURCES})

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/lib)
message(STATUS "CMAKE_LIBRARY_OUTPUT_DIRECTORY: ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")

# Setup Executable
add_executable(${BINARY}_run ${SOURCES})
target_link_libraries( ${BINARY}_run ${OpenCV_LIBS} opencv_core opencv_highgui)
add_dependencies(${BINARY}_run opencv)

# Setup Library
add_library(${BINARY}_lib STATIC ${SOURCES})
target_link_libraries( ${BINARY}_lib ${OpenCV_LIBS} )
add_dependencies(${BINARY}_lib opencv)

install(TARGETS ${BINARY}_lib DESTINATION ../../../libs)
