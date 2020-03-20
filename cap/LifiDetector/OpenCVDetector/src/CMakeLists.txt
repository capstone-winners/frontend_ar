set(BINARY ${CMAKE_PROJECT_NAME})

file(GLOB_RECURSE SOURCES LIST_DIRECTORIES true *.h *.cpp)

set(SOURCES ${SOURCES})

# Setup Executable
add_executable(${BINARY}_run ${SOURCES})
target_link_libraries( ${BINARY}_run ${OpenCV_LIBS} )

# Setup Library
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/lib)
message(WARNING "CMAKE_LIBRARY_OUTPUT_DIRECTORY: ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
add_library(${BINARY}_lib STATIC ${SOURCES})
target_link_libraries( ${BINARY}_lib ${OpenCV_LIBS} )

install(TARGETS ${BINARY}_lib DESTINATION ../../../libs)
