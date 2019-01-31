#!/usr/bin/env bash

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
    echo "$HOST_USER:*" | chpasswd -e
    usermod -p "" $HOST_USER

    if [[ -n $HOST_PUBKEY ]]; then
        mkdir -p $HOME/.ssh/
        mkdir -p /root/.ssh/
        echo $HOST_PUBKEY >> $HOME/.ssh/authorized_keys
        echo $HOST_PUBKEY >> /root/.ssh/authorized_keys
        chmod 600 $HOME/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys
        chown $HOST_UID:$HOST_GID $HOME/.ssh/authorized_keys
    fi

    chown -R $HOST_UID:$HOST_GID $HOME 2>/dev/null

    if [[ -n $USER_SHELL ]]; then
        apt-get install -q --no-install-recommends --yes $(basename $USER_SHELL)\
            && usermod --shell $(which $(basename $USER_SHELL)) root\
            && usermod --shell $(which $(basename $USER_SHELL)) $HOST_USER
    fi
fi
