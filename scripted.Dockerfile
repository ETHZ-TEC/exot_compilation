# The following Dockerfile builds upon the base image with compilation support,
# and provides a special host-side script, and an entrypoint script. They
# allow mounting the current host directory in the container, while maintaining
# the same user/group names and ids, such that all permissions are maintained.
# A regular docker container runs everything as root, preventing the user from
# making any changes to files.

# Note: A recent version of docker is required for using ARGs before the FROM
# statement. If only an older version (e.g. 1.13) is available, comment out the
# following statements and provide the necessary variables via "--build-arg"
# command line options to the "docker build" command.
ARG NAMESPACE=tooling
ARG IMAGE_BASE=base
ARG IMAGE_SCRIPTED=dock
ARG IMAGE_TAG=latest

FROM $NAMESPACE/$IMAGE_BASE:$IMAGE_TAG
MAINTAINER Bruno Klopott "klopottb@student.ethz.ch"

# install the gosu tool for matching entrypoint user/group
RUN apt-get install -q --no-install-recommends --yes \
    gosu

# clean up after apt
RUN apt-get clean -q --yes

# copy user scripts to /setup on the container
COPY scripts/$IMAGE_SCRIPTED scripts/entry.sh /setup/
RUN chmod 755 /setup/*

# copy toolchains to /tool on the container
COPY toolchains/ /tool

WORKDIR /workdir
ENTRYPOINT ["/setup/entry.sh"]

LABEL org.label-schema.name="$NAMESPACE/$IMAGE_SCRIPTED" \
      org.label-schema.name="A complete environment necessary for cross-compiling C and C++ projects with extended support." \
      org.label-schema.schema-version="1.0"
