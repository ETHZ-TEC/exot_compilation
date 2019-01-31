#!/usr/bin/env bash
# This script attempts to run the command passed to the container with the
# same user/group as the host.

# If user and group ids are set, they will be of non-zero length. Flag (-n)
# returns true if a value is non-zero.
if [[ -n $HOST_UID ]] && [[ -n $HOST_GID ]]; then
    # Create a group matching the host group
    groupadd --non-unique \
        --gid $HOST_GID $HOST_GROUP 2>/dev/null
    # Create a user matching the host user
    useradd --non-unique --create-home \
        --gid $HOST_GID \
        --uid $HOST_UID $HOST_USER 2>/dev/null
    export HOME=/home/${HOST_USER}

    # Copy files in /root to the new user's home directory
    shopt -s dotglob
    cp -r /root/* $HOME/
    chown -R $HOST_UID:$HOST_GID $HOME 2>/dev/null

    # Set setuid bit on the gosu binary to allow sudo capabilities without the
    # need for a password.
    chown root:$HOST_GID $(which gosu) 2>/dev/null
    chmod +s $(which gosu 2>/dev/null); sync 2>/dev/null

    # Execute the command as the new user
    exec gosu $HOST_UID:$HOST_GID "$@"
else
    exec "$@"
fi
