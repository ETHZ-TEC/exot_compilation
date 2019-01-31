#!/usr/bin/env bash

line=$(head -c 80 /dev/zero | tr '\0' '-')

echo $line
echo

echo "GNU compilers' versions:"

echo " - x86_64:       $(gcc-8 --version | grep gcc)"
echo " - 64b arm:      $(aarch64-linux-gnu-gcc-8 --version | grep gcc)"
echo " - 32b arm (sf): $(arm-linux-gnueabi-gcc-8 --version | grep gcc)"
echo " - 32b arm (hf): $(arm-linux-gnueabihf-gcc-8 --version | grep gcc)"

echo "Build programs' versions:"

echo " - CMake:        $(cmake --version | grep version)"
echo " - make:         $(make --version | grep Make)"
echo " - ninja:        $(ninja --version)"

echo "Support programs' versions:"

echo " - clang-format: $(clang-format-6.0 --version | grep version)"
echo " - clang-tidy:   $(clang-tidy-6.0 --version | grep version)"

echo
echo $line
