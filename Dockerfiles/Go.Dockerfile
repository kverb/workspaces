# Use an Arch Linux base image
FROM archlinux:latest

# this should be built and ran from an already cloned local copy of a repo
# see https://github.com/moby/moby/issues/38814 for ulimit issue
# docker build --ulimit "nofile=1024:1048576"  --build-arg USER_NAME=<user-name> -t <image-name> .
# docker run -it -v $(pwd):/usr/src/app -d --name <container-name> <image-name>
# docker attach <container-name>
ARG USER_NAME=jim
RUN echo "User Name is: ${USER_NAME}"
# Create a non-root user to use yay
RUN useradd -m "${USER_NAME}" \
    # Allow '${USER_NAME}' to run sudo without password prompt
    && echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# set up some of our custom config
COPY --chown=${USER_NAME}:${USER_NAME} config /home/${USER_NAME}/.config
COPY --chown=${USER_NAME}:${USER_NAME} config/gitconfig /home/${USER_NAME}/.gitconfig

# idk why but the latest makepkg default conf is really slow.
# this conf disables debug packages and compression
COPY --chown=root:root config/makepkg.conf /etc/makepkg.conf

# Update system and install base-devel and git for AUR packages, and other dependencies
# Run reflector to optimize the mirror list
RUN pacman -Syu --noconfirm \
    && pacman -S --noconfirm reflector \
    && reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

RUN pacman -Syu --noconfirm \
    && pacman -S --noconfirm \
    base-devel \
    git \
    git-delta \
    fish \
    less \
    tig \
    tmux \
    vim

# Switch to the non-root user (yay requires non-root)
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# Install pkgs from AUR using yay
RUN git clone https://aur.archlinux.org/yay.git \
    && cd yay \
    && makepkg -si --noconfirm \
    && cd .. \
    && rm -rf yay

# add more AUR pkgs here at build time if needed
# docker build --build-arg EXTRA_PKGS='pkg1 pkg2 pkg3'
ARG EXTRA_PKGS
RUN yay -S --noconfirm helix \
    jq \
    starship \
    zoxide \
    eza \
    ranger \
    pacseek \
    bat \
    ${EXTRA_PKGS}

WORKDIR /workspace

# Include stub sections
# Note: stubs should assume non-root user is being used
# ---------------------
# dockerfile stub for Go dev

RUN yay -S --noconfirm \
	delve \
	go \
	gopls
	

# ---------------------

# Open a shell when the container starts
# CMD ["/usr/bin/fish"]



