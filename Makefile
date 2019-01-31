# A simple makefile that only enforces name compatibility. The values below
# determine the namespace and image names to be used when building.

# main namespace, useful when building for distributing in hubs.
NAMESPACE=tooling
# name of the base image
IMAGE_BASE=base
# name of the scripted image
IMAGE_SCRIPTED=dock
# name of the ssh image
IMAGE_SSH=ssh
# tag to be used when building images
IMAGE_TAG=latest

# name of the ssh image script
SSH_RUN_SCRIPT=start-ssh-builder
# name of shell for ssh image
USER_SHELL=bash

# GNU Make is a bit idiotic when it comes to creating multiline expressions...
# It is not possible to make a sed program using the 'a' command because of its
# requirement to include a newline characted. Autoconf manual suggests using:
#
# nlinit=`echo 'nl="'; echo '"'`; eval "$$nlinit"
#
# which is even worse of a hack, and in fact does not work either. Therefore
# below a separate target writes a config which is then appended using sed.
host-script-config:
	@echo "CONFIG_NAMESPACE=${NAMESPACE}"            > generated-config.txt
	@echo "CONFIG_IMAGE_SCRIPTED=${IMAGE_SCRIPTED}" >> generated-config.txt
	@echo "CONFIG_IMAGE_SSH=${IMAGE_SSH}"           >> generated-config.txt
	@echo "CONFIG_IMAGE_TAG=${IMAGE_TAG}"           >> generated-config.txt
	@echo "CONFIG_USER_SHELL=${USER_SHELL}"         >> generated-config.txt

# Rule to create a user-script for running commands in the container.
host-script: src/host-script.sh host-script-config
	@sed -e '/Makefile/ r generated-config.txt' $< > scripts/${IMAGE_SCRIPTED}
	@rm generated-config.txt

# Rule to create a user-script for running commands in the container.
host-script-ssh: src/host-script-ssh.sh host-script-config
	@sed -e '/Makefile/ r generated-config.txt' $< > scripts/${SSH_RUN_SCRIPT}
	@rm generated-config.txt

echo-script: host-script
	@cat scripts/${IMAGE_SCRIPTED}

echo-script-ssh: host-script-ssh
	@cat scripts/${SSH_RUN_SCRIPT}

# Rule to build the base image, containing the compilers and build support.
base:
	@docker build \
		--build-arg NAMESPACE=$(NAMESPACE)              \
		--build-arg IMAGE_BASE=$(IMAGE_BASE)            \
		--tag "${NAMESPACE}/${IMAGE_BASE}:${IMAGE_TAG}" \
		-f base.Dockerfile .

line=$(shell head -c 80 /dev/zero | tr '\0' '-')

# Rule to build the image with extended user support.
scripted: base host-script
	@docker build \
		--build-arg NAMESPACE=${NAMESPACE}                  \
		--build-arg IMAGE_BASE=${IMAGE_BASE}                \
		--build-arg IMAGE_SCRIPTED=${IMAGE_SCRIPTED}        \
		--build-arg IMAGE_TAG=${IMAGE_TAG}                  \
		--tag "${NAMESPACE}/${IMAGE_SCRIPTED}:${IMAGE_TAG}" \
		-f scripted.Dockerfile .
	@chmod u+x scripts/${IMAGE_SCRIPTED}
	@echo $(line)
	@echo "The user script is available at scripts/${IMAGE_SCRIPTED}."
	@echo "For convienience, you may copy the script somewhere in your PATH."
	@echo "Alternatively, use the 'echo-script' make rule to get the script to"
	@echo "standard output."
	@echo $(line)

ssh: host-script-ssh
	@docker build \
		--build-arg NAMESPACE=${NAMESPACE}              \
		--build-arg IMAGE_BASE=${IMAGE_BASE}            \
		--build-arg IMAGE_SSH=${IMAGE_SSH}              \
		--build-arg IMAGE_TAG=${IMAGE_TAG}              \
		--tag "${NAMESPACE}/${IMAGE_SSH}:${IMAGE_TAG}"  \
		-f ssh.Dockerfile .
	@chmod u+x scripts/${SSH_RUN_SCRIPT}

.PHONY: clean delete-images
clean:
	-rm -f scripts/${IMAGE_SCRIPTED}
	-rm -f scripts/${SSH_RUN_SCRIPT}
	-rm -f generated-config.txt

delete-images:
	docker rmi $(shell docker images -q "${NAMESPACE}/${IMAGE_SCRIPTED}")
	docker rmi $(shell docker images -q "${NAMESPACE}/${IMAGE_SSH}")
	docker rmi $(shell docker images -q "${NAMESPACE}/${IMAGE_BASE}")
