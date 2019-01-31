set(CMAKE_C_COMPILER "arm-linux-gnueabihf-gcc-8")
set(CMAKE_CXX_COMPILER "arm-linux-gnueabihf-g++-8")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-rpath,$ORIGIN")
