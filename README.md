### Dockerised build environment
This directory contains the sources necessary for building [Docker](https://docs.docker.com) containers, which encapsulate the required tools for building C and C++ based projects. The container is based on the latest Ubuntu LTS, and supports cross-compiling for x86_64, aarch64, and 32-bit arm architectures with soft and hard floating-point implementations.

> *Note:* At the moment the images have to be built locally. Pulling directly from git should be quite straightforward, but would require some minor manual changes to the host script.

The script running on the host and the entrypoint script running inside the container were inspired by [sdt/docker-raspberry-pi-cross-compiler](https://github.com/sdt/docker-raspberry-pi-cross-compiler). The main idea is to have a script which passes all commands and arguments to the container, which runs them with the host's UID, GID, username and group. Thanks to that, there are no permission/access issues on the host's side. The [host script](src/host-script.sh) mounts the host's current working directory inside the container.

Additionally, a number of CMake toolchains are available inside the container for further convenience. These are available for targets **x86_64**, **aarch64**, **arm**, and **armhf**, in **basic** (dynamic linkage), **static** (static linkage), and **rpath** (dynamic linkage with current directory set as runtime load path) configurations. These are available in the container at `/tool/{basic,static,rpath}/{x86_64,aarch64,arm,armhf}.cmake`.

### Requirements

To successfully build and use the Docker containers, a recent version of Docker is required.

> **Note:** The version of Docker available default repositories might be outdated. Follow the guides available at *[Docker → Guides → Install → Supported platforms](https://docs.docker.com/install/#supported-platforms)*.

- On macOS, download the [Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/install/);
- On Windows download the [Docker Desktop for Windows](https://docs.docker.com/docker-for-windows/install/);
- For Linux, a number of guides are available for [Debian](https://docs.docker.com/install/linux/docker-ce/debian/), [Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/), and [Fedora](https://docs.docker.com/install/linux/docker-ce/fedora/).

The fastest way of installing Docker on Linux via https://get.docker.com:

```sh
curl -fsSL https://get.docker.com -o get-docker.sh

sudo sh get-docker.sh

sudo usermod -aG docker $USER
```

The following are the steps required on [Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/):

1. Remove old versions of Docker:

    ```sh
    sudo apt-get remove docker docker-engine docker.io containerd runc
    ```

2. Set up Docker repositories:

    ```sh
    sudo apt-get update

    sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
    ```

3. Install Docker:

    ```sh
    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io
    ```

4. [Post-installation step](https://docs.docker.com/install/linux/linux-postinstall/) → Add yourself to the *docker* group to use Docker as a non-root user:

    ```sh
    sudo usermod -aG docker $USER
    ```

### How to build?

Make sure that docker is running before proceeding with installation.

To build the container images, clone the repository and navigate to the folder in which this README is contained, and use `make`. The contained [Makefile](./Makefile) defines the following rules:

- __*base*: build the base image__,
- __*scripted*: build the extended image, depends on *base*__,
- __*ssh*: build the ssh development image, depends on *base*__,
- *host-script*: create a the script to run commands in the *scripted* container, depends on *host-script-config*,
- *host-script-config*: create a config file for the script above,
- *host-script-ssh*: create a config file for the script above,
- *echo-script*: echo the 'scripted' script to stdout,
- *echo-script-ssh*: echo the 'ssh' script to stdout,
- *clean*: clean the script and config files,
- *delete-images*: delete docker images created using the script.

The following variables, defined in the Makefile, can be used to customise the configuration:

- `NAMESPACE`: the namespace with which the images will be tagged, default: *tooling*;
- `IMAGE_BASE`: the name of the base image, default: *base*;
- `IMAGE_SCRIPTED`: the name of the image with extended user-scripting support, default: *dock*;
- `IMAGE_SSH`: the name of the image with SSH-support, default: *ssh*;
- `IMAGE_TAG`: the tag which will be used during the build, default: *latest*;
- `SSH_RUN_SCRIPT`: the name of the script spawning the SSH image, default: *start-ssh-builder*;
- `USER_SHELL`: the name of the desired shell for the SSH image, default: *bash*.

During build time, the *base* image will report the installed versions of the contained tools. When building the *scripted* some further information will be displayed.

### How to use?

After building the image using the *scripted* rule, a special script will be created. For the sake of convenience, the script can be copied somewhere in the user's PATH.

Assuming that the created script was called *dock*, one can, for example, build a CMake project by running on the host machine:

```sh
dock cmake -DCMAKE_TOOLCHAIN_FILE=/tool/static/x86_64.cmake -DCMAKE_BUILD_TYPE=Debug -B build/linux-amd64 -H.
dock cmake --build build/linux-amd64 --target <target>
```

To output the version info of the installed compilers and tools, run:

```sh
dock /setup/print-env.sh
```

To get a shell inside the container, one can run:

```sh
dock /usr/bin/env bash
```

To bypass the entrypoint script in the *scripted* or to get a shell in the *base* container, on create a docker container manually (assumes images *tooling/base* and *tooling/dock*):

```sh
docker run --interactive --tty --rm tooling/base /bin/bash
# or
docker run --interactive --tty --rm --entrypoint /bin/bash tooling/base
# or
docker run --interactive --tty --rm --entrypoint /bin/bash tooling/dock
```

#### SSH development environment

The SSH development image can be used to take advantage of the provided tooling
from a remote machine, or in IDEs that can use remote SSH machines (e.g. CLion, PyCharm).

The user launch script, *start-ssh-builder*, can be used to launch the container.
The script will import the user's public SSH identity file and push it to
the authorized keys of root and newly created users.

Unlike the 'scripted' image, the SSH container is persistent, and will run as long
as the SSH daemon is running. To turn it off, either poweroff via SSH, or:

```bash
docker stop tooling-ssh # the default name
docker stop $(docker ps -a -q) # stop all containers
```
