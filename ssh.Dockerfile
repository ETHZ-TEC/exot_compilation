ARG NAMESPACE=tooling
ARG IMAGE_BASE=base
ARG IMAGE_SSH=ssh
ARG IMAGE_TAG=latest

FROM $NAMESPACE/$IMAGE_BASE:$IMAGE_TAG
MAINTAINER Bruno Klopott "klopottb@student.ethz.ch"

# Install the SSH server
RUN apt-get install -q --no-install-recommends --yes \
    openssh-server

# Permit root login to SSH
RUN sed -i "s/^(#)?RSAAuthentication.*/RSAAuthentication yes/g" \
        /etc/ssh/sshd_config && \
    sed -i "s/^(#)?PubkeyAuthentication.*/PubkeyAuthentication yes/g" \
        /etc/ssh/sshd_config && \
    sed -i "s/^(#)?TCPKeepAlive.*/TCPKeepAlive yes/g" \
        /etc/ssh/sshd_config && \
    sed -i "s/^(#)?ClientAliveInterval.*/ClientAliveInterval 600/g" \
        /etc/ssh/sshd_config && \
    sed -i "s/^(#)?PasswordAuthentication.*/PasswordAuthentication yes/g" \
        /etc/ssh/sshd_config && \
    sed -i "s/^(#)?AuthorizedKeysFile.*/AuthorizedKeysFile\t\.ssh\/authorized_keys/g" \
        /etc/ssh/sshd_config && \
    sed -i "s/^(#)?PermitRootLogin.*/PermitRootLogin yes/g" \
        /etc/ssh/sshd_config && \
    sed -i "s/^(#)?PermitEmptyPasswords.*/PermitEmptyPasswords yes/g" \
        /etc/ssh/sshd_config

# Create the privilege separation directory
RUN mkdir /var/run/sshd

# Expose the SSH port
EXPOSE 22

# copy toolchains to /tool on the container
COPY toolchains/ /tool

COPY scripts/setup-ssh.sh /setup/
RUN chmod u+x /setup/setup-ssh.sh

CMD /setup/setup-ssh.sh && /usr/sbin/sshd -D

LABEL org.label-schema.name="$NAMESPACE/$IMAGE_SSH" \
      org.label-schema.name="A complete environment necessary for cross-compiling C and C++ projects with extended support, exposed via SSH." \
      org.label-schema.schema-version="1.0"
