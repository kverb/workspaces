# Use an Arch Linux base image
FROM archlinux:latest

# this should be built and ran from an already cloned local copy of a repo
# see https://github.com/moby/moby/issues/38814 for ulimit issue
# docker build --ulimit "nofile=1024:1048576"  --build-arg USER_NAME=<user-name> -t <image-name> .
# docker run -it -v $(pwd):/usr/src/app <image-name>
ARG USER_NAME=jim
RUN echo "User Name is: ${USER_NAME}"

ARG EXTRA_PKGS

# Update system and install base-devel and git for AUR packages, and other dependencies
# XXX: maybe use a node version manager instead
RUN pacman -Syu --noconfirm \
    && pacman -S --noconfirm \
        base-devel \
        git \
        git-delta \
        fish \
        go \
        nodejs \
        npm \
        less \
        tig \
        tmux \
        vim \
        # use pacman, not npm for globally installed npm packages
        eslint \
        eslint-language-server \
        prettier \
        tailwindcss-language-server \
        typescript \
        typescript-language-server \
        ${EXTRA_PKGS}

# Create a non-root user to use yay
RUN useradd -m "${USER_NAME}" \
    # Allow '${USER_NAME}' to run sudo without password prompt
    && echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to the non-root user (yay requires non-root)
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# Install pkgs from AUR using yay
RUN git clone https://aur.archlinux.org/yay.git \
    && cd yay \
    && makepkg -si --noconfirm \
    && cd .. \
    && rm -rf yay

# add more AUR pkgs here if needed
RUN yay -S --noconfirm helix \
    emmet-language-server  \
    vscode-css-languageserver  \
    vscode-html-languageserver \
    jq \
    starship \
    zoxide \
    eza \
    ranger

# set up some of our custom config
RUN mkdir -p /home/${USER_NAME}/.config/helix/ \
    && mkdir /home/${USER_NAME}/.config/fish/
# maybe TODO: make these URLs configurable
# maybe TODO: clone from dotfiles repo instead
RUN curl -L https://kb.w81st.com/config/helix/languages.toml -o /home/${USER_NAME}/.config/helix/languages.toml \
    && curl -L https://kb.w81st.com/config/helix/config.toml -o /home/${USER_NAME}/.config/helix/config.toml \
    && curl -L https://kb.w81st.com/config/starship.toml -o /home/${USER_NAME}/.config/starship.toml \
    && curl -L https://kb.w81st.com/config/fish/config.fish -o /home/${USER_NAME}/.config/fish/config.fish \
    && curl -L https://kb.w81st.com/config/gitconfig -o /home/${USER_NAME}/.gitconfig \
    
WORKDIR /home/${USER_NAME}/workspace

# Open a shell when the container starts
USER ${USER_NAME}
CMD ["/bin/fish"]

