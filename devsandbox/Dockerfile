# Dev container: Debian trixie, non-root user, mirrors local (oh-my-zsh robbyrussell,
# dotfiles from github.com/jghoman/dotfiles)
FROM debian:trixie-slim

ARG USERNAME=jakob
ARG USER_UID=1000
ARG USER_GID=1000
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# --- System packages (trixie carries bat, eza, just, lazygit, btop natively) ---
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        gnupg \
        locales \
        ncurses-term \
        sudo \
        unzip \
        xz-utils \
        less \
        procps \
        openssh-client \
        pkg-config \
        libssl-dev \
        zsh \
        tmux \
        jq \
        bat \
        eza \
        btop \
        htop \
        lazygit \
        just \
        powerline \
        fonts-powerline \
        elixir \
        openjdk-21-jdk \
        podman \
        uidmap \
        passt \
        slirp4netns \
        fuse-overlayfs \
        python3 \
        python3-pip \
        python3-venv \
    && sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && locale-gen \
    && ln -s /usr/bin/batcat /usr/local/bin/bat \
    && rm -rf /var/lib/apt/lists/*

# --- Node.js 22 LTS (NodeSource; trixie's node is older) ---
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# --- Helix (not packaged in Debian) ---
ARG HELIX_VERSION=25.07.1
RUN case "${TARGETARCH:-$(dpkg --print-architecture)}" in \
        amd64) HX_ARCH=x86_64 ;; \
        arm64) HX_ARCH=aarch64 ;; \
        *) echo "unsupported arch" && exit 1 ;; \
    esac \
    && curl -fsSL "https://github.com/helix-editor/helix/releases/download/${HELIX_VERSION}/helix-${HELIX_VERSION}-${HX_ARCH}-linux.tar.xz" \
       | tar -xJ -C /opt \
    && mv /opt/helix-${HELIX_VERSION}-*-linux /opt/helix \
    && ln -s /opt/helix/hx /usr/local/bin/hx
ENV HELIX_RUNTIME=/opt/helix/runtime

# --- flox (versioned .deb; registers its own apt source for upgrades) ---
ARG FLOX_VERSION=1.13.2
RUN case "${TARGETARCH:-$(dpkg --print-architecture)}" in \
        amd64) FLOX_ARCH=x86_64 ;; \
        arm64) FLOX_ARCH=aarch64 ;; \
        *) echo "unsupported arch" && exit 1 ;; \
    esac \
    && curl -fsSL -o /tmp/flox.deb \
        "https://downloads.flox.dev/by-env/stable/deb/flox-${FLOX_VERSION}.${FLOX_ARCH}-linux.deb" \
    && apt-get update \
    && apt-get install -y /tmp/flox.deb \
    && rm /tmp/flox.deb \
    && rm -rf /var/lib/apt/lists/*

# --- ctop (not packaged in Debian) ---
ARG CTOP_VERSION=0.7.7
RUN curl -fsSL -o /usr/local/bin/ctop \
        "https://github.com/bcicen/ctop/releases/download/v${CTOP_VERSION}/ctop-${CTOP_VERSION}-linux-${TARGETARCH:-$(dpkg --print-architecture)}" \
    && chmod +x /usr/local/bin/ctop

# --- Entrypoint: open up device nodes rootless podman needs (fuse-overlayfs,
#     pasta), then drop to the CMD. Needs the passwordless sudo below. ---
RUN cat > /usr/local/bin/devbox-init.sh <<'EOF' && chmod +x /usr/local/bin/devbox-init.sh
#!/bin/sh
sudo chmod 666 /dev/fuse /dev/net/tun 2>/dev/null || true
exec "$@"
EOF

# --- Non-root user ---
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /usr/bin/zsh ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && { grep -q "^${USERNAME}:" /etc/subuid || echo "${USERNAME}:100000:65536" >> /etc/subuid; } \
    && { grep -q "^${USERNAME}:" /etc/subgid || echo "${USERNAME}:100000:65536" >> /etc/subgid; }

USER ${USERNAME}
WORKDIR /home/${USERNAME}
ENV HOME=/home/${USERNAME}

# --- Rust (rustup, as user) ---
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# --- uv (as user; installs to ~/.local/bin) ---
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# --- Rootless podman storage: fuse-overlayfs (native overlay can't nest on the
#     outer container's overlayfs) ---
RUN mkdir -p ${HOME}/.config/containers \
    && cat > ${HOME}/.config/containers/storage.conf <<'EOF'
[storage]
driver = "overlay"

[storage.options.overlay]
mount_program = "/usr/bin/fuse-overlayfs"
EOF

# --- oh-my-zsh + dotfiles (tmux conf, aliases, robbyrussell prompt as local) ---
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone --depth 1 https://github.com/jghoman/dotfiles.git ${HOME}/dotfiles \
    && ln -sf ${HOME}/dotfiles/tmux/.tmux.conf ${HOME}/.tmux.conf

RUN cat > ${HOME}/.zshrc <<'EOF'
# If the host terminal's terminfo is missing or <256 colors, fall back
[[ $(tput colors 2>/dev/null) -ge 256 ]] || export TERM=xterm-256color

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Rainbow (Devbox) prefix on the prompt
PROMPT="(%F{196}D%f%F{208}e%f%F{226}v%f%F{46}b%f%F{33}o%f%F{129}x%f) $PROMPT"

source "$HOME/dotfiles/zsh-aliases.zsh"
alias ls="eza"
alias docker=podman

source "$HOME/.cargo/env"
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=hx
EOF

ENV SHELL=/usr/bin/zsh
ENTRYPOINT ["/usr/local/bin/devbox-init.sh"]
CMD ["tmux", "new-session", "-A", "-s", "main"]
