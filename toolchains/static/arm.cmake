set(CMAKE_C_COMPILER "arm-linux-gnueabi-gcc-8")
set(CMAKE_CXX_COMPILER "arm-linux-gnueabi-g++-8")

set(BUILD_SHARED_LIBS OFF)
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
