#!/usr/bin/env bash

# Makefile

# ------------------------------------------------------------------------------
# Configuration

SCRIPT_NAME=$(basename $0)
DOCKER_IMAGE_NAMESPACE="${CONFIG_NAMESPACE:-tooling}"
DOCKER_IMAGE_NAME="${CONFIG_IMAGE_SSH:-ssh}"
DOCKER_IMAGE_TAG="${CONFIG_IMAGE_TAG:-latest}"
DOCKER_IMAGE="$DOCKER_IMAGE_NAMESPACE/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG"
CONTAINER_NAME="${DOCKER_IMAGE_NAMESPACE}-${DOCKER_IMAGE_NAME}"
USER_SHELL="${CONFIG_USER_SHELL}"

# Check if docker is available and the daemon is running
`which docker 1>/dev/null 2>/dev/null` || \
    error_and_exit "Docker does not seem to be available on the host device."

`docker ps -q 1>/dev/null 2>/dev/null` || \
    error_and_exit "Docker daemon does not seem to be running."

# Get current host working directory, user and group ids and names
HOST_WD=`/bin/pwd -P`
HOST_UID="$(id -u)"
HOST_GID="$(id -g)"
HOST_USER="$(id -un)"
HOST_GROUP="$(id -gn)"

HOST_PORT=${CONFIG_HOST_PORT:-9999}

if [[ -r $HOME/.ssh/id_rsa.pub ]]; then
    HOST_PUBKEY=$(cat $HOME/.ssh/id_rsa.pub)
fi

# Run the docker container, pass arguments and environment variables
docker run -d --rm                 \
    -p $HOST_PORT:22               \
    --name $CONTAINER_NAME         \
    -v "$HOST_WD":/workdir         \
    -e HOST_UID=$HOST_UID          \
    -e HOST_GID=$HOST_GID          \
    -e HOST_USER=$HOST_USER        \
    -e HOST_GROUP=$HOST_GROUP      \
    -e HOST_PUBKEY="$HOST_PUBKEY"  \
    -e USER_SHELL=$USER_SHELL      \
    $DOCKER_IMAGE

echo "Container with name \"$CONTAINER_NAME\" started."
echo "Container can be accessed via SSH on port $HOST_PORT."

# Exit with the return code of the docker run command above
exit $?
