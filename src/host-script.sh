#!/usr/bin/env bash

# Makefile

# ------------------------------------------------------------------------------
# Configuration

SCRIPT_NAME=$(basename $0)
DOCKER_IMAGE_NAMESPACE="${CONFIG_NAMESPACE:-tooling}"
DOCKER_IMAGE_NAME="${CONFIG_IMAGE_SCRIPTED:-dock}"
DOCKER_IMAGE_TAG="${CONFIG_IMAGE_TAG:-latest}"
DOCKER_IMAGE="$DOCKER_IMAGE_NAMESPACE/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG"

# ------------------------------------------------------------------------------
# Utilities
u:error() {
    echo >&2 Error: $@
}

u:error_and_exit() {
    u:error $@
    exit 1
}

u:help() {
    if [[ $# == 0 ]]; then
        cat >&2 << __END__
Usage:
    $SCRIPT_NAME command [args]

All arguments to the comcon script are passed directly to
the docker container. The environment inside the container
contains GCC compilers for x86_64, aarch64, arm, and armhf.
Additionally, the container image contains make, cmake, and
ninja for building software.
__END__
    fi
}

# ------------------------------------------------------------------------------
# Parse arguments
if [[ $# == 0 ]]; then
    u:help
    exit 1
fi

# Check if docker is available and the daemon is running
`which docker 1>/dev/null 2>/dev/null` || \
    u:error_and_exit "Docker does not seem to be available on the host device."

`docker ps -q 1>/dev/null 2>/dev/null` || \
    u:error_and_exit "Docker daemon does not seem to be running."

# Get current host working directory, user and group ids and names
HOST_WD=`/bin/pwd -P`
HOST_UID="$(id -u)"
HOST_GID="$(id -g)"
HOST_USER="$(id -un)"
HOST_GROUP="$(id -gn)"

# If running from tty0, have docker allocate a pseudo-tty (-t)
# and keep stdin open (-i).
# See https://docs.docker.com/engine/reference/run/#foreground
test -t 0 && DOCKER_RUN_ARGS=-it || DOCKER_RUN_ARGS=

# Run the docker container, pass arguments and environment variables
docker run $DOCKER_RUN_ARGS --rm \
    -v "$HOST_WD":/workdir       \
    -e HOST_UID=$HOST_UID        \
    -e HOST_GID=$HOST_GID        \
    -e HOST_USER=$HOST_USER      \
    -e HOST_GROUP=$HOST_GROUP    \
    $DOCKER_IMAGE                \
    "$@"

# Exit with the return code of the docker run command above
exit $?
