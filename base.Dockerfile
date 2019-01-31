# The following Dockerfile defines a basic container based on the latest
# Ubuntu LTS distribution, which contains the build environment necessary for
# building C and C++ projects.
#
# The currently available target architectures are:
#  - x86_64
#  - aarch64 (64-bit ARMv8)
#  - arm     (32-bit ARM with soft floating-point implementation)
#  - armhf   (32-bit ARM with hard floating-point implementation)
#
# Additionally, make, ninja, and CMake are available for futher support.
# Lastly, clang tooling is available for formatting (using clang-format) and
# static analysis (using clang-tidy).

# use the latest LTS distribution
FROM ubuntu:latest
MAINTAINER Bruno Klopott "klopottb@student.ethz.ch"
ARG NAMESPACE=tooling
ARG IMAGE_BASE=base

# compiler & tools versions
ARG GCC_VER="8"
ARG CLANG_VER="6.0"

# environment variables for apt
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux

# update repositories
RUN apt-get update -q --yes

# install apt-utils to silence some warning messages
RUN apt-get install -q --no-install-recommends --yes \
    dialog                                           \
    apt-utils

# make apt use a secure transport protocol
RUN apt-get install -q --no-install-recommends --yes \
    apt-transport-https                              \
    ca-certificates

# install gcc with C++ support for x86, aarch64, arm, and armhf
RUN apt-get install -q --no-install-recommends --yes \
    gcc-$GCC_VER                                     \
    gcc-$GCC_VER-aarch64-linux-gnu                   \
    gcc-$GCC_VER-arm-linux-gnueabi                   \
    gcc-$GCC_VER-arm-linux-gnueabihf                 \
    g++-$GCC_VER                                     \
    g++-$GCC_VER-aarch64-linux-gnu                   \
    g++-$GCC_VER-arm-linux-gnueabi                   \
    g++-$GCC_VER-arm-linux-gnueabihf

# install build tools
RUN apt-get install -q --no-install-recommends --yes \
    ninja-build                                      \
    make                                             \
    cmake

# install the formatter and static analyser
RUN apt-get install -q --no-install-recommends --yes \
    clang-format-$CLANG_VER                          \
    clang-tidy-$CLANG_VER

# clean up after apt
RUN apt-get clean -q --yes

# set root password to "root" using /usr/sbin/chpasswd
RUN echo "root:root" | chpasswd

# copy util scripts
COPY scripts/print-env.sh /setup/
RUN chmod 755 /setup/print-env.sh
RUN /setup/print-env.sh

LABEL org.label-schema.name="$NAMESPACE/$IMAGE_BASE" \
      org.label-schema.name="A complete environment necessary for building C and C++ projects for AMD64, 32-bit and 64-bit ARM." \
      org.label-schema.schema-version="1.0"
