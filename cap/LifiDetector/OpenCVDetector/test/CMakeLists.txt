include(gtest)
set (CMAKE_CXX_STANDARD 11)

# Make sure we have google test installed
include_directories(${GTEST_INCLUDE_DIRS})
include_directories(${GMOCK_INCLUDE_DIRS})

# Set the name for these tests
set(BINARY ${CMAKE_PROJECT_NAME}_tst)

# Get all of the test files by name
file(GLOB_RECURSE TEST_SOURCES LIST_DIRECTORIES false *.h *.cpp)
set(SOURCES ${TEST_SOURCES})

# Stuff that's run
add_executable(${BINARY} ${TEST_SOURCES})
add_test(NAME ${BINARY} COMMAND ${BINARY} "--gtest_color=yes")

# Stuff to link
#target_link_libraries(${BINARY} PUBLIC 
#    ${CMAKE_PROJECT_NAME}_lib 
#    gtest)

link_directories(${CMAKE_SOURCE_DIR}/lib)

target_link_libraries(${BINARY} PUBLIC
    ${GTEST_LIBS_DIR}/libgtest.a
    ${GTEST_LIBS_DIR}/libgtest_main.a
    ${GTEST_LIBS_DIR}/libgmock.a
    ${GTEST_LIBS_DIR}/libgmock_main.a
    ${CMAKE_PROJECT_NAME}_lib
    ${CMAKE_THREAD_LIBS_INIT})

add_dependencies(${BINARY} googletest)
add_dependencies(${BINARY} ${CMAKE_PROJECT_NAME}_lib)

