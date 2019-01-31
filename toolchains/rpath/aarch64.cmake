set(CMAKE_C_COMPILER "aarch64-linux-gnu-gcc-8")
set(CMAKE_CXX_COMPILER "aarch64-linux-gnu-g++-8")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-rpath,$ORIGIN")
